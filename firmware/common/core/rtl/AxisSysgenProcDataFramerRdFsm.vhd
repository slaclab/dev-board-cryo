-------------------------------------------------------------------------------
-- File       : AxisSysgenProcDataFramerRdFsm.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2018-04-25
-- Last update: 2018-04-25
-------------------------------------------------------------------------------
-- Description: Read FSM for the FIFO
--
-- Data Format:
--    DATA[0].BIT[7:0]    = protocol version (0x0)
--    DATA[0].BIT[15:8]   = channel index
--    DATA[0].BIT[63:16]  = event id
--    DATA[1].BIT[63:0]   = timestamp
--    DATA[2].BIT[63:32]  = DATA[I][0];
--    DATA[2].BIT[31:0]   = DATA[Q][0];
--    DATA[3].BIT[63:32]  = DATA[I][1];
--    DATA[3].BIT[31:0]   = DATA[Q][1];
--    DATA[4].BIT[63:32]  = DATA[I][2];
--    DATA[4].BIT[31:0]   = DATA[Q][2];
--    ................................................
--    ................................................
--    ................................................
--    DATA[513].BIT[63:32]  = DATA[I][511];
--    DATA[513].BIT[31:0]   = DATA[Q][511];
--
-------------------------------------------------------------------------------
-- This file is part of 'LCLS2 Common Carrier Core'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'LCLS2 Common Carrier Core', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

use work.StdRtlPkg.all;
use work.AxiStreamPkg.all;
use work.SsiPkg.all;
use work.AmcCarrierPkg.all;
use work.TimingPkg.all;

entity AxisSysgenProcDataFramerRdFsm is
   generic (
      TPD_G   : time := 1 ns;
      TDEST_G : Slv8Array(7 downto 0));
   port (
      -- Clock and Reset (AXIS)
      clk            : in  sl;
      rst            : in  sl;
      -- FIFO Interface
      rdReady        : out sl;
      rdValid        : in  sl;
      rdData         : in  slv(137 downto 0);
      -- Header data
      rtmDacConfig   : in  Slv64Array(5 downto 0);
      fluxRampConfig : in  slv(63 downto 0);
      tesRelayConfig : in  slv(63 downto 0);
      errorDet       : out sl;
      -- Timing Interface (timingClk domain)
      timingClk      : in  sl;
      timingRst      : in  sl;
      timingBus      : in  TimingBusType;
      timeConfigIn   : in  slv(7 downto 0);
      -- IPMI Interface (axisClk domain)
      ipmiBsi        : in  BsiBusType;
      -- EOFE counter 
      eofe           : out sl;
      -- AXI Stream Interface
      axisMaster     : out AxiStreamMasterType;
      axisSlave      : in  AxiStreamSlaveType);
end AxisSysgenProcDataFramerRdFsm;

architecture mapping of AxisSysgenProcDataFramerRdFsm is

   constant AXI_CONFIG_C : AxiStreamConfigType := ssiAxiStreamConfig(8, TKEEP_COMP_C, TUSER_FIRST_LAST_C, 8);  -- 64-bit AXIS interface

   constant HDR_SIZE_C : positive := 13;

   constant VERSION_C : slv(7 downto 0) := (others => '0');
   constant SOF_CNT_C : slv(9 downto 0) := (others => '0');
   constant EOF_CNT_C : slv(9 downto 0) := (others => '1');

   type StateType is (
      IDLE_S,
      HDR0_S,
      HDR1_S,
      PAYLOAD_S);

   type RegType is record
      eofe       : sl;
      hdrCnt     : natural range 0 to HDR_SIZE_C-1;
      header     : Slv64Array(HDR_SIZE_C-1 downto 0);
      rdReady    : sl;
      eventId    : slv(47 downto 0);
      timestamp  : slv(63 downto 0);
      cnt        : slv(9 downto 0);
      axisMaster : AxiStreamMasterType;
      state      : StateType;
   end record;

   constant REG_INIT_C : RegType := (
      eofe       => '0',
      hdrCnt     => 0,
      header     => (others => (others => '0')),
      rdReady    => '0',
      eventId    => (others => '0'),
      timestamp  => (others => '0'),
      cnt        => (others => '0'),
      axisMaster => AXI_STREAM_MASTER_INIT_C,
      state      => IDLE_S);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal timestamp        : slv(63 downto 0) := (others => '0');
   signal baseRateSince1Hz : slv(31 downto 0) := (others => '0');
   signal baseRateSinceTM  : slv(31 downto 0) := (others => '0');
   signal fixedRates       : slv(9 downto 0)  := (others => '0');
   signal timeConfig       : slv(7 downto 0)  := (others => '0');

   signal valid    : sl;
   signal overflow : sl;
   signal dataRead : sl;
   signal data     : slv(63 downto 0);
   signal index    : slv(8 downto 0);

   signal txCtrl : AxiStreamCtrlType;

begin

   U_timing : entity work.SynchronizerFifo
      generic map (
         TPD_G        => TPD_G,
         DATA_WIDTH_G => 146)
      port map (
         -- Asynchronous Reset
         rst                  => timingRst,
         -- Write Ports (wr_clk domain)
         wr_clk               => timingClk,
         wr_en                => timingBus.valid,
         din(63 downto 0)     => timingBus.message.timestamp,
         din(95 downto 64)    => timingBus.extn.baseRateSince1Hz,
         din(127 downto 96)   => timingBus.extn.baseRateSinceTM,
         din(137 downto 128)  => timingBus.message.fixedRates,
         din(145 downto 138)  => timeConfigIn,
         -- Read Ports (rd_clk domain)
         rd_clk               => jesdClk,
         dout(63 downto 0)    => timestamp,
         dout(95 downto 64)   => baseRateSince1Hz,
         dout(127 downto 96)  => baseRateSinceTM,
         dout(137 downto 128) => fixedRates,
         dout(145 downto 138) => timeConfig);

   comb : process (axisSlave, r, rdData, rdValid, rst) is

      variable v         : RegType;
      variable i         : natural;
      variable data      : slv(63 downto 0);
      variable timestamp : slv(63 downto 0);
      variable dataIndex : slv(9 downto 0);

   begin
      -- Latch the current value
      v   := r;

      -- Reset strobes
      v.rdReady := '0';
      if axisSlave.tReady = '1' then
         v.axisMaster.tValid := '0';
         v.axisMaster.tLast  := '0';
         v.axisMaster.tUser  := (others => '0');
      end if;

      -- Map the FIFO output to variables
      data      := rdData(63 downto 0);
      timestamp := rdData(127 downto 64);
      dataIndex := rdData(137 downto 128);

      -- State Machine
      case (r.state) is
         ----------------------------------------------------------------------
         when IDLE_S =>
            -- Reset the flag
            v.eofe := '0';
            -- Reset the counters
            v.cnt    := (others => '0');
            v.hdrCnt := 0;
            -- Check for valid
            if (rdValid = '1') then
               -- Check for SOF
               if (dataIndex = SOF_CNT_C) then
                  --------------------------------------------------------------
                  --                   Generate the header                    --
                  --------------------------------------------------------------
                  -- HDR[0]: HEADER
                  v.header(0)(7 downto 0)       := x"01";       -- Version = 0x1
                  v.header(0)(15 downto 8)      := ipmiBsi.crateId(7 downto 0);  -- ATCA Crate ID[15:8] not included in header
                  v.header(0)(23 downto 16)     := ipmiBsi.slotNumber;
                  v.header(0)(31 downto 24)     := timeConfig;  -- (user defined)
                  v.header(0)(63 downto 32)     := toSlv(4096, 32);  -- # of 32 bit word in data payload
                  -- HDR[6:1]: RTM DAC settings
                  v.header(1)                   := rtmDacConfig(0);  -- (user defined)
                  v.header(2)                   := rtmDacConfig(1);  -- (user defined)
                  v.header(3)                   := rtmDacConfig(2);  -- (user defined)
                  v.header(4)                   := rtmDacConfig(3);  -- (user defined)
                  v.header(5)                   := rtmDacConfig(4);  -- (user defined)
                  v.header(6)                   := rtmDacConfig(5);  -- (user defined)
                  -- HDR[7]: Flux Ramp Settings
                  v.header(7)                   := fluxRampConfig;
                  -- HDR[9:8]: Timing System Counters
                  v.header(8)(31 downto 0)      := baseRateSince1Hz;
                  v.header(8)(63 downto 32)     := baseRateSinceTM;
                  v.header(9)                   := timestamp;
                  -- HDR[10]: Synchronization bits
                  v.header(10)(9 downto 0)      := fixedRates;  -- ????
                  v.header(10)(31 downto 10)    := (others => '0');  -- ????
                  v.header(10)(63 downto 32)    := r.seqCnt;
                  -- HDR[11]: TES relay settings
                  v.header(11)                  := tesRelayConfig;  -- (user defined)
                  -- HDR[12]: External real time clock from timing system
                  v.header(12)(63 downto 0)     := (others => '0');  -- ????
                  --------------------------------------------------------------
                  --------------------------------------------------------------
                  --------------------------------------------------------------
                  -- Write the first header 
                  v.txMaster.tValid             := '1';
                  v.txMaster.tData(63 downto 0) := v.header(0);
                  ssiSetUserSof(AXI_CONFIG_C, v.txMaster, '1');
                  -- Preset the counter
                  v.hdrCnt                      := 1;
                  -- Next state
                  v.state   := HDR0_S;
                  v.seqCnt  := r.seqCnt + 1;
               else
                  -- Blowoff the data because not aligned
                  v.rdReady := '1';
               end if;
            end if;
         ----------------------------------------------------------------------
         when HDR_S =>
            -- Move data
            v.txMaster.tValid             := '1';
            v.txMaster.tData(63 downto 0) := r.header(r.hdrCnt);
            -- Check the counter size
            if (r.hdrCnt = (HDR_SIZE_C-1)) then
               -- Next state
               v.state := PAYLOAD_S;
            else
               -- Increment the counter
               v.hdrCnt := r.hdrCnt + 1;
            end if;
         ----------------------------------------------------------------------
         when PAYLOAD_S =>
            -- Check if ready to move data, cycle through all 8
            if (v.axisMaster.tValid = '0') and (rdValid = '1') then
               -- Accept the data
               v.rdReady   := '1';
               -- Increment the counter
               v.cnt       := r.cnt + 1;

               -- Pack/move the data
               v.axisMaster.tValid             := '1';
               v.axisMaster.tData(63 downto 0) := data;

               -- Error checking (probably due to FIFO overflow)
               if (r.cnt /= dataIndex)              -- Check for misalignment in sequence counter
                            or (r.timestamp /= timestamp) then  -- Check for misalignment in timestamp
                  -- Set error flag
                  v.eofe := '1';
               end if;
               -- Check for last index or error occurred
               if (r.cnt = EOF_CNT_C) or (v.eofe = '1') then
                  -- Terminate the frame
                  v.axisMaster.tLast := '1';
                  -- Set the EOFE flag
                  ssiSetUserEofe(AXI_CONFIG_C, v.axisMaster, v.eofe);
                  -- Next state
                  v.state            := IDLE_S;
               end if;
            end if;
      ----------------------------------------------------------------------
      end case;

      -- Combinatorial Outputs
      rdReady <= v.rdReady;

      -- Synchronous Reset
      if (rst = '1') then
         v := REG_INIT_C;
      end if;

      -- Register the variable for next clock cycle
      rin <= v;

      -- Registered Outputs
      axisMaster <= r.axisMaster;
      eofe       <= r.eofe;

   end process comb;

   seq : process (clk) is
   begin
      if (rising_edge(clk)) then
         r <= rin after TPD_G;
      end if;
   end process seq;

end mapping;

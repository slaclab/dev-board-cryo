-------------------------------------------------------------------------------
-- File       : AxisSysgenProcDataFramer.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2018-04-25
-- Last update: 2018-09-19
-------------------------------------------------------------------------------
--
-- Data Format:
--    DATA[0].BIT[63:0]     = HEADER[0]; -- Refer to IDLE_S for header format
--    DATA[1].BIT[63:0]     = HEADER[1];
--    DATA[2].BIT[63:0]     = HEADER[2];
--    ................................................
--    ................................................
--    ................................................
--    DATA[15].BIT[63:0]    = HEADER[15];
--    ................................................
--    DATA[16].BIT[15:0]    = PHASE[0], Int16 +/- pi
--    DATA[16].BIT[31:16]   = PHASE[1], Int16 +/- pi
--    DATA[16].BIT[47:32]   = PHASE[2], Int16 +/- pi
--    DATA[16].BIT[63:48]   = PHASE[3], Int16 +/- pi
--    ................................................
--    ................................................
--    ................................................
--    DATA[1039].BIT[15:0]  = PHASE[4092], Int16 +/- pi
--    DATA[1039].BIT[31:16] = PHASE[4093], Int16 +/- pi
--    DATA[1039].BIT[47:32] = PHASE[4094], Int16 +/- pi
--    DATA[1039].BIT[63:48] = PHASE[4095], Int16 +/- pi
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
use ieee.std_logic_arith.all;

use work.StdRtlPkg.all;
use work.AxiStreamPkg.all;
use work.SsiPkg.all;
use work.AmcCarrierPkg.all;
use work.TimingPkg.all;

entity AxisSysgenProcDataFramer is
   generic (
      TPD_G        : time                := 1 ns;
      TDEST_G      : slv(7 downto 0)     := x"C1";
      AXI_CONFIG_G : AxiStreamConfigType := ssiAxiStreamConfig(8));
   port (
      -- SYSGEN Interface (jesdClk domain)
      jesdClk        : in  sl;
      jesdRst        : in  sl;
      dataValid      : in  sl;
      dataIndex      : in  slv(9 downto 0);
      dataIn         : in  slv(63 downto 0);
      rtmDacConfig   : in  Slv64Array(5 downto 0);
      fluxRampConfig : in  slv(63 downto 0);
      tesRelayConfig : in  slv(63 downto 0);
      user           : in  Slv64Array(2 downto 0);
      errorDet       : out sl;
      -- Timing Interface (timingClk domain)
      timingClk      : in  sl;
      timingRst      : in  sl;
      timingBus      : in  TimingBusType;
      timeConfigIn   : in  slv(7 downto 0);
      -- IPMI Interface (axisClk domain)
      ipmiBsi        : in  BsiBusType;
      -- AXI Stream Interface (axisClk domain)
      axisClk        : in  sl;
      axisRst        : in  sl;
      axisMaster     : out AxiStreamMasterType;
      axisSlave      : in  AxiStreamSlaveType);
end AxisSysgenProcDataFramer;

architecture mapping of AxisSysgenProcDataFramer is

   constant AXI_CONFIG_C : AxiStreamConfigType := ssiAxiStreamConfig(8);  -- 64-bit AXIS interface

   constant HDR_SIZE_C : positive := 16;

   constant SOF_CNT_C : slv(9 downto 0) := (others => '0');
   constant EOF_CNT_C : slv(9 downto 0) := (others => '1');

   type StateType is (
      IDLE_S,
      HDR_S,
      PAYLOAD_S);

   type RegType is record
      eofe     : sl;
      wordDrop : sl;
      dataRead : sl;
      hdrCnt   : natural range 0 to HDR_SIZE_C-1;
      header   : Slv64Array(HDR_SIZE_C-1 downto 0);
      cnt      : slv(9 downto 0);
      seqCnt   : slv(31 downto 0);
      txMaster : AxiStreamMasterType;
      state    : StateType;
   end record;

   constant REG_INIT_C : RegType := (
      eofe     => '0',
      wordDrop => '0',
      dataRead => '0',
      hdrCnt   => 0,
      header   => (others => (others => '0')),
      cnt      => (others => '0'),
      seqCnt   => (others => '0'),
      txMaster => AXI_STREAM_MASTER_INIT_C,
      state    => IDLE_S);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal timestamp        : slv(63 downto 0);
   signal baseRateSince1Hz : slv(31 downto 0);
   signal baseRateSinceTM  : slv(31 downto 0);
   signal mceData          : slv(39 downto 0);
   signal fixedRates       : slv(9 downto 0);
   signal timeConfig       : slv(7 downto 0);

   signal valid    : sl;
   signal overflow : sl;
   signal dataRead : sl;
   signal data     : slv(63 downto 0);
   signal index    : slv(9 downto 0);

   signal txCtrl : AxiStreamCtrlType;

begin

   U_timing : entity work.SynchronizerFifo
      generic map (
         TPD_G        => TPD_G,
         DATA_WIDTH_G => 186)
      port map (
         -- Asynchronous Reset
         rst                  => timingRst,
         -- Write Ports (wr_clk domain)
         wr_clk               => timingClk,
         wr_en                => timingBus.strobe,
         din(63 downto 0)     => timingBus.message.timestamp,
         din(95 downto 64)    => timingBus.extn.baseRateSince1Hz,
         din(127 downto 96)   => timingBus.extn.baseRateSinceTM,
         din(159 downto 128)  => timingBus.extn.timeCode,
         din(167 downto 160)  => timingBus.extn.timeCodeHeader,
         din(177 downto 168)  => timingBus.message.fixedRates,
         din(185 downto 178)  => timeConfigIn,
         -- Read Ports (rd_clk domain)
         rd_clk               => jesdClk,
         dout(63 downto 0)    => timestamp,
         dout(95 downto 64)   => baseRateSince1Hz,
         dout(127 downto 96)  => baseRateSinceTM,
         dout(167 downto 128) => mceData,
         dout(177 downto 168) => fixedRates,
         dout(185 downto 178) => timeConfig);

   U_data_cache : entity work.FifoSync
      generic map (
         TPD_G        => TPD_G,
         BRAM_EN_G    => false,
         FWFT_EN_G    => true,
         DATA_WIDTH_G => 74,
         ADDR_WIDTH_G => 5)             -- 32 buffers > 16 headers
      port map (
         clk                => jesdClk,
         rst                => jesdRst,
         -- Write Interface
         wr_en              => dataValid,
         overflow           => overflow,
         din(63 downto 0)   => dataIn,
         din(73 downto 64)  => dataIndex,
         -- Read Interface
         rd_en              => dataRead,
         dout(63 downto 0)  => data,
         dout(73 downto 64) => index,
         valid              => valid);

   comb : process (baseRateSince1Hz, baseRateSinceTM, mceData, data, dataIndex,
                   dataValid, fixedRates, fluxRampConfig, index, ipmiBsi,
                   jesdRst, overflow, r, rtmDacConfig, tesRelayConfig, user,
                   timeConfig, timestamp, txCtrl, valid) is
      variable v : RegType;
   begin
      -- Latch the current value
      v := r;

      -- Reset strobes
      v.dataRead        := '0';
      v.txMaster.tValid := '0';
      v.txMaster.tLast  := '0';
      v.txMaster.tUser  := (others => '0');
      --v.wordDrop        := '0';

      --TDEST
      v.txMaster.tDest  := TDEST_G;

      -- State Machine
      case (r.state) is
         ----------------------------------------------------------------------
         when IDLE_S =>
            -- Reset the flag
            v.eofe     := '0';
            -- Blow off the data (no data should be in the data cache)
            v.dataRead := '1';
            -- Set the flag
            if valid = '1' then
               v.wordDrop := '1';
            end if;
            -- Check for SOF event and empty data cache and able to move data
            if (dataValid = '1') and (dataIndex = SOF_CNT_C) and (valid = '0') and (txCtrl.pause = '0')then
               -- Stop the blowoff read
               v.dataRead                    := '0';
               --------------------------------------------------------------
               --                   Generate the header                    --
               --------------------------------------------------------------
               -- HDR[0]: HEADER
               v.header(0)(7 downto 0)       := x"01";       -- Version = 0x1
               v.header(0)(15 downto 8)      := ipmiBsi.crateId(7 downto 0);  -- ATCA Crate ID[15:8] not included in header
               v.header(0)(23 downto 16)     := ipmiBsi.slotNumber;
               v.header(0)(31 downto 24)     := timeConfig;  -- (user defined)
               v.header(0)(63 downto 32)     := toSlv(4096, 32);  -- # of 16 bit word in data payload
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
               v.header(10)(9 downto 0)      := fixedRates;
               v.header(10)(31 downto 10)    := (others => '0');  -- RESERVED
               v.header(10)(63 downto 32)    := r.seqCnt;
               -- HDR[11]: TES relay settings
               v.header(11)                  := tesRelayConfig;  -- (user defined)
               -- HDR[12]: External real time clock from timing system
               v.header(12)(39 downto 0)     := mceData;          -- MCE data
               v.header(12)(63 downto 40)    := (others => '0');  -- RESERVED
               -- User words
               v.header(13)(63 downto 0)     := user(0);  -- (user defined)
               v.header(14)(63 downto 0)     := user(1);  -- (user defined)
               v.header(15)(63 downto 0)     := user(2);  -- (user defined)
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
               v.state                       := HDR_S;
            end if;
            -- Check for SOF event (independent of data cache and back pressure)
            if (dataValid = '1') and (dataIndex = SOF_CNT_C) then
               -- Increment the sequence counter
               v.seqCnt   := r.seqCnt + 1;
               -- clear frame drop counter
               v.wordDrop := '0';
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
            -- Check for data in the data cache
            if (valid = '1') then
               -- Accept the data
               v.dataRead                    := '1';
               -- Move data
               v.txMaster.tValid             := '1';
               v.txMaster.tData(63 downto 0) := data;
               -- Increment the counter
               v.cnt                         := r.cnt + 1;
               -- Check for misalignment in sequence counter
               if (r.cnt /= index) then
                  -- Set error flag
                  v.eofe := '1';
               end if;
               -- Check for last index or error occurred
               if (r.cnt = EOF_CNT_C) or (v.eofe = '1') then
                  -- Reset the counter
                  v.cnt            := SOF_CNT_C;
                  -- Terminate the frame
                  v.txMaster.tLast := '1';
                  -- Set the EOFE flag
                  ssiSetUserEofe(AXI_CONFIG_C, v.txMaster, v.eofe);
                  -- Next state
                  v.state          := IDLE_S;
               end if;
            end if;
      ----------------------------------------------------------------------
      end case;

      -- Combinatorial Outputs
      dataRead <= v.dataRead;

      -- Synchronous Reset
      if (jesdRst = '1') then
         v := REG_INIT_C;
      end if;

      -- Register the variable for next clock cycle
      rin <= v;

      -- Registered Outputs
      errorDet <= r.wordDrop or r.eofe or overflow;

   end process comb;

   seq : process (jesdClk) is
   begin
      if (rising_edge(jesdClk)) then
         r <= rin after TPD_G;
      end if;
   end process seq;

   ---------------------------
   -- Outbound AXI Stream FIFO
   ---------------------------
   U_ObFifo : entity work.AxiStreamFifoV2
      generic map (
         TPD_G               => TPD_G,
         PIPE_STAGES_G       => 1,
         SLAVE_READY_EN_G    => false,  -- Using pause flow control
         VALID_THOLD_G       => 0,      -- 0 = store then forward the packet
         BRAM_EN_G           => true,
         GEN_SYNC_FIFO_G     => false,
         CASCADE_SIZE_G      => 1,
         FIFO_ADDR_WIDTH_G   => 11,     -- 2048 word buffer
         FIFO_FIXED_THRESH_G => true,
         FIFO_PAUSE_THRESH_G => 1000,   -- 1000 + 1024 payload + 16 header = 2040 < 2048
         INT_WIDTH_SELECT_G  => "CUSTOM", -- Enforcing a fixed width (not auto-selected from widest bus)
         INT_DATA_WIDTH_G    => 8, -- Enforcing 64-bit (8 byte) wide internal bus
         SLAVE_AXI_CONFIG_G  => AXI_CONFIG_C,
         MASTER_AXI_CONFIG_G => AXI_CONFIG_G)
      port map (
         -- Slave Interface
         sAxisClk    => jesdClk,
         sAxisRst    => jesdRst,
         sAxisMaster => r.txMaster,
         sAxisCtrl   => txCtrl,
         -- Master Interface
         mAxisClk    => axisClk,
         mAxisRst    => axisRst,
         mAxisMaster => axisMaster,
         mAxisSlave  => axisSlave);

end mapping;

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
use work.ArbiterPkg.all;
use work.AxiStreamPkg.all;
use work.SsiPkg.all;

entity AxisSysgenProcDataFramerRdFsm is
   generic (
      TPD_G   : time := 1 ns;
      TDEST_G : Slv8Array(7 downto 0));
   port (
      -- Clock and Reset
      clk        : in  sl;
      rst        : in  sl;
      -- FIFO Interface
      rdReady    : out slv(7 downto 0);
      rdValid    : in  slv(7 downto 0);
      rdData     : in  Slv89Array(7 downto 0);
      -- AXI Stream Interface
      axisMaster : out AxiStreamMasterType;
      axisSlave  : in  AxiStreamSlaveType);
end AxisSysgenProcDataFramerRdFsm;

architecture mapping of AxisSysgenProcDataFramerRdFsm is

   attribute dont_touch : string;
   component ila_0
      port (
         clk    : in STD_LOGIC;
         probe0 : in STD_LOGIC_VECTOR ( 0 to 0 );
         probe1 : in STD_LOGIC_VECTOR ( 11 downto 0 );
         probe2 : in STD_LOGIC_VECTOR ( 8 downto 0 );
         probe3 : in STD_LOGIC_VECTOR ( 15 downto 0 );
         probe4 : in STD_LOGIC_VECTOR ( 63 downto 0 )
      );
   end component;
   attribute dont_touch of ila_0 : component is "yes";

   constant AXI_CONFIG_C : AxiStreamConfigType := ssiAxiStreamConfig(8, TKEEP_COMP_C, TUSER_FIRST_LAST_C, 8);  -- 64-bit AXIS interface

   constant VERSION_C : slv(7 downto 0) := (others => '0');
   constant SOF_CNT_C : slv(11 downto 0) := (others => '0');
   constant EOF_CNT_C : slv(11 downto 0) := (others => '1');

   type StateType is (
      IDLE_S,
      HDR0_S,
      HDR1_S,
      PAYLOAD_S);

   type RegType is record
      acks       : slv(7 downto 0);
      ackNum     : slv(2 downto 0);
      valid      : sl;
      eofe       : sl;
      rdReady    : slv(7 downto 0);
      eventId    : Slv48Array(7 downto 0);
      timestamp  : slv(63 downto 0);
      cnt        : slv(11 downto 0);
      axisMaster : AxiStreamMasterType;
      state      : StateType;
   end record;

   constant REG_INIT_C : RegType := (
      acks   => (others => '0'),
      ackNum => (others => '0'),
      valid  => '0',
      eofe       => '0',
      rdReady    => (others => '0'),
      eventId    => (others => (others => '0')),
      timestamp  => (others => '0'),
      cnt        => (others => '0'),
      axisMaster => AXI_STREAM_MASTER_INIT_C,
      state      => IDLE_S);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal index       : natural range 0 to 7;

   signal eofe        : sl;
   signal count       : slv(11 downto 0);
   signal countIn     : slv(8 downto 0);
   signal dataIn      : slv(15 downto 0);
   signal timestampIn : slv(63 downto 0);

begin

   index       <= to_integer(unsigned(r.cnt(11 downto 9)));

   eofe        <= r.eofe;
   count       <= r.cnt;
   countIn     <= rdData(index)(88 downto 80);
   dataIn      <= rdData(index)(15 downto 0);
   timestampIn <= rdData(index)(79 downto 16);

   DEBUG : ila_0
      port map (
         clk       => clk,
         probe0(0) => eofe,
         probe1    => count,
         probe2    => countIn,
         probe3    => dataIn,
         probe4    => timestampin);


   comb : process (axisSlave, r, rdData, rdValid, rst) is
      variable v         : RegType;
      variable i         : natural;
      variable request   : sl;
      variable data      : Slv16Array(7 downto 0);
      variable timestamp : Slv64Array(7 downto 0);
      variable dataIndex : Slv9Array(7 downto 0);
      variable idx       : natural range 0 to 7;
   begin
      -- Latch the current value
      v   := r;

      idx := to_integer(unsigned(r.cnt(11 downto 9)));

      -- Reset strobes
      v.rdReady := (others => '0');
      request   := '0';
      if axisSlave.tReady = '1' then
         v.axisMaster.tValid := '0';
         v.axisMaster.tLast  := '0';
         v.axisMaster.tUser  := (others => '0');
      end if;

      -- Map the FIFO output to variables
      for i in 7 downto 0 loop
         data(i)      := rdData(i)(15 downto 0);
         timestamp(i) := rdData(i)(79 downto 16);
         dataIndex(i) := rdData(i)(88 downto 80);
      end loop;

      -- State Machine
      case (r.state) is
         ----------------------------------------------------------------------
         when IDLE_S =>
            -- Reset the flag
            v.eofe := '0';
            -- Reset the counters
            v.cnt  := (others => '0');
            -- Format request
            for i in 7 downto 0 loop
               -- Check for valid
               if (rdValid(i) = '1') then
                  -- Check for SOF
                  if (dataIndex(i) = SOF_CNT_C(8 downto 0)) then
                     request := '1';
                  else
                     -- Blowoff the data because not aligned
                     v.rdReady(i) := '1';
                  end if;
               end if;
            end loop;

            v.valid := request;

            if (v.valid = '1') then
               -- Next state
               v.state := HDR0_S;
            end if;
         ----------------------------------------------------------------------
         when HDR0_S =>
            -- Check if ready to move data
            if (v.axisMaster.tValid = '0') then
               -- Move data
               v.axisMaster.tValid              := '1';
               v.axisMaster.tData(7 downto 0)   := VERSION_C;  -- Version = 0x0
               v.axisMaster.tData(15 downto 8)  := toSlv(idx, 8);  -- Channel Index
               v.axisMaster.tData(63 downto 16) := r.eventId(idx);  -- Event ID
               -- Set the tDest field
               v.axisMaster.tDest               := TDEST_G(idx);
               -- Set SOF bit
               ssiSetUserSof(AXI_CONFIG_C, v.axisMaster, '1');
               -- Latch the timestamp
               v.timestamp                      := timestamp(idx);
               -- Increment the counter
               v.eventId(idx)                 := r.eventId(idx) + 1;
               -- Next state
               v.state                          := HDR1_S;
            end if;
         ----------------------------------------------------------------------
         when HDR1_S =>
            -- Check if ready to move data
            if (v.axisMaster.tValid = '0') then
               -- Move data
               v.axisMaster.tValid             := '1';
               v.axisMaster.tData(63 downto 0) := v.timestamp;
               -- Next state
               v.state                         := PAYLOAD_S;
            end if;
         ----------------------------------------------------------------------
         when PAYLOAD_S =>
            -- Check if ready to move data, cycle through all 8
            if (v.axisMaster.tValid = '0') and (rdValid(idx) = '1') then
               -- Accept the data
               v.rdReady(idx)   := '1';
               -- Increment the counter
               v.cnt            := r.cnt + 1;

               -- Pack/move the data
               case r.cnt(1 downto 0) is
                  when "00" =>
                     v.axisMaster.tValid              := '0';
                     v.axisMaster.tData(15 downto 0)  := data(idx);
                  when "01" =>
                     v.axisMaster.tValid              := '0';
                     v.axisMaster.tData(31 downto 16) := data(idx);
                  when "10" =>
                     v.axisMaster.tValid              := '0';
                     v.axisMaster.tData(47 downto 32) := data(idx);
                  when "11" =>
                     v.axisMaster.tValid              := '1';
                     v.axisMaster.tData(63 downto 48) := data(idx);
               end case;

               -- Error checking (probably due to FIFO overflow)
               if (r.cnt(8 downto 0) /= dataIndex(idx))              -- Check for misalignment in sequence counter
                            or (r.timestamp /= timestamp(idx)) then  -- Check for misalignment in timestamp
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

   end process comb;

   seq : process (clk) is
   begin
      if (rising_edge(clk)) then
         r <= rin after TPD_G;
      end if;
   end process seq;

end mapping;

-------------------------------------------------------------------------------
-- File       : InfoStream.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2018-06-20
-- Last update: 2018-06-20
-------------------------------------------------------------------------------
-- Description: Dummy data producer for cryo streaming interface
--
-- trig in kicks off frame.  
--    dataValid for 512 samples, dataIndex 0...511
--    dataI increment at clock rate
--    dataQ decrement at trig rate
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

entity InfoStream is
   generic (
      TDEST_G : slv(7 downto 0) := x"C0"; 
      TPD_G   : time            := 1 ns);
   port (
      -- Clock and Reset
      clk           : in  sl;
      rst           : in  sl;
      -- Trigger (Flux ramp reset)
      trig          : in  sl;
      -- TES settings
      tesConfig     : in slv20Array(31 downto 0);
      -- flux ramp settings
      rampOffset    : in slv(31 downto 0);
      rampIncrement : in slv(31 downto 0);
      -- Timing interface
      pulseId       : in slv(63 downto 0);
      count1        : in slv(31 downto 0);
      count2        : in slv(31 downto 0);
      avgStrat      : in slv(15 downto 0);
      timingBits    : in slv(136 downto 0);
      -- Output
      dataValid     : out  sl;
      dataOut       : out  slv(31 downto 0);
end InfoStream;

architecture rtl of InfoStream is

   constant SOF_CNT_C : slv(8 downto 0) := (others => '0');
   constant EOF_CNT_C : slv(8 downto 0) := (others => '1');

   constant DATA_SIZE_C : positive        := 1024/8;
   constant VERSION_C   : slv(7 downto 0) := "00000000";
   

   type StateType is (
      IDLE_S,
      DATA_S);

   type RegType is record
      cnt    : slv(15 downto 0);
      valid  : sl;
      data   : slv(31 downto 0);
      state  : StateType;
   end record;

   constant REG_INIT_C : RegType := (
      cnt    => (others => '0'),
      valid  => '0',
      data   => (others => '0'),
      state  => IDLE_S);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

begin

   comb : process (r, rst, trig) is
      variable v : RegType;
   begin
      -- Latch the current value
      v := r;


      -- State Machine
      case (r.state) is
         ----------------------------------------------------------------------
         when IDLE_S =>
            -- Reset
            v.cnt := (others => '0');
            if (trig = '1') then
               v.state     := DATA_S;
               v.dataValid := '1';
               v.dataQ     := r.dataQ + '1';
            end if;
         ----------------------------------------------------------------------
         when DATA_S =>
            case (r.cnt) is
               when toSlv(0, 32) =>
                  v.data := "00000000" & r.numberFrames & TDEST_G & PROTO_VERSION_C;
               when toSlv(1, 32) =>
            v.dataIndex := r.dataIndex + 1;
            if ( r.dataIndex = EOF_CNT_C ) then
               v.state     := IDLE_S;
               v.dataValid := '0';
            end if;
         ----------------------------------------------------------------------
         end case;

      -- Synchronous Reset
      if (rst = '1') then
         v := REG_INIT_C;
      end if;

      -- Register the variable for next clock cycle
      rin       <= v;

      -- Outputs
      dataIndex <= r.dataIndex;
      dataValid <= r.dataValid;
      dataI     <= r.dataI;
      dataQ     <= r.dataQ;

   end process comb;

   seq : process (clk) is
   begin
      if (rising_edge(clk)) then
         r <= rin after TPD_G;
      end if;
   end process seq;

end rtl;

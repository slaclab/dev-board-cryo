-------------------------------------------------------------------------------
-- File       : AxisSysgenProcDataFramerWrFsm.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2018-04-25
-- Last update: 2018-04-25
-------------------------------------------------------------------------------
-- Description: Write FSM for the FIFO
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

entity AxisSysgenProcDataFramerWrFsm is
   generic (
      TPD_G : time := 1 ns);
   port (
      -- Clock and Reset
      clk       : in  sl;
      rst       : in  sl;
      -- SYSGEN Interface
      dataValid : in  sl;
      dataIndex : in  slv(8 downto 0);
      data      : in  slv(15 downto 0);
      -- Timing Interface
      timestamp : in  slv(63 downto 0);
      -- FIFO Interface
      wrEn      : out sl;
      wrData    : out slv(88 downto 0));
end AxisSysgenProcDataFramerWrFsm;

architecture rtl of AxisSysgenProcDataFramerWrFsm is

   type RegType is record
      wrEn   : sl;
      wrData : slv(88 downto 0);
   end record;

   constant REG_INIT_C : RegType := (
      wrEn   => '0',
      wrData => (others => '0'));

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

begin

   comb : process (data, dataIndex, dataValid, r, rst, timestamp) is
      variable v : RegType;
      variable i : natural;
   begin
      -- Latch the current value
      v := r;

      -- Reset strobes
      v.wrEn := '0';

      -- Wait for new data
      if (dataValid = '1') then
         -- Set the flag
         v.wrEn                 := '1';
         -- Latch the data
         v.wrData(15 downto 0)  := data;
         -- Check for SOF
         if (dataIndex = 0) then
            -- Latch the timestamp value
            v.wrData(79 downto 16) := timestamp;
         end if;
         -- Update the index
         v.wrData(88 downto 80) := dataIndex;
      end if;

      -- Synchronous Reset
      if (rst = '1') then
         v := REG_INIT_C;
      end if;

      -- Register the variable for next clock cycle
      rin <= v;

      -- Outputs
      wrEn   <= r.wrEn;
      wrData <= r.wrData;

   end process comb;

   seq : process (clk) is
   begin
      if (rising_edge(clk)) then
         r <= rin after TPD_G;
      end if;
   end process seq;

end rtl;

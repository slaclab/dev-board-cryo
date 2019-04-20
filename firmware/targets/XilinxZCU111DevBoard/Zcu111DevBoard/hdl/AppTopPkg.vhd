-------------------------------------------------------------------------------
-- File       : AppTopPkg.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2016-11-11
-- Last update: 2017-08-24
-------------------------------------------------------------------------------
-- Description: 
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

use work.StdRtlPkg.all;

package AppTopPkg is

   type AppTopJesdRouteType is array (9 downto 0) of natural;
   type AppTopJesdRouteArray is array (1 downto 0) of AppTopJesdRouteType;

   constant DAC_SIG_WIDTH_C : positive := 10;

   type DacSigCtrlType is record
      start : slv(9 downto 0);
   end record;
   type DacSigCtrlArray is array (natural range <>) of DacSigCtrlType;
   constant DAC_SIG_CTRL_INIT_C : DacSigCtrlType := (
      start => (others => '0'));

   type DacSigStatusType is record
      sow     : slv(9 downto 0);  -- Start of waveform strobe (running = '1' and RAM Address = 0x0)
      running : slv(9 downto 0);
   end record;
   type DacSigStatusArray is array (natural range <>) of DacSigStatusType;
   constant DAC_SIG_STATUS_INIT_C : DacSigStatusType := (
      sow     => (others => '0'),
      running => (others => '0'));

end package AppTopPkg;

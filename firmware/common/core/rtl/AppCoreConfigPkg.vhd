-------------------------------------------------------------------------------
-- File       : AppCoreConfigPkg.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- This file is part of 'DevBoard Common Platform'.
-- It is subject to the license terms in the LICENSE.txt file found in the
-- top-level directory of this distribution and at:
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
-- No part of 'DevBoard Common Platform', including this file,
-- may be copied, modified, propagated, or distributed except according to
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.StdRtlPkg.all;
use work.AppCorePkg.all;

package AppCoreConfigPkg is

   function cryoConfig return AppCoreConfigType;

   constant APP_CORE_CONFIG_C  : AppCoreConfigType := cryoConfig;

end AppCoreConfigPkg;

package body AppCoreConfigPkg is

   function cryoConfig return AppCoreConfigType is
      variable config : AppCoreConfigType := APP_CORE_CONFIG_DFLT_C;
   begin

      config.ipAddress            := x"0A02A8C0";      -- 192.168.2.10 (ETH only);
      config.useXvcJtagBridge     := false;           -- use JTAG cable
      config.enableEthJumboFrames := true;        -- jumbo frames

      -- Signal generator setup
      config.sigGenAddrWidth  := (others => 13);
      config.sigGenRamClk     := (others => "11111111"); -- 0: jesd2x, 1: jesd1x

      -- Disable BSA
      config.disableBSA       := true;
      config.disableBLD       := true;

      -- We want jesdClk2x = 614.4MHz, jesdClk = 307.2Mhz
      config.jesdClk_IDIV     := 11;               -- with AXIL_CLK_FRQ_G = 125*5/4 -> 156.25/11MHz
      config.jesdClk_MULT_F   := 43.25;            -- VCO freq  = 614.347MHz
      config.jesdClk_ODIV     := 1;                -- jesdClk2x = 614.347MHz;
      config.jesdUsrClk_ODIV  := 3;                -- jesd2x / 3

      -- 64 bit bus between DaqMuxV2 and BSA
      config.waveformTdataBytes := 8;

      return config;

   end cryoConfig;

end package body;

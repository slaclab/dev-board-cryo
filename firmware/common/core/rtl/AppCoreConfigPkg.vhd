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
      config.ipAddress       := x"6C03000A";      -- 10.0.3.108 (ETH only);
      -- We want jesdClk2x = 614.4MHz, jesdClk = 307.2Mhz
      config.jesdClk_IDIV    := 11;               -- with AXIL_CLK_FRQ_G = 125*5/4 -> 156.25/11MHz
      config.jesdClk_MULT_F  := 43.25;            -- VCO freq  = 614.347MHz
      config.jesdClk_ODIV    := 1;                -- jesdClk2x = 614.347MHz;
      config.jesdUsrClk_ODIV := 3;                -- jesd2x / 3

      return config;
   end cryoConfig;

end package body;

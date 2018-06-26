-------------------------------------------------------------------------------
-- File       : AppCoreTrig.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2017-08-28
-- Last update: 2017-08-28
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.StdRtlPkg.all;
use work.AmcCarrierPkg.all;
use work.AppTopPkg.all;

entity AppCoreTrig is
   generic (
      TPD_G : time := 1 ns);
   port (
      jesdClk         : in  sl;
      jesdRst         : in  sl;
      dacSigTrigArm   : in  sl;
      dacSigTrigDelay : in  slv(23 downto 0);
      dacSigStatus    : in  DacSigStatusType;
      evrTrig         : in  sl;
      trigHw          : out sl;
      freezeHw        : out sl);
end AppCoreTrig;

architecture rtl of AppCoreTrig is

   type StateType is (
      IDLE_S,
      ARM_S,
      DLY_S);

   type RegType is record
      trigHw    : sl;
      delay     : slv(23 downto 0);
      trigDelay : slv(23 downto 0);
      state     : StateType;
   end record;

   constant REG_INIT_C : RegType := (
      trigHw    => '0',
      delay     => (others => '0'),
      trigDelay => (others => '0'),
      state     => IDLE_S);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal trigDelay : slv(23 downto 0);
   signal armTrig   : sl;

   -- attribute dont_touch      : string;
   -- attribute dont_touch of r : signal is "TRUE";   

begin

   Sync_trigDelay : entity work.SynchronizerVector
      generic map (
         TPD_G   => TPD_G,
         WIDTH_G => 24)
      port map (
         clk     => jesdClk,
         dataIn  => dacSigTrigDelay,
         dataOut => trigDelay);

   Sync_armTrig : entity work.SynchronizerOneShot
      generic map (
         TPD_G => TPD_G)
      port map (
         clk     => jesdClk,
         dataIn  => dacSigTrigArm,
         dataOut => armTrig);

   comb : process (armTrig, dacSigStatus, evrTrig, jesdRst, r, trigDelay) is
      variable v : RegType;
   begin
      -- Latch the current value
      v := r;

      -- Check for EVR trigger
      v.trigHw := evrTrig;

      -- State Machine
      case (r.state) is
         ----------------------------------------------------------------------
         when IDLE_S =>
            -- Save the value
            v.trigDelay := trigDelay;
            -- Wait for a arming of trigger
            if (armTrig = '1') then
               -- Next state
               v.state := ARM_S;
            end if;
         ----------------------------------------------------------------------
         when ARM_S =>
            -- Wait for start of waveform
            if (dacSigStatus.sow(0) = '1') then
               -- Next state
               v.state := DLY_S;
            end if;
         ----------------------------------------------------------------------
         when DLY_S =>
            -- Check the counter
            if (r.delay = r.trigDelay) then
               -- Reset the counter
               v.delay  := (others => '0');
               -- Set the trigger flag
               v.trigHw := '1';
               -- Next state
               v.state  := IDLE_S;
            else
               -- Increment the counter
               v.delay := r.delay + 1;
            end if;
      ----------------------------------------------------------------------
      end case;

      -- Synchronous Reset
      if (jesdRst = '1') then
         v := REG_INIT_C;
      end if;

      -- Register the variable for next clock cycle
      rin <= v;

      -- Outputs
      trigHw   <= r.trigHw;
      freezeHw <= r.trigHw;             -- freezeHw is same as trigHw (same behavior as before)

   end process comb;

   seq : process (jesdClk) is
   begin
      if (rising_edge(jesdClk)) then
         r <= rin after TPD_G;
      end if;
   end process seq;

end rtl;

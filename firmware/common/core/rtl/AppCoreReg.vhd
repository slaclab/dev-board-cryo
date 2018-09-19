-------------------------------------------------------------------------------
-- File       : AppCoreReg.vhd
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
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;

entity AppCoreReg is
   generic (
      TPD_G            : time            := 1 ns;
      AXI_BASE_ADDR_G  : slv(31 downto 0) := (others => '0'));
   port (
      -- Configuration/Status
      dacSigTrigArm   : out sl;
      dacSigTrigDelay : out slv(23 downto 0);
      -- Streaming interface
      enableStreams   : out sl;
      streamCounter   : in  slv(31 downto 0);
      streamCounterRst: out sl;
      eofeCounter     : in  slv(31 downto 0);
      eofeCounterRst  : out sl;
      internalTrigSel : out sl;
      timingValid     : in  sl;
      timestamp       : in  slv(63 downto 0);
      baseRateSince1Hz: in  slv(31 downto 0);
      baseRateSinceTM : in  slv(31 downto 0);
      mceData         : in  slv(39 downto 0);
      fixedRates      : in  slv(9  downto 0);
      timeConfig      : in  slv(7  downto 0);
      -- AXI-Lite Register Interface
      axilClk         : in  sl;
      axilRst         : in  sl;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType);
end AppCoreReg;

architecture rtl of AppCoreReg is

   type RegType is record
      dacSigTrigArm   : sl;
      dacSigTrigDelay : slv(23 downto 0);
      enableStreams   : sl;
      streamCounter   : slv(31 downto 0);
      streamCounterRst: sl;
      eofeCounter     : slv(31 downto 0);
      eofeCounterRst  : sl;
      internalTrigSel : sl;
      timingValid     : sl;
      timestamp       : slv(63 downto 0);
      baseRateSince1Hz: slv(31 downto 0);
      baseRateSinceTM : slv(31 downto 0);
      mceData         : slv(39 downto 0);
      fixedRates      : slv(9  downto 0);
      timeConfig      : slv(7  downto 0);
      axilReadSlave   : AxiLiteReadSlaveType;
      axilWriteSlave  : AxiLiteWriteSlaveType;
   end record;

   constant REG_INIT_C : RegType := (
      dacSigTrigArm    => '0',
      dacSigTrigDelay  => (others => '0'),
      enableStreams    => '1',
      streamCounter    => (others => '0'),
      streamCounterRst => '0',
      eofeCounter      => (others => '0'),
      eofeCounterRst   => '0',
      internalTrigSel  => '1',
      timingValid      => '0',
      timestamp        => (others => '0'),
      baseRateSince1Hz => (others => '0'),
      baseRateSinceTM  => (others => '0'),
      mceData          => (others => '0'),
      fixedRates       => (others => '0'),
      timeConfig       => (others => '0'),
      axilReadSlave    => AXI_LITE_READ_SLAVE_INIT_C,
      axilWriteSlave   => AXI_LITE_WRITE_SLAVE_INIT_C);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

begin

   --------------------- 
   -- AXI Lite Interface
   --------------------- 
   comb : process (axilReadMaster, axilRst, axilWriteMaster, r, streamCounter, eofeCounter,
                   timingValid, timestamp, baseRateSince1Hz, baseRateSinceTM, mceData,
                   fixedRates, timeConfig) is
      variable v      : RegType;
      variable regCon : AxiLiteEndPointType;
   begin
      -- Latch the current value
      v := r;

      -- Reset strobes
      v.dacSigTrigArm := '0';

      v.streamCounter := streamCounter;
      v.eofeCounter   := eofeCounter;

      v.timingValid      := timingValid;
      v.timestamp        := timestamp;
      v.baseRateSince1Hz := baseRateSince1Hz;
      v.baseRateSinceTM  := baseRateSinceTM;
      v.mceData          := mceData;
      v.fixedRates       := fixedRates;
      v.timeConfig       := timeConfig;

      -- Determine the transaction type
      axiSlaveWaitTxn(regCon, axilWriteMaster, axilReadMaster, v.axilWriteSlave, v.axilReadSlave);

      -- Map the read registers
      axiSlaveRegister(regCon, x"00",  0, v.dacSigTrigDelay);
      axiSlaveRegister(regCon, x"04",  0, v.dacSigTrigArm);
      axiSlaveRegister(regCon, x"08",  0, v.enableStreams);
      axiSlaveRegister(regCon, x"08",  8, v.streamCounterRst);
      axiSlaveRegister(regCon, x"08",  9, v.eofeCounterRst);
      axiSlaveRegister(regCon, x"08", 10, v.internalTrigSel);
      axiSlaveRegisterR(regCon, x"0C", 0, r.streamCounter);
      axiSlaveRegisterR(regCon, x"10", 0, r.eofeCounter);
      axiSlaveRegisterR(regCon, x"14", 0, r.timingValid);
      axiSlaveRegisterR(regCon, x"18", 0, r.timestamp(31 downto 0));
      axiSlaveRegisterR(regCon, x"1C", 0, r.timestamp(63 downto 32));
      axiSlaveRegisterR(regCon, x"20", 0, r.baseRateSince1Hz);
      axiSlaveRegisterR(regCon, x"24", 0, r.baseRateSinceTM);
      axiSlaveRegisterR(regCon, x"28", 0, r.mceData(31 downto 0));
      axiSlaveRegisterR(regCon, x"2C", 0, r.mceData(39 downto 32));
      axiSlaveRegisterR(regCon, x"30", 0, r.fixedRates);
      axiSlaveRegisterR(regCon, x"34", 0, r.timeConfig);

      -- Closeout the transaction
      axiSlaveDefault(regCon, v.axilWriteSlave, v.axilReadSlave, AXI_RESP_DECERR_C);

      -- Synchronous Reset
      if (axilRst = '1') then
         v := REG_INIT_C;
      end if;

      -- Register the variable for next clock cycle
      rin <= v;

      -- Outputs
      axilWriteSlave  <= r.axilWriteSlave;
      axilReadSlave   <= r.axilReadSlave;
      dacSigTrigDelay <= r.dacSigTrigDelay;
      dacSigTrigArm   <= r.dacSigTrigArm;
      enableStreams   <= r.enableStreams;
      streamCounterRst<= r.streamCounterRst;
      eofeCounterRst  <= r.eofeCounterRst;
      internalTrigSel <= r.internalTrigSel;

   end process comb;

   seq : process (axilClk) is
   begin
      if (rising_edge(axilClk)) then
         r <= rin after TPD_G;
      end if;
   end process seq;

end rtl;

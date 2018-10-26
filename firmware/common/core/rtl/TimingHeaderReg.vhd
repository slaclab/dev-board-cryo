-------------------------------------------------------------------------------
-- File       : TimingHeaderReg.vhd
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
use work.AmcCarrierPkg.all;
use work.TimingPkg.all;

entity TimingHeaderReg is
   generic (
      TPD_G            : time            := 1 ns;
      AXI_BASE_ADDR_G  : slv(31 downto 0) := (others => '0'));
   port (
      -- jesdClk config registers
      jesdClk         : in  sl;
      rtmDacConfig    : out Slv64Array(5 downto 0);
      fluxRampConfig  : out slv(63 downto 0);
      tesRelayConfig  : out slv(63 downto 0);
      timingConfig    : out slv(7  downto 0);
      ipmiBsi         : out BsiBusType; 
      user            : out Slv64Array(2 downto 0);
      -- jesdClk status register
      errorDet        : in  sl;
      -- timingClk status registers
      timingClk       : in  sl;
      timingRst       : in  sl;
      timingBus       : in  TimingBusType;
      -- AXI-Lite Register Interface
      axilClk         : in  sl;
      axilRst         : in  sl;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType);
end TimingHeaderReg;

architecture rtl of TimingHeaderReg is

   constant BSI_BUS_CONFIG_C : BsiBusType := (
      slotNumber => x"07",
      crateId    => x"0003",
      macAddress => (others => (others => '0')));

   type RegType is record
      rtmDacConfig    : Slv64Array(5 downto 0);
      fluxRampConfig  : slv(63 downto 0);
      tesRelayConfig  : slv(63 downto 0);
      timingConfig    : slv(7  downto 0);
      ipmiBsiSlot     : slv(7 downto 0); 
      ipmiBsiCrate    : slv(15 downto 0); 
      user            : Slv64Array(2 downto 0);
      errorCounter    : slv(31 downto 0);
      errorCounterRst : sl;
      timingValid     : sl;
      timingExtnValid : sl;
      timestamp       : slv(63 downto 0);
      baseRateSince1Hz: slv(31 downto 0);
      baseRateSinceTM : slv(31 downto 0);
      mceData         : slv(39 downto 0);
      fixedRates      : slv(9  downto 0);
      axilReadSlave   : AxiLiteReadSlaveType;
      axilWriteSlave  : AxiLiteWriteSlaveType;
   end record;

   constant REG_INIT_C : RegType := (
      rtmDacConfig     => (others => (others => '0')),
      fluxRampConfig   => (others => '0'),
      tesRelayConfig   => (others => '0'),
      timingConfig     => (others => '0'),
      ipmiBsiSlot      => (others => '0'),
      ipmiBsiCrate     => (others => '0'),
      user             => (others => (others => '0')),
      errorCounter     => (others => '0'),
      errorCounterRst  => '0',
      timingValid      => '0',
      timingExtnValid  => '0',
      timestamp        => (others => '0'),
      baseRateSince1Hz => (others => '0'),
      baseRateSinceTM  => (others => '0'),
      mceData          => (others => '0'),
      fixedRates       => (others => '0'),
      axilReadSlave    => AXI_LITE_READ_SLAVE_INIT_C,
      axilWriteSlave   => AXI_LITE_WRITE_SLAVE_INIT_C);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal timingValid      : sl;
   signal timingExtnValid  : sl;
   signal timestamp        : slv(63 downto 0);
   signal baseRateSince1Hz : slv(31 downto 0);
   signal baseRateSinceTM  : slv(31 downto 0);
   signal mceData          : slv(39 downto 0);
   signal fixedRates       : slv(9 downto 0);
   signal timeConfig       : slv(7 downto 0);

   signal errorCounter     : slv(31 downto 0);
   signal errorCounterRst  : sl;

   signal ipmiBsiS         : BsiBusType := BSI_BUS_CONFIG_C;

begin

   U_TIMING_VALID_SYNC : entity work.Synchronizer
      generic map (
         TPD_G        => TPD_G)
      port map (
         clk     => axilClk,
         dataIn  => timingBus.valid,
         dataOut => timingValid);

   U_TIMING_EXTN_VALID_SYNC : entity work.Synchronizer
      generic map (
         TPD_G        => TPD_G)
      port map (
         clk     => axilClk,
         dataIn  => timingBus.extnValid,
         dataOut => timingExtnValid);

   U_TIMING_SYNC : entity work.SynchronizerFifo
      generic map (
         TPD_G        => TPD_G,
         DATA_WIDTH_G => 178)
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
         -- Read Ports (rd_clk domain)
         rd_clk               => axilClk,
         dout(63 downto 0)    => timestamp,
         dout(95 downto 64)   => baseRateSince1Hz,
         dout(127 downto 96)  => baseRateSinceTM,
         dout(167 downto 128) => mceData,
         dout(177 downto 168) => fixedRates);

   -- Counts the number of stream EOFE
   U_SyncEofeVector : entity work.SynchronizerOneShotCnt
      generic map (
         TPD_G          => TPD_G,
         OUT_POLARITY_G => '1',
         CNT_RST_EDGE_G => true,
         CNT_WIDTH_G    => 32)
      port map (
         -- Input Status bit Signals (wrClk domain)
         dataIn     => errorDet,
         -- Output Status bit Signals (rdClk domain)  
         dataOut    => open,
         -- Status Bit Counters Signals (rdClk domain) 
         rollOverEn => '1',
         cntRst     => errorCounterRst,
         cntOut     => errorCounter,
         -- Clocks and Reset Ports
         wrClk      => jesdClk,
         rdClk      => axilClk);

   U_GEN_SYNC : entity work.SynchronizerVector
      generic map (
         TPD_G        => TPD_G,
         WIDTH_G      => 728)
      port map (
         clk                     => jesdClk,
         -- data in
         dataIn(63 downto 0)     => r.rtmDacConfig(0),
         dataIn(127 downto 64)   => r.rtmDacConfig(1),
         dataIn(191 downto 128)  => r.rtmDacConfig(2),
         dataIn(255 downto 192)  => r.rtmDacConfig(3),
         dataIn(319 downto 256)  => r.rtmDacConfig(4),
         dataIn(383 downto 320)  => r.rtmDacConfig(5),
         dataIn(447 downto 384)  => r.fluxRampConfig,
         dataIn(511 downto 448)  => r.tesRelayConfig,
         dataIn(519 downto 512)  => r.ipmiBsiSlot,
         dataIn(535 downto 520)  => r.ipmiBsiCrate,
         dataIn(599 downto 536)  => r.user(0),
         dataIn(663 downto 600)  => r.user(1),
         dataIn(727 downto 664)  => r.user(2),
         -- data out
         dataOut(63 downto 0)    => rtmDacConfig(0),
         dataOut(127 downto 64)  => rtmDacConfig(1),
         dataOut(191 downto 128) => rtmDacConfig(2),
         dataOut(255 downto 192) => rtmDacConfig(3),
         dataOut(319 downto 256) => rtmDacConfig(4),
         dataOut(383 downto 320) => rtmDacConfig(5),
         dataOut(447 downto 384) => fluxRampConfig,
         dataOut(511 downto 448) => tesRelayConfig,
         dataOut(519 downto 512) => ipmiBsi.slotNumber,
         dataOut(535 downto 520) => ipmiBsi.crateId,
         dataOut(599 downto 536) => user(0),
         dataOut(663 downto 600) => user(1),
         dataOut(727 downto 664) => user(2));

   --------------------- 
   -- AXI Lite Interface
   --------------------- 
   comb : process (axilReadMaster, axilRst, axilWriteMaster, r, errorCounter,
                   timingValid, timingExtnValid, timestamp, baseRateSince1Hz, 
                   baseRateSinceTM, mceData, fixedRates) is
      variable v      : RegType;
      variable regCon : AxiLiteEndPointType;
   begin
      -- Latch the current value
      v := r;

      v.errorCounter     := errorCounter;
      v.timingValid      := timingValid;
      v.timingExtnValid  := timingExtnValid;
      v.timestamp        := timestamp;
      v.baseRateSince1Hz := baseRateSince1Hz;
      v.baseRateSinceTM  := baseRateSinceTM;
      v.mceData          := mceData;
      v.fixedRates       := fixedRates;

      -- Determine the transaction type
      axiSlaveWaitTxn(regCon, axilWriteMaster, axilReadMaster, v.axilWriteSlave, v.axilReadSlave);

      -- Map the read registers
      axiSlaveRegister(regCon,  x"00", 0, v.rtmDacConfig(0)(31 downto 0));
      axiSlaveRegister(regCon,  x"04", 0, v.rtmDacConfig(0)(63 downto 32));
      axiSlaveRegister(regCon,  x"08", 0, v.rtmDacConfig(1)(31 downto 0));
      axiSlaveRegister(regCon,  x"0C", 0, v.rtmDacConfig(1)(63 downto 32));
      axiSlaveRegister(regCon,  x"10", 0, v.rtmDacConfig(2)(31 downto 0));
      axiSlaveRegister(regCon,  x"14", 0, v.rtmDacConfig(2)(63 downto 32));
      axiSlaveRegister(regCon,  x"18", 0, v.rtmDacConfig(3)(31 downto 0));
      axiSlaveRegister(regCon,  x"1C", 0, v.rtmDacConfig(3)(63 downto 32));
      axiSlaveRegister(regCon,  x"20", 0, v.rtmDacConfig(4)(31 downto 0));
      axiSlaveRegister(regCon,  x"24", 0, v.rtmDacConfig(4)(63 downto 32));
      axiSlaveRegister(regCon,  x"28", 0, v.rtmDacConfig(5)(31 downto 0));
      axiSlaveRegister(regCon,  x"2C", 0, v.rtmDacConfig(5)(63 downto 32));
      axiSlaveRegister(regCon,  x"30", 0, v.fluxRampConfig(31 downto 0));
      axiSlaveRegister(regCon,  x"34", 0, v.fluxRampConfig(63 downto 32));
      axiSlaveRegister(regCon,  x"38", 0, v.tesRelayConfig(31 downto 0));
      axiSlaveRegister(regCon,  x"3C", 0, v.tesRelayConfig(63 downto 32));
      axiSlaveRegister(regCon,  x"40", 0, v.timingConfig);
      axiSlaveRegister(regCon,  x"44", 0, v.ipmiBsiSlot);
      axiSlaveRegister(regCon,  x"48", 0, v.ipmiBsiCrate);
      axiSlaveRegister(regCon,  x"4C", 0, v.errorCounterRst);

      axiSlaveRegister(regCon,  x"50", 0, v.user(0)(31 downto 0));
      axiSlaveRegister(regCon,  x"54", 0, v.user(0)(63 downto 32));
      axiSlaveRegister(regCon,  x"58", 0, v.user(1)(31 downto 0));
      axiSlaveRegister(regCon,  x"5C", 0, v.user(1)(63 downto 32));
      axiSlaveRegister(regCon,  x"60", 0, v.user(2)(31 downto 0));
      axiSlaveRegister(regCon,  x"64", 0, v.user(2)(63 downto 32));

      axiSlaveRegisterR(regCon, x"70", 0, r.errorCounter);
      axiSlaveRegisterR(regCon, x"74", 0, r.timingValid);
      axiSlaveRegisterR(regCon, x"74", 1, r.timingExtnValid);
      axiSlaveRegisterR(regCon, x"78", 0, r.timestamp(31 downto 0));
      axiSlaveRegisterR(regCon, x"7C", 0, r.timestamp(63 downto 32));
      axiSlaveRegisterR(regCon, x"80", 0, r.baseRateSince1Hz);
      axiSlaveRegisterR(regCon, x"84", 0, r.baseRateSinceTM);
      axiSlaveRegisterR(regCon, x"88", 0, r.mceData(31 downto 0));
      axiSlaveRegisterR(regCon, x"8C", 0, r.mceData(39 downto 32));
      axiSlaveRegisterR(regCon, x"90", 0, r.fixedRates);

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

      errorCounterRst <= r.errorCounterRst;

   end process comb;

   seq : process (axilClk) is
   begin
      if (rising_edge(axilClk)) then
         r <= rin after TPD_G;
      end if;
   end process seq;

end rtl;

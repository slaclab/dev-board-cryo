-------------------------------------------------------------------------------
-- File       : AppTop.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2017-02-04
-- Last update: 2018-05-02
-------------------------------------------------------------------------------
-- Description: Application's Top Level
--
-- Note: Common-to-Application interface defined in HPS ESD: LCLSII-2.7-ES-0536
--
-------------------------------------------------------------------------------
-- This file is part of 'LCLS2 AMC Carrier Firmware'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'LCLS2 AMC Carrier Firmware', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.StdRtlPkg.all;
use work.AxiStreamPkg.all;
use work.AxiLitePkg.all;
use work.TimingPkg.all;
use work.AmcCarrierPkg.all;
use work.jesd204bpkg.all;
use work.AppTopPkg.all;

entity AppTop is
   generic (
      -- General Generics
      TPD_G                  : time                      := 1 ns;
      SIM_SPEEDUP_G          : boolean                   := false;
      SIMULATION_G           : boolean                   := false;
      DAQMUX_DECIMATOR_EN_G  : boolean                   := true;
      MR_LCLS_APP_G          : boolean                   := false;
      WAVEFORM_TDATA_BYTES_G : positive                  := 4;
      TIMING_BUS_DOMAIN_G    : string                    := "REC_CLK";
      -- Signal Generator Generics
      SIG_GEN_SIZE_G         : NaturalArray(1 downto 0)  := (others => 8);
      SIG_GEN_ADDR_WIDTH_G   : PositiveArray(1 downto 0) := (others => 9);
      SIG_GEN_LANE_MODE_G    : Slv10Array(1 downto 0)    := (others => "0000000000");
      SIG_GEN_RAM_CLK_G      : Slv10Array(1 downto 0)    := (others => "0000000000"));
   port (
      ----------------------
      -- Top Level Interface
      ----------------------
      -- AXI-Lite Interface (axilClk domain)
      axilClk              : in    sl;
      axilRst              : in    sl;
      axilReadMaster       : in    AxiLiteReadMasterType;
      axilReadSlave        : out   AxiLiteReadSlaveType;
      axilWriteMaster      : in    AxiLiteWriteMasterType;
      axilWriteSlave       : out   AxiLiteWriteSlaveType;
      -- Timing Interface (timingClk domain) 
      timingClk            : out   sl;
      timingRst            : out   sl;
      timingBus            : in    TimingBusType;
      timingPhy            : out   TimingPhyType;
      timingPhyClk         : in    sl;
      timingPhyRst         : in    sl;
      timingTrig           : in    TimingTrigType;
      -- Diagnostic Interface (diagnosticClk domain)
      diagnosticClk        : out   sl;
      diagnosticRst        : out   sl;
      diagnosticBus        : out   DiagnosticBusType;
      -- Waveform interface (waveformClk domain)
      waveformClk          : in    sl;
      waveformRst          : in    sl;
      obAppWaveformMasters : out   WaveformMasterArrayType;
      obAppWaveformSlaves  : in    WaveformSlaveArrayType;
      ibAppWaveformMasters : in    WaveformMasterArrayType;
      ibAppWaveformSlaves  : out   WaveformSlaveArrayType;
      -- Backplane Messaging Interface  (axilClk domain)
      obBpMsgClientMaster  : out   AxiStreamMasterType;
      obBpMsgClientSlave   : in    AxiStreamSlaveType;
      ibBpMsgClientMaster  : in    AxiStreamMasterType;
      ibBpMsgClientSlave   : out   AxiStreamSlaveType;
      obBpMsgServerMaster  : out   AxiStreamMasterType;
      obBpMsgServerSlave   : in    AxiStreamSlaveType;
      ibBpMsgServerMaster  : in    AxiStreamMasterType;
      ibBpMsgServerSlave   : out   AxiStreamSlaveType;
      -- Application Debug Interface (axilClk domain)
      obAppDebugMaster     : out   AxiStreamMasterType;
      obAppDebugSlave      : in    AxiStreamSlaveType;
      ibAppDebugMaster     : in    AxiStreamMasterType;
      ibAppDebugSlave      : out   AxiStreamSlaveType;
      -- Reference Clocks and Resets
      recTimingClk         : in    sl;
      recTimingRst         : in    sl);
      -----------------------
      -- Application Ports --
      -----------------------

end AppTop;

architecture mapping of AppTop is

   constant NUM_AXI_MASTERS_C : natural := 8;

   constant CORE_INDEX_C     : natural := 0;
   constant TIMING_INDEX_C   : natural := 1;
   constant DAQ_MUX0_INDEX_C : natural := 2;
   constant DAQ_MUX1_INDEX_C : natural := 3;
   constant JESD0_INDEX_C    : natural := 4;
   constant JESD1_INDEX_C    : natural := 5;
   constant SIG_GEN0_INDEX_C : natural := 6;
   constant SIG_GEN1_INDEX_C : natural := 7;

   constant AXI_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXI_MASTERS_C-1 downto 0) := genAxiLiteConfig(NUM_AXI_MASTERS_C, x"80000000", 31, 28);

   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_AXI_MASTERS_C-1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXI_MASTERS_C-1 downto 0);
   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_AXI_MASTERS_C-1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXI_MASTERS_C-1 downto 0);

   signal trigCascBay : slv(2 downto 0);
   signal armCascBay  : slv(2 downto 0);
   signal trigHw      : slv(1 downto 0);
   signal freezeHw    : slv(1 downto 0);

   signal jesdClk    : slv(1 downto 0);
   signal jesdRst    : slv(1 downto 0);
   signal jesdUsrClk : slv(1 downto 0);
   signal jesdUsrRst : slv(1 downto 0);
   signal jesdClk2x  : slv(1 downto 0);
   signal jesdRst2x  : slv(1 downto 0);
   signal jesdSysRef : slv(1 downto 0);
   signal jesdRxSync : slv(1 downto 0);
   signal jesdTxSync : slv(1 downto 0);

   signal adcValids : Slv10Array(1 downto 0);
   signal adcValues : sampleDataVectorArray(1 downto 0, 9 downto 0);

   signal dacValids : Slv10Array(1 downto 0);
   signal dacValues : sampleDataVectorArray(1 downto 0, 9 downto 0);

   signal debugValids : Slv4Array(1 downto 0);
   signal debugValues : sampleDataVectorArray(1 downto 0, 3 downto 0);

   signal dataValids : Slv24Array(1 downto 0);
   signal linkReady  : Slv24Array(1 downto 0);

   signal dacSigCtrl   : DacSigCtrlArray(1 downto 0);
   signal dacSigStatus : DacSigStatusArray(1 downto 0);
   signal dacSigValids : Slv10Array(1 downto 0);
   signal dacSigValues : sampleDataVectorArray(1 downto 0, 9 downto 0);

begin

   assert ((TIMING_BUS_DOMAIN_G = "REC_CLK") or
           (TIMING_BUS_DOMAIN_G = "JESD_CLK0") or
           (TIMING_BUS_DOMAIN_G = "JESD_CLK1") or
           (TIMING_BUS_DOMAIN_G = "JESD_2xCLK0") or
           (TIMING_BUS_DOMAIN_G = "JESD_2xCLK1") or
           (TIMING_BUS_DOMAIN_G = "JESD_UsrCLK0") or
           (TIMING_BUS_DOMAIN_G = "JESD_UsrCLK1") or
           (TIMING_BUS_DOMAIN_G = "AXI_LITE"))
      report "TIMING_BUS_DOMAIN_G be either [REC_CLK,AXI_LITE,JESD_CLK0,JESD_CLK1,JESD_2xCLK0,JESD_2xCLK1,JESD_UsrCLK0,JESD_UsrCLK1]" severity error;

   --------------------------
   -- Clock and reset mapping
   --------------------------
   process(axilClk, axilRst, jesdClk, jesdClk2x, jesdRst, jesdRst2x,
           jesdUsrClk, jesdUsrRst, recTimingClk, recTimingRst)
   begin
      case TIMING_BUS_DOMAIN_G is
         ------------------------------
         when "REC_CLK" =>
            timingClk <= recTimingClk;
            timingRst <= recTimingRst;
         ------------------------------
         when "JESD_CLK0" =>
            timingClk <= jesdClk(0);
            timingRst <= jesdRst(0);
         ------------------------------
         when "JESD_CLK1" =>
            timingClk <= jesdClk(1);
            timingRst <= jesdRst(1);
         ------------------------------
         when "JESD_2xCLK0" =>
            timingClk <= jesdClk2x(0);
            timingRst <= jesdRst2x(0);
         ------------------------------
         when "JESD_2xCLK1" =>
            timingClk <= jesdClk2x(1);
            timingRst <= jesdRst2x(1);
         ------------------------------
         when "JESD_UsrCLK0" =>
            timingClk <= jesdUsrClk(0);
            timingRst <= jesdUsrRst(0);
         ------------------------------
         when "JESD_UsrCLK1" =>
            timingClk <= jesdUsrClk(1);
            timingRst <= jesdUsrRst(1);
         ------------------------------
         when others =>
            -- (TIMING_BUS_DOMAIN_G = "AXI-LITE")
            timingClk <= axilClk;
            timingRst <= axilRst;
      ------------------------------
      end case;
   end process;

   -------------------------------
   -- Terminating legacy interface
   -------------------------------
   axilReadSlaves(TIMING_INDEX_C)  <= AXI_LITE_READ_SLAVE_EMPTY_DECERR_C;
   axilWriteSlaves(TIMING_INDEX_C) <= AXI_LITE_WRITE_SLAVE_EMPTY_DECERR_C;

   ---------------------
   -- AXI-Lite Crossbar
   ---------------------
   U_XBAR : entity work.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => NUM_AXI_MASTERS_C,
         MASTERS_CONFIG_G   => AXI_CONFIG_C)
      port map (
         axiClk              => axilClk,
         axiClkRst           => axilRst,
         sAxiWriteMasters(0) => axilWriteMaster,
         sAxiWriteSlaves(0)  => axilWriteSlave,
         sAxiReadMasters(0)  => axilReadMaster,
         sAxiReadSlaves(0)   => axilReadSlave,
         mAxiWriteMasters    => axilWriteMasters,
         mAxiWriteSlaves     => axilWriteSlaves,
         mAxiReadMasters     => axilReadMasters,
         mAxiReadSlaves      => axilReadSlaves);

   ---------------
   -- DAQ MUX Core
   ---------------            
   trigCascBay(2) <= trigCascBay(0);    -- to make cross and use generate
   armCascBay(2)  <= armCascBay(0);     -- to make cross and use generate

   U_AmcBay : for i in 1 downto 0 generate

      ------------------
      -- DAQ MUXV2 Module
      ------------------
      U_DaqMuxV2 : entity work.DaqMuxV2
         generic map (
            TPD_G                  => TPD_G,
            DECIMATOR_EN_G         => DAQMUX_DECIMATOR_EN_G,
            WAVEFORM_TDATA_BYTES_G => WAVEFORM_TDATA_BYTES_G,
            BAY_INDEX_G            => ite((i = 0), '0', '1'),
            N_DATA_IN_G            => 24,
            N_DATA_OUT_G           => 4)
         port map (
            -- Clocks and Resets
            axiClk              => axilClk,
            axiRst              => axilRst,
            devClk_i            => jesdClk(i),
            devRst_i            => jesdRst(i),
            -- External DAQ trigger input
            trigHw_i            => trigHw(i),
            -- Cascaded Sw trigger for external connection between modules
            trigCasc_i          => trigCascBay(i+1),
            trigCasc_o          => trigCascBay(i),
            -- Cascaded Arm trigger for external connection between modules 
            armCasc_i           => armCascBay(i+1),
            armCasc_o           => armCascBay(i),
            -- Freeze buffers
            freezeHw_i          => freezeHw(i),
            -- Time-stamp and bsa (if enabled it will be added to start of data)
            timeStamp_i         => timingTrig.timeStamp,
            bsa_i               => timingTrig.bsa,
            dmod_i              => timingTrig.dmod,
            -- AXI-Lite Register Interface
            axilReadMaster      => axilReadMasters(DAQ_MUX0_INDEX_C+i),
            axilReadSlave       => axilReadSlaves(DAQ_MUX0_INDEX_C+i),
            axilWriteMaster     => axilWriteMasters(DAQ_MUX0_INDEX_C+i),
            axilWriteSlave      => axilWriteSlaves(DAQ_MUX0_INDEX_C+i),
            -- ADC Input 
            sampleDataArr_i(0)  => adcValues(i, 0),
            sampleDataArr_i(1)  => adcValues(i, 1),
            sampleDataArr_i(2)  => adcValues(i, 2),
            sampleDataArr_i(3)  => adcValues(i, 3),
            sampleDataArr_i(4)  => adcValues(i, 4),
            sampleDataArr_i(5)  => adcValues(i, 5),
            sampleDataArr_i(6)  => adcValues(i, 6),
            sampleDataArr_i(7)  => adcValues(i, 7),
            sampleDataArr_i(8)  => adcValues(i, 8),
            sampleDataArr_i(9)  => adcValues(i, 9),
            -- DAC Input 
            sampleDataArr_i(10) => dacValues(i, 0),
            sampleDataArr_i(11) => dacValues(i, 1),
            sampleDataArr_i(12) => dacValues(i, 2),
            sampleDataArr_i(13) => dacValues(i, 3),
            sampleDataArr_i(14) => dacValues(i, 4),
            sampleDataArr_i(15) => dacValues(i, 5),
            sampleDataArr_i(16) => dacValues(i, 6),
            sampleDataArr_i(17) => dacValues(i, 7),
            sampleDataArr_i(18) => dacValues(i, 8),
            sampleDataArr_i(19) => dacValues(i, 9),
            -- DBG Input             
            sampleDataArr_i(20) => debugValues(i, 0),
            sampleDataArr_i(21) => debugValues(i, 1),
            sampleDataArr_i(22) => debugValues(i, 2),
            sampleDataArr_i(23) => debugValues(i, 3),
            -- MISC Interfaces
            sampleValidVec_i    => dataValids(i),
            linkReadyVec_i      => linkReady(i),
            -- Output AXI Streaming Interface (Has to be synced with waveform clk)
            wfClk_i             => waveformClk,
            wfRst_i             => waveformRst,
            rxAxisMasterArr_o   => obAppWaveformMasters(i),
            rxAxisSlaveArr_i(0) => obAppWaveformSlaves(i)(0).slave,
            rxAxisSlaveArr_i(1) => obAppWaveformSlaves(i)(1).slave,
            rxAxisSlaveArr_i(2) => obAppWaveformSlaves(i)(2).slave,
            rxAxisSlaveArr_i(3) => obAppWaveformSlaves(i)(3).slave,
            rxAxisCtrlArr_i(0)  => obAppWaveformSlaves(i)(0).ctrl,
            rxAxisCtrlArr_i(1)  => obAppWaveformSlaves(i)(1).ctrl,
            rxAxisCtrlArr_i(2)  => obAppWaveformSlaves(i)(2).ctrl,
            rxAxisCtrlArr_i(3)  => obAppWaveformSlaves(i)(3).ctrl);

      dataValids(i) <= debugValids(i) & dacValids(i) & adcValids(i);
      linkReady(i)  <= x"F" & dacValids(i) & adcValids(i);
      
      -------------------------------
      -- Terminating legacy interface
      -------------------------------
      axilReadSlaves(JESD0_INDEX_C+i)  <= AXI_LITE_READ_SLAVE_EMPTY_DECERR_C;
      axilWriteSlaves(JESD0_INDEX_C+i) <= AXI_LITE_WRITE_SLAVE_EMPTY_DECERR_C;      

      U_DacSigGen : entity work.DacSigGen
         generic map (
            TPD_G                => TPD_G,
            AXI_BASE_ADDR_G      => AXI_CONFIG_C(SIG_GEN0_INDEX_C+i).baseAddr,
            SIG_GEN_SIZE_G       => SIG_GEN_SIZE_G(i),
            SIG_GEN_ADDR_WIDTH_G => SIG_GEN_ADDR_WIDTH_G(i),
            SIG_GEN_LANE_MODE_G  => SIG_GEN_LANE_MODE_G(i),
            SIG_GEN_RAM_CLK_G    => SIG_GEN_RAM_CLK_G(i))
         port map (
            -- DAC Signal Generator Interface
            jesdClk         => jesdClk(i),
            jesdRst         => jesdRst(i),
            jesdClk2x       => jesdClk2x(i),
            jesdRst2x       => jesdRst2x(i),
            dacSigCtrl      => dacSigCtrl(i),
            dacSigStatus    => dacSigStatus(i),
            dacSigValids    => dacSigValids(i),
            dacSigValues(0) => dacSigValues(i, 0),
            dacSigValues(1) => dacSigValues(i, 1),
            dacSigValues(2) => dacSigValues(i, 2),
            dacSigValues(3) => dacSigValues(i, 3),
            dacSigValues(4) => dacSigValues(i, 4),
            dacSigValues(5) => dacSigValues(i, 5),
            dacSigValues(6) => dacSigValues(i, 6),
            dacSigValues(7) => dacSigValues(i, 7),
            dacSigValues(8) => dacSigValues(i, 8),
            dacSigValues(9) => dacSigValues(i, 9),
            -- AXI-Lite Interface
            axilClk         => axilClk,
            axilRst         => axilRst,
            axilReadMaster  => axilReadMasters(SIG_GEN0_INDEX_C+i),
            axilReadSlave   => axilReadSlaves(SIG_GEN0_INDEX_C+i),
            axilWriteMaster => axilWriteMasters(SIG_GEN0_INDEX_C+i),
            axilWriteSlave  => axilWriteSlaves(SIG_GEN0_INDEX_C+i));

   end generate U_AmcBay;

   -------------------
   -- Application Core
   -------------------
   U_AppCore : entity work.AppCore
      generic map (
         TPD_G           => TPD_G,
         SIM_SPEEDUP_G   => SIM_SPEEDUP_G,
         SIMULATION_G    => SIMULATION_G,
         AXI_BASE_ADDR_G => AXI_CONFIG_C(CORE_INDEX_C).baseAddr)
      port map (
         -- Clocks and resets   
         jesdClk             => jesdClk,
         jesdRst             => jesdRst,
         jesdClk2x           => jesdClk2x,
         jesdRst2x           => jesdRst2x,
         jesdUsrClk          => jesdUsrClk,
         jesdUsrRst          => jesdUsrRst,
         -- DaqMux/Trig Interface (timingClk domain) 
         freezeHw            => freezeHw,
         timingTrig          => timingTrig,
         trigHw              => trigHw,
         trigCascBay         => trigCascBay(1 downto 0),
         -- ADC/DAC/Debug Interface (jesdClk[1:0] domain)
         adcValids           => adcValids,
         adcValues           => adcValues,
         dacValids           => dacValids,
         dacValues           => dacValues,
         debugValids         => debugValids,
         debugValues         => debugValues,
         -- DAC Signal Generator Interface
         -- If SIG_GEN_LANE_MODE_G = '0', (jesdClk[1:0] domain)
         -- If SIG_GEN_LANE_MODE_G = '1', (jesdClk2x[1:0] domain)
         dacSigCtrl          => dacSigCtrl,
         dacSigStatus        => dacSigStatus,
         dacSigValids        => dacSigValids,
         dacSigValues        => dacSigValues,
         -- AXI-Lite Interface (axilClk domain) 
         axilClk             => axilClk,
         axilRst             => axilRst,
         axilReadMaster      => axilReadMasters(CORE_INDEX_C),
         axilReadSlave       => axilReadSlaves(CORE_INDEX_C),
         axilWriteMaster     => axilWriteMasters(CORE_INDEX_C),
         axilWriteSlave      => axilWriteSlaves(CORE_INDEX_C),
         ----------------------
         -- Top Level Interface
         ----------------------
         -- Timing Interface (timingClk domain)   
         timingClk           => recTimingClk,
         timingRst           => recTimingRst,
         timingBus           => timingBus,
         timingPhy           => timingPhy,
         timingPhyClk        => timingPhyClk,
         timingPhyRst        => timingPhyRst,
         -- Diagnostic Interface (diagnosticClk domain)
         diagnosticClk       => diagnosticClk,
         diagnosticRst       => diagnosticRst,
         diagnosticBus       => diagnosticBus,
         -- Backplane Messaging Interface  (axilClk domain)
         obBpMsgClientMaster => obBpMsgClientMaster,
         obBpMsgClientSlave  => obBpMsgClientSlave,
         ibBpMsgClientMaster => ibBpMsgClientMaster,
         ibBpMsgClientSlave  => ibBpMsgClientSlave,
         obBpMsgServerMaster => obBpMsgServerMaster,
         obBpMsgServerSlave  => obBpMsgServerSlave,
         ibBpMsgServerMaster => ibBpMsgServerMaster,
         ibBpMsgServerSlave  => ibBpMsgServerSlave,
         -- Application Debug Interface (axilClk domain)
         obAppDebugMaster    => obAppDebugMaster,
         obAppDebugSlave     => obAppDebugSlave,
         ibAppDebugMaster    => ibAppDebugMaster,
         ibAppDebugSlave     => ibAppDebugSlave);
         -----------------------
         -- Application Ports --
         -----------------------

end mapping;
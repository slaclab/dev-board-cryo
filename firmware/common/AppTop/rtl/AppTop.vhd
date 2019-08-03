-------------------------------------------------------------------------------
-- File       : AppTop.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2017-02-15
-- Last update: 2017-03-17
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
use work.AxiStreamPkg.all;
use work.AxiLitePkg.all;
use work.AxiPkg.all;
use work.SsiPkg.all;
use work.AmcCarrierPkg.all;
use work.AppTopPkg.all;
use work.AppCorePkg.all;
use work.TimingPkg.all;
use work.Jesd204bPkg.all;

entity AppTop is
   generic (
      TPD_G                  : time                  := 1 ns;
      BUILD_INFO_G           : BuildInfoType;
      XIL_DEVICE_G           : string                := "7SERIES";
      AXIL_CLK_FRQ_G         : real                  := 156.25E6;
      APP_CORE_CONFIG_G      : AppCoreConfigType     := APP_CORE_CONFIG_DFLT_C
   );

   port (
      -- Clock and Reset
      axilClk         : in  sl;
      axilRst         : in  sl;
      -- AXI Memory Interface
      axiClk          : in  sl;
      axiRst          : in  sl;
      axiWriteMaster  : out AxiWriteMasterType;
      axiWriteSlave   : in  AxiWriteSlaveType;
      axiReadMaster   : out AxiReadMasterType;
      axiReadSlave    : in  AxiReadSlaveType;
      -- AXIS interface
      txMasters       : out AxiStreamMasterArray(0 downto 0);
      txSlaves        : in  AxiStreamSlaveArray (0 downto 0);
      rxMasters       : in  AxiStreamMasterArray(0 downto 0);
      rxSlaves        : out AxiStreamSlaveArray (0 downto 0);
      -- Ethernet/IP Addresses
      localMac        : in  slv(47 downto 0); -- big-endian !
      localIp         : in  slv(31 downto 0); -- big-endian !
      -- ADC Ports
      v0PIn           : in  sl;
      v0NIn           : in  sl;
      v2PIn           : in  sl;
      v2NIn           : in  sl;
      v8PIn           : in  sl;
      v8NIn           : in  sl;
      vPIn            : in  sl;
      vNIn            : in  sl;
      muxAddrOut      : out slv(4 downto 0) := (others => '0');

      -- Fan
      fanPwmOut       : out sl := '1';

      -- IIC Port
      iicScl          : inout sl;
      iicSda          : inout sl;

      -- Timing
      timingRefClkP   : in  sl := '0';
      timingRefClkN   : in  sl := '1';
      timingRxP       : in  sl := '0';
      timingRxN       : in  sl := '0';
      timingTxP       : out sl := '0';
      timingTxN       : out sl := '1';

      appTimingClk    : out sl;
      appTimingRst    : out sl;

      gpioDip         : in  slv(3 downto 0);
      appLeds         : out slv(APP_CORE_CONFIG_G.numAppLEDs - 1 downto 0) := (others => '0');
      gpioSmaP        : inout IOLine;
      gpioSmaN        : inout IOLine;
      pmod            : inout PMODArray(1 downto 0)
      );
end AppTop;

architecture mapping of AppTop is

   constant RSSI_SIZE_C     : positive := 4;
   constant RSSI_STRM_CFG_C : AxiStreamConfigArray(RSSI_SIZE_C - 1 downto 0) := (
      others => ETH_AXIS_CONFIG_C
   );

   constant RSSI_ROUTES_C   : Slv8Array(RSSI_SIZE_C - 1 downto 0) := (
      0 => x"04",
      1 => x"02",
      2 => x"03",
      3 => "10------"
   );

   constant NUM_APP_STRMS_C : natural := 2;

   constant N_AXIL_MASTERS_C: natural := 5;

   -- CORE_INDEX_C *MUST* be 0 so that the (exported) APP_CORE_BASE_ADDR_C is valid!
   constant CORE_INDEX_C    : natural := 0;
   constant DAQMUX0_INDEX_C : natural := 1;
   constant DAQMUX1_INDEX_C : natural := 2;
   constant SIGGEN0_INDEX_C : natural := 3;
   constant SIGGEN1_INDEX_C : natural := 4;

   constant AXIL_CONFIG_C   : AxiLiteCrossbarMasterConfigArray(N_AXIL_MASTERS_C - 1 downto 0) :=
      genAxiLiteConfig(N_AXIL_MASTERS_C, x"8000_0000", 31, 28);

   signal axilReadMasters   : AxiLiteReadMasterArray (N_AXIL_MASTERS_C - 1 downto 0);
   signal axilReadSlaves    : AxiLiteReadSlaveArray  (N_AXIL_MASTERS_C - 1 downto 0) := (others => AXI_LITE_READ_SLAVE_EMPTY_DECERR_C);
   signal axilWriteMasters  : AxiLiteWriteMasterArray(N_AXIL_MASTERS_C - 1 downto 0);
   signal axilWriteSlaves   : AxiLiteWriteSlaveArray (N_AXIL_MASTERS_C - 1 downto 0) := (others => AXI_LITE_WRITE_SLAVE_EMPTY_DECERR_C);

   signal mAxilReadMasters  : AxiLiteReadMasterArray (1 downto 0);
   signal mAxilReadSlaves   : AxiLiteReadSlaveArray  (1 downto 0);
   signal mAxilWriteMasters : AxiLiteWriteMasterArray(1 downto 0);
   signal mAxilWriteSlaves  : AxiLiteWriteSlaveArray (1 downto 0);

   signal bsaReadMaster     : AxiLiteReadMasterType;
   signal bsaReadSlave      : AxiLiteReadSlaveType  := AXI_LITE_READ_SLAVE_EMPTY_DECERR_C;
   signal bsaWriteMaster    : AxiLiteWriteMasterType;
   signal bsaWriteSlave     : AxiLiteWriteSlaveType := AXI_LITE_WRITE_SLAVE_EMPTY_DECERR_C;

   signal ethReadMaster     : AxiLiteReadMasterType;
   signal ethReadSlave      : AxiLiteReadSlaveType  := AXI_LITE_READ_SLAVE_EMPTY_DECERR_C;
   signal ethWriteMaster    : AxiLiteWriteMasterType;
   signal ethWriteSlave     : AxiLiteWriteSlaveType := AXI_LITE_WRITE_SLAVE_EMPTY_DECERR_C;

   signal appReadMaster     : AxiLiteReadMasterType;
   signal appReadSlave      : AxiLiteReadSlaveType;
   signal appWriteMaster    : AxiLiteWriteMasterType;
   signal appWriteSlave     : AxiLiteWriteSlaveType;

   signal ibTimingEthMaster : AxiStreamMasterType;
   signal ibTimingEthSlave  : AxiStreamSlaveType;
   signal obTimingEthMaster : AxiStreamMasterType;
   signal obTimingEthSlave  : AxiStreamSlaveType;

   signal obAxisMasters     : AxiStreamMasterArray(NUM_APP_STRMS_C - 1 downto 0);
   signal obAxisSlaves      : AxiStreamSlaveArray (NUM_APP_STRMS_C - 1 downto 0);
   signal ibAxisMasters     : AxiStreamMasterArray(NUM_APP_STRMS_C - 1 downto 0);
   signal ibAxisSlaves      : AxiStreamSlaveArray (NUM_APP_STRMS_C - 1 downto 0);

   signal timingClk         : sl;
   signal timingRst         : sl;

   signal timingTrig        : TimingTrigType;
   signal timingBus         : TimingBusType;

   signal diagnosticClk     : sl;
   signal diagnosticRst     : sl;
   signal diagnosticBus     : DiagnosticBusType;

   signal rssiIbMasters     : AxiStreamMasterArray(RSSI_SIZE_C - 1 downto 0) := (others=>AXI_STREAM_MASTER_INIT_C);
   signal rssiIbSlaves      : AxiStreamSlaveArray (RSSI_SIZE_C - 1 downto 0) := (others=>AXI_STREAM_SLAVE_FORCE_C);
   signal rssiObMasters     : AxiStreamMasterArray(RSSI_SIZE_C - 1 downto 0) := (others=>AXI_STREAM_MASTER_INIT_C);
   signal rssiObSlaves      : AxiStreamSlaveArray (RSSI_SIZE_C - 1 downto 0) := (others=>AXI_STREAM_SLAVE_FORCE_C);

   signal waveformMasters   : WaveformMasterArrayType := WAVEFORM_MASTER_ARRAY_INIT_C;
   signal waveformSlaves    : WaveformSlaveArrayType;

   signal jesdClk           : sl;
   signal jesdRst           : sl;
   signal jesdClk2x         : sl;
   signal jesdRst2x         : sl;
   signal userClk           : sl;
   signal userRst           : sl;

   signal trigCascBay       : slv(2 downto 0);
   signal armCascBay        : slv(2 downto 0);
   signal trigHw            : slv(1 downto 0);
   signal freezeHw          : slv(1 downto 0);

   signal adcValids         : Slv7Array            (1 downto 0) := (others => (others => '0' ) );
   signal adcValues         : sampleDataVectorArray(1 downto 0, 6 downto 0) :=
      (others => (others => (others => '0')));
   signal dacValids         : Slv7Array            (1 downto 0) := (others => (others => '0' ) );
   signal dacValues         : sampleDataVectorArray(1 downto 0, 6 downto 0) :=
         (others => (others => (others => '0')));

   signal debugValids       : Slv4Array            (1 downto 0) := (others => (others => '0' ) );
   signal debugValues       : sampleDataVectorArray(1 downto 0, 3 downto 0) :=
         (others => (others => (others => '0')));


   signal dacSigCtrl        : DacSigCtrlArray      (1 downto 0) := (others => DAC_SIG_CTRL_INIT_C);
   signal dacSigStatus      : DacSigStatusArray    (1 downto 0) := (others => DAC_SIG_STATUS_INIT_C);
   signal dacSigValids      : Slv7Array            (1 downto 0) := (others => (others => '0' ) );
   signal dacSigValues      : sampleDataVectorArray(1 downto 0, 6 downto 0) :=
            (others => (others => (others => '0')));

   component Ila_256 is
      port (
         clk            : in  sl;
--       trig_out       : out sl;
--       trig_out_ack   : in  sl;
--       trig_in        : in  sl;
--       trig_in_ack    : out sl;
         probe0         : in  slv(63 downto 0) := (others => '0');
         probe1         : in  slv(63 downto 0) := (others => '0');
         probe2         : in  slv(63 downto 0) := (others => '0');
         probe3         : in  slv(63 downto 0) := (others => '0')
      );
   end component Ila_256;

   attribute dont_touch : string;
   attribute dont_touch of userClk : signal is "true";

begin

   -- FIXME: keep generate statement so we don't have to worry about constraints ATM
   GEN_ETH : if (true) generate

      --------------------------
      -- UDP Port Mapping Module
      --------------------------
      U_EthPortMapping : entity work.EthPortMapping
         generic map (
            TPD_G           => TPD_G,
            USE_XVC_G       => APP_CORE_CONFIG_G.useXvcJtagBridge,
            DHCP_G          => APP_CORE_CONFIG_G.useDhcp,
            JUMBO_G         => APP_CORE_CONFIG_G.enableEthJumboFrames,
            RSSI_SIZE_G     => RSSI_SIZE_C,
            RSSI_STRM_CFG_G => RSSI_STRM_CFG_C,
            RSSI_ROUTES_G   => RSSI_ROUTES_C,
            UDP_SRV_SIZE_G  => 2,
            UDP_SRV_PORTS_G => (0 => 8197, 1 => 8195),
            UDP_CLT_SIZE_G  => 1,
            UDP_CLT_PORTS_G => (0 => 8196)
         )
         port map (
            -- Clock and Reset
            clk                => axilClk,
            rst                => axilRst,
            localMac           => localMac,
            localIp            => localIp,
            -- AXIS interface
            txMaster           => txMasters(0),
            txSlave            => txSlaves(0),
            rxMaster           => rxMasters(0),
            rxSlave            => rxSlaves(0),
            -- RSSI Interface
            rssiIbMasters      => rssiIbMasters,
            rssiIbSlaves       => rssiIbSlaves,
            rssiObMasters      => rssiObMasters,
            rssiObSlaves       => rssiObSlaves,
            -- UDP Interface
            udpIbSrvMasters(0) => obTimingEthMaster,
            udpIbSrvMasters(1) => obAxisMasters(APP_DEBUG_STRM_C),
            udpIbSrvSlaves(0)  => obTimingEthSlave,
            udpIbSrvSlaves(1)  => obAxisSlaves (APP_DEBUG_STRM_C),
            udpObSrvMasters(0) => ibTimingEthMaster,
            udpObSrvMasters(1) => ibAxisMasters(APP_DEBUG_STRM_C),
            udpObSrvSlaves(0)  => ibTimingEthSlave,
            udpObSrvSlaves(1)  => ibAxisSlaves(APP_DEBUG_STRM_C),

            udpIbCltMasters(0) => obAxisMasters(APP_BPCLT_STRM_C),
            udpIbCltSlaves (0) => obAxisSlaves (APP_BPCLT_STRM_C),
            udpObCltMasters(0) => ibAxisMasters(APP_BPCLT_STRM_C),
            udpObCltSlaves (0) => ibAxisSlaves (APP_BPCLT_STRM_C),
            -- AXI-Lite Master interface
            mAxilWriteMaster   => mAxilWriteMasters(0),
            mAxilWriteSlave    => mAxilWriteSlaves(0),
            mAxilReadMaster    => mAxilReadMasters(0),
            mAxilReadSlave     => mAxilReadSlaves(0),
            -- AXI-Lite Slave interface
            sAxilWriteMaster   => ethWriteMaster,
            sAxilWriteSlave    => ethWriteSlave,
            sAxilReadMaster    => ethReadMaster,
            sAxilReadSlave     => ethReadSlave
         );

      Ila_BsaStream : component Ila_256
         port map (
            clk                  => axilClk,

            probe0(63 downto  0) => rssiObMasters(0).tData (63 downto 0),

            probe1( 7 downto  0) => rssiObMasters(0).tStrb ( 7 downto 0),
            probe1(15 downto  8) => rssiObMasters(0).tKeep ( 7 downto 0),
            probe1(23 downto 16) => rssiObMasters(0).tDest ( 7 downto 0),
            probe1(31 downto 24) => rssiObMasters(0).tId   ( 7 downto 0),
            probe1(60 downto 32) => rssiObMasters(0).tUser (28 downto 0),

            probe1(61          ) => rssiObMasters(0).tLast,
            probe1(62          ) => rssiObMasters(0).tValid,
            probe1(63          ) => rssiObSlaves (0).tReady,

            probe2(63 downto  0) => rssiIbMasters(0).tData (63 downto 0),

            probe3( 7 downto  0) => rssiIbMasters(0).tStrb ( 7 downto 0),
            probe3(15 downto  8) => rssiIbMasters(0).tKeep ( 7 downto 0),
            probe3(23 downto 16) => rssiIbMasters(0).tDest ( 7 downto 0),
            probe3(31 downto 24) => rssiIbMasters(0).tId   ( 7 downto 0),
            probe3(60 downto 32) => rssiIbMasters(0).tUser (28 downto 0),

            probe3(61          ) => rssiIbMasters(0).tLast,
            probe3(62          ) => rssiIbMasters(0).tValid,
            probe3(63          ) => rssiIbSlaves (0).tReady
         );

   end generate;

   U_SimJesdClock : entity work.SimJesdClkGen
      generic map (
         INPT_CLK_FREQ_G    => AXIL_CLK_FRQ_G,
         JESD_CLK_IDIV_G    => APP_CORE_CONFIG_G.jesdClk_IDIV,
         JESD_CLK_MULT_G    => APP_CORE_CONFIG_G.jesdClk_MULT_F,
         JESD_CLK_ODIV_G    => APP_CORE_CONFIG_G.jesdClk_ODIV,
         USER_CLK_ODIV_G    => APP_CORE_CONFIG_G.jesdUsrClk_ODIV
      )
      port map (
         clkIn              => axilClk,
         rstIn              => axilRst,

         userClk            => userClk,
         jesdClk            => jesdClk,
         jesdClk2x          => jesdClk2x,

         userRst            => userRst,
         jesdRst            => jesdRst,
         jesdRst2x          => jesdRst2x
      );

   -------------------
   -- AXI-Lite Modules
   -------------------

   U_Xbar : entity work.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => N_AXIL_MASTERS_C,
         MASTERS_CONFIG_G   => AXIL_CONFIG_C)
      port map (
         axiClk              => axilClk,
         axiClkRst           => axilRst,
         sAxiWriteMasters(0) => appWriteMaster,
         sAxiWriteSlaves(0)  => appWriteSlave,
         sAxiReadMasters(0)  => appReadMaster,
         sAxiReadSlaves(0)   => appReadSlave,
         mAxiWriteMasters    => axilWriteMasters,
         mAxiWriteSlaves     => axilWriteSlaves,
         mAxiReadMasters     => axilReadMasters,
         mAxiReadSlaves      => axilReadSlaves);


   U_Reg : entity work.SysReg
      generic map (
         TPD_G             => TPD_G,
         USE_TIMING_GTH_G  => APP_CORE_CONFIG_G.useTimingGth,
         BUILD_INFO_G      => BUILD_INFO_G,
         XIL_DEVICE_G      => XIL_DEVICE_G,
         AXIL_CLK_FRQ_G    => AXIL_CLK_FRQ_G)
      port map (
         -- Clock and Reset
         clk               => axilClk,
         rst               => axilRst,
         -- AXI-Lite interface
         sAxilWriteMaster  => mAxilWriteMasters,
         sAxilWriteSlave   => mAxilWriteSlaves,
         sAxilReadMaster   => mAxilReadMasters,
         sAxilReadSlave    => mAxilReadSlaves,

         -- AXI-Lite devices
         bsaReadMaster     => bsaReadMaster,
         bsaReadSlave      => bsaReadSlave,
         bsaWriteMaster    => bsaWriteMaster,
         bsaWriteSlave     => bsaWriteSlave,

         ethReadMaster     => ethReadMaster,
         ethReadSlave      => ethReadSlave,
         ethWriteMaster    => ethWriteMaster,
         ethWriteSlave     => ethWriteSlave,

         appReadMaster     => appReadMaster,
         appReadSlave      => appReadSlave,
         appWriteMaster    => appWriteMaster,
         appWriteSlave     => appWriteSlave,

         obTimingEthMaster => obTimingEthMaster,
         obTimingEthSlave  => obTimingEthSlave,
         ibTimingEthMaster => ibTimingEthMaster,
         ibTimingEthSlave  => ibTimingEthSlave,

         -- ADC Ports
         v0PIn             => v0PIn,
         v0NIn             => v0NIn,
         v2PIn             => v2PIn,
         v2NIn             => v2NIn,
         v8PIn             => v8PIn,
         v8NIn             => v8NIn,
         vPIn              => vPIn,
         vNIn              => vNIn,
         muxAddrOut        => muxAddrOut,

         -- Fan
         fanPwmOut         => fanPwmOut,

         -- IIC Port
         iicScl            => iicScl,
         iicSda            => iicSda,

         -- Timing
         timingRefClkP     => timingRefClkP,
         timingRefClkN     => timingRefClkN,
         timingRxP         => timingRxP,
         timingRxN         => timingRxN,
         timingTxP         => timingTxP,
         timingTxN         => timingTxN,

         recTimingClk      => timingClk,
         recTimingRst      => timingRst,

         appTimingClk      => timingClk,
         appTimingRst      => timingRst,

         appTimingBus      => timingBus,
         appTimingTrig     => timingTrig
      );

      U_BSA : entity work.AmcCarrierBsa
         generic map (
            TPD_G                  => TPD_G,
            FSBL_G                 => false,
            WAVEFORM_TDATA_BYTES_G => APP_CORE_CONFIG_G.waveformTdataBytes,
            DISABLE_BSA_G          => APP_CORE_CONFIG_G.disableBSA,
            DISABLE_BLD_G          => APP_CORE_CONFIG_G.disableBLD
         )
         port map (
            -- AXI-Lite Interface (axilClk domain)
            axilClk              => axilClk,
            axilRst              => axilRst,
            axilReadMaster       => bsaReadMaster,
            axilReadSlave        => bsaReadSlave,
            axilWriteMaster      => bsaWriteMaster,
            axilWriteSlave       => bsaWriteSlave,
            -- AXI4 Interface (axiClk domain)
            axiClk               => axiClk,
            axiRst               => axiRst,
            axiWriteMaster       => axiWriteMaster,
            axiWriteSlave        => axiWriteSlave,
            axiReadMaster        => axiReadMaster,
            axiReadSlave         => axiReadSlave,

            -- Ethernet Interface (axilClk domain)
            obBsaMasters         => rssiIbMasters(3 downto 0),
            obBsaSlaves          => rssiIbSlaves (3 downto 0),
            ibBsaMasters         => rssiObMasters(3 downto 0),
            ibBsaSlaves          => rssiObSlaves (3 downto 0),
            ----------------------
            -- Top Level Interface
            ----------------------
            -- Diagnostic Interface
            diagnosticClk        => diagnosticClk,
            diagnosticRst        => diagnosticRst,
            diagnosticBus        => diagnosticBus,
            -- Waveform interface (axiClk domain)
            waveformClk          => axiClk,
            waveformRst          => axiRst,
            obAppWaveformMasters => waveformMasters,
            obAppWaveformSlaves  => waveformSlaves
         );

      trigCascBay(APP_CORE_CONFIG_G.numBays) <= trigCascBay(0);
      armCascBay (APP_CORE_CONFIG_G.numBays) <= armCascBay(0);

      GEN_BAY : for i in APP_CORE_CONFIG_G.numBays - 1 downto 0 generate
         signal linkReady : slv(17 downto 0) := (others => '1');
         signal dataValid : slv(17 downto 0) := (others => '0');
      begin

      U_DaqMuxV2 : entity work.DaqMuxV2
         generic map (
            TPD_G                  => TPD_G,
            DECIMATOR_EN_G         => true,
            WAVEFORM_TDATA_BYTES_G => APP_CORE_CONFIG_G.waveformTdataBytes,
            BAY_INDEX_G            => ite((i = 0), '0', '1'),
            N_DATA_IN_G            => 18,
            N_DATA_OUT_G           => 4)
         port map (
            -- Clocks and Resets
            axiClk              => axilClk,
            axiRst              => axilRst,
            devClk_i            => jesdClk,
            devRst_i            => jesdRst,
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
            axilReadMaster      => axilReadMasters(DAQMUX0_INDEX_C+i),
            axilReadSlave       => axilReadSlaves(DAQMUX0_INDEX_C+i),
            axilWriteMaster     => axilWriteMasters(DAQMUX0_INDEX_C+i),
            axilWriteSlave      => axilWriteSlaves(DAQMUX0_INDEX_C+i),
            -- Sample data input
            sampleDataArr_i(0)  => adcValues(i, 0),
            sampleDataArr_i(1)  => adcValues(i, 1),
            sampleDataArr_i(2)  => adcValues(i, 2),
            sampleDataArr_i(3)  => adcValues(i, 3),
            sampleDataArr_i(4)  => adcValues(i, 4),
            sampleDataArr_i(5)  => adcValues(i, 5),
            sampleDataArr_i(6)  => adcValues(i, 6),
            sampleDataArr_i(7)  => dacValues(i, 0),
            sampleDataArr_i(8)  => dacValues(i, 1),
            sampleDataArr_i(9)  => dacValues(i, 2),
            sampleDataArr_i(10) => dacValues(i, 3),
            sampleDataArr_i(11) => dacValues(i, 4),
            sampleDataArr_i(12) => dacValues(i, 5),
            sampleDataArr_i(13) => dacValues(i, 6),
            sampleDataArr_i(14) => debugValues(i, 0),
            sampleDataArr_i(15) => debugValues(i, 1),
            sampleDataArr_i(16) => debugValues(i, 2),
            sampleDataArr_i(17) => debugValues(i, 3),
            sampleValidVec_i    => dataValid,
            linkReadyVec_i      => linkReady,
            -- Output AXI Streaming Interface (Has to be synced with waveform clk)
            wfClk_i             => axiClk,
            wfRst_i             => axiRst,
            rxAxisMasterArr_o   => waveformMasters(i),
            rxAxisSlaveArr_i(0) => waveformSlaves(i)(0).slave,
            rxAxisSlaveArr_i(1) => waveformSlaves(i)(1).slave,
            rxAxisSlaveArr_i(2) => waveformSlaves(i)(2).slave,
            rxAxisSlaveArr_i(3) => waveformSlaves(i)(3).slave,
            rxAxisCtrlArr_i(0)  => waveformSlaves(i)(0).ctrl,
            rxAxisCtrlArr_i(1)  => waveformSlaves(i)(1).ctrl,
            rxAxisCtrlArr_i(2)  => waveformSlaves(i)(2).ctrl,
            rxAxisCtrlArr_i(3)  => waveformSlaves(i)(3).ctrl
      );

      dataValid <= debugValids(i) & dacValids(i) & adcValids(i);
      linkReady <= x"F" & dacValids(i) & adcValids(i);

      U_DacSigGen : entity work.DacSigGen
         generic map (
            TPD_G                => TPD_G,
            AXI_BASE_ADDR_G      => AXIL_CONFIG_C(SIGGEN0_INDEX_C+i).baseAddr,
            SIG_GEN_SIZE_G       => APP_CORE_CONFIG_G.numSigGenerators(i),
            SIG_GEN_ADDR_WIDTH_G => APP_CORE_CONFIG_G.sigGenAddrWidth(i),
            SIG_GEN_LANE_MODE_G  => APP_CORE_CONFIG_G.sigGenLaneMode(i),
            SIG_GEN_RAM_CLK_G    => APP_CORE_CONFIG_G.sigGenRamClk(i)
         )
         port map (
            -- DAC Signal Generator Interface
            jesdClk         => jesdClk,
            jesdRst         => jesdRst,
            jesdClk2x       => jesdClk2x,
            jesdRst2x       => jesdRst2x,
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
            -- AXI-Lite Interface
            axilClk         => axilClk,
            axilRst         => axilRst,
            axilReadMaster  => axilReadMasters(SIGGEN0_INDEX_C+i),
            axilReadSlave   => axilReadSlaves(SIGGEN0_INDEX_C+i),
            axilWriteMaster => axilWriteMasters(SIGGEN0_INDEX_C+i),
            axilWriteSlave  => axilWriteSlaves(SIGGEN0_INDEX_C+i)
         );

      end generate;

      GEN_NO_BAY1 : if (APP_CORE_CONFIG_G.numBays = 1) generate
         waveformMasters(1) <= WAVEFORM_MASTER_ARRAY_INIT_C(1);
      end generate;

      U_AppCore : entity work.AppCore
         generic map (
            TPD_G               => TPD_G,
            XIL_DEVICE_G        => XIL_DEVICE_G,
            AXIL_CLK_FRQ_G      => AXIL_CLK_FRQ_G,
            AXIL_BASE_ADDR_G    => AXIL_CONFIG_C(CORE_INDEX_C).baseAddr,
            APP_CORE_CONFIG_G   => APP_CORE_CONFIG_G
         )
         port map (
            -- Clock and Reset
            axilClk             => axilClk,
            axilRst             => axilRst,
            -- AXI-Lite interface
            sAxilWriteMaster    => axilWriteMasters( CORE_INDEX_C ),
            sAxilWriteSlave     => axilWriteSlaves ( CORE_INDEX_C ),
            sAxilReadMaster     => axilReadMasters ( CORE_INDEX_C ),
            sAxilReadSlave      => axilReadSlaves  ( CORE_INDEX_C ),

            mAxilWriteMaster    => mAxilWriteMasters(1),
            mAxilWriteSlave     => mAxilWriteSlaves(1),
            mAxilReadMaster     => mAxilReadMasters(1),
            mAxilReadSlave      => mAxilReadSlaves(1),

            -- Streams
            obAxisMasters       => obAxisMasters,
            obAxisSlaves        => obAxisSlaves,
            ibAxisMasters       => ibAxisMasters,
            ibAxisSlaves        => ibAxisSlaves,

            -- Timing Interface
            timingClk           => timingClk,
            timingRst           => timingRst,
            timingBus           => timingBus,
            timingTrig          => timingTrig,

            -- Diagnostic Interface
            diagnosticClk       => diagnosticClk,
            diagnosticRst       => diagnosticRst,
            diagnosticBus       => diagnosticBus,

            -- JESD
            jesdClk(0)          => jesdClk,
            jesdClk(1)          => jesdClk,
            jesdRst(0)          => jesdRst,
            jesdRst(1)          => jesdRst,
            jesdClk2x(0)        => jesdClk2x,
            jesdClk2x(1)        => jesdClk2x,
            jesdRst2x(0)        => jesdRst2x,
            jesdRst2x(1)        => jesdRst2x,
            jesdUsrClk(0)       => userClk,
            jesdUsrClk(1)       => userClk,
            jesdUsrRst(0)       => userRst,
            jesdUsrRst(1)       => userRst,

            freezeHw            => freezeHw,
            trigHw              => trigHw,
            trigCascBay         => trigCascBay(1 downto 0),

            adcValids           => adcValids,
            adcValues           => adcValues,
            dacValids           => dacValids,
            dacValues           => dacValues,
            debugValids         => debugValids,
            debugValues         => debugValues,

            dacSigCtrl          => dacSigCtrl,
            dacSigStatus        => dacSigStatus,
            dacSigValids        => dacSigValids,
            dacSigValues        => dacSigValues,

            gpioDip             => gpioDip,
            appLeds             => appLeds,

            gpioSmaP            => gpioSmaP,
            gpioSmaN            => gpioSmaN,
            pmod                => pmod
         );

      GEN_SMA_P_TRIG : if ( APP_CORE_CONFIG_G.smaPTrigger <= timingTrig.trigPulse'high
                           and
                            APP_CORE_CONFIG_G.smaPTrigger >= timingTrig.trigPulse'low ) generate
         gpioSmaP.i <= timingTrig.trigPulse( APP_CORE_CONFIG_G.smaPTrigger );
         gpioSmaP.t <= '0';
      end generate;

      GEN_SMA_N_TRIG : if ( APP_CORE_CONFIG_G.smaNTrigger <= timingTrig.trigPulse'high
                           and
                            APP_CORE_CONFIG_G.smaNTrigger >= timingTrig.trigPulse'low ) generate
         gpioSmaN.i <= timingTrig.trigPulse( APP_CORE_CONFIG_G.smaNTrigger );
         gpioSmaN.t <= '0';
      end generate;


      -- For now just loop back
      adcValids        <= dacValids;
      adcValues        <= dacValues;

      appTimingClk     <= timingClk;
      appTimingRst     <= timingRst;

--      rssiIbMasters(4)                <= obAxisMasters(APP_DEBUG_STRM_C);
--      obAxisSlaves (APP_DEBUG_STRM_C) <= rssiIbSlaves (4);
--      ibAxisMasters(APP_DEBUG_STRM_C) <= rssiObMasters(4);
--      rssiObSlaves (4)                <= ibAxisSlaves(APP_DEBUG_STRM_C);

end mapping;

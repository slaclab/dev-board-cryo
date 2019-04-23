-------------------------------------------------------------------------------
-- File       : Zcu111DevBoard.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2015-04-08
-- Last update: 2019-04-23
-------------------------------------------------------------------------------
-- Description: Example using 1000BASE-SX Protocol
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
use work.SsiPkg.all;
use work.AxiLitePkg.all;
use work.AxiPkg.all;
use work.TimingPkg.all;
use work.AmcCarrierPkg.all;

library unisim;
use unisim.vcomponents.all;

entity Zcu111DevBoard is
   generic (
      TPD_G        : time := 1 ns;
      BUILD_INFO_G : BuildInfoType);
   port (
      -----------------------
      -- Application Ports --
      -----------------------

      ----------------
      -- Core Ports --
      ----------------   
      -- Common Fabricate Clock
      fabClkP          : in    sl;
      fabClkN          : in    sl;
      extRst           : in    sl;
      led              : out   slv(7 downto 0);
      -- SFP Ports
      sfpRxP           : in    slv(3 downto 0);
      sfpRxN           : in    slv(3 downto 0);
      sfpTxP           : out   slv(3 downto 0);
      sfpTxN           : out   slv(3 downto 0);
      sfpTxEnable      : out   slv(3 downto 0) := (others => '1');
      -- Ethernet Ports
      ethClkP          : in    sl;
      ethClkN          : in    sl;
      -- LCLS Timing Ports
      timingRefClkInP  : in    sl;
      timingRefClkInN  : in    sl;
      timingClkScl     : inout sl;
      timingClkSda     : inout sl;
      -- IPMC Ports
      ipmcScl          : inout sl;
      ipmcSda          : inout sl;
      -- Configuration PROM Ports
      calScl           : inout sl;
      calSda           : inout sl;
      -- DDR4 Ports
      c0_sys_clk_p     : in    sl;
      c0_sys_clk_n     : in    sl;
      c0_ddr4_adr      : out   slv(16 downto 0);
      c0_ddr4_ba       : out   slv(1 downto 0);
      c0_ddr4_cke      : out   slv(0 downto 0);
      c0_ddr4_cs_n     : out   slv(0 downto 0);
      c0_ddr4_dm_dbi_n : inout slv(7 downto 0);
      c0_ddr4_dq       : inout slv(63 downto 0);
      c0_ddr4_dqs_c    : inout slv(7 downto 0);
      c0_ddr4_dqs_t    : inout slv(7 downto 0);
      c0_ddr4_odt      : out   slv(0 downto 0);
      c0_ddr4_bg       : out   slv(0 downto 0);
      c0_ddr4_reset_n  : out   sl;
      c0_ddr4_act_n    : out   sl;
      c0_ddr4_ck_c     : out   slv(0 downto 0);
      c0_ddr4_ck_t     : out   slv(0 downto 0);
      ddrScl           : inout sl;
      ddrSda           : inout sl;
      -- SYSMON Ports
      vPIn             : in    sl;
      vNIn             : in    sl);
end Zcu111DevBoard;

architecture top_level of Zcu111DevBoard is

   constant WAVEFORM_TDATA_BYTES_C : positive := 8;

   signal axiClk         : sl;
   signal axiRst         : sl;
   signal axiWriteMaster : AxiWriteMasterType;
   signal axiWriteSlave  : AxiWriteSlaveType;
   signal axiReadMaster  : AxiReadMasterType;
   signal axiReadSlave   : AxiReadSlaveType;

   signal obBsaMasters : AxiStreamMasterArray(3 downto 0);
   signal obBsaSlaves  : AxiStreamSlaveArray(3 downto 0);
   signal ibBsaMasters : AxiStreamMasterArray(3 downto 0);
   signal ibBsaSlaves  : AxiStreamSlaveArray(3 downto 0);

   signal obTimingEthMsgMaster  : AxiStreamMasterType;
   signal obTimingEthMsgSlave   : AxiStreamSlaveType;
   signal ibTimingEthMsgMaster  : AxiStreamMasterType;
   signal ibTimingEthMsgSlave   : AxiStreamSlaveType;
   signal intTimingEthMsgMaster : AxiStreamMasterType;
   signal intTimingEthMsgSlave  : AxiStreamSlaveType;

   signal axilReadMasters  : AxiLiteReadMasterArray(1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(1 downto 0);
   signal axilWriteMasters : AxiLiteWriteMasterArray(1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(1 downto 0);

   signal ethReadMaster  : AxiLiteReadMasterType;
   signal ethReadSlave   : AxiLiteReadSlaveType;
   signal ethWriteMaster : AxiLiteWriteMasterType;
   signal ethWriteSlave  : AxiLiteWriteSlaveType;
   signal efuse          : slv(31 downto 0);
   signal localMac       : slv(47 downto 0);
   signal ethLinkUp      : sl;

   signal timingTrig        : TimingTrigType;
   signal timingReadMaster  : AxiLiteReadMasterType;
   signal timingReadSlave   : AxiLiteReadSlaveType;
   signal timingWriteMaster : AxiLiteWriteMasterType;
   signal timingWriteSlave  : AxiLiteWriteSlaveType;

   signal bsaReadMaster  : AxiLiteReadMasterType;
   signal bsaReadSlave   : AxiLiteReadSlaveType;
   signal bsaWriteMaster : AxiLiteWriteMasterType;
   signal bsaWriteSlave  : AxiLiteWriteSlaveType;

   signal ddrReadMaster  : AxiLiteReadMasterType;
   signal ddrReadSlave   : AxiLiteReadSlaveType;
   signal ddrWriteMaster : AxiLiteWriteMasterType;
   signal ddrWriteSlave  : AxiLiteWriteSlaveType;
   signal ddrMemReady    : sl;
   signal ddrMemError    : sl;

   signal mpsReadMaster  : AxiLiteReadMasterType;
   signal mpsReadSlave   : AxiLiteReadSlaveType  := AXI_LITE_READ_SLAVE_EMPTY_DECERR_C;
   signal mpsWriteMaster : AxiLiteWriteMasterType;
   signal mpsWriteSlave  : AxiLiteWriteSlaveType := AXI_LITE_WRITE_SLAVE_EMPTY_DECERR_C;

   signal axilClk         : sl;
   signal axilRst         : sl;
   signal axilReadMaster  : AxiLiteReadMasterType;
   signal axilReadSlave   : AxiLiteReadSlaveType;
   signal axilWriteMaster : AxiLiteWriteMasterType;
   signal axilWriteSlave  : AxiLiteWriteSlaveType;

   signal timingClk        : sl;
   signal timingRst        : sl;
   signal timingBus        : TimingBusType;
   signal timingPhy        : TimingPhyType;
   signal timingPhyClk     : sl;
   signal timingPhyRst     : sl;
   signal timingRefClk     : sl;
   signal timingRefClkDiv2 : sl;

   signal diagnosticClk : sl;
   signal diagnosticRst : sl;
   signal diagnosticBus : DiagnosticBusType;

   signal obAppWaveformMasters : WaveformMasterArrayType;
   signal obAppWaveformSlaves  : WaveformSlaveArrayType;
   signal ibAppWaveformMasters : WaveformMasterArrayType;
   signal ibAppWaveformSlaves  : WaveformSlaveArrayType;

   signal obBpMsgClientMaster : AxiStreamMasterType;
   signal obBpMsgClientSlave  : AxiStreamSlaveType;
   signal ibBpMsgClientMaster : AxiStreamMasterType;
   signal ibBpMsgClientSlave  : AxiStreamSlaveType;
   signal obBpMsgServerMaster : AxiStreamMasterType;
   signal obBpMsgServerSlave  : AxiStreamSlaveType;
   signal ibBpMsgServerMaster : AxiStreamMasterType;
   signal ibBpMsgServerSlave  : AxiStreamSlaveType;

   signal obAppDebugMaster : AxiStreamMasterType;
   signal obAppDebugSlave  : AxiStreamSlaveType;
   signal ibAppDebugMaster : AxiStreamMasterType;
   signal ibAppDebugSlave  : AxiStreamSlaveType;

   signal recTimingClk : sl;
   signal recTimingRst : sl;
   signal fabClock     : sl;
   signal fabClk       : sl;
   signal fabRst       : sl;
   signal reset        : sl;

begin

   led(7) <= extRst;
   led(6) <= ethLinkUp;
   led(5) <= not(fabRst);
   led(4) <= not(axilRst);
   led(3) <= not(axiRst);
   led(2) <= not(diagnosticRst);
   led(1) <= not(timingRst);
   led(0) <= not(recTimingRst);

   U_TERM_GTs : entity work.Gtye4ChannelDummy
      generic map (
         TPD_G   => TPD_G,
         WIDTH_G => 2)
      port map (
         refClk => fabClk,
         gtRxP  => sfpRxP(3 downto 2),
         gtRxN  => sfpRxN(3 downto 2),
         gtTxP  => sfpTxP(3 downto 2),
         gtTxN  => sfpTxN(3 downto 2));

   U_AppTop : entity work.AppTop
      generic map (
         TPD_G                  => TPD_G,
         DAQMUX_DECIMATOR_EN_G  => false,  -- Configured by application
         MR_LCLS_APP_G          => false,  -- Configured by application
         WAVEFORM_TDATA_BYTES_G => WAVEFORM_TDATA_BYTES_C,
         -- Signal Generator Generics
         SIG_GEN_SIZE_G         => (0 => 2, 1 => 2),  -- Configured by application
         SIG_GEN_ADDR_WIDTH_G   => (others => 13),  -- Configured by application
         SIG_GEN_LANE_MODE_G    => (others => "0000000000"),  -- '0': 32 bit mode
         SIG_GEN_RAM_CLK_G      => (others => "1111111111"))  -- '1': RAM using jesdClk (not jesdClk2x)         
      port map (
         ----------------------
         -- Top Level Interface
         ----------------------
         -- AXI-Lite Interface (axilClk domain)
         axilClk              => axilClk,
         axilRst              => axilRst,
         axilReadMaster       => axilReadMaster,
         axilReadSlave        => axilReadSlave,
         axilWriteMaster      => axilWriteMaster,
         axilWriteSlave       => axilWriteSlave,
         -- Timing Interface (timingClk domain) 
         timingClk            => timingClk,
         timingRst            => timingRst,
         timingBus            => timingBus,
         timingPhy            => timingPhy,
         timingPhyClk         => timingPhyClk,
         timingPhyRst         => timingPhyRst,
         timingTrig           => timingTrig,
         -- Diagnostic Interface (diagnosticClk domain)
         diagnosticClk        => diagnosticClk,
         diagnosticRst        => diagnosticRst,
         diagnosticBus        => diagnosticBus,
         -- Waveform interface (waveformClk domain)
         waveformClk          => axiClk,
         waveformRst          => axiRst,
         obAppWaveformMasters => obAppWaveformMasters,
         obAppWaveformSlaves  => obAppWaveformSlaves,
         ibAppWaveformMasters => ibAppWaveformMasters,
         ibAppWaveformSlaves  => ibAppWaveformSlaves,
         -- Backplane Messaging Interface  (axilClk domain)
         obBpMsgClientMaster  => obBpMsgClientMaster,
         obBpMsgClientSlave   => obBpMsgClientSlave,
         ibBpMsgClientMaster  => ibBpMsgClientMaster,
         ibBpMsgClientSlave   => ibBpMsgClientSlave,
         obBpMsgServerMaster  => obBpMsgServerMaster,
         obBpMsgServerSlave   => obBpMsgServerSlave,
         ibBpMsgServerMaster  => ibBpMsgServerMaster,
         ibBpMsgServerSlave   => ibBpMsgServerSlave,
         -- Application Debug Interface (axilClk domain)
         obAppDebugMaster     => obAppDebugMaster,
         obAppDebugSlave      => obAppDebugSlave,
         ibAppDebugMaster     => ibAppDebugMaster,
         ibAppDebugSlave      => ibAppDebugSlave,
         -- Reference Clocks and Resets
         recTimingClk         => recTimingClk,
         recTimingRst         => recTimingRst);
   -----------------------
   -- Application Ports --
   -----------------------

   --------------------------------
   -- Common Clock and Reset Module
   -------------------------------- 
   U_IBUFDS : IBUFDS
      port map (
         I  => fabClkP,
         IB => fabClkN,
         O  => fabClock);

   U_BUFG : BUFG
      port map (
         I => fabClock,
         O => fabClk);

   U_PwrUpRst : entity work.PwrUpRst
      generic map(
         TPD_G => TPD_G)
      port map(
         clk    => fabClk,
         arst   => extRst,
         rstOut => fabRst);

   U_AmcCorePll : entity work.ClockManagerUltraScale
      generic map(
         TPD_G             => TPD_G,
         TYPE_G            => "PLL",
         INPUT_BUFG_G      => false,
         FB_BUFG_G         => true,
         RST_IN_POLARITY_G => '1',
         NUM_CLOCKS_G      => 1,
         -- MMCM attributes
         CLKIN_PERIOD_G    => 8.0,      -- 125 MHz
         CLKFBOUT_MULT_G   => 10,       -- 1.25 GHz
         CLKOUT0_DIVIDE_G  => 8)        -- 156.25 MHz
      port map(
         -- Clock Input
         clkIn     => fabClk,
         rstIn     => fabRst,
         -- Clock Outputs
         clkOut(0) => axilClk,
         -- Reset Outputs
         rstOut(0) => reset);

   -- Help with meeting timing on the reset path
   U_Rst : entity work.RstPipeline
      generic map (
         TPD_G => TPD_G)
      port map (
         clk    => axilClk,
         rstIn  => reset,
         rstOut => axilRst);

   ----------------------------------   
   -- Register Address Mapping Module
   ----------------------------------   
   U_SysReg : entity work.AmcCarrierSysReg
      generic map (
         TPD_G        => TPD_G,
         BUILD_INFO_G => BUILD_INFO_G,
         APP_TYPE_G   => APP_NULL_TYPE_C,
         MPS_SLOT_G   => false,
         FSBL_G       => false)
      port map (
         -- Primary AXI-Lite Interface
         axilClk           => axilClk,
         axilRst           => axilRst,
         sAxilReadMasters  => axilReadMasters,
         sAxilReadSlaves   => axilReadSlaves,
         sAxilWriteMasters => axilWriteMasters,
         sAxilWriteSlaves  => axilWriteSlaves,
         -- Timing AXI-Lite Interface
         timingReadMaster  => timingReadMaster,
         timingReadSlave   => timingReadSlave,
         timingWriteMaster => timingWriteMaster,
         timingWriteSlave  => timingWriteSlave,
         -- Bsa AXI-Lite Interface
         bsaReadMaster     => bsaReadMaster,
         bsaReadSlave      => bsaReadSlave,
         bsaWriteMaster    => bsaWriteMaster,
         bsaWriteSlave     => bsaWriteSlave,
         -- ETH AXI-Lite Interface
         ethReadMaster     => ethReadMaster,
         ethReadSlave      => ethReadSlave,
         ethWriteMaster    => ethWriteMaster,
         ethWriteSlave     => ethWriteSlave,
         -- DDR PHY AXI-Lite Interface
         ddrReadMaster     => ddrReadMaster,
         ddrReadSlave      => ddrReadSlave,
         ddrWriteMaster    => ddrWriteMaster,
         ddrWriteSlave     => ddrWriteSlave,
         ddrMemReady       => ddrMemReady,
         ddrMemError       => ddrMemError,
         -- MPS PHY AXI-Lite Interface
         mpsReadMaster     => mpsReadMaster,
         mpsReadSlave      => mpsReadSlave,
         mpsWriteMaster    => mpsWriteMaster,
         mpsWriteSlave     => mpsWriteSlave,
         -- Local Configuration
         ethLinkUp         => ethLinkUp,
         ----------------------
         -- Top Level Interface
         ----------------------              
         -- Application AXI-Lite Interface
         appReadMaster     => axilReadMaster,
         appReadSlave      => axilReadSlave,
         appWriteMaster    => axilWriteMaster,
         appWriteSlave     => axilWriteSlave,
         ----------------
         -- Core Ports --
         ----------------   
         -- IPMC Ports
         ipmcScl           => ipmcScl,
         ipmcSda           => ipmcSda,
         -- Configuration PROM Ports
         calScl            => calScl,
         calSda            => calSda,
         -- Clock Cleaner Ports
         timingClkScl      => timingClkScl,
         timingClkSda      => timingClkSda,
         -- DDR Ports
         ddrScl            => ddrScl,
         ddrSda            => ddrSda,
         -- SYSMON Ports
         vPIn              => vPIn,
         vNIn              => vNIn);

   U_EFuse : EFUSE_USR
      port map (
         EFUSEUSR => efuse);

   localMac(23 downto 0)  <= x"56_00_08";  -- 08:00:56:XX:XX:XX (big endian SLV)   
   localMac(47 downto 24) <= efuse(31 downto 8);

   ------------------
   -- Ethernet Module
   ------------------
   U_Eth : entity work.AmcCarrierEth
      generic map (
         TPD_G                 => TPD_G,
         -- ETH_SPEED_G           => true,        -- false: 1GbE, true: 10GbE
         ETH_SPEED_G           => false,        -- false: 1GbE, true: 10GbE
         DHCP_G                => false,
         RSSI_ILEAVE_EN_G      => true,
         ETH_USR_FRAME_LIMIT_G => 9000)
      port map (
         -- Local Configuration
         localMac             => localMac,
         localIp              => x"0A02A8C0",  -- Set the default IP address before DHCP: 192.168.2.10 = x"0A02A8C0"
         ethPhyReady          => ethLinkUp,
         -- Master AXI-Lite Interface
         mAxilReadMasters     => axilReadMasters,
         mAxilReadSlaves      => axilReadSlaves,
         mAxilWriteMasters    => axilWriteMasters,
         mAxilWriteSlaves     => axilWriteSlaves,
         -- AXI-Lite Interface
         axilClk              => axilClk,
         axilRst              => axilRst,
         axilReadMaster       => ethReadMaster,
         axilReadSlave        => ethReadSlave,
         axilWriteMaster      => ethWriteMaster,
         axilWriteSlave       => ethWriteSlave,
         -- BSA Ethernet Interface
         obBsaMasters         => obBsaMasters,
         obBsaSlaves          => obBsaSlaves,
         ibBsaMasters         => ibBsaMasters,
         ibBsaSlaves          => ibBsaSlaves,
         -- Timing ETH MSG Interface
         obTimingEthMsgMaster => obTimingEthMsgMaster,
         obTimingEthMsgSlave  => obTimingEthMsgSlave,
         ibTimingEthMsgMaster => ibTimingEthMsgMaster,
         ibTimingEthMsgSlave  => ibTimingEthMsgSlave,
         ----------------------
         -- Top Level Interface
         ----------------------
         -- Application Debug Interface
         obAppDebugMaster     => obAppDebugMaster,
         obAppDebugSlave      => obAppDebugSlave,
         ibAppDebugMaster     => ibAppDebugMaster,
         ibAppDebugSlave      => ibAppDebugSlave,
         -- Backplane Messaging Interface
         obBpMsgClientMaster  => obBpMsgClientMaster,
         obBpMsgClientSlave   => obBpMsgClientSlave,
         ibBpMsgClientMaster  => ibBpMsgClientMaster,
         ibBpMsgClientSlave   => ibBpMsgClientSlave,
         obBpMsgServerMaster  => obBpMsgServerMaster,
         obBpMsgServerSlave   => obBpMsgServerSlave,
         ibBpMsgServerMaster  => ibBpMsgServerMaster,
         ibBpMsgServerSlave   => ibBpMsgServerSlave,
         ----------------
         -- Core Ports --
         ----------------   
         -- ETH Ports
         ethRxP               => sfpRxP(0),
         ethRxN               => sfpRxN(0),
         ethTxP               => sfpTxP(0),
         ethTxN               => sfpTxN(0),
         ethClkP              => ethClkP,
         ethClkN              => ethClkN);

   --------------
   -- Timing Core
   --------------
   U_Timing : entity work.AmcCarrierTiming
      generic map (
         TPD_G             => TPD_G,
         TIME_GEN_APP_G    => false,
         TIME_GEN_EXTREF_G => false,
         DISABLE_TIME_GT_G => false,
         CORE_TRIGGERS_G   => 16,
         TRIG_PIPE_G       => 0,
         STREAM_L1_G       => true)
      port map (
         stableClk            => fabClk,
         stableRst            => fabRst,
         -- AXI-Lite Interface (axilClk domain)
         axilClk              => axilClk,
         axilRst              => axilRst,
         axilReadMaster       => timingReadMaster,
         axilReadSlave        => timingReadSlave,
         axilWriteMaster      => timingWriteMaster,
         axilWriteSlave       => timingWriteSlave,
         -- Timing ETH MSG Interface (axilClk domain)
         obTimingEthMsgMaster => intTimingEthMsgMaster,
         obTimingEthMsgSlave  => intTimingEthMsgSlave,
         ibTimingEthMsgMaster => ibTimingEthMsgMaster,
         ibTimingEthMsgSlave  => ibTimingEthMsgSlave,
         ----------------------
         -- Top Level Interface
         ----------------------         
         -- Timing Interface 
         recTimingClk         => recTimingClk,
         recTimingRst         => recTimingRst,
         appTimingClk         => timingClk,
         appTimingRst         => timingRst,
         appTimingBus         => timingBus,
         appTimingTrig        => timingTrig,
         appTimingPhy         => timingPhy,
         appTimingPhyClk      => timingPhyClk,
         appTimingPhyRst      => timingPhyRst,
         appTimingRefClk      => timingRefClk,
         appTimingRefClkDiv2  => timingRefClkDiv2,
         ----------------
         -- Core Ports --
         ----------------   
         -- LCLS Timing Ports
         timingRxP            => sfpRxP(1),
         timingRxN            => sfpRxN(1),
         timingTxP            => sfpTxP(1),
         timingTxN            => sfpTxN(1),
         timingRefClkInP      => timingRefClkInP,
         timingRefClkInN      => timingRefClkInN,
         timingRecClkOutP     => open,
         timingRecClkOutN     => open,
         timingClkSel         => open);

   --------------
   -- BSA Core
   --------------
   U_Bsa : entity work.AmcCarrierBsa
      generic map (
         TPD_G                  => TPD_G,
         FSBL_G                 => false,
         DISABLE_BSA_G          => true,
         DISABLE_BLD_G          => true,
         DISABLE_DDR_SRP_G      => true,
         WAVEFORM_TDATA_BYTES_G => WAVEFORM_TDATA_BYTES_C)
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
         obBsaMasters         => obBsaMasters,
         obBsaSlaves          => obBsaSlaves,
         ibBsaMasters         => ibBsaMasters,
         ibBsaSlaves          => ibBsaSlaves,
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
         obAppWaveformMasters => obAppWaveformMasters,
         obAppWaveformSlaves  => obAppWaveformSlaves,
         -- Timing ETH MSG Interface (axilClk domain)
         ibEthMsgMaster       => intTimingEthMsgMaster,
         ibEthMsgSlave        => intTimingEthMsgSlave,
         obEthMsgMaster       => obTimingEthMsgMaster,
         obEthMsgSlave        => obTimingEthMsgSlave);

   ------------------
   -- DDR Memory Core
   ------------------
   U_DdrMem : entity work.AmcCarrierDdrMem
      generic map (
         TPD_G  => TPD_G,
         -- FSBL_G => false)
         FSBL_G => true)
      port map (
         -- AXI-Lite Interface
         axilClk          => axilClk,
         axilRst          => axilRst,
         axilReadMaster   => ddrReadMaster,
         axilReadSlave    => ddrReadSlave,
         axilWriteMaster  => ddrWriteMaster,
         axilWriteSlave   => ddrWriteSlave,
         memReady         => ddrMemReady,
         memError         => ddrMemError,
         -- AXI4 Interface
         axiClk           => axiClk,
         axiRst           => axiRst,
         axiWriteMaster   => axiWriteMaster,
         axiWriteSlave    => axiWriteSlave,
         axiReadMaster    => axiReadMaster,
         axiReadSlave     => axiReadSlave,
         ----------------
         -- Core Ports --
         ----------------   
         -- DDR4 Ports
         c0_sys_clk_p     => c0_sys_clk_p,
         c0_sys_clk_n     => c0_sys_clk_n,
         c0_ddr4_adr      => c0_ddr4_adr,
         c0_ddr4_ba       => c0_ddr4_ba,
         c0_ddr4_cke      => c0_ddr4_cke,
         c0_ddr4_cs_n     => c0_ddr4_cs_n,
         c0_ddr4_dm_dbi_n => c0_ddr4_dm_dbi_n,
         c0_ddr4_dq       => c0_ddr4_dq,
         c0_ddr4_dqs_c    => c0_ddr4_dqs_c,
         c0_ddr4_dqs_t    => c0_ddr4_dqs_t,
         c0_ddr4_odt      => c0_ddr4_odt,
         c0_ddr4_bg       => c0_ddr4_bg,
         c0_ddr4_reset_n  => c0_ddr4_reset_n,
         c0_ddr4_act_n    => c0_ddr4_act_n,
         c0_ddr4_ck_c     => c0_ddr4_ck_c,
         c0_ddr4_ck_t     => c0_ddr4_ck_t);

end top_level;

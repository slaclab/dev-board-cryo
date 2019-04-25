-------------------------------------------------------------------------------
-- File       : AppCore.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2017-02-04
-- Last update: 2019-04-19
-------------------------------------------------------------------------------
-- Description: Application Core's Top Level
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
use work.I2cPkg.all;

entity AppCore is
   generic (
      TPD_G           : time             := 1 ns;
      SIM_SPEEDUP_G   : boolean          := false;
      SIMULATION_G    : boolean          := false;
      AXI_BASE_ADDR_G : slv(31 downto 0) := x"80000000");
   port (
      -- Clocks and resets   
      jesdClk             : out slv(1 downto 0);
      jesdRst             : out slv(1 downto 0);
      jesdClk2x           : out slv(1 downto 0);
      jesdRst2x           : out slv(1 downto 0);
      jesdUsrClk          : out slv(1 downto 0);
      jesdUsrRst          : out slv(1 downto 0);
      -- DaqMux/Trig Interface (timingClk domain) 
      freezeHw            : out slv(1 downto 0);
      timingTrig          : in  TimingTrigType;
      trigHw              : out slv(1 downto 0);
      trigCascBay         : in  slv(1 downto 0);
      -- ADC/DAC/Debug Interface (jesdClk[1:0] domain)
      adcValids           : out Slv10Array(1 downto 0);
      adcValues           : out sampleDataVectorArray(1 downto 0, 9 downto 0);
      dacValids           : out Slv10Array(1 downto 0);
      dacValues           : out sampleDataVectorArray(1 downto 0, 9 downto 0);
      debugValids         : out Slv4Array(1 downto 0);
      debugValues         : out sampleDataVectorArray(1 downto 0, 3 downto 0);
      -- DAC Signal Generator Interface
      -- If SIG_GEN_LANE_MODE_G = '0', (jesdClk[1:0] domain)
      -- If SIG_GEN_LANE_MODE_G = '1', (jesdClk2x[1:0] domain)
      dacSigCtrl          : out DacSigCtrlArray(1 downto 0);
      dacSigStatus        : in  DacSigStatusArray(1 downto 0);
      dacSigValids        : in  Slv10Array(1 downto 0);
      dacSigValues        : in  sampleDataVectorArray(1 downto 0, 9 downto 0);
      -- AXI-Lite Interface (axilClk domain) [0x8FFFFFFF:0x80000000]
      axilClk             : in  sl;
      axilRst             : in  sl;
      axilReadMaster      : in  AxiLiteReadMasterType;
      axilReadSlave       : out AxiLiteReadSlaveType;
      axilWriteMaster     : in  AxiLiteWriteMasterType;
      axilWriteSlave      : out AxiLiteWriteSlaveType;
      ----------------------
      -- Top Level Interface
      ----------------------
      -- IIC
      iicScl              : inout slv(1 downto 0);
      iicSda              : inout slv(1 downto 0);
      -- Timing Interface (timingClk domain) 
      timingClk           : in  sl;
      timingRst           : in  sl;
      timingBus           : in  TimingBusType;
      timingPhy           : out TimingPhyType;
      timingPhyClk        : in  sl;
      timingPhyRst        : in  sl;
      -- Diagnostic Interface (diagnosticClk domain)
      diagnosticClk       : out sl;
      diagnosticRst       : out sl;
      diagnosticBus       : out DiagnosticBusType;
      -- Backplane Messaging Interface  (axilClk domain)
      obBpMsgClientMaster : out AxiStreamMasterType;
      obBpMsgClientSlave  : in  AxiStreamSlaveType;
      ibBpMsgClientMaster : in  AxiStreamMasterType;
      ibBpMsgClientSlave  : out AxiStreamSlaveType;
      obBpMsgServerMaster : out AxiStreamMasterType;
      obBpMsgServerSlave  : in  AxiStreamSlaveType;
      ibBpMsgServerMaster : in  AxiStreamMasterType;
      ibBpMsgServerSlave  : out AxiStreamSlaveType;
      -- Application Debug Interface (axilClk domain)
      obAppDebugMaster    : out AxiStreamMasterType;
      obAppDebugSlave     : in  AxiStreamSlaveType;
      ibAppDebugMaster    : in  AxiStreamMasterType;
      ibAppDebugSlave     : out AxiStreamSlaveType);
      -----------------------
      -- Application Ports --
      -----------------------      
end AppCore;

architecture mapping of AppCore is

   constant NUM_AXI_MASTERS_C : natural := 2;

   constant IIC_1_INDEX_C : natural := 0;

   constant AXI_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXI_MASTERS_C-1 downto 0) := genAxiLiteConfig(NUM_AXI_MASTERS_C, AXI_BASE_ADDR_G, 28, 24);  -- [0x8FFFFFFF:0x80000000]

   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_AXI_MASTERS_C-1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXI_MASTERS_C-1 downto 0) := (others => AXI_LITE_WRITE_SLAVE_EMPTY_DECERR_C);
   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_AXI_MASTERS_C-1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXI_MASTERS_C-1 downto 0)  := (others => AXI_LITE_READ_SLAVE_EMPTY_DECERR_C);

   signal locAdcValids   : Slv10Array(1 downto 0)                         := (others => (others => '0'));
   signal locAdcValues   : sampleDataVectorArray(1 downto 0, 9 downto 0) := (others => (others => x"0000_0000"));
   signal locDacValids   : Slv10Array(1 downto 0)                         := (others => (others => '0'));
   signal locDacValues   : sampleDataVectorArray(1 downto 0, 9 downto 0) := (others => (others => x"0000_0000"));
   signal locDebugValids : Slv4Array(1 downto 0)                         := (others => (others => '0'));
   signal locDebugValues : sampleDataVectorArray(1 downto 0, 3 downto 0) := (others => (others => x"0000_0000"));   

   constant NUM_IIC_1_DEVS_C  : natural := 6;

   constant IIC_1_DEVICE_MAP_C: I2cAxiLiteDevArray(0 to NUM_IIC_1_DEVS_C-1) := (
      0 => (MakeI2cAxiLiteDevType("1110100", 8,  0, '1')), -- TCA9548
      1 => (MakeI2cAxiLiteDevType("1010100", 8,  8, '1')), -- Atmel24C08 
      2 => (MakeI2cAxiLiteDevType("0110110", 8,  8, '1')), -- Si5341
      3 => (MakeI2cAxiLiteDevType("1011101", 8,  8, '1')), -- Si570
      4 => (MakeI2cAxiLiteDevType("1101000", 8,  8, '1')), -- Si5382 (SFP CLK recovery)
      5 => (MakeI2cAxiLiteDevType("0101111", 32, 0, '1'))  -- SC18IS602B
   );

begin

   adcValids   <= locAdcValids;
   adcValues   <= locAdcValues;
   dacValids   <= locDacValids;
   dacValues   <= locDacValues;
   debugValids <= locDebugValids;
   debugValues <= locDebugValues;
   
   ---------------------------
   -- Terminate unused outputs
   ---------------------------
   obBpMsgClientMaster <= AXI_STREAM_MASTER_INIT_C;
   ibBpMsgClientSlave  <= AXI_STREAM_SLAVE_FORCE_C;

   obBpMsgServerMaster <= AXI_STREAM_MASTER_INIT_C;
   ibBpMsgServerSlave  <= AXI_STREAM_SLAVE_FORCE_C;

   obAppDebugMaster <= AXI_STREAM_MASTER_INIT_C;
   ibAppDebugSlave  <= AXI_STREAM_SLAVE_FORCE_C;

   dacSigCtrl  <= (others => DAC_SIG_CTRL_INIT_C);
   timingPhy   <= TIMING_PHY_INIT_C;

   freezeHw <= (others => '0');
   trigHw   <= (others => '0');

   jesdClk    <= (others => axilClk);
   jesdRst    <= (others => axilRst);
   jesdClk2x  <= (others => axilClk);
   jesdRst2x  <= (others => axilRst);
   jesdUsrClk <= (others => axilClk);
   jesdUsrRst <= (others => axilRst);

   diagnosticClk <= axilClk;
   diagnosticRst <= axilRst;
   diagnosticBus <= DIAGNOSTIC_BUS_INIT_C;

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

   -- IIC Master
   U_AxiI2cRegMaster : entity work.AxiI2cRegMaster
      generic map (
         TPD_G              => TPD_G,
         DEVICE_MAP_G       => IIC_1_DEVICE_MAP_C
      )
      port map (
         scl                => iicScl(1),
         sda                => iicSda(1),

         axiClk             => axilClk,
         axiRst             => axilRst,

         axiReadMaster      => axilReadMasters(IIC_1_INDEX_C),
         axiReadSlave       => axilReadSlaves(IIC_1_INDEX_C),
         axiWriteMaster     => axilWriteMasters(IIC_1_INDEX_C),
         axiWriteSlave      => axilWriteSlaves(IIC_1_INDEX_C)
      );

         
end mapping;

-------------------------------------------------------------------------------
-- File       : DspCoreWrapper.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2017-06-28
-- Last update: 2017-12-06
-------------------------------------------------------------------------------
-- Description:
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
use ieee.numeric_std.all;

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.Jesd204bPkg.all;
use work.AppTopPkg.all;

entity DspCoreWrapper is
   generic (
      TPD_G            : time             := 1 ns;
      BUILD_DSP_G      : slv(7 downto 0)  := x"00";
      AXI_BASE_ADDR_G  : slv(31 downto 0) := (others => '0'));
   port (
      -- JESD Clocks and resets   
      jesdClk         : in  slv(1 downto 0);
      jesdRst         : in  slv(1 downto 0);
      -- ADC/DAC/Debug Interface (jesdClk[1:0] domain)
      adcValids       : in  Slv10Array(1 downto 0);
      adcValues       : in  sampleDataVectorArray(1 downto 0, 9 downto 0);
      dacValids       : out Slv10Array(1 downto 0);
      dacValues       : out sampleDataVectorArray(1 downto 0, 9 downto 0);
      debugValids     : out Slv4Array(1 downto 0);
      debugValues     : out sampleDataVectorArray(1 downto 0, 3 downto 0);
      -- DAC Signal Generator Interface (jesdClk[1:0] domain)
      dacSigCtrl      : out DacSigCtrlArray(1 downto 0);
      dacSigStatus    : in  DacSigStatusArray(1 downto 0);
      dacSigValids    : in  Slv10Array(1 downto 0);
      dacSigValues    : in  sampleDataVectorArray(1 downto 0, 9 downto 0);
      -- Digital I/O Interface
      startRamp       : in  sl;
      selectRamp      : in  sl;
      rampCnt         : in  slv(31 downto 0);
      -- Input timing interface (timingClk domain)
      timingClk        : in  sl;
      timingRst        : in  sl;
      timingTimestamp  : in  slv(63 downto 0);
      -- Application Debug Interface (axilClk domain)
      obAppDebugMaster : out AxiStreamMasterType;
      obAppDebugSlave  : in  AxiStreamSlaveType;
      ibAppDebugMaster : in  AxiStreamMasterType;
      ibAppDebugSlave  : out AxiStreamSlaveType := AXI_STREAM_SLAVE_FORCE_C;
      -- AXI-Lite Port
      axilClk         : in  sl;
      axilRst         : in  sl;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType);
end DspCoreWrapper;

architecture mapping of DspCoreWrapper is

   constant NUM_AXI_MASTERS_C : natural := 9;

   constant AXI_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXI_MASTERS_C-1 downto 0) := genAxiLiteConfig(NUM_AXI_MASTERS_C, AXI_BASE_ADDR_G, 24, 20);

   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_AXI_MASTERS_C-1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXI_MASTERS_C-1 downto 0) := (others => AXI_LITE_WRITE_SLAVE_EMPTY_OK_C);
   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_AXI_MASTERS_C-1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXI_MASTERS_C-1 downto 0) := (others => AXI_LITE_READ_SLAVE_EMPTY_OK_C);

   signal adc        : Slv32Array(15 downto 0);
   signal dac        : Slv32Array(15 downto 0);
   signal debug      : Slv32Array(15 downto 0);
   signal sigGen     : Slv32Array(15 downto 0);
   signal sigGenSync : Slv32Array(1 downto 0);

   signal jesdClkVec      : slv(7 downto 0) := (others => '0');
   signal jesdRstVec      : slv(7 downto 0) := (others => '0');
   signal sigGenStart     : slv(7 downto 0) := (others => '0');
   signal sigGenStartSync : slv(7 downto 0) := (others => '0');

   signal debugvalid : Slv2Array(7 downto 0) := (others => "00");

   signal streamValid : slv(7 downto 0) := (others => '0');
   signal streamIndex : Slv9Array(7 downto 0);
   signal streamData  : Slv16Array(7 downto 0);

begin

   ---------------------------------
   -- Mapping/Terminating Interfaces
   ---------------------------------
   dacValids       <= (others => (others => '1'));
   dacValues(0, 8) <= (others => '0');
   dacValues(0, 9) <= (others => '0');
   dacValues(1, 8) <= (others => '0');
   dacValues(1, 9) <= (others => '0');

   debugValids(0)(0) <= debugvalid(2)(0);
   debugValids(0)(1) <= debugvalid(2)(1);
   debugValids(0)(2) <= debugvalid(3)(0);
   debugValids(0)(3) <= debugvalid(3)(1);

   debugValues(0, 0) <= debug(4);
   debugValues(0, 1) <= debug(5);
   debugValues(0, 2) <= debug(6);
   debugValues(0, 3) <= debug(7);

   debugValids(1)(0) <= debugvalid(4)(0);
   debugValids(1)(1) <= debugvalid(4)(1);
   debugValids(1)(2) <= debugvalid(5)(0);
   debugValids(1)(3) <= debugvalid(5)(1);

   debugValues(1, 0) <= debug(8);
   debugValues(1, 1) <= debug(9);
   debugValues(1, 2) <= debug(10);
   debugValues(1, 3) <= debug(11);

   dacSigCtrl(0).start <= (others => uOr(sigGenStartSync));
   dacSigCtrl(1)       <= DAC_SIG_CTRL_INIT_C;

   MORE_MAPPING :
   for i in 3 downto 0 generate

      jesdClkVec(i) <= jesdClk(0);
      jesdRstVec(i) <= jesdRst(0);

      jesdClkVec(i+4) <= jesdClk(1);
      jesdRstVec(i+4) <= jesdRst(1);

      sigGen(0+(2*i)) <= dacSigValues(0, 0);
      sigGen(1+(2*i)) <= dacSigValues(0, 1);

      sigGen(8+(2*i)) <= sigGenSync(0);
      sigGen(9+(2*i)) <= sigGenSync(1);

      sigGenStartSync(i) <= sigGenStart(i);

      U_sigGenStart : entity work.SynchronizerOneShot
         generic map (
            TPD_G => TPD_G)
         port map (
            clk     => jesdClk(0),
            dataIn  => sigGenStart(i+4),
            dataOut => sigGenStartSync(i+4));

   end generate MORE_MAPPING;

   SYNC_SIGGEN :
   for i in 1 downto 0 generate
      U_sigGen : entity work.SynchronizerFifo
         generic map (
            TPD_G        => TPD_G,
            DATA_WIDTH_G => 32)
         port map (
            rst    => jesdRst(0),
            -- Write Ports (wr_clk domain)
            wr_clk => jesdClk(0),
            din    => sigGen(i),
            -- Read Ports (rd_clk domain)
            rd_clk => jesdClk(1),
            dout   => sigGenSync(i));
   end generate SYNC_SIGGEN;

   GEN_CH :
   for i in 7 downto 0 generate

      --------------
      -- JESD BAY[0]
      --------------
      adc(i)          <= adcValues(0, i);
      dacValues(0, i) <= dac(i);

      --------------
      -- JESD BAY[1]
      --------------   
      adc(i+8)        <= adcValues(1, i);
      dacValues(1, i) <= dac(i+8);

   end generate GEN_CH;

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

   ----------------
   -- SYSGEN Module
   ----------------
   GEN_VEC :
   for i in 7 downto 0 generate

--      GEN_DSP : if (BUILD_DSP_G(i) = '1') generate
--
--         U_DSP : entity work.DspCoreWrapperBase
--            generic map (
--               TPD_G            => TPD_G,
--               AXI_BASE_ADDR_G  => AXI_CONFIG_C(i).baseAddr)
--            port map (
--               -- JESD Clocks and resets   
--               jesdClk         => jesdClkVec(i),
--               jesdRst         => jesdRstVec(i),
--               -- ADC/DAC/Debug Interface (jesdClk domain)
--               adc(0)          => adc((2*i)+0),
--               adc(1)          => adc((2*i)+1),
--               dac(0)          => dac((2*i)+0),
--               dac(1)          => dac((2*i)+1),
--               debugvalid      => debugvalid(i),
--               debug(0)        => debug((2*i)+0),
--               debug(1)        => debug((2*i)+1),
--               -- DAC Signal Generator Interface (jesdClk domain)
--               sigGenStart     => sigGenStart(i),
--               sigGen(0)       => sigGen((2*i)+0),
--               sigGen(1)       => sigGen((2*i)+1),
--               -- Digital I/O Interface
--               startRamp       => startRamp,
--               selectRamp      => selectRamp,
--               rampCnt         => rampCnt,
--               -- Processed Data Interface (jesdClk domain)
--               streamValid     => streamValid(i),
--               streamIndex     => streamIndex(i),
--               streamData      => streamData(i),
--               -- AXI-Lite Interface
--               axilClk         => axilClk,
--               axilRst         => axilRst,
--               axilReadMaster  => axilReadMasters(i),
--               axilReadSlave   => axilReadSlaves(i),
--               axilWriteMaster => axilWriteMasters(i),
--               axilWriteSlave  => axilWriteSlaves(i));
--
--      end generate;
--
      BYP_DSP : if (BUILD_DSP_G(i) = '0') generate

         dac(((2*i)+0))   <= (others => '0');
         dac(((2*i)+1))   <= (others => '0');
         debug(((2*i)+0)) <= (others => '0');
         debug(((2*i)+1)) <= (others => '0');
         sigGenStart(i)   <= '0';

         U_Stream : entity work.DummyCryoStream
            generic map (
               TPD_G     => TPD_G)
            port map (
               clk       => jesdClk(0),
               rst       => jesdRst(0),
               trig      => startRamp,
               dataValid => streamValid(i),
               dataIndex => streamIndex(i),
               data      => streamData(i));

      end generate;

   end generate GEN_VEC;

   U_ProcDataFramer : entity work.AxisSysgenProcDataFramer
      generic map (
         BUILD_DSP_G => BUILD_DSP_G,
         TPD_G       => TPD_G)
      port map (
         -- Input timing interface (timingClk domain)
         timingClk       => timingClk,
         timingRst       => timingRst,
         timingTimestamp => timingTimestamp,
         -- Input Data Interface (jesdClk domain)
         jesdClk         => jesdClkVec,
         jesdRst         => jesdRstVec,
         dataValid       => streamValid,
         dataIndex       => streamIndex,
         data            => streamData,
         -- Output AXIS Interface (axisClk domain)
         axisClk         => axilClk,
         axisRst         => axilRst,
         axisMaster      => obAppDebugMaster,
         axisSlave       => obAppDebugSlave);

end mapping;

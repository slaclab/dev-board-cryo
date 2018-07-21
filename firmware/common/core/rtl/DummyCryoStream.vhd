-------------------------------------------------------------------------------
-- File       : DummyCryoStream.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2018-06-20
-- Last update: 2018-06-20
-------------------------------------------------------------------------------
-- Description: Dummy data producer for cryo streaming interface
--
-- trig in kicks off frame.  
--    dataValid for 512 samples, dataIndex 0...511
--    data increment at clock rate
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
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;

entity DummyCryoStream is
   generic (
      TPD_G            : time             := 1 ns;
      AXI_BASE_ADDR_G  : slv(31 downto 0) := (others => '0'));
   port (
      -- Clock and Reset
      clk             : in  sl;
      rst             : in  sl;
      -- Trigger (Flux ramp reset)
      trig            : in  sl;
      -- SYSGEN Interface
      dataValid       : out  slv(7 downto 0);
      dataIndex       : out  Slv9Array(7 downto 0);
      data            : out  Slv16Array(7 downto 0);
      -- AXI-Lite Interface
      axilClk         : in  sl;
      axilRst         : in  sl;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType);


end DummyCryoStream;

architecture rtl of DummyCryoStream is

   constant NUM_AXI_MASTERS_C : natural := 8;

   constant AXI_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXI_MASTERS_C-1 downto 0) := genAxiLiteConfig(NUM_AXI_MASTERS_C, AXI_BASE_ADDR_G, 16, 11);

   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_AXI_MASTERS_C-1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXI_MASTERS_C-1 downto 0);
   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_AXI_MASTERS_C-1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXI_MASTERS_C-1 downto 0);


   constant SOF_CNT_C : slv(8 downto 0) := (others => '0');
   constant EOF_CNT_C : slv(8 downto 0) := (others => '1');

   type StateType is (
      IDLE_S,
      DATA_S);

   type RegType is record
      dataValid    : sl;
      dataValidR1  : sl;
      dataValidR2  : sl;
      dataIndex    : slv(8 downto 0);
      dataIndexR1  : slv(8 downto 0);
      dataIndexR2  : slv(8 downto 0);
      data         : Slv16Array(7 downto 0);
      state        : StateType;
   end record;

   constant REG_INIT_C : RegType := (
      dataValid    => '0',
      dataValidR1  => '0',
      dataValidR2  => '0',
      dataIndex    => (others => '0'),
      dataIndexR1  => (others => '0'),
      dataIndexR2  => (others => '0'),
      data         => (others => (others => '0')),
      state        => IDLE_S);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal ramAddr        : slv(8 downto 0);
   signal ramData        : Slv16Array(7 downto 0);

begin

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


   GEN_BRAM : for i in 7 downto 0 generate

      --------------------------------          
      -- AXI-Lite Shared Memory Module
      --------------------------------          
      U_Mem : entity work.AxiDualPortRam
         generic map (
            TPD_G            => TPD_G,
            BRAM_EN_G        => true,
            REG_EN_G         => true,  -- true = 2 cycle read access latency
            AXI_WR_EN_G      => true,
            SYS_WR_EN_G      => false,
            COMMON_CLK_G     => false,
            ADDR_WIDTH_G     => 9,
            DATA_WIDTH_G     => 16)
         port map (
            -- Clock and Reset
            clk            => clk,
            rst            => rst,
            we             => '0',
            addr           => r.dataIndex,
            din            => x"0000",
            dout           => data(i),
            -- AXI-Lite Interface
            axiClk         => axilClk,
            axiRst         => axilRst,
            axiReadMaster  => axilReadMasters(i),
            axiReadSlave   => axilReadSlaves(i),
            axiWriteMaster => axilWriteMasters(i),
            axiWriteSlave  => axilWriteSlaves(i));

   end generate GEN_BRAM;


   comb : process (r, rst, trig) is
      variable v : RegType;
   begin
      -- Latch the current value
      v := r;

      -- BRAM has 2 CC delay
      v.dataIndexR2 := v.dataIndexR1;
      v.dataIndexR1 := v.dataIndex;

      v.dataValidR2 := v.dataValidR1;
      v.dataValidR1 := v.dataValid;

      -- State Machine
      case (r.state) is
         ----------------------------------------------------------------------
         when IDLE_S =>
            -- Reset
            v.dataIndex := (others => '0');
            if (trig = '1') then
               v.state     := DATA_S;
               v.dataValid := '1';
            end if;
         ----------------------------------------------------------------------
         when DATA_S =>
            v.dataIndex := r.dataIndex + 1;
            if ( r.dataIndex = EOF_CNT_C ) then
               v.state     := IDLE_S;
               v.dataValid := '0';
            end if;
         ----------------------------------------------------------------------
         end case;

      -- Synchronous Reset
      if (rst = '1') then
         v := REG_INIT_C;
      end if;

      -- Register the variable for next clock cycle
      rin       <= v;

      -- Outputs
      dataIndex     <= (others => r.dataIndexR2);
      dataValid     <= (others => r.dataValidR2);
   end process comb;

   seq : process (clk) is
   begin
      if (rising_edge(clk)) then
         r <= rin after TPD_G;
      end if;
   end process seq;

end rtl;

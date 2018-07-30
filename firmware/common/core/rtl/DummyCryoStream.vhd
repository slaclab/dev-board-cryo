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
      dataValid       : out  sl;
      dataIndex       : out  slv(9 downto 0);
      dataOut         : out  slv(63 downto 0);
      -- timestamp (counter)
      timestamp       : out slv(63 downto 0);
      -- AXI-Lite Interface
      axilClk         : in  sl;
      axilRst         : in  sl;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType);


end DummyCryoStream;

architecture rtl of DummyCryoStream is

   attribute dont_touch : string;
   component ila_0
      port (
         clk    : in STD_LOGIC;
         probe0 : in STD_LOGIC_VECTOR ( 0 to 0 );
         probe1 : in STD_LOGIC_VECTOR ( 0 to 0 );
         probe2 : in STD_LOGIC_VECTOR ( 9 downto 0 );
         probe3 : in STD_LOGIC_VECTOR ( 9 downto 0 );
         probe4 : in STD_LOGIC_VECTOR ( 63 downto 0 );
         probe5 : in STD_LOGIC_VECTOR ( 63 downto 0 )
      );
   end component;
   attribute dont_touch of ila_0 : component is "yes";


   constant NUM_AXI_MASTERS_C : natural := 8;

   constant AXI_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXI_MASTERS_C-1 downto 0) := genAxiLiteConfig(NUM_AXI_MASTERS_C, AXI_BASE_ADDR_G, 16, 10);

   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_AXI_MASTERS_C-1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXI_MASTERS_C-1 downto 0);
   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_AXI_MASTERS_C-1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXI_MASTERS_C-1 downto 0);


   constant SOF_CNT_C : slv(10 downto 0) := (others => '0');
   constant EOF_CNT_C : slv(10 downto 0) := (others => '1');

   type StateType is (
      IDLE_S,
      DATA_S);

   type RegType is record
      dataValid    : sl;
      dataIndex    : slv(10 downto 0);
      dataIndexR1  : slv(10 downto 0);
      dataIndexR2  : slv(10 downto 0);
      dataIndexR3  : slv(10 downto 0);
      data         : slv(63 downto 0);
      timestamp    : slv(63 downto 0);
      state        : StateType;
   end record;

   constant REG_INIT_C : RegType := (
      dataValid    => '0',
      dataIndex    => (others => '0'),
      dataIndexR1  => (others => '0'),
      dataIndexR2  => (others => '0'),
      dataIndexR3  => (others => '0'),
      data         => (others => '0'),
      timestamp    => (others => '0'),
      state        => IDLE_S);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal ramAddr        : slv(8 downto 0);
   signal ramData        : Slv32Array(7 downto 0);


begin

   DEBUG : ila_0
      port map (
         clk       => clk,
         probe0(0) => trig,
         probe1(0) => r.dataValid,
         probe2    => r.dataIndexR3(10 downto 1),
         probe3    => r.dataIndexR3(10 downto 1),
         probe4    => r.data,
         probe5    => r.timestamp);

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
            ADDR_WIDTH_G     => 8,
            DATA_WIDTH_G     => 32)
         port map (
            -- Clock and Reset
            clk            => clk,
            rst            => rst,
            we             => '0',
            addr           => r.dataIndex(7 downto 0),
            din            => x"00000000",
            dout           => ramData(i),
            -- AXI-Lite Interface
            axiClk         => axilClk,
            axiRst         => axilRst,
            axiReadMaster  => axilReadMasters(i),
            axiReadSlave   => axilReadSlaves(i),
            axiWriteMaster => axilWriteMasters(i),
            axiWriteSlave  => axilWriteSlaves(i));

   end generate GEN_BRAM;


   comb : process (r, rst, trig, ramData) is
      variable v    : RegType;
      variable idx  : natural range 0 to 7;
      variable mod2 : sl;
      variable data : slv(31 downto 0);
   begin
      -- Latch the current value
      v := r;

      -- BRAM has 2 CC delay
      v.dataIndexR3 := r.dataIndexR2;
      v.dataIndexR2 := r.dataIndexR1;
      v.dataIndexR1 := r.dataIndex;

      -- MUX from BRAM
      idx           := to_integer(unsigned(r.dataIndexR2(10 downto 8)));
      data          := ramData(idx); 

      -- State Machine
      case (r.state) is
         ----------------------------------------------------------------------
         when IDLE_S =>
            -- Reset
            v.dataIndex := (others => '0');
            if (trig = '1') then
               v.state     := DATA_S;
               v.timestamp := r.timestamp + 1;
            end if;
         ----------------------------------------------------------------------
         when DATA_S =>
            v.dataIndex := r.dataIndex + 1;
            if ( r.dataIndex = EOF_CNT_C ) then
               v.state     := IDLE_S;
            end if;
         ----------------------------------------------------------------------
      end case;

      case r.dataIndexR2(0) is
         when '0' =>
            v.data(31 downto 0)  := data;
            v.dataValid := '0';
         when '1' =>
            v.data(63 downto 32) := data;
            v.dataValid := '1';
      end case;

      -- Synchronous Reset
      if (rst = '1') then
         v := REG_INIT_C;
      end if;

      -- Register the variable for next clock cycle
      rin       <= v;

      -- Outputs
      dataIndex     <= r.dataIndexR3(10 downto 1);
      dataValid     <= r.dataValid;
      dataOut       <= r.data;
      timestamp     <= r.timestamp;
   end process comb;

   seq : process (clk) is
   begin
      if (rising_edge(clk)) then
         r <= rin after TPD_G;
      end if;
   end process seq;

end rtl;

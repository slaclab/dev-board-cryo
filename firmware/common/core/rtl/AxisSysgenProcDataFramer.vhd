-------------------------------------------------------------------------------
-- File       : AxisSysgenProcDataFramer.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2018-04-25
-- Last update: 2018-04-25
-------------------------------------------------------------------------------
-- Description: AxisSysgenProcDataFramer Top-level  
--
-- Data Format:
--    DATA[0].BIT[7:0]    = protocol version (0x0)
--    DATA[0].BIT[15:8]   = channel index
--    DATA[0].BIT[63:16]  = event id
--    DATA[1].BIT[63:0]   = timestamp
--    DATA[2].BIT[63:32]  = DATA[I][0];
--    DATA[2].BIT[31:0]   = DATA[Q][0];
--    DATA[3].BIT[63:32]  = DATA[I][1];
--    DATA[3].BIT[31:0]   = DATA[Q][1];
--    DATA[4].BIT[63:32]  = DATA[I][2];
--    DATA[4].BIT[31:0]   = DATA[Q][2];
--    ................................................
--    ................................................
--    ................................................
--    DATA[513].BIT[63:32]  = DATA[I][511];
--    DATA[513].BIT[31:0]   = DATA[Q][511];
--
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
use work.AxiStreamPkg.all;

entity AxisSysgenProcDataFramer is
   generic (
      TPD_G   : time                  := 1 ns;
      TDEST_G : Slv8Array(7 downto 0) := (0 => x"C1", 1 => x"C2", 2 => x"C3", 3 => x"C4", 4 => x"C5", 5 => x"C6", 6 => x"C7", 7 => x"C8"));
   port (
      -- Input timing interface (timingClk domain)
      timingClk       : in  sl;
      timingRst       : in  sl;
      timingTimestamp : in  slv(63 downto 0);
      -- Input Data Interface (jesdClk domain)
      jesdClk         : in  slv(7 downto 0);
      jesdRst         : in  slv(7 downto 0);
      dataValid       : in  slv(7 downto 0);
      dataIndex       : in  Slv9Array(7 downto 0);
      data            : in  Slv16Array(7 downto 0);
      -- Output AXIS Interface (axisClk domain)
      axisClk         : in  sl;
      axisRst         : in  sl;
      axisMaster      : out AxiStreamMasterType;
      axisSlave       : in  AxiStreamSlaveType);
end AxisSysgenProcDataFramer;

architecture mapping of AxisSysgenProcDataFramer is

   signal timestamp : Slv64Array(7 downto 0);

   signal wrEn   : slv(7 downto 0);
   signal wrData : Slv89Array(7 downto 0);

   signal rdReady : slv(7 downto 0);
   signal rdValid : slv(7 downto 0);
   signal rdData  : Slv89Array(7 downto 0);

begin

   GEN_VEC :
   for i in 7 downto 0 generate

      U_SyncTimestamp : entity work.SynchronizerFifo
         generic map (
            TPD_G        => TPD_G,
            DATA_WIDTH_G => 64)
         port map (
            -- Asynchronous Reset
            rst    => timingRst,
            -- Write Ports (wr_clk domain)
            wr_clk => timingClk,
            din    => timingTimestamp,
            -- Read Ports (rd_clk domain)
            rd_clk => jesdClk(i),
            dout   => timestamp(i));

      U_WrFsm : entity work.AxisSysgenProcDataFramerWrFsm
         generic map (
            TPD_G => TPD_G)
         port map (
            -- Clock and Reset
            clk       => jesdClk(i),
            rst       => jesdRst(i),
            -- SYSGEN Interface
            dataValid => dataValid(i),
            dataIndex => dataIndex(i),
            data      => data(i),
            -- Timing Interface
            timestamp => timestamp(i),
            -- FIFO Interface
            wrEn      => wrEn(i),
            wrData    => wrData(i));

      U_SyncData : entity work.SynchronizerFifo
         generic map (
            TPD_G        => TPD_G,
            BRAM_EN_G    => true,
            ADDR_WIDTH_G => 10,         -- Buffering up to two full frames
            DATA_WIDTH_G => 89)
         port map (
            -- Asynchronous Reset
            rst    => jesdRst(i),
            -- Write Ports (wr_clk domain)
            wr_clk => jesdClk(i),
            wr_en  => wrEn(i),
            din    => wrData(i),
            -- Read Ports (rd_clk domain)
            rd_clk => axisClk,
            rd_en  => rdReady(i),
            valid  => rdValid(i),
            dout   => rdData(i));

   end generate GEN_VEC;

   -----------------
   -- FIFO Read FSM
   -----------------
   U_ReadFsm : entity work.AxisSysgenProcDataFramerRdFsm
      generic map (
         TPD_G   => TPD_G,
         TDEST_G => TDEST_G)
      port map (
         -- Clock and Reset
         clk        => axisClk,
         rst        => axisRst,
         -- FIFO Interface
         rdReady    => rdReady,
         rdValid    => rdValid,
         rdData     => rdData,
         -- AXI Stream Interface
         axisMaster => axisMaster,
         axisSlave  => axisSlave);

end mapping;

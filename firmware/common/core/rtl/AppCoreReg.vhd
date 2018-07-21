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
      axilReadSlave   : AxiLiteReadSlaveType;
      axilWriteSlave  : AxiLiteWriteSlaveType;
   end record;

   constant REG_INIT_C : RegType := (
      dacSigTrigArm   => '0',
      dacSigTrigDelay => (others => '0'),
      enableStreams   => '1',
      streamCounter   => (others => '0'),
      streamCounterRst=> '0',
      axilReadSlave   => AXI_LITE_READ_SLAVE_INIT_C,
      axilWriteSlave  => AXI_LITE_WRITE_SLAVE_INIT_C);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal counterSync : slv(31 downto 0);

begin

   counterSync <= streamCounter;
   --------------------- 
   -- AXI Lite Interface
   --------------------- 
   comb : process (axilReadMaster, axilRst, axilWriteMaster, r, counterSync) is
      variable v      : RegType;
      variable regCon : AxiLiteEndPointType;
   begin
      -- Latch the current value
      v := r;

      -- Reset strobes
      v.dacSigTrigArm := '0';

      v.streamCounter := counterSync;

      -- Determine the transaction type
      axiSlaveWaitTxn(regCon, axilWriteMaster, axilReadMaster, v.axilWriteSlave, v.axilReadSlave);

      -- Map the read registers
      axiSlaveRegister(regCon, x"00", 0, v.dacSigTrigDelay);
      axiSlaveRegister(regCon, x"04", 0, v.dacSigTrigArm);
      axiSlaveRegister(regCon, x"08", 0, v.enableStreams);
      axiSlaveRegister(regCon, x"08", 8, v.streamCounterRst);
      axiSlaveRegisterR(regCon, x"0C", 0, r.streamCounter);

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

   end process comb;

   seq : process (axilClk) is
   begin
      if (rising_edge(axilClk)) then
         r <= rin after TPD_G;
      end if;
   end process seq;

end rtl;

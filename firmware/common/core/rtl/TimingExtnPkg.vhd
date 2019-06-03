-------------------------------------------------------------------------------
-- Title      : TimingExtnPkg
-------------------------------------------------------------------------------
-- File       : TimingExtnPkg.vhd
-- Author     : Matt Weaver  <weaver@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2018-07-20
-- Last update: 2018-08-10
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- This file is part of 'LCLS2 Timing Core'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'LCLS2 Timing Core', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

use work.StdRtlPkg.all;

package TimingExtnPkg is

   constant EXPT_STREAM_ID    : slv(3 downto 0) := x"2";

   constant EXPT_MESSAGE_BITS_C : integer := 320;

   type ExptMessageType is record
     baseRateSince1Hz : slv( 31 downto 0);
     baseRateSinceTM  : slv( 31 downto 0);
     timeCode         : slv( 31 downto 0);
     timeCodeHeader   : slv(  7 downto 0);
     reserved         : slv(215 downto 0); 
   end record;
   constant EXPT_MESSAGE_INIT_C : ExptMessageType := (
     baseRateSince1Hz => (others=>'1'),
     baseRateSinceTM  => (others=>'1'),
     timeCode         => (others=>'1'),
     timeCodeHeader   => (others=>'1'),
     reserved         => (others=>'1') );

   function toSlv(message : ExptMessageType) return slv;
   function toExptMessageType (vector : slv) return ExptMessageType;

   -- The extended interface
   subtype TimingExtnType is ExptMessageType;
   constant TIMING_EXTN_INIT_C : ExptMessageType := EXPT_MESSAGE_INIT_C;
   constant TIMING_EXTN_BITS_C : integer := EXPT_MESSAGE_BITS_C;
   constant TIMING_EXTN_STREAMS_C : integer := 2;
   constant TIMING_EXTN_WORDS_C : IntegerArray(1 downto 0) := (
     1,
     EXPT_MESSAGE_BITS_C/16 );   
   
--   function toSlv(message : TimingExtnType) return slv;
   function toTimingExtnType (vector : slv) return TimingExtnType;
   procedure toTimingExtnType(stream : in    integer;
                              vector : in    slv;
                              validi : in    sl;
                              extn   : inout TimingExtnType;
                              valido : inout sl );   
   
end package TimingExtnPkg;

package body TimingExtnPkg is

   function toSlv(message : ExptMessageType) return slv
   is
      variable vector  : slv(EXPT_MESSAGE_BITS_C-1 downto 0) := (others=>'0');
      variable i       : integer := 0;
   begin
      assignSlv(i, vector, message.baseRateSince1Hz);
      assignSlv(i, vector, message.baseRateSinceTM);
      assignSlv(i, vector, message.timeCode);
      assignSlv(i, vector, message.timeCodeHeader);
      assignSlv(i, vector, message.reserved);
      return vector;
   end function;
      
   function toExptMessageType (vector : slv) return ExptMessageType
   is
      variable message : ExptMessageType;
      variable i       : integer := 0;
   begin
      assignRecord(i, vector, message.baseRateSince1Hz);
      assignRecord(i, vector, message.baseRateSinceTM);
      assignRecord(i, vector, message.timeCode);
      assignRecord(i, vector, message.timeCodeHeader);
      assignRecord(i, vector, message.reserved);
      return message;
   end function;
   
--   function toSlv(message : TimingExtnType) return slv is
--   begin
--     return toSlv(ExptMessageType(message));
--   end function;
   
   function toTimingExtnType (vector : slv) return TimingExtnType is
   begin
     return TimingExtnType(toExptMessageType(vector));
   end function;
   
   procedure toTimingExtnType(stream : in    integer;
                              vector : in    slv;
                              validi : in    sl;
                              extn   : inout TimingExtnType;
                              valido : inout sl ) is
   begin
     case stream is
       when 2 =>
         extn   := toExptMessageType(vector);
         valido := '1';
       when others => null;
     end case;
   end procedure;   
   
end package body TimingExtnPkg;

##############################################################################
## This file is part of 'DevBoard Common Platform'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'DevBoard Common Platform', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################

set_property -dict { PACKAGE_PIN AF16 IOSTANDARD LVCMOS18 } [get_ports { timingClkScl }]; # GPIO_DIP_SW0
set_property -dict { PACKAGE_PIN AF17 IOSTANDARD LVCMOS18 } [get_ports { timingClkSda }]; # GPIO_DIP_SW1

set_property -dict { PACKAGE_PIN AH15 IOSTANDARD LVCMOS18 } [get_ports { ddrScl }]; # GPIO_DIP_SW2
set_property -dict { PACKAGE_PIN AH16 IOSTANDARD LVCMOS18 } [get_ports { ddrSda }]; # GPIO_DIP_SW3

set_property -dict { PACKAGE_PIN AH17 IOSTANDARD LVCMOS18 } [get_ports { ipmcScl }]; # GPIO_DIP_SW4
set_property -dict { PACKAGE_PIN AG17 IOSTANDARD LVCMOS18 } [get_ports { ipmcSda }]; # GPIO_DIP_SW5

set_property -dict { PACKAGE_PIN AJ15 IOSTANDARD LVCMOS18 } [get_ports { calScl }]; # GPIO_DIP_SW6
set_property -dict { PACKAGE_PIN AJ16 IOSTANDARD LVCMOS18 } [get_ports { calSda }]; # GPIO_DIP_SW7

set_property -dict { PACKAGE_PIN AL17 IOSTANDARD LVDS } [get_ports { fabClkP }]
set_property -dict { PACKAGE_PIN AM17 IOSTANDARD LVDS } [get_ports { fabClkN }]
set_property -dict { PACKAGE_PIN AF15 IOSTANDARD LVCMOS18 } [get_ports { extRst }]

set_property -dict { PACKAGE_PIN AR13 IOSTANDARD LVCMOS18 } [get_ports { led[0] }]
set_property -dict { PACKAGE_PIN AP13 IOSTANDARD LVCMOS18 } [get_ports { led[1] }]
set_property -dict { PACKAGE_PIN AR16 IOSTANDARD LVCMOS18 } [get_ports { led[2] }]
set_property -dict { PACKAGE_PIN AP16 IOSTANDARD LVCMOS18 } [get_ports { led[3] }]
set_property -dict { PACKAGE_PIN AP15 IOSTANDARD LVCMOS18 } [get_ports { led[4] }]
set_property -dict { PACKAGE_PIN AN16 IOSTANDARD LVCMOS18 } [get_ports { led[5] }]
set_property -dict { PACKAGE_PIN AN17 IOSTANDARD LVCMOS18 } [get_ports { led[6] }]
set_property -dict { PACKAGE_PIN AV15 IOSTANDARD LVCMOS18 } [get_ports { led[7] }]

set_property PACKAGE_PIN V31 [get_ports { ethClkP }]
set_property PACKAGE_PIN V32 [get_ports { ethClkN }]

set_property PACKAGE_PIN Y31 [get_ports { timingRefClkInP }]
set_property PACKAGE_PIN Y32 [get_ports { timingRefClkInN }]

set_property PACKAGE_PIN Y35  [get_ports { sfpTxP[0] }]
set_property PACKAGE_PIN Y36  [get_ports { sfpTxN[0] }]
set_property PACKAGE_PIN AA38 [get_ports { sfpRxP[0] }]
set_property PACKAGE_PIN AA39 [get_ports { sfpRxN[0] }]

set_property PACKAGE_PIN V35 [get_ports { sfpTxP[1] }]
set_property PACKAGE_PIN V36 [get_ports { sfpTxN[1] }]
set_property PACKAGE_PIN W38 [get_ports { sfpRxP[1] }]
set_property PACKAGE_PIN W39 [get_ports { sfpRxN[1] }]

set_property PACKAGE_PIN T35 [get_ports { sfpTxP[2] }]
set_property PACKAGE_PIN T36 [get_ports { sfpTxN[2] }]
set_property PACKAGE_PIN U38 [get_ports { sfpRxP[2] }]
set_property PACKAGE_PIN U39 [get_ports { sfpRxN[2] }]

set_property PACKAGE_PIN R33 [get_ports { sfpTxP[3] }]
set_property PACKAGE_PIN R34 [get_ports { sfpTxN[3] }]
set_property PACKAGE_PIN R38 [get_ports { sfpRxP[3] }]
set_property PACKAGE_PIN R39 [get_ports { sfpRxN[3] }]

set_property -dict { PACKAGE_PIN G12 IOSTANDARD LVCMOS12 } [get_ports { sfpTxEnable[0] }]
set_property -dict { PACKAGE_PIN G10 IOSTANDARD LVCMOS12 } [get_ports { sfpTxEnable[1] }]
set_property -dict { PACKAGE_PIN K12 IOSTANDARD LVCMOS12 } [get_ports { sfpTxEnable[2] }]
set_property -dict { PACKAGE_PIN J7  IOSTANDARD LVCMOS12 } [get_ports { sfpTxEnable[3] }]

set_property -dict { PACKAGE_PIN W17 IOSTANDARD ANALOG } [get_ports { vPIn }]
set_property -dict { PACKAGE_PIN Y16 IOSTANDARD ANALOG } [get_ports { vNIn }]

create_clock -name fabClk     -period  8.000  [get_ports {fabClkP}]
create_clock -name ethRef     -period  6.400  [get_ports {ethClkP}]
create_clock -name timingRef  -period  2.691  [get_ports {timingRefClkInP}]

set_clock_groups -asynchronous \
   -group [get_clocks -include_generated_clocks {fabClk}] \
   -group [get_clocks -include_generated_clocks {ethRef}] \
   -group [get_clocks -include_generated_clocks {timingRef}] \
   -group [get_clocks -include_generated_clocks {c0_sys_clk_n}] 
   
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_AmcCorePll/PllGen.U_Pll/CLKOUT0]] -group [get_clocks -of_objects [get_pins U_SysReg/U_Iprog/GEN_ULTRA_SCALE.IprogUltraScale_Inst/BUFGCE_DIV_Inst/O]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_AmcCorePll/PllGen.U_Pll/CLKOUT0]] -group [get_clocks -of_objects [get_pins U_SysReg/U_Version/GEN_DEVICE_DNA.DeviceDna_1/GEN_ULTRA_SCALE.DeviceDnaUltraScale_Inst/BUFGCE_DIV_Inst/O]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_AmcCorePll/PllGen.U_Pll/CLKOUT0]] -group [get_clocks -of_objects [get_pins U_DdrMem/MigCore_Inst/inst/u_ddr4_infrastructure/gen_mmcme4.u_mmcme_adv_inst/CLKOUT0]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_AmcCorePll/PllGen.U_Pll/CLKOUT0]] -group [get_clocks fabClk]
   
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_Timing/TimingGthCoreWrapper_1/LOCREF_G.U_TimingGtyCore/inst/gen_gtwizard_gtye4_top.TimingGty_fixedlat_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[3].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLKPCS}]] -group [get_clocks -of_objects [get_pins U_Timing/TIMING_REFCLK_IBUFDS_GTE3/U_IBUFDS_GT/ODIV2]]

set_clock_groups -asynchronous -group [get_clocks ethRef] -group [get_clocks -of_objects [get_pins {U_Eth/ETH_10GbE.U_ETH/GEN_LANE[0].TenGigEthGtyUltraScale_Inst/U_TenGigEthGtyUltraScaleCore/inst/i_TenGigEthGtyUltraScale156p25MHzCore_gt/inst/gen_gtwizard_gtye4_top.TenGigEthGtyUltraScale156p25MHzCore_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[1].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/RXOUTCLK}]]
set_clock_groups -asynchronous -group [get_clocks ethRef] -group [get_clocks -of_objects [get_pins {U_Eth/ETH_10GbE.U_ETH/GEN_LANE[0].TenGigEthGtyUltraScale_Inst/U_TenGigEthGtyUltraScaleCore/inst/i_TenGigEthGtyUltraScale156p25MHzCore_gt/inst/gen_gtwizard_gtye4_top.TenGigEthGtyUltraScale156p25MHzCore_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[1].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_Eth/ETH_10GbE.U_ETH/GEN_LANE[0].TenGigEthGtyUltraScale_Inst/U_TenGigEthGtyUltraScaleCore/inst/i_TenGigEthGtyUltraScale156p25MHzCore_gt/inst/gen_gtwizard_gtye4_top.TenGigEthGtyUltraScale156p25MHzCore_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[1].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]] -group [get_clocks -of_objects [get_pins {U_Eth/ETH_10GbE.U_ETH/GEN_LANE[0].TenGigEthGtyUltraScale_Inst/U_TenGigEthGtyUltraScaleCore/inst/i_TenGigEthGtyUltraScale156p25MHzCore_gt/inst/gen_gtwizard_gtye4_top.TenGigEthGtyUltraScale156p25MHzCore_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[1].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/RXOUTCLK}]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_Eth/ETH_10GbE.U_ETH/GEN_LANE[0].TenGigEthGtyUltraScale_Inst/U_TenGigEthGtyUltraScaleCore/inst/i_TenGigEthGtyUltraScale156p25MHzCore_gt/inst/gen_gtwizard_gtye4_top.TenGigEthGtyUltraScale156p25MHzCore_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[1].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLKPCS}]] -group [get_clocks -of_objects [get_pins {U_Eth/ETH_10GbE.U_ETH/GEN_LANE[0].TenGigEthGtyUltraScale_Inst/U_TenGigEthGtyUltraScaleCore/inst/i_TenGigEthGtyUltraScale156p25MHzCore_gt/inst/gen_gtwizard_gtye4_top.TenGigEthGtyUltraScale156p25MHzCore_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[1].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_Eth/ETH_10GbE.U_ETH/GEN_LANE[0].TenGigEthGtyUltraScale_Inst/U_TenGigEthGtyUltraScaleCore/inst/i_TenGigEthGtyUltraScale156p25MHzCore_gt/inst/gen_gtwizard_gtye4_top.TenGigEthGtyUltraScale156p25MHzCore_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[1].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLKPCS}]] -group [get_clocks ethRef]

set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_Eth/ETH_1GbE.U_ETH/U_MMCM/MmcmGen.U_Mmcm/CLKOUT1]] -group [get_clocks -of_objects [get_pins {U_Eth/ETH_1GbE.U_ETH/GEN_LANE[0].U_GigEthGtyUltraScale/U_GigEthGtyUltraScaleCore/U0/transceiver_inst/GigEthGtyUltraScaleCore_gt_i/inst/gen_gtwizard_gtye4_top.GigEthGtyUltraScaleCore_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[2].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_Eth/ETH_1GbE.U_ETH/GEN_LANE[0].U_GigEthGtyUltraScale/U_GigEthGtyUltraScaleCore/U0/transceiver_inst/GigEthGtyUltraScaleCore_gt_i/inst/gen_gtwizard_gtye4_top.GigEthGtyUltraScaleCore_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[2].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]] -group [get_clocks -of_objects [get_pins U_Eth/ETH_1GbE.U_ETH/U_MMCM/MmcmGen.U_Mmcm/CLKOUT1]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_Eth/ETH_1GbE.U_ETH/GEN_LANE[0].U_GigEthGtyUltraScale/U_GigEthGtyUltraScaleCore/U0/transceiver_inst/GigEthGtyUltraScaleCore_gt_i/inst/gen_gtwizard_gtye4_top.GigEthGtyUltraScaleCore_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[2].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLKPCS}]] -group [get_clocks -of_objects [get_pins U_Eth/ETH_1GbE.U_ETH/U_MMCM/MmcmGen.U_Mmcm/CLKOUT1]]


set_property BITSTREAM.CONFIG.OVERTEMPSHUTDOWN ENABLE [current_design]

##############################################################################
## This file is part of 'DevBoard Common Platform'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'DevBoard Common Platform', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################

set_property PACKAGE_PIN A16      [get_ports { c0_ddr4_cke[0] }] ;# Bank  69 VCCO - VCC1V2   - IO_L24N_T3U_N11_69
set_property IOSTANDARD  SSTL12_DCI   [get_ports { c0_ddr4_cke[0] }] ;# Bank  69 VCCO - VCC1V2   - IO_L24N_T3U_N11_69

set_property PACKAGE_PIN A17      [get_ports { c0_ddr4_reset_n }] ;# Bank  69 VCCO - VCC1V2   - IO_L24P_T3U_N10_69
set_property IOSTANDARD  LVCMOS12 [get_ports { c0_ddr4_reset_n }] ;# Bank  69 VCCO - VCC1V2   - IO_L24P_T3U_N10_69
set_property DRIVE 6              [get_ports { c0_ddr4_reset_n }] ;# Bank  69 VCCO - VCC1V2   - IO_L24P_T3U_N10_69

set_property PACKAGE_PIN D16      [get_ports { c0_ddr4_cs_n[0] }] ;# Bank  69 VCCO - VCC1V2   - IO_L23P_T3U_N8_69
set_property IOSTANDARD  SSTL12_DCI   [get_ports { c0_ddr4_cs_n[0] }] ;# Bank  69 VCCO - VCC1V2   - IO_L23P_T3U_N8_69

set_property PACKAGE_PIN C16      [get_ports { c0_ddr4_bg[0] }] ;# Bank  69 VCCO - VCC1V2   - IO_L21N_T3L_N5_AD8N_69
set_property IOSTANDARD  SSTL12_DCI   [get_ports { c0_ddr4_bg[0] }] ;# Bank  69 VCCO - VCC1V2   - IO_L21N_T3L_N5_AD8N_69

set_property PACKAGE_PIN A19      [get_ports { c0_ddr4_act_n }] ;# Bank  69 VCCO - VCC1V2   - IO_L20N_T3L_N3_AD1N_69
set_property IOSTANDARD  SSTL12_DCI   [get_ports { c0_ddr4_act_n }] ;# Bank  69 VCCO - VCC1V2   - IO_L20N_T3L_N3_AD1N_69

set_property PACKAGE_PIN B19      [get_ports { c0_ddr4_odt[0] }] ;# Bank  69 VCCO - VCC1V2   - IO_L20P_T3L_N2_AD1P_69
set_property IOSTANDARD  SSTL12_DCI   [get_ports { c0_ddr4_odt[0] }] ;# Bank  69 VCCO - VCC1V2   - IO_L20P_T3L_N2_AD1P_69

set_property PACKAGE_PIN F17      [get_ports { c0_ddr4_ck_c[0] }] ;# Bank  69 VCCO - VCC1V2   - IO_L13N_T2L_N1_GC_QBC_69
set_property IOSTANDARD  DIFF_SSTL12_DCI [get_ports { c0_ddr4_ck_c[0] }] ;# Bank  69 VCCO - VCC1V2   - IO_L13N_T2L_N1_GC_QBC_69
set_property PACKAGE_PIN G17      [get_ports { c0_ddr4_ck_t[0] }] ;# Bank  69 VCCO - VCC1V2   - IO_L13P_T2L_N0_GC_QBC_69
set_property IOSTANDARD  DIFF_SSTL12_DCI [get_ports { c0_ddr4_ck_t[0] }] ;# Bank  69 VCCO - VCC1V2   - IO_L13P_T2L_N0_GC_QBC_69

set_property PACKAGE_PIN J18      [get_ports { c0_sys_clk_n }] ;# Bank  69 VCCO - VCC1V2   - IO_L12N_T1U_N11_GC_69
set_property IOSTANDARD  DIFF_POD12_DCI [get_ports { c0_sys_clk_n }] ;# Bank  69 VCCO - VCC1V2   - IO_L12N_T1U_N11_GC_69
set_property PACKAGE_PIN J19      [get_ports { c0_sys_clk_p }] ;# Bank  69 VCCO - VCC1V2   - IO_L12P_T1U_N10_GC_69
set_property IOSTANDARD  DIFF_POD12_DCI [get_ports { c0_sys_clk_p }] ;# Bank  69 VCCO - VCC1V2   - IO_L12P_T1U_N10_GC_69

set_property PACKAGE_PIN K18      [get_ports { c0_ddr4_ba[0] }] ;# Bank  69 VCCO - VCC1V2   - IO_L10N_T1U_N7_QBC_AD4N_69
set_property IOSTANDARD  SSTL12_DCI   [get_ports { c0_ddr4_ba[0] }] ;# Bank  69 VCCO - VCC1V2   - IO_L10N_T1U_N7_QBC_AD4N_69
set_property PACKAGE_PIN K19      [get_ports { c0_ddr4_ba[1] }] ;# Bank  69 VCCO - VCC1V2   - IO_L10P_T1U_N6_QBC_AD4P_69
set_property IOSTANDARD  SSTL12_DCI   [get_ports { c0_ddr4_ba[1] }] ;# Bank  69 VCCO - VCC1V2   - IO_L10P_T1U_N6_QBC_AD4P_69

set_property PACKAGE_PIN D18      [get_ports { c0_ddr4_adr[0] }] ;# Bank  69 VCCO - VCC1V2   - IO_L19P_T3L_N0_DBC_AD9P_69
set_property IOSTANDARD  SSTL12_DCI   [get_ports { c0_ddr4_adr[0] }] ;# Bank  69 VCCO - VCC1V2   - IO_L19P_T3L_N0_DBC_AD9P_69
set_property PACKAGE_PIN E19      [get_ports { c0_ddr4_adr[1] }] ;# Bank  69 VCCO - VCC1V2   - IO_T2U_N12_69
set_property IOSTANDARD  SSTL12_DCI   [get_ports { c0_ddr4_adr[1] }] ;# Bank  69 VCCO - VCC1V2   - IO_T2U_N12_69
set_property PACKAGE_PIN E17      [get_ports { c0_ddr4_adr[2] }] ;# Bank  69 VCCO - VCC1V2   - IO_L18N_T2U_N11_AD2N_69
set_property IOSTANDARD  SSTL12_DCI   [get_ports { c0_ddr4_adr[2] }] ;# Bank  69 VCCO - VCC1V2   - IO_L18N_T2U_N11_AD2N_69
set_property PACKAGE_PIN E18      [get_ports { c0_ddr4_adr[3] }] ;# Bank  69 VCCO - VCC1V2   - IO_L18P_T2U_N10_AD2P_69
set_property IOSTANDARD  SSTL12_DCI   [get_ports { c0_ddr4_adr[3] }] ;# Bank  69 VCCO - VCC1V2   - IO_L18P_T2U_N10_AD2P_69
set_property PACKAGE_PIN E16      [get_ports { c0_ddr4_adr[4] }] ;# Bank  69 VCCO - VCC1V2   - IO_L17N_T2U_N9_AD10N_69
set_property IOSTANDARD  SSTL12_DCI   [get_ports { c0_ddr4_adr[4] }] ;# Bank  69 VCCO - VCC1V2   - IO_L17N_T2U_N9_AD10N_69
set_property PACKAGE_PIN F16      [get_ports { c0_ddr4_adr[5] }] ;# Bank  69 VCCO - VCC1V2   - IO_L17P_T2U_N8_AD10P_69
set_property IOSTANDARD  SSTL12_DCI   [get_ports { c0_ddr4_adr[5] }] ;# Bank  69 VCCO - VCC1V2   - IO_L17P_T2U_N8_AD10P_69
set_property PACKAGE_PIN F19      [get_ports { c0_ddr4_adr[6] }] ;# Bank  69 VCCO - VCC1V2   - IO_L16N_T2U_N7_QBC_AD3N_69
set_property IOSTANDARD  SSTL12_DCI   [get_ports { c0_ddr4_adr[6] }] ;# Bank  69 VCCO - VCC1V2   - IO_L16N_T2U_N7_QBC_AD3N_69
set_property PACKAGE_PIN G19      [get_ports { c0_ddr4_adr[7] }] ;# Bank  69 VCCO - VCC1V2   - IO_L16P_T2U_N6_QBC_AD3P_69
set_property IOSTANDARD  SSTL12_DCI   [get_ports { c0_ddr4_adr[7] }] ;# Bank  69 VCCO - VCC1V2   - IO_L16P_T2U_N6_QBC_AD3P_69
set_property PACKAGE_PIN F15      [get_ports { c0_ddr4_adr[8] }] ;# Bank  69 VCCO - VCC1V2   - IO_L15N_T2L_N5_AD11N_69
set_property IOSTANDARD  SSTL12_DCI   [get_ports { c0_ddr4_adr[8] }] ;# Bank  69 VCCO - VCC1V2   - IO_L15N_T2L_N5_AD11N_69
set_property PACKAGE_PIN G15      [get_ports { c0_ddr4_adr[9] }] ;# Bank  69 VCCO - VCC1V2   - IO_L15P_T2L_N4_AD11P_69
set_property IOSTANDARD  SSTL12_DCI   [get_ports { c0_ddr4_adr[9] }] ;# Bank  69 VCCO - VCC1V2   - IO_L15P_T2L_N4_AD11P_69
set_property PACKAGE_PIN G18      [get_ports { c0_ddr4_adr[10] }] ;# Bank  69 VCCO - VCC1V2   - IO_L14N_T2L_N3_GC_69
set_property IOSTANDARD  SSTL12_DCI   [get_ports { c0_ddr4_adr[10] }] ;# Bank  69 VCCO - VCC1V2   - IO_L14N_T2L_N3_GC_69
set_property PACKAGE_PIN H18      [get_ports { c0_ddr4_adr[11] }] ;# Bank  69 VCCO - VCC1V2   - IO_L14P_T2L_N2_GC_69
set_property IOSTANDARD  SSTL12_DCI   [get_ports { c0_ddr4_adr[11] }] ;# Bank  69 VCCO - VCC1V2   - IO_L14P_T2L_N2_GC_69
set_property PACKAGE_PIN K17      [get_ports { c0_ddr4_adr[12] }] ;# Bank  69 VCCO - VCC1V2   - IO_L8N_T1L_N3_AD5N_69
set_property IOSTANDARD  SSTL12_DCI   [get_ports { c0_ddr4_adr[12] }] ;# Bank  69 VCCO - VCC1V2   - IO_L8N_T1L_N3_AD5N_69
set_property PACKAGE_PIN L17      [get_ports { c0_ddr4_adr[13] }] ;# Bank  69 VCCO - VCC1V2   - IO_L8P_T1L_N2_AD5P_69
set_property IOSTANDARD  SSTL12_DCI   [get_ports { c0_ddr4_adr[13] }] ;# Bank  69 VCCO - VCC1V2   - IO_L8P_T1L_N2_AD5P_69

set_property PACKAGE_PIN B17      [get_ports { c0_ddr4_adr[14] }] ;# Bank  69 VCCO - VCC1V2   - IO_L22N_T3U_N7_DBC_AD0N_69 (PL_DDR4_WE_B)
set_property IOSTANDARD  SSTL12_DCI   [get_ports { c0_ddr4_adr[14] }] ;# Bank  69 VCCO - VCC1V2   - IO_L22N_T3U_N7_DBC_AD0N_69 (PL_DDR4_WE_B)
set_property PACKAGE_PIN D15      [get_ports { c0_ddr4_adr[15] }] ;# Bank  69 VCCO - VCC1V2   - IO_L23N_T3U_N9_69 (PL_DDR4_CAS_B)
set_property IOSTANDARD  SSTL12_DCI   [get_ports { c0_ddr4_adr[15] }] ;# Bank  69 VCCO - VCC1V2   - IO_L23N_T3U_N9_69 (PL_DDR4_CAS_B)
set_property PACKAGE_PIN C18      [get_ports { c0_ddr4_adr[16] }] ;# Bank  69 VCCO - VCC1V2   - IO_L19N_T3L_N1_DBC_AD9N_69 (PL_DDR4_RAS_B)
set_property IOSTANDARD  SSTL12_DCI   [get_ports { c0_ddr4_adr[16] }] ;# Bank  69 VCCO - VCC1V2   - IO_L19N_T3L_N1_DBC_AD9N_69 (PL_DDR4_RAS_B)

set_property PACKAGE_PIN D14      [get_ports { c0_ddr4_dq[0] }] ;# Bank  68 VCCO - VCC1V2   - IO_L18N_T2U_N11_AD2N_68
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[0] }] ;# Bank  68 VCCO - VCC1V2   - IO_L18N_T2U_N11_AD2N_68
set_property PACKAGE_PIN E14      [get_ports { c0_ddr4_dq[4] }] ;# Bank  68 VCCO - VCC1V2   - IO_L18P_T2U_N10_AD2P_68
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[4] }] ;# Bank  68 VCCO - VCC1V2   - IO_L18P_T2U_N10_AD2P_68
set_property PACKAGE_PIN E11      [get_ports { c0_ddr4_dq[1] }] ;# Bank  68 VCCO - VCC1V2   - IO_L17N_T2U_N9_AD10N_68
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[1] }] ;# Bank  68 VCCO - VCC1V2   - IO_L17N_T2U_N9_AD10N_68
set_property PACKAGE_PIN F12      [get_ports { c0_ddr4_dq[3] }] ;# Bank  68 VCCO - VCC1V2   - IO_L17P_T2U_N8_AD10P_68
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[3] }] ;# Bank  68 VCCO - VCC1V2   - IO_L17P_T2U_N8_AD10P_68
set_property PACKAGE_PIN E12      [get_ports { c0_ddr4_dqs_c[0] }] ;# Bank  68 VCCO - VCC1V2   - IO_L16N_T2U_N7_QBC_AD3N_68
set_property IOSTANDARD  DIFF_POD12_DCI    [get_ports { c0_ddr4_dqs_c[0] }] ;# Bank  68 VCCO - VCC1V2   - IO_L16N_T2U_N7_QBC_AD3N_68
set_property PACKAGE_PIN E13      [get_ports { c0_ddr4_dqs_t[0] }] ;# Bank  68 VCCO - VCC1V2   - IO_L16P_T2U_N6_QBC_AD3P_68
set_property IOSTANDARD  DIFF_POD12_DCI    [get_ports { c0_ddr4_dqs_t[0] }] ;# Bank  68 VCCO - VCC1V2   - IO_L16P_T2U_N6_QBC_AD3P_68
set_property PACKAGE_PIN F14      [get_ports { c0_ddr4_dq[2] }] ;# Bank  68 VCCO - VCC1V2   - IO_L15N_T2L_N5_AD11N_68
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[2] }] ;# Bank  68 VCCO - VCC1V2   - IO_L15N_T2L_N5_AD11N_68
set_property PACKAGE_PIN G14      [get_ports { c0_ddr4_dq[6] }] ;# Bank  68 VCCO - VCC1V2   - IO_L15P_T2L_N4_AD11P_68
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[6] }] ;# Bank  68 VCCO - VCC1V2   - IO_L15P_T2L_N4_AD11P_68
set_property PACKAGE_PIN H12      [get_ports { c0_ddr4_dq[5] }] ;# Bank  68 VCCO - VCC1V2   - IO_L14N_T2L_N3_GC_68
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[5] }] ;# Bank  68 VCCO - VCC1V2   - IO_L14N_T2L_N3_GC_68
set_property PACKAGE_PIN H13      [get_ports { c0_ddr4_dq[7] }] ;# Bank  68 VCCO - VCC1V2   - IO_L14P_T2L_N2_GC_68
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[7] }] ;# Bank  68 VCCO - VCC1V2   - IO_L14P_T2L_N2_GC_68
set_property PACKAGE_PIN G13      [get_ports { c0_ddr4_dm_dbi_n[0] }] ;# Bank  68 VCCO - VCC1V2   - IO_L13P_T2L_N0_GC_QBC_68
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dm_dbi_n[0] }] ;# Bank  68 VCCO - VCC1V2   - IO_L13P_T2L_N0_GC_QBC_68

set_property PACKAGE_PIN A14      [get_ports { c0_ddr4_dq[11] }] ;# Bank  68 VCCO - VCC1V2   - IO_L24N_T3U_N11_68
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[11] }] ;# Bank  68 VCCO - VCC1V2   - IO_L24N_T3U_N11_68
set_property PACKAGE_PIN A15      [get_ports { c0_ddr4_dq[9] }] ;# Bank  68 VCCO - VCC1V2   - IO_L24P_T3U_N10_68
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[9] }] ;# Bank  68 VCCO - VCC1V2   - IO_L24P_T3U_N10_68
set_property PACKAGE_PIN A11      [get_ports { c0_ddr4_dq[14] }] ;# Bank  68 VCCO - VCC1V2   - IO_L23N_T3U_N9_68
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[14] }] ;# Bank  68 VCCO - VCC1V2   - IO_L23N_T3U_N9_68
set_property PACKAGE_PIN A12      [get_ports { c0_ddr4_dq[10] }] ;# Bank  68 VCCO - VCC1V2   - IO_L23P_T3U_N8_68
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[10] }] ;# Bank  68 VCCO - VCC1V2   - IO_L23P_T3U_N8_68
set_property PACKAGE_PIN B15      [get_ports { c0_ddr4_dqs_c[1] }] ;# Bank  68 VCCO - VCC1V2   - IO_L22N_T3U_N7_DBC_AD0N_68
set_property IOSTANDARD  DIFF_POD12_DCI    [get_ports { c0_ddr4_dqs_c[1] }] ;# Bank  68 VCCO - VCC1V2   - IO_L22N_T3U_N7_DBC_AD0N_68
set_property PACKAGE_PIN C15      [get_ports { c0_ddr4_dqs_t[1] }] ;# Bank  68 VCCO - VCC1V2   - IO_L22P_T3U_N6_DBC_AD0P_68
set_property IOSTANDARD  DIFF_POD12_DCI    [get_ports { c0_ddr4_dqs_t[1] }] ;# Bank  68 VCCO - VCC1V2   - IO_L22P_T3U_N6_DBC_AD0P_68
set_property PACKAGE_PIN B13      [get_ports { c0_ddr4_dq[8] }] ;# Bank  68 VCCO - VCC1V2   - IO_L21N_T3L_N5_AD8N_68
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[8] }] ;# Bank  68 VCCO - VCC1V2   - IO_L21N_T3L_N5_AD8N_68
set_property PACKAGE_PIN B14      [get_ports { c0_ddr4_dq[13] }] ;# Bank  68 VCCO - VCC1V2   - IO_L21P_T3L_N4_AD8P_68
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[13] }] ;# Bank  68 VCCO - VCC1V2   - IO_L21P_T3L_N4_AD8P_68
set_property PACKAGE_PIN C13      [get_ports { c0_ddr4_dq[15] }] ;# Bank  68 VCCO - VCC1V2   - IO_L20N_T3L_N3_AD1N_68
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[15] }] ;# Bank  68 VCCO - VCC1V2   - IO_L20N_T3L_N3_AD1N_68
set_property PACKAGE_PIN D13      [get_ports { c0_ddr4_dq[12] }] ;# Bank  68 VCCO - VCC1V2   - IO_L20P_T3L_N2_AD1P_68
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[12] }] ;# Bank  68 VCCO - VCC1V2   - IO_L20P_T3L_N2_AD1P_68
set_property PACKAGE_PIN C12      [get_ports { c0_ddr4_dm_dbi_n[1] }] ;# Bank  68 VCCO - VCC1V2   - IO_L19P_T3L_N0_DBC_AD9P_68
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dm_dbi_n[1] }] ;# Bank  68 VCCO - VCC1V2   - IO_L19P_T3L_N0_DBC_AD9P_68

set_property PACKAGE_PIN H10      [get_ports { c0_ddr4_dq[18] }] ;# Bank  68 VCCO - VCC1V2   - IO_L12N_T1U_N11_GC_68
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[18] }] ;# Bank  68 VCCO - VCC1V2   - IO_L12N_T1U_N11_GC_68
set_property PACKAGE_PIN H11      [get_ports { c0_ddr4_dq[23] }] ;# Bank  68 VCCO - VCC1V2   - IO_L12P_T1U_N10_GC_68
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[23] }] ;# Bank  68 VCCO - VCC1V2   - IO_L12P_T1U_N10_GC_68
set_property PACKAGE_PIN J10      [get_ports { c0_ddr4_dq[22] }] ;# Bank  68 VCCO - VCC1V2   - IO_L11N_T1U_N9_GC_68
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[22] }] ;# Bank  68 VCCO - VCC1V2   - IO_L11N_T1U_N9_GC_68
set_property PACKAGE_PIN J11      [get_ports { c0_ddr4_dq[17] }] ;# Bank  68 VCCO - VCC1V2   - IO_L11P_T1U_N8_GC_68
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[17] }] ;# Bank  68 VCCO - VCC1V2   - IO_L11P_T1U_N8_GC_68
set_property PACKAGE_PIN J13      [get_ports { c0_ddr4_dqs_c[2] }] ;# Bank  68 VCCO - VCC1V2   - IO_L10N_T1U_N7_QBC_AD4N_68
set_property IOSTANDARD  DIFF_POD12_DCI    [get_ports { c0_ddr4_dqs_c[2] }] ;# Bank  68 VCCO - VCC1V2   - IO_L10N_T1U_N7_QBC_AD4N_68
set_property PACKAGE_PIN J14      [get_ports { c0_ddr4_dqs_t[2] }] ;# Bank  68 VCCO - VCC1V2   - IO_L10P_T1U_N6_QBC_AD4P_68
set_property IOSTANDARD  DIFF_POD12_DCI    [get_ports { c0_ddr4_dqs_t[2] }] ;# Bank  68 VCCO - VCC1V2   - IO_L10P_T1U_N6_QBC_AD4P_68
set_property PACKAGE_PIN F10      [get_ports { c0_ddr4_dq[21] }] ;# Bank  68 VCCO - VCC1V2   - IO_L9N_T1L_N5_AD12N_68
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[21] }] ;# Bank  68 VCCO - VCC1V2   - IO_L9N_T1L_N5_AD12N_68
set_property PACKAGE_PIN F11      [get_ports { c0_ddr4_dq[19] }] ;# Bank  68 VCCO - VCC1V2   - IO_L9P_T1L_N4_AD12P_68
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[19] }] ;# Bank  68 VCCO - VCC1V2   - IO_L9P_T1L_N4_AD12P_68
set_property PACKAGE_PIN K10      [get_ports { c0_ddr4_dq[20] }] ;# Bank  68 VCCO - VCC1V2   - IO_L8N_T1L_N3_AD5N_68
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[20] }] ;# Bank  68 VCCO - VCC1V2   - IO_L8N_T1L_N3_AD5N_68
set_property PACKAGE_PIN K11      [get_ports { c0_ddr4_dq[16] }] ;# Bank  68 VCCO - VCC1V2   - IO_L8P_T1L_N2_AD5P_68
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[16] }] ;# Bank  68 VCCO - VCC1V2   - IO_L8P_T1L_N2_AD5P_68
set_property PACKAGE_PIN K13      [get_ports { c0_ddr4_dm_dbi_n[2] }] ;# Bank  68 VCCO - VCC1V2   - IO_L7P_T1L_N0_QBC_AD13P_68
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dm_dbi_n[2] }] ;# Bank  68 VCCO - VCC1V2   - IO_L7P_T1L_N0_QBC_AD13P_68

set_property PACKAGE_PIN F9       [get_ports { c0_ddr4_dq[26] }] ;# Bank  68 VCCO - VCC1V2   - IO_L6N_T0U_N11_AD6N_68
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[26] }] ;# Bank  68 VCCO - VCC1V2   - IO_L6N_T0U_N11_AD6N_68
set_property PACKAGE_PIN G9       [get_ports { c0_ddr4_dq[24] }] ;# Bank  68 VCCO - VCC1V2   - IO_L6P_T0U_N10_AD6P_68
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[24] }] ;# Bank  68 VCCO - VCC1V2   - IO_L6P_T0U_N10_AD6P_68
set_property PACKAGE_PIN G6       [get_ports { c0_ddr4_dq[27] }] ;# Bank  68 VCCO - VCC1V2   - IO_L5N_T0U_N9_AD14N_68
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[27] }] ;# Bank  68 VCCO - VCC1V2   - IO_L5N_T0U_N9_AD14N_68
set_property PACKAGE_PIN G7       [get_ports { c0_ddr4_dq[25] }] ;# Bank  68 VCCO - VCC1V2   - IO_L5P_T0U_N8_AD14P_68
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[25] }] ;# Bank  68 VCCO - VCC1V2   - IO_L5P_T0U_N8_AD14P_68
set_property PACKAGE_PIN G8       [get_ports { c0_ddr4_dqs_c[3] }] ;# Bank  68 VCCO - VCC1V2   - IO_L4N_T0U_N7_DBC_AD7N_68
set_property IOSTANDARD  DIFF_POD12_DCI    [get_ports { c0_ddr4_dqs_c[3] }] ;# Bank  68 VCCO - VCC1V2   - IO_L4N_T0U_N7_DBC_AD7N_68
set_property PACKAGE_PIN H8       [get_ports { c0_ddr4_dqs_t[3] }] ;# Bank  68 VCCO - VCC1V2   - IO_L4P_T0U_N6_DBC_AD7P_68
set_property IOSTANDARD  DIFF_POD12_DCI    [get_ports { c0_ddr4_dqs_t[3] }] ;# Bank  68 VCCO - VCC1V2   - IO_L4P_T0U_N6_DBC_AD7P_68
set_property PACKAGE_PIN H6       [get_ports { c0_ddr4_dq[28] }] ;# Bank  68 VCCO - VCC1V2   - IO_L3N_T0L_N5_AD15N_68
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[28] }] ;# Bank  68 VCCO - VCC1V2   - IO_L3N_T0L_N5_AD15N_68
set_property PACKAGE_PIN H7       [get_ports { c0_ddr4_dq[29] }] ;# Bank  68 VCCO - VCC1V2   - IO_L3P_T0L_N4_AD15P_68
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[29] }] ;# Bank  68 VCCO - VCC1V2   - IO_L3P_T0L_N4_AD15P_68
set_property PACKAGE_PIN J9       [get_ports { c0_ddr4_dq[30] }] ;# Bank  68 VCCO - VCC1V2   - IO_L2N_T0L_N3_68
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[30] }] ;# Bank  68 VCCO - VCC1V2   - IO_L2N_T0L_N3_68
set_property PACKAGE_PIN K9       [get_ports { c0_ddr4_dq[31] }] ;# Bank  68 VCCO - VCC1V2   - IO_L2P_T0L_N2_68
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[31] }] ;# Bank  68 VCCO - VCC1V2   - IO_L2P_T0L_N2_68
set_property PACKAGE_PIN J8       [get_ports { c0_ddr4_dm_dbi_n[3] }] ;# Bank  68 VCCO - VCC1V2   - IO_L1P_T0L_N0_DBC_68
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dm_dbi_n[3] }] ;# Bank  68 VCCO - VCC1V2   - IO_L1P_T0L_N0_DBC_68

set_property PACKAGE_PIN A21      [get_ports { c0_ddr4_dq[34] }] ;# Bank  67 VCCO - VCC1V2   - IO_L24N_T3U_N11_67
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[34] }] ;# Bank  67 VCCO - VCC1V2   - IO_L24N_T3U_N11_67
set_property PACKAGE_PIN A20      [get_ports { c0_ddr4_dq[33] }] ;# Bank  67 VCCO - VCC1V2   - IO_L24P_T3U_N10_67
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[33] }] ;# Bank  67 VCCO - VCC1V2   - IO_L24P_T3U_N10_67
set_property PACKAGE_PIN B20      [get_ports { c0_ddr4_dq[37] }] ;# Bank  67 VCCO - VCC1V2   - IO_L23N_T3U_N9_67
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[37] }] ;# Bank  67 VCCO - VCC1V2   - IO_L23N_T3U_N9_67
set_property PACKAGE_PIN C20      [get_ports { c0_ddr4_dq[39] }] ;# Bank  67 VCCO - VCC1V2   - IO_L23P_T3U_N8_67
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[39] }] ;# Bank  67 VCCO - VCC1V2   - IO_L23P_T3U_N8_67
set_property PACKAGE_PIN A22      [get_ports { c0_ddr4_dqs_c[4] }] ;# Bank  67 VCCO - VCC1V2   - IO_L22N_T3U_N7_DBC_AD0N_67
set_property IOSTANDARD  DIFF_POD12_DCI    [get_ports { c0_ddr4_dqs_c[4] }] ;# Bank  67 VCCO - VCC1V2   - IO_L22N_T3U_N7_DBC_AD0N_67
set_property PACKAGE_PIN B22      [get_ports { c0_ddr4_dqs_t[4] }] ;# Bank  67 VCCO - VCC1V2   - IO_L22P_T3U_N6_DBC_AD0P_67
set_property IOSTANDARD  DIFF_POD12_DCI    [get_ports { c0_ddr4_dqs_t[4] }] ;# Bank  67 VCCO - VCC1V2   - IO_L22P_T3U_N6_DBC_AD0P_67
set_property PACKAGE_PIN C22      [get_ports { c0_ddr4_dq[32] }] ;# Bank  67 VCCO - VCC1V2   - IO_L21N_T3L_N5_AD8N_67
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[32] }] ;# Bank  67 VCCO - VCC1V2   - IO_L21N_T3L_N5_AD8N_67
set_property PACKAGE_PIN C21      [get_ports { c0_ddr4_dq[35] }] ;# Bank  67 VCCO - VCC1V2   - IO_L21P_T3L_N4_AD8P_67
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[35] }] ;# Bank  67 VCCO - VCC1V2   - IO_L21P_T3L_N4_AD8P_67
set_property PACKAGE_PIN A24      [get_ports { c0_ddr4_dq[36] }] ;# Bank  67 VCCO - VCC1V2   - IO_L20N_T3L_N3_AD1N_67
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[36] }] ;# Bank  67 VCCO - VCC1V2   - IO_L20N_T3L_N3_AD1N_67
set_property PACKAGE_PIN B24      [get_ports { c0_ddr4_dq[38] }] ;# Bank  67 VCCO - VCC1V2   - IO_L20P_T3L_N2_AD1P_67
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[38] }] ;# Bank  67 VCCO - VCC1V2   - IO_L20P_T3L_N2_AD1P_67
set_property PACKAGE_PIN C23      [get_ports { c0_ddr4_dm_dbi_n[4] }] ;# Bank  67 VCCO - VCC1V2   - IO_L19P_T3L_N0_DBC_AD9P_67
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dm_dbi_n[4] }] ;# Bank  67 VCCO - VCC1V2   - IO_L19P_T3L_N0_DBC_AD9P_67

set_property PACKAGE_PIN D21      [get_ports { c0_ddr4_dq[47] }] ;# Bank  67 VCCO - VCC1V2   - IO_L18N_T2U_N11_AD2N_67
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[47] }] ;# Bank  67 VCCO - VCC1V2   - IO_L18N_T2U_N11_AD2N_67
set_property PACKAGE_PIN E21      [get_ports { c0_ddr4_dq[45] }] ;# Bank  67 VCCO - VCC1V2   - IO_L18P_T2U_N10_AD2P_67
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[45] }] ;# Bank  67 VCCO - VCC1V2   - IO_L18P_T2U_N10_AD2P_67
set_property PACKAGE_PIN E23      [get_ports { c0_ddr4_dq[42] }] ;# Bank  67 VCCO - VCC1V2   - IO_L17N_T2U_N9_AD10N_67
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[42] }] ;# Bank  67 VCCO - VCC1V2   - IO_L17N_T2U_N9_AD10N_67
set_property PACKAGE_PIN E22      [get_ports { c0_ddr4_dq[41] }] ;# Bank  67 VCCO - VCC1V2   - IO_L17P_T2U_N8_AD10P_67
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[41] }] ;# Bank  67 VCCO - VCC1V2   - IO_L17P_T2U_N8_AD10P_67
set_property PACKAGE_PIN D24      [get_ports { c0_ddr4_dqs_c[5] }] ;# Bank  67 VCCO - VCC1V2   - IO_L16N_T2U_N7_QBC_AD3N_67
set_property IOSTANDARD  DIFF_POD12_DCI    [get_ports { c0_ddr4_dqs_c[5] }] ;# Bank  67 VCCO - VCC1V2   - IO_L16N_T2U_N7_QBC_AD3N_67
set_property PACKAGE_PIN D23      [get_ports { c0_ddr4_dqs_t[5] }] ;# Bank  67 VCCO - VCC1V2   - IO_L16P_T2U_N6_QBC_AD3P_67
set_property IOSTANDARD  DIFF_POD12_DCI    [get_ports { c0_ddr4_dqs_t[5] }] ;# Bank  67 VCCO - VCC1V2   - IO_L16P_T2U_N6_QBC_AD3P_67
set_property PACKAGE_PIN E24      [get_ports { c0_ddr4_dq[40] }] ;# Bank  67 VCCO - VCC1V2   - IO_L15N_T2L_N5_AD11N_67
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[40] }] ;# Bank  67 VCCO - VCC1V2   - IO_L15N_T2L_N5_AD11N_67
set_property PACKAGE_PIN F24      [get_ports { c0_ddr4_dq[44] }] ;# Bank  67 VCCO - VCC1V2   - IO_L15P_T2L_N4_AD11P_67
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[44] }] ;# Bank  67 VCCO - VCC1V2   - IO_L15P_T2L_N4_AD11P_67
set_property PACKAGE_PIN F20      [get_ports { c0_ddr4_dq[46] }] ;# Bank  67 VCCO - VCC1V2   - IO_L14N_T2L_N3_GC_67
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[46] }] ;# Bank  67 VCCO - VCC1V2   - IO_L14N_T2L_N3_GC_67
set_property PACKAGE_PIN G20      [get_ports { c0_ddr4_dq[43] }] ;# Bank  67 VCCO - VCC1V2   - IO_L14P_T2L_N2_GC_67
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[43] }] ;# Bank  67 VCCO - VCC1V2   - IO_L14P_T2L_N2_GC_67

set_property PACKAGE_PIN F21      [get_ports { c0_ddr4_dm_dbi_n[5] }] ;# Bank  67 VCCO - VCC1V2   - IO_L13P_T2L_N0_GC_QBC_67
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dm_dbi_n[5] }] ;# Bank  67 VCCO - VCC1V2   - IO_L13P_T2L_N0_GC_QBC_67
set_property PACKAGE_PIN G23      [get_ports { c0_ddr4_dq[49] }] ;# Bank  67 VCCO - VCC1V2   - IO_L12N_T1U_N11_GC_67
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[49] }] ;# Bank  67 VCCO - VCC1V2   - IO_L12N_T1U_N11_GC_67
set_property PACKAGE_PIN H23      [get_ports { c0_ddr4_dq[48] }] ;# Bank  67 VCCO - VCC1V2   - IO_L12P_T1U_N10_GC_67
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[48] }] ;# Bank  67 VCCO - VCC1V2   - IO_L12P_T1U_N10_GC_67
set_property PACKAGE_PIN G22      [get_ports { c0_ddr4_dq[51] }] ;# Bank  67 VCCO - VCC1V2   - IO_L11N_T1U_N9_GC_67
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[51] }] ;# Bank  67 VCCO - VCC1V2   - IO_L11N_T1U_N9_GC_67
set_property PACKAGE_PIN H22      [get_ports { c0_ddr4_dq[53] }] ;# Bank  67 VCCO - VCC1V2   - IO_L11P_T1U_N8_GC_67
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[53] }] ;# Bank  67 VCCO - VCC1V2   - IO_L11P_T1U_N8_GC_67
set_property PACKAGE_PIN H20      [get_ports { c0_ddr4_dqs_c[6] }] ;# Bank  67 VCCO - VCC1V2   - IO_L10N_T1U_N7_QBC_AD4N_67
set_property IOSTANDARD  DIFF_POD12_DCI    [get_ports { c0_ddr4_dqs_c[6] }] ;# Bank  67 VCCO - VCC1V2   - IO_L10N_T1U_N7_QBC_AD4N_67
set_property PACKAGE_PIN J20      [get_ports { c0_ddr4_dqs_t[6] }] ;# Bank  67 VCCO - VCC1V2   - IO_L10P_T1U_N6_QBC_AD4P_67
set_property IOSTANDARD  DIFF_POD12_DCI    [get_ports { c0_ddr4_dqs_t[6] }] ;# Bank  67 VCCO - VCC1V2   - IO_L10P_T1U_N6_QBC_AD4P_67
set_property PACKAGE_PIN H21      [get_ports { c0_ddr4_dq[55] }] ;# Bank  67 VCCO - VCC1V2   - IO_L9N_T1L_N5_AD12N_67
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[55] }] ;# Bank  67 VCCO - VCC1V2   - IO_L9N_T1L_N5_AD12N_67
set_property PACKAGE_PIN J21      [get_ports { c0_ddr4_dq[52] }] ;# Bank  67 VCCO - VCC1V2   - IO_L9P_T1L_N4_AD12P_67
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[52] }] ;# Bank  67 VCCO - VCC1V2   - IO_L9P_T1L_N4_AD12P_67
set_property PACKAGE_PIN K24      [get_ports { c0_ddr4_dq[50] }] ;# Bank  67 VCCO - VCC1V2   - IO_L8N_T1L_N3_AD5N_67
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[50] }] ;# Bank  67 VCCO - VCC1V2   - IO_L8N_T1L_N3_AD5N_67
set_property PACKAGE_PIN L24      [get_ports { c0_ddr4_dq[54] }] ;# Bank  67 VCCO - VCC1V2   - IO_L8P_T1L_N2_AD5P_67
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[54] }] ;# Bank  67 VCCO - VCC1V2   - IO_L8P_T1L_N2_AD5P_67
set_property PACKAGE_PIN J23      [get_ports { c0_ddr4_dm_dbi_n[6] }] ;# Bank  67 VCCO - VCC1V2   - IO_L7P_T1L_N0_QBC_AD13P_67
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dm_dbi_n[6] }] ;# Bank  67 VCCO - VCC1V2   - IO_L7P_T1L_N0_QBC_AD13P_67

set_property PACKAGE_PIN L20      [get_ports { c0_ddr4_dq[57] }] ;# Bank  67 VCCO - VCC1V2   - IO_L6N_T0U_N11_AD6N_67
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[57] }] ;# Bank  67 VCCO - VCC1V2   - IO_L6N_T0U_N11_AD6N_67
set_property PACKAGE_PIN L19      [get_ports { c0_ddr4_dq[61] }] ;# Bank  67 VCCO - VCC1V2   - IO_L6P_T0U_N10_AD6P_67
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[61] }] ;# Bank  67 VCCO - VCC1V2   - IO_L6P_T0U_N10_AD6P_67
set_property PACKAGE_PIN L23      [get_ports { c0_ddr4_dq[56] }] ;# Bank  67 VCCO - VCC1V2   - IO_L5N_T0U_N9_AD14N_67
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[56] }] ;# Bank  67 VCCO - VCC1V2   - IO_L5N_T0U_N9_AD14N_67
set_property PACKAGE_PIN L22      [get_ports { c0_ddr4_dq[58] }] ;# Bank  67 VCCO - VCC1V2   - IO_L5P_T0U_N8_AD14P_67
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[58] }] ;# Bank  67 VCCO - VCC1V2   - IO_L5P_T0U_N8_AD14P_67
set_property PACKAGE_PIN K22      [get_ports { c0_ddr4_dqs_c[7] }] ;# Bank  67 VCCO - VCC1V2   - IO_L4N_T0U_N7_DBC_AD7N_67
set_property IOSTANDARD  DIFF_POD12_DCI    [get_ports { c0_ddr4_dqs_c[7] }] ;# Bank  67 VCCO - VCC1V2   - IO_L4N_T0U_N7_DBC_AD7N_67
set_property PACKAGE_PIN K21      [get_ports { c0_ddr4_dqs_t[7] }] ;# Bank  67 VCCO - VCC1V2   - IO_L4P_T0U_N6_DBC_AD7P_67
set_property IOSTANDARD  DIFF_POD12_DCI    [get_ports { c0_ddr4_dqs_t[7] }] ;# Bank  67 VCCO - VCC1V2   - IO_L4P_T0U_N6_DBC_AD7P_67
set_property PACKAGE_PIN L21      [get_ports { c0_ddr4_dq[59] }] ;# Bank  67 VCCO - VCC1V2   - IO_L3N_T0L_N5_AD15N_67
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[59] }] ;# Bank  67 VCCO - VCC1V2   - IO_L3N_T0L_N5_AD15N_67
set_property PACKAGE_PIN M20      [get_ports { c0_ddr4_dq[60] }] ;# Bank  67 VCCO - VCC1V2   - IO_L3P_T0L_N4_AD15P_67
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[60] }] ;# Bank  67 VCCO - VCC1V2   - IO_L3P_T0L_N4_AD15P_67
set_property PACKAGE_PIN M19      [get_ports { c0_ddr4_dq[62] }] ;# Bank  67 VCCO - VCC1V2   - IO_L2N_T0L_N3_67
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[62] }] ;# Bank  67 VCCO - VCC1V2   - IO_L2N_T0L_N3_67
set_property PACKAGE_PIN N19      [get_ports { c0_ddr4_dq[63] }] ;# Bank  67 VCCO - VCC1V2   - IO_L2P_T0L_N2_67
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dq[63] }] ;# Bank  67 VCCO - VCC1V2   - IO_L2P_T0L_N2_67
set_property PACKAGE_PIN N20      [get_ports { c0_ddr4_dm_dbi_n[7] }] ;# Bank  67 VCCO - VCC1V2   - IO_L1P_T0L_N0_DBC_67
set_property IOSTANDARD  POD12_DCI    [get_ports { c0_ddr4_dm_dbi_n[7] }] ;# Bank  67 VCCO - VCC1V2   - IO_L1P_T0L_N0_DBC_67

set_property -dict { PACKAGE_PIN AF16 IOSTANDARD LVCMOS18 } [get_ports { timingClkScl }]
set_property -dict { PACKAGE_PIN AF17 IOSTANDARD LVCMOS18 } [get_ports { timingClkSda }]

set_property -dict { PACKAGE_PIN AH15 IOSTANDARD LVCMOS18 } [get_ports { ddrScl }]
set_property -dict { PACKAGE_PIN AH16 IOSTANDARD LVCMOS18 } [get_ports { ddrSda }]

set_property -dict { PACKAGE_PIN AH17 IOSTANDARD LVCMOS18 } [get_ports { ipmcScl }]
set_property -dict { PACKAGE_PIN AG17 IOSTANDARD LVCMOS18 } [get_ports { ipmcSda }]

set_property -dict { PACKAGE_PIN AJ15 IOSTANDARD LVCMOS18 } [get_ports { calScl }]
set_property -dict { PACKAGE_PIN AJ16 IOSTANDARD LVCMOS18 } [get_ports { calSda }]

set_property -dict { PACKAGE_PIN AL17 IOSTANDARD LVDS } [get_ports { fabClkP }]
set_property -dict { PACKAGE_PIN AM17 IOSTANDARD LVDS } [get_ports { fabClkN }]

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

set_property -dict { PACKAGE_PIN W17 IOSTANDARD ANALOG } [get_ports { vPIn }]
set_property -dict { PACKAGE_PIN Y16 IOSTANDARD ANALOG } [get_ports { vNIn }]

create_clock -name ddrClk     -period  3.333  [get_ports {c0_sys_clk_p}]
create_clock -name fabClk     -period  8.000  [get_ports {fabClkP}]
create_clock -name ethRef     -period  6.400  [get_ports {ethClkP}]
create_clock -name timingRef  -period  2.691  [get_ports {timingRefClkInP}]

set_clock_groups -asynchronous \
   -group [get_clocks -include_generated_clocks {fabClk}] \
   -group [get_clocks -include_generated_clocks {ethRef}] \
   -group [get_clocks -include_generated_clocks {timingRef}] \
   -group [get_clocks -include_generated_clocks {ddrClk}] 
   
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_AmcCorePll/PllGen.U_Pll/CLKOUT0]] -group [get_clocks -of_objects [get_pins U_SysReg/U_Iprog/GEN_ULTRA_SCALE.IprogUltraScale_Inst/BUFGCE_DIV_Inst/O]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_AmcCorePll/PllGen.U_Pll/CLKOUT0]] -group [get_clocks -of_objects [get_pins U_SysReg/U_Version/GEN_DEVICE_DNA.DeviceDna_1/GEN_ULTRA_SCALE.DeviceDnaUltraScale_Inst/BUFGCE_DIV_Inst/O]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_AmcCorePll/PllGen.U_Pll/CLKOUT0]] -group [get_clocks fabClk]
   
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_Timing/TimingGthCoreWrapper_1/LOCREF_G.U_TimingGtyCore/inst/gen_gtwizard_gtye4_top.TimingGty_fixedlat_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[3].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLKPCS}]] -group [get_clocks -of_objects [get_pins U_Timing/TIMING_REFCLK_IBUFDS_GTE3/U_IBUFDS_GT/ODIV2]]

set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_Eth/ETH_10GbE.U_ETH/GEN_LANE[0].TenGigEthGtyUltraScale_Inst/U_TenGigEthGtyUltraScaleCore/inst/i_TenGigEthGtyUltraScale156p25MHzCore_gt/inst/gen_gtwizard_gtye4_top.TenGigEthGtyUltraScale156p25MHzCore_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[0].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/RXOUTCLK}]] -group [get_clocks ethRef]   
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_Eth/ETH_10GbE.U_ETH/GEN_LANE[0].TenGigEthGtyUltraScale_Inst/U_TenGigEthGtyUltraScaleCore/inst/i_TenGigEthGtyUltraScale156p25MHzCore_gt/inst/gen_gtwizard_gtye4_top.TenGigEthGtyUltraScale156p25MHzCore_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[0].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]] -group [get_clocks ethRef]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_Eth/ETH_10GbE.U_ETH/GEN_LANE[0].TenGigEthGtyUltraScale_Inst/U_TenGigEthGtyUltraScaleCore/inst/i_TenGigEthGtyUltraScale156p25MHzCore_gt/inst/gen_gtwizard_gtye4_top.TenGigEthGtyUltraScale156p25MHzCore_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[0].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/RXOUTCLK}]] -group [get_clocks -of_objects [get_pins {U_Eth/ETH_10GbE.U_ETH/GEN_LANE[0].TenGigEthGtyUltraScale_Inst/U_TenGigEthGtyUltraScaleCore/inst/i_TenGigEthGtyUltraScale156p25MHzCore_gt/inst/gen_gtwizard_gtye4_top.TenGigEthGtyUltraScale156p25MHzCore_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[0].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_Eth/ETH_10GbE.U_ETH/GEN_LANE[0].TenGigEthGtyUltraScale_Inst/U_TenGigEthGtyUltraScaleCore/inst/i_TenGigEthGtyUltraScale156p25MHzCore_gt/inst/gen_gtwizard_gtye4_top.TenGigEthGtyUltraScale156p25MHzCore_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[0].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLKPCS}]] -group [get_clocks -of_objects [get_pins {U_Eth/ETH_10GbE.U_ETH/GEN_LANE[0].TenGigEthGtyUltraScale_Inst/U_TenGigEthGtyUltraScaleCore/inst/i_TenGigEthGtyUltraScale156p25MHzCore_gt/inst/gen_gtwizard_gtye4_top.TenGigEthGtyUltraScale156p25MHzCore_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[0].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_Eth/ETH_10GbE.U_ETH/GEN_LANE[0].TenGigEthGtyUltraScale_Inst/U_TenGigEthGtyUltraScaleCore/inst/i_TenGigEthGtyUltraScale156p25MHzCore_gt/inst/gen_gtwizard_gtye4_top.TenGigEthGtyUltraScale156p25MHzCore_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[0].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLKPCS}]] -group [get_clocks ethRef]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_Eth/ETH_10GbE.U_ETH/GEN_LANE[0].TenGigEthGtyUltraScale_Inst/U_TenGigEthGtyUltraScaleCore/inst/i_TenGigEthGtyUltraScale156p25MHzCore_gt/inst/gen_gtwizard_gtye4_top.TenGigEthGtyUltraScale156p25MHzCore_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[0].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]] -group [get_clocks -of_objects [get_pins {U_Eth/ETH_10GbE.U_ETH/GEN_LANE[0].TenGigEthGtyUltraScale_Inst/U_TenGigEthGtyUltraScaleCore/inst/i_TenGigEthGtyUltraScale156p25MHzCore_gt/inst/gen_gtwizard_gtye4_top.TenGigEthGtyUltraScale156p25MHzCore_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[0].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/RXOUTCLK}]]

set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_Eth/ETH_1GbE.U_ETH/U_MMCM/MmcmGen.U_Mmcm/CLKOUT1]] -group [get_clocks -of_objects [get_pins {U_Eth/ETH_1GbE.U_ETH/GEN_LANE[0].U_GigEthGtyUltraScale/U_GigEthGtyUltraScaleCore/U0/transceiver_inst/GigEthGtyUltraScaleCore_gt_i/inst/gen_gtwizard_gtye4_top.GigEthGtyUltraScaleCore_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[2].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_Eth/ETH_1GbE.U_ETH/GEN_LANE[0].U_GigEthGtyUltraScale/U_GigEthGtyUltraScaleCore/U0/transceiver_inst/GigEthGtyUltraScaleCore_gt_i/inst/gen_gtwizard_gtye4_top.GigEthGtyUltraScaleCore_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[2].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]] -group [get_clocks -of_objects [get_pins U_Eth/ETH_1GbE.U_ETH/U_MMCM/MmcmGen.U_Mmcm/CLKOUT1]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_Eth/ETH_1GbE.U_ETH/GEN_LANE[0].U_GigEthGtyUltraScale/U_GigEthGtyUltraScaleCore/U0/transceiver_inst/GigEthGtyUltraScaleCore_gt_i/inst/gen_gtwizard_gtye4_top.GigEthGtyUltraScaleCore_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[2].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLKPCS}]] -group [get_clocks -of_objects [get_pins U_Eth/ETH_1GbE.U_ETH/U_MMCM/MmcmGen.U_Mmcm/CLKOUT1]]

set_property BITSTREAM.CONFIG.OVERTEMPSHUTDOWN ENABLE [current_design]

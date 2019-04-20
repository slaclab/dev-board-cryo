create_clock -name ethRefClk   -period 6.4        [get_ports {refClkP[0]}]

set_false_path -from [get_ports {gpioDip[3]}]

set_clock_groups -asynchronous -group [get_clocks ethRefClk] -group [get_clocks -of_objects [get_pins {GEN_10G_GTH.U_10GigE/GEN_LANE[0].TenGigEthGthUltraScale_Inst/U_TenGigEthRst/CLK156_BUFG_GT/O}]]
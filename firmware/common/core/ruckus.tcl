# Load RUCKUS library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load Source Code
loadSource -dir  "$::DIR_PATH/rtl/"

# ILA DCP
loadSource -path "$::DIR_PATH/dcp/ila_0.dcp"
loadSource -path "$::DIR_PATH/dcp/ila_1.dcp"

# Load Simulation
loadSource -sim_only -dir "$::DIR_PATH/tb/"

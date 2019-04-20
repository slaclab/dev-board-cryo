# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Set the Xilinx Board type
set_property board_part xilinx.com:zcu111:part0:1.1 [current_project]

# Load common and sub-module ruckus.tcl files
loadRuckusTcl $::env(TOP_DIR)/submodules/surf
loadRuckusTcl $::env(TOP_DIR)/submodules/lcls-timing-core

loadSource -path "$::env(TOP_DIR)/submodules/amc-carrier-core/AmcCarrierCore/core/AmcCarrierBsa.vhd"
loadSource -path "$::env(TOP_DIR)/submodules/amc-carrier-core/AmcCarrierCore/core/AmcCarrierBsi.vhd"
loadSource -path "$::env(TOP_DIR)/submodules/amc-carrier-core/AmcCarrierCore/core/AmcCarrierPkg.vhd"
loadSource -path "$::env(TOP_DIR)/submodules/amc-carrier-core/AmcCarrierCore/core/AmcCarrierSysMon.vhd"
loadSource -path "$::env(TOP_DIR)/submodules/amc-carrier-core/AmcCarrierCore/core/AmcCarrierSysReg.vhd"
loadSource -path "$::env(TOP_DIR)/submodules/amc-carrier-core/AmcCarrierCore/core/AmcCarrierSysRegPkg.vhd"
loadSource -path "$::env(TOP_DIR)/submodules/amc-carrier-core/AmcCarrierCore/core/AmcCarrierTiming.vhd"
loadSource -path "$::env(TOP_DIR)/submodules/amc-carrier-core/AmcCarrierCore/core/kintexuplus/AmcCarrierIbufGt.vhd"

loadSource -path "$::env(TOP_DIR)/submodules/amc-carrier-core/AmcCarrierCore/non-fsbl/AmcCarrierRssi.vhd"
loadSource -path "$::env(TOP_DIR)/submodules/amc-carrier-core/AmcCarrierCore/non-fsbl/AmcCarrierRssiInterleave.vhd"
loadSource -path "$::env(TOP_DIR)/submodules/amc-carrier-core/AmcCarrierCore/non-fsbl/AmcCarrierXvcDebug.vhd"

loadSource -dir "$::env(TOP_DIR)/submodules/amc-carrier-core/AppMps/rtl"
loadSource -dir "$::env(TOP_DIR)/submodules/amc-carrier-core/AppTop/rtl"
loadRuckusTcl $::env(TOP_DIR)/submodules/amc-carrier-core/AxisBramRingBuffer
loadRuckusTcl $::env(TOP_DIR)/submodules/amc-carrier-core/BsaCore
loadRuckusTcl $::env(TOP_DIR)/submodules/amc-carrier-core/DacSigGen
loadRuckusTcl $::env(TOP_DIR)/submodules/amc-carrier-core/DaqMuxV2

# Load local source Code and constraints
loadSource      -dir  "$::DIR_PATH/hdl"
loadConstraints -dir  "$::DIR_PATH/hdl"
loadIpCore      -dir  "$::DIR_PATH/ip"
loadIpCore      -path "$::env(TOP_DIR)/submodules/amc-carrier-core/AmcCarrierCore/ip/SysMonCore.xci"
loadSource      -path "$::env(TOP_DIR)/submodules/amc-carrier-core/BsaCore/cores/BsaAxiInterconnect/xilinxUltraScale/BsaAxiInterconnect.dcp"

# Load the XVC code
if { [info exists ::env(USE_XVC_DEBUG)] != 1 || $::env(USE_XVC_DEBUG) == 0 } {
	loadSource -path "$::env(TOP_DIR)/submodules/amc-carrier-core/AmcCarrierCore/debug/dcp/Stub/images/UdpDebugBridge.dcp"
   set_property IS_GLOBAL_INCLUDE {1} [get_files UdpDebugBridge.dcp]
} elseif { $::env(USE_XVC_DEBUG) == -1 } {
} else {
	loadSource -path "$::env(TOP_DIR)/submodules/amc-carrier-core/AmcCarrierCore/debug/dcp/Impl/images/UdpDebugBridge.dcp"
   set_property IS_GLOBAL_INCLUDE {1} [get_files UdpDebugBridge.dcp]
}

# Place and Route strategies 
set_property strategy Performance_Explore [get_runs impl_1]
set_property STEPS.OPT_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1]

# Skip the utilization check during placement
set_param place.skipUtilizationCheck 1

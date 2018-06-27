# Load RUCKUS library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load the Core
loadRuckusTcl "$::DIR_PATH/AppTop"

if { [file exists "$::DIR_PATH/core/ruckus.tcl"] == 1 } {
    # use the user's AppCore if it's there
	loadRuckusTcl "$::DIR_PATH/core"
} else {
	# otherwise fall back on the stub
	loadRuckusTcl "$::DIR_PATH/coreStub"
}

# Get the family type
set family [getFpgaFamily]

if { ${family} == "artix7" } {
   loadRuckusTcl "$::DIR_PATH/7Series"
}

if { ${family} == "kintex7" } {
   loadRuckusTcl "$::DIR_PATH/7Series"
}

if { ${family} == "virtex7" } {
   loadRuckusTcl "$::DIR_PATH/7Series"
}

if { ${family} == "zynq" } {
   loadRuckusTcl "$::DIR_PATH/7Series"
}

if { ${family} == "kintexu" } {
   loadRuckusTcl "$::DIR_PATH/UltraScale"
}

# workaround for PyRogue
exec rm -rf $::DIR_PATH/python

exec cp -r $::DIR_PATH/pyrogue $::DIR_PATH/python
exec cp -r $::DIR_PATH/../submodules/amc-carrier-core/python/AmcCarrierCore     $::DIR_PATH/python/.
exec cp -r $::DIR_PATH/../submodules/amc-carrier-core/python/AppMps             $::DIR_PATH/python/.
exec cp -r $::DIR_PATH/../submodules/amc-carrier-core/python/AxisBramRingBuffer $::DIR_PATH/python/.
exec cp -r $::DIR_PATH/../submodules/amc-carrier-core/python/BsaCore            $::DIR_PATH/python/.
exec cp -r $::DIR_PATH/../submodules/amc-carrier-core/python/DacSigGen          $::DIR_PATH/python/.
exec cp -r $::DIR_PATH/../submodules/amc-carrier-core/python/DaqMuxV2 $::DIR_PATH/python/.

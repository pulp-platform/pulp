#!/usr/bin/env tclsh

source ./tcl_files/config/vsim_ips.tcl
source ./tcl_files/config/vsim_rtl.tcl

proc color {foreground text} {
    # tput is a little Unix utility that lets you use the termcap database
    # *much* more easily...
    return [exec tput setaf $foreground]$text[exec tput sgr0]
}

if {[catch {
  info exists $::env(VSIM_PATH)
}]} {
  puts [concat [color 1 "ERROR"] ": You should have the PULP SDK in your path before building the RTL platform."]
  exit 1
}

eval exec vlib $::env(VSIM_PATH)/modelsim_libs/work
eval exec vmap work $::env(VSIM_PATH)/modelsim_libs/work
if {[info exists ::env(VSIM_PATH)]} {
    eval exec >@stdout vopt +acc=mnpr -o vopt_tb tb_pulp -floatparameters+tb_pulp -Ldir $::env(VSIM_PATH)/modelsim_libs $VSIM_IP_LIBS $VSIM_RTL_LIBS -work work
} else {
    eval exec >@stdout vopt +acc=mnpr -o vopt_pulp_chip pulp_chip $VSIM_IP_LIBS $VSIM_RTL_LIBS -work pulpissimo_lib
}


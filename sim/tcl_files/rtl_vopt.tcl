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
  puts [concat [color 1 "ERROR"] ": VSIM_PATH should be defined before building the RTL platform."]
  exit 1
}
eval exec vlib $::env(VSIM_PATH)/modelsim_libs/tb_lib
eval exec vmap work $::env(VSIM_PATH)/modelsim_libs/tb_lib

set sub_str "-L ${::env(VSIM_PATH)}/modelsim_libs/"
set VSIM_IP_LIBS  [regsub -all -- "-L " $VSIM_IP_LIBS $sub_str]
set VSIM_RTL_LIBS [regsub -all -- "-L " $VSIM_RTL_LIBS $sub_str]

if {[info exists ::env(VSIM_PATH)]} {
    #eval exec >@stdout vopt +acc=mnpr -o vopt_tb tb_pulp -floatparameters+tb_pulp -Ldir $::env(VSIM_PATH)/modelsim_libs $VSIM_IP_LIBS $VSIM_RTL_LIBS -work work  
    eval exec >@stdout vopt +acc=mnpr -o vopt_tb tb_pulp -floatparameters+tb_pulp  $VSIM_IP_LIBS $VSIM_RTL_LIBS -work work 
} else {
    eval exec >@stdout vopt +acc=mnpr -o vopt_pulp_chip pulp_chip $VSIM_IP_LIBS $VSIM_RTL_LIBS -work pulpissimo_lib
}


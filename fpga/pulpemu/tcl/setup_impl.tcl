# setup
if [info exists ::env(SDK_WORKSPACE)] {
    set SDK_WORKSPACE $::env(SDK_WORKSPACE)
}


# detect board
if [info exists ::env(BOARD)] {
    set BOARD $::env(BOARD)
} else {
    puts "Please execute 'source ../sourceme.sh first before you start vivado in order to setup necessary environment variables."
    exit
}
if [info exists ::env(XILINX_BOARD)] {
    set XILINX_BOARD $::env(XILINX_BOARD)
}

# create project
create_project pulpemu . -force -part $::env(XILINX_PART)
set_property board_part $::env(XILINX_BOARD) [current_project]

# set up meaningful errors
source ../common/messages.tcl

#include ip inc dirs
source tcl/ips_inc_dirs.tcl
source tcl/rtl_inc_dirs.tcl
set_property include_dirs $INCLUDE_DIRS [current_fileset]

# setup source files
source tcl/ips_src_files.tcl
source tcl/rtl_src_files.tcl

# add IPs
source tcl/ips_add_files.tcl
source tcl/rtl_add_files.tcl


# add memory cuts + other FPGA IPs
read_ip $FPGA_IPS/xilinx_interleaved_ram/ip/xilinx_interleaved_ram.xci
read_ip $FPGA_IPS/xilinx_private_ram/ip/xilinx_private_ram.xci
read_ip $FPGA_IPS/xilinx_rom_bank_2048x32/ip/xilinx_rom_bank_2048x32.xci
read_ip $FPGA_IPS/xilinx_clk_mngr/ip/xilinx_clk_mngr.xci
read_ip $FPGA_IPS/xilinx_slow_clk_mngr/ip/xilinx_slow_clk_mngr.xci



# add pulp_cluster
catch {
add_files -norecurse ../pulp_cluster/pulp_cluster.edf \
                     ../pulp_cluster/pulp_cluster_stub.v
}

# needed only if used in batch mode
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# add constraints
add_files -fileset constrs_1 -norecurse tcl/constraints.xdc
set_property target_constrs_file tcl/constraints.xdc [current_fileset -constrset]
add_files -fileset constrs_1 -norecurse "tcl/fmc_board_$::env(BOARD).xdc"
set_property target_constrs_file "tcl/fmc_board_$::env(BOARD).xdc" [current_fileset -constrset]

# workaround for Maestro packages
set_property source_mgmt_mode DisplayOnly [current_project]

# set pulpemu as top
set_property top pulpemu [current_fileset]

# elaborate
set_msg_config -id {Synth 8-350} -new_severity {CRITICAL WARNING}


save_constraints


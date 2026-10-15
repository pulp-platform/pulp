
source tcl/common.tcl

set PROJECT pulp-$BOARD
set RTL ../../../rtl
set CONSTRS constraints
set FPGA_RTL rtl
set FPGA_IPS ips


# It fixes the long delays during update_compile_order step
set_param project.hsv.draftModeDefault only

# create project
create_project $PROJECT . -force -part $::env(XILINX_PART)
set_property board_part $XILINX_BOARD [current_project]
set_property XPM_LIBRARIES XPM_MEMORY [current_project]

# Add sources
source tcl/add_sources.tcl

# detect target clock
if [info exists ::env(FC_CLK_PERIOD_NS)] {
    set FC_CLK_PERIOD_NS $::env(FC_CLK_PERIOD_NS)
} else {
    set FC_CLK_PERIOD_NS 10.000
}
set CLK_HALFPERIOD_NS [expr ${FC_CLK_PERIOD_NS} / 2.0]

# Add toplevel wrapper
add_files -norecurse ../pulp-$BOARD/rtl/xilinx_pulp.v

# Add Xilinx IPs
read_ip $FPGA_IPS/xilinx_clk_mngr/xilinx_clk_mngr.srcs/sources_1/ip/xilinx_clk_mngr/xilinx_clk_mngr.xci
read_ip $FPGA_IPS/xilinx_slow_clk_mngr/xilinx_slow_clk_mngr.srcs/sources_1/ip/xilinx_slow_clk_mngr/xilinx_slow_clk_mngr.xci
read_ip $FPGA_IPS/vio/xilinx_vio.srcs/sources_1/ip/xilinx_vio/xilinx_vio.xci
read_ip $FPGA_IPS/xilinx_clk_wiz/xlnx_clk_wiz.srcs/sources_1/ip/xlnx_clk_wiz/xlnx_clk_wiz.xci

# set pulp as top
set_property top xilinx_pulp [current_fileset]; #

# needed only if used in batch mode
update_compile_order -fileset sources_1

# Add constraints
add_files -fileset constrs_1 -norecurse ../pulp-$BOARD/$CONSTRS/$BOARD.xdc

# Elaborate design
synth_design -rtl -name rtl_1 -gated_clock_conversion on -sfcu;# sfcu -> run synthesis in single file compilation unit mode

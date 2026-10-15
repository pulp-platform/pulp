# Copyright 2023 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Cyril Koenig <cykoenig@iis.ee.ethz.ch>

source ../../tcl/common.tcl

set ipName xlnx_clk_wiz

create_project $ipName . -force -part $partNumber
set_property board_part $XILINX_BOARD [current_project]

create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 -module_name $ipName

set_property -dict  [list CONFIG.PRIM_SOURCE {No_buffer} \
                            CONFIG.PRIM_IN_FREQ {125.000} \
                            CONFIG.CLKOUT1_USED {true} \
                            CONFIG.CLKOUT2_USED {true} \
                            CONFIG.CLKOUT3_USED {true} \
                            CONFIG.CLKOUT4_USED {true} \
                            CONFIG.CLK_OUT1_PORT {clk_100} \
                            CONFIG.CLK_OUT2_PORT {clk_50} \
                            CONFIG.CLK_OUT3_PORT {clk_20} \
                            CONFIG.CLK_OUT4_PORT {clk_10} \
                            CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {100.000} \
                            CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {50.000} \
                            CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {20.000} \
                            CONFIG.CLKOUT4_REQUESTED_OUT_FREQ {10.000} \
                            CONFIG.CLKIN1_JITTER_PS {33.330000000000005} \
                            CONFIG.MMCM_CLKFBOUT_MULT_F {4.000} \
                            CONFIG.MMCM_CLKIN1_PERIOD {8.0} \
                            CONFIG.MMCM_CLKOUT1_DIVIDE {12} \
                            CONFIG.MMCM_CLKOUT2_DIVIDE {24} \
                            CONFIG.MMCM_CLKOUT3_DIVIDE {60} \
                            CONFIG.MMCM_CLKOUT4_DIVIDE {120} \
                            CONFIG.NUM_OUT_CLKS {4} \
                            CONFIG.CLKOUT1_JITTER {134.506} \
                            CONFIG.CLKOUT1_PHASE_ERROR {154.678} \
                            CONFIG.CLKOUT2_JITTER {153.164} \
                            CONFIG.CLKOUT2_PHASE_ERROR {154.678} \
                            CONFIG.CLKOUT3_JITTER {184.746} \
                            CONFIG.CLKOUT3_PHASE_ERROR {154.678} \
                            CONFIG.CLKOUT4_JITTER {213.887} \
                            CONFIG.CLKOUT4_PHASE_ERROR {154.678} \
                    ] [get_ips $ipName]

generate_target {instantiation_template} [get_files ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
generate_target all [get_files  ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
create_ip_run [get_files -of_objects [get_fileset sources_1] ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
launch_run -jobs 8 ${ipName}_synth_1
wait_on_run ${ipName}_synth_1
source ../../tcl/common.tcl

set ipName xilinx_vio

create_project $ipName . -part $partNumber
set_property board_part $XILINX_BOARD [current_project]

create_ip -name vio -vendor xilinx.com -library ip -version 3.0 -module_name $ipName
set_property -dict [list \
                        CONFIG.C_NUM_PROBE_OUT {1} \
                        CONFIG.C_PROBE_OUT0_INIT_VAL {0x1} \
                        CONFIG.C_EN_PROBE_IN_ACTIVITY {0} \
                        CONFIG.C_NUM_PROBE_IN {0} \
                    ] [get_ips $ipName]

generate_target all [get_files  ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
create_ip_run [get_files -of_objects [get_fileset sources_1] ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
launch_run -jobs 12 ${ipName}_synth_1
wait_on_run ${ipName}_synth_1
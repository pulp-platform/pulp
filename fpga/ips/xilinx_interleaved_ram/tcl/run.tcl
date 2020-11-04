set partNumber $::env(XILINX_PART)
set boardName  $::env(XILINX_BOARD)

# detect target ram size
if [info exists ::env(INTERLEAVED_BANK_SIZE)] {
    set INTERLEAVED_BANK_SIZE $::env(INTERLEAVED_BANK_SIZE)
} else {
    set INTERLEAVED_BANK_SIZE 28672
}

set ipName xilinx_interleaved_ram

create_project $ipName . -part $partNumber
set_property board_part $boardName [current_project]

create_ip -name blk_mem_gen -vendor xilinx.com -library ip -module_name $ipName

set_property -dict [eval list CONFIG.Use_Byte_Write_Enable {true} \
                     CONFIG.Byte_Size {8} \
                     CONFIG.Write_Width_A {32} \
                     CONFIG.Write_Depth_A {$INTERLEAVED_BANK_SIZE} \
                     CONFIG.Read_Width_A {32} \
                     CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
                    ] [get_ips $ipName]

generate_target all [get_files  ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
create_ip_run [get_files -of_objects [get_fileset sources_1] ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
launch_run -jobs 8 ${ipName}_synth_1
wait_on_run ${ipName}_synth_1

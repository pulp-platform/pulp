open_hw

connect_hw_server  -url localhost:3121

open_hw_target
current_hw_device [get_hw_devices xcvu9p_0]
set_property PROGRAM.FILE {./board/vcu118/pulpemu.bit} [get_hw_devices xcvu9p_0]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices xcvu9p_0] 0]
create_hw_cfgmem -hw_device [lindex [get_hw_devices] 0] -mem_dev [lindex [get_cfgmem_parts {mt25qu01g-spi-x1_x2_x4_x8}] 0]
set_property FULL_PROBES.FILE {} [get_hw_devices xcvu9p_0]
program_hw_devices [get_hw_devices xcvu9p_0]
refresh_hw_device [lindex [get_hw_devices xcvu9p_0] 0]
exit

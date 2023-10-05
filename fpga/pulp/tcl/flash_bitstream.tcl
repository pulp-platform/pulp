open_hw_manager
connect_hw_server -allow_non_jtag
open_hw_target
set_property PROGRAM.FILE ../pulp_${::env(BOARD)}.bit [get_hw_devices xczu9_0]
current_hw_device [get_hw_devices $::env(XILINX_FPGA_DEV)]
set_property PROBES.FILE {} [get_hw_devices $::env(XILINX_FPGA_DEV)]
set_property FULL_PROBES.FILE {} [get_hw_devices $::env(XILINX_FPGA_DEV)]
program_hw_devices [get_hw_devices $::env(XILINX_FPGA_DEV)]
refresh_hw_device [lindex [get_hw_devices $::env(XILINX_FPGA_DEV)] 0]

set CLK_PERIOD 10.000
set CLK_WAVEFORM { 0.000 5.000 }

create_project pulpemu_top . -part xc7z045ffg900-2
set_property board xilinx.com:zynq:zc706:1.1 [current_project]
set_property design_mode GateLvl [current_fileset]
add_files -norecurse ./pulpemu.edf
add_files -norecurse ../ulpcluster/ulpcluster.edf
add_files -norecurse ../ips/xilinx_tcdm_bank_512x32/ip/xilinx_tcdm_bank_512x32.dcp
add_files -norecurse ../ips/xilinx_l2_mem_8192x64/ip/xilinx_l2_mem_8192x64.dcp
add_files -norecurse ../ips/xilinx_tcdm_bank_256x32/ip/xilinx_tcdm_bank_256x32.dcp
add_files -norecurse ../ips/xilinx_ic_ram_128x32/ip/xilinx_ic_ram_128x32.dcp
add_files -norecurse ../ips/xilinx_core_ila/ip/xilinx_core_ila.dcp
add_files -norecurse ../ips/xilinx_icache_ila/ip/xilinx_icache_ila.dcp
add_files -norecurse ../ips/xilinx_tcdm_scm_ila/ip/xilinx_tcdm_scm_ila.dcp
add_files -norecurse ../ips/xilinx_tcdm_sram_ila/ip/xilinx_tcdm_sram_ila.dcp
set_property top pulpemu [current_fileset]
link_design -name netlist_1

# false paths
source tcl/false_paths.tcl

# clocks
create_clock -period ${CLK_PERIOD} -name ref_clk_i  -waveform ${CLK_WAVEFORM} [get_nets {ref_clk_i}]
create_clock -period ${CLK_PERIOD} -name ps7_clk -waveform ${CLK_WAVEFORM} [get_pins {ps7_wrapper_i/ps7_i/processing_system7_0/inst/PS7_i/FCLKCLK[0]}]
create_clock -period ${CLK_PERIOD} -name ulpsoc_clk -waveform ${CLK_WAVEFORM} [get_nets {ulpsoc_i/i_clk_rst_gen/clk_manager_i/clk_o}]
create_clock -period 100 -name spi_clk -waveform { 0.0 50.0 } [ get_nets {spi_slave_clk_r}]

# pins
set_property package_pin AJ21    [get_ports PULP_SPI_clk]
set_property is_loc_fixed true   [get_ports [list  PULP_SPI_clk]]
set_property IOSTANDARD LVCMOS25 [get_ports PULP_SPI_clk]
set_property PULLTYPE NONE       [get_ports PULP_SPI_clk]
set_property package_pin AK12    [get_ports PULP_SPI_cs]
set_property is_loc_fixed true   [get_ports [list  PULP_SPI_cs]]
set_property IOSTANDARD LVCMOS25 [get_ports PULP_SPI_cs]
set_property PULLTYPE PULLUP     [get_ports PULP_SPI_cs]
set_property package_pin AA13    [get_ports PULP_SPI_sdo]
set_property is_loc_fixed true   [get_ports [list  PULP_SPI_sdo]]
set_property IOSTANDARD LVCMOS25 [get_ports PULP_SPI_sdo]
set_property PULLTYPE PULLUP     [get_ports PULP_SPI_sdo]
set_property package_pin AH18    [get_ports PULP_SPI_sdi]
set_property is_loc_fixed true   [get_ports [list  PULP_SPI_sdi]]
set_property IOSTANDARD LVCMOS25 [get_ports PULP_SPI_sdi]
set_property PULLTYPE PULLUP     [get_ports PULP_SPI_sdi]
set_property package_pin Y20     [get_ports PULP_SPI_mode_1]
set_property is_loc_fixed true   [get_ports [list  PULP_SPI_mode_1]]
set_property IOSTANDARD LVCMOS25 [get_ports PULP_SPI_mode_1]
set_property PULLTYPE PULLUP     [get_ports PULP_SPI_mode_1]
set_property package_pin AA20    [get_ports PULP_SPI_mode_0]
set_property is_loc_fixed true   [get_ports [list  PULP_SPI_mode_0]]
set_property IOSTANDARD LVCMOS25 [get_ports PULP_SPI_mode_0]
set_property PULLTYPE PULLUP     [get_ports PULP_SPI_mode_0]
#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets PULP_SPI_clk_IBUF]

save_constraints

#source tcl/probes.tcl

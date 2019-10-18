#######################################
#  _______ _           _              #
# |__   __(_)         (_)             #
#    | |   _ _ __ ___  _ _ __   __ _  #
#    | |  | | '_ ` _ \| | '_ \ / _` | #
#    | |  | | | | | | | | | | | (_| | #
#    |_|  |_|_| |_| |_|_|_| |_|\__, | #
#                               __/ | #
#                              |___/  #
#######################################


#Create constraint for the clock input of the nexys video board
create_clock -period 10.000 -name ref_clk [get_ports sys_clk]

#I2S and CAM interface are not used in this FPGA port. Set constraints to
#disable the clock
set_case_analysis 0 i_pulpissimo/safe_domain_i/cam_pclk_o
set_case_analysis 0 i_pulpissimo/safe_domain_i/i2s_slave_sck_o
#set_input_jitter tck 1.000

## JTAG
create_clock -period 100.000 -name tck -waveform {0.000 50.000} [get_ports pad_jtag_tck]
set_input_jitter tck 1.000


# minimize routing delay
set_input_delay -clock tck -clock_fall 5.000 [get_ports pad_jtag_tdi]
set_input_delay -clock tck -clock_fall 5.000 [get_ports pad_jtag_tms]
set_output_delay -clock tck 5.000 [get_ports pad_jtag_tdo]
set_false_path -from [get_ports pad_jtag_trst]

set_max_delay -to [get_ports pad_jtag_tdo] 20.000
set_max_delay -from [get_ports pad_jtag_tms] 20.000
set_max_delay -from [get_ports pad_jtag_tdi] 20.000
set_max_delay -from [get_ports pad_jtag_trst] 20.000

set_max_delay -datapath_only -from [get_pins i_pulpissimo/soc_domain_i/pulp_soc_i/i_dmi_jtag/i_dmi_cdc/i_cdc_resp/i_src/data_src_q_reg*/C] -to [get_pins i_pulpissimo/soc_domain_i/pulp_soc_i/i_dmi_jtag/i_dmi_cdc/i_cdc_resp/i_dst/data_dst_q_reg*/D] 20.000
set_max_delay -datapath_only -from [get_pins i_pulpissimo/soc_domain_i/pulp_soc_i/i_dmi_jtag/i_dmi_cdc/i_cdc_resp/i_src/req_src_q_reg/C] -to [get_pins i_pulpissimo/soc_domain_i/pulp_soc_i/i_dmi_jtag/i_dmi_cdc/i_cdc_resp/i_dst/req_dst_q_reg/D] 20.000
set_max_delay -datapath_only -from [get_pins i_pulpissimo/soc_domain_i/pulp_soc_i/i_dmi_jtag/i_dmi_cdc/i_cdc_req/i_dst/ack_dst_q_reg/C] -to [get_pins i_pulpissimo/soc_domain_i/pulp_soc_i/i_dmi_jtag/i_dmi_cdc/i_cdc_req/i_src/ack_src_q_reg/D] 20.000


# reset signal
set_false_path -from [get_ports pad_reset_n]

# Set ASYNC_REG attribute for ff synchronizers to place them closer together and
# increase MTBF
set_property ASYNC_REG true [get_cells i_pulpissimo/soc_domain_i/pulp_soc_i/soc_peripherals_i/apb_adv_timer_i/u_tim0/u_in_stage/r_ls_clk_sync_reg*]
set_property ASYNC_REG true [get_cells i_pulpissimo/soc_domain_i/pulp_soc_i/soc_peripherals_i/apb_adv_timer_i/u_tim1/u_in_stage/r_ls_clk_sync_reg*]
set_property ASYNC_REG true [get_cells i_pulpissimo/soc_domain_i/pulp_soc_i/soc_peripherals_i/apb_adv_timer_i/u_tim2/u_in_stage/r_ls_clk_sync_reg*]
set_property ASYNC_REG true [get_cells i_pulpissimo/soc_domain_i/pulp_soc_i/soc_peripherals_i/apb_adv_timer_i/u_tim3/u_in_stage/r_ls_clk_sync_reg*]
set_property ASYNC_REG true [get_cells i_pulpissimo/soc_domain_i/pulp_soc_i/soc_peripherals_i/i_apb_timer_unit/s_ref_clk*]
set_property ASYNC_REG true [get_cells i_pulpissimo/soc_domain_i/pulp_soc_i/soc_peripherals_i/i_ref_clk_sync/i_pulp_sync/r_reg_reg*]
set_property ASYNC_REG true [get_cells i_pulpissimo/soc_domain_i/pulp_soc_i/soc_peripherals_i/u_evnt_gen/r_ls_sync_reg*]

# Create asynchronous clock group between slow-clk and SoC clock. Those clocks
# are considered asynchronously and proper synchronization regs are in place
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins i_pulpissimo/safe_domain_i/i_slow_clk_gen/i_slow_clk_mngr/inst/mmcm_adv_inst/CLKOUT0]] -group [get_clocks -of_objects [get_pins i_pulpissimo/soc_domain_i/pulp_soc_i/i_clk_rst_gen/i_fpga_clk_gen/i_clk_manager/inst/mmcm_adv_inst/CLKOUT0]]


#############################################################
#  _____ ____         _____      _   _   _                  #
# |_   _/ __ \       / ____|    | | | | (_)                 #
#   | || |  | |_____| (___   ___| |_| |_ _ _ __   __ _ ___  #
#   | || |  | |______\___ \ / _ \ __| __| | '_ \ / _` / __| #
#  _| || |__| |      ____) |  __/ |_| |_| | | | | (_| \__ \ #
# |_____\____/      |_____/ \___|\__|\__|_|_| |_|\__, |___/ #
#                                                 __/ |     #
#                                                |___/      #
#############################################################

## Sys clock
set_property -dict {PACKAGE_PIN R4  IOSTANDARD LVCMOS33} [get_ports sys_clk]

## Buttons
set_property -dict {PACKAGE_PIN G4  IOSTANDARD LVCMOS15} [get_ports pad_reset_n]
set_property -dict {PACKAGE_PIN B22 IOSTANDARD LVCMOS12} [get_ports btnc_i]
set_property -dict {PACKAGE_PIN D22 IOSTANDARD LVCMOS12} [get_ports btnd_i]
set_property -dict {PACKAGE_PIN C22 IOSTANDARD LVCMOS12} [get_ports btnl_i]
set_property -dict {PACKAGE_PIN D14 IOSTANDARD LVCMOS12} [get_ports btnr_i]
set_property -dict {PACKAGE_PIN F15 IOSTANDARD LVCMOS12} [get_ports btnu_i]

## To use FTDI FT2232 JTAG
set_property -dict {PACKAGE_PIN R17 IOSTANDARD LVCMOS33} [get_ports pad_jtag_trst]
set_property -dict {PACKAGE_PIN U20 IOSTANDARD LVCMOS33} [get_ports pad_jtag_tck]
set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports pad_jtag_tdi]
set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33} [get_ports pad_jtag_tdo]
set_property -dict {PACKAGE_PIN U17 IOSTANDARD LVCMOS33} [get_ports pad_jtag_tms]

## UART
set_property -dict {PACKAGE_PIN AA19 IOSTANDARD LVCMOS33} [get_ports pad_uart_tx]
set_property -dict {PACKAGE_PIN V18  IOSTANDARD LVCMOS33} [get_ports pad_uart_rx]

## LEDs
set_property -dict {PACKAGE_PIN T14 IOSTANDARD LVCMOS25} [get_ports led0_o]
set_property -dict {PACKAGE_PIN T15 IOSTANDARD LVCMOS25} [get_ports led1_o]
set_property -dict {PACKAGE_PIN T16 IOSTANDARD LVCMOS25} [get_ports led2_o]
set_property -dict {PACKAGE_PIN U16 IOSTANDARD LVCMOS25} [get_ports led3_o]

## Switches
set_property -dict {PACKAGE_PIN E22 IOSTANDARD LVCMOS12} [get_ports switch0_i]
set_property -dict {PACKAGE_PIN F21 IOSTANDARD LVCMOS12} [get_ports switch1_i]

## I2C Bus
set_property -dict {PACKAGE_PIN W5 IOSTANDARD LVCMOS33} [get_ports pad_i2c0_scl]
set_property -dict {PACKAGE_PIN V5 IOSTANDARD LVCMOS33} [get_ports pad_i2c0_sda]

## QSPI Flash
set_property -dict {PACKAGE_PIN T19 IOSTANDARD LVCMOS33} [get_ports pad_spim_csn0]
#set_property -dict {PACKAGE_PIN P22 IOSTANDARD LVCMOS33} [get_ports { pad_spim_sdio0 }]; #IO_L1P_T0_D00_MOSI_14 Sch=qspi_dq[0]
set_property -dict {PACKAGE_PIN R22 IOSTANDARD LVCMOS33} [get_ports pad_spim_sdio1]
set_property -dict {PACKAGE_PIN P21 IOSTANDARD LVCMOS33} [get_ports pad_spim_sdio2]
set_property -dict {PACKAGE_PIN R21 IOSTANDARD LVCMOS33} [get_ports pad_spim_sdio3]

## OLED Display
set_property -dict {PACKAGE_PIN W22 IOSTANDARD LVCMOS33} [get_ports oled_dc_o]
set_property -dict {PACKAGE_PIN U21 IOSTANDARD LVCMOS33} [get_ports oled_rst_o]
set_property -dict {PACKAGE_PIN W21 IOSTANDARD LVCMOS33} [get_ports oled_spim_sck_o]
set_property -dict {PACKAGE_PIN Y22 IOSTANDARD LVCMOS33} [get_ports oled_spim_mosi_o]
set_property -dict {PACKAGE_PIN P20 IOSTANDARD LVCMOS33} [get_ports oled_vbat_o]
set_property -dict {PACKAGE_PIN V22 IOSTANDARD LVCMOS33} [get_ports oled_vdd_o]

## SD Card
set_property -dict {PACKAGE_PIN W19 IOSTANDARD LVCMOS33} [get_ports pad_sdio_clk]
#set_property -dict {PACKAGE_PIN T18 IOSTANDARD LVCMOS33} [get_ports { sd_cd }]; #IO_L20N_T3_A07_D23_14 Sch=sd_cd
set_property -dict {PACKAGE_PIN W20 IOSTANDARD LVCMOS33} [get_ports pad_sdio_cmd]
set_property -dict {PACKAGE_PIN V19 IOSTANDARD LVCMOS33} [get_ports pad_sdio_data0]
set_property -dict {PACKAGE_PIN T21 IOSTANDARD LVCMOS33} [get_ports pad_sdio_data1]
set_property -dict {PACKAGE_PIN T20 IOSTANDARD LVCMOS33} [get_ports pad_sdio_data2]
set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports pad_sdio_data3]
set_property -dict {PACKAGE_PIN V20 IOSTANDARD LVCMOS33} [get_ports sdio_reset_o]

# Nexys Video has a quad SPI flash
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]

# Configuration options, can be used for all designs
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

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
set_property -dict {PACKAGE_PIN F21 IOSTANDARD LVDS_25} [get_ports ref_clk_n]
set_property -dict {PACKAGE_PIN G21 IOSTANDARD LVDS_25} [get_ports ref_clk_p]

## Reset
######################################################################
# Reset mapping
######################################################################
set_property -dict {PACKAGE_PIN AM13 IOSTANDARD LVCMOS33} [get_ports pad_reset]

## Buttons
#set_property -dict {PACKAGE_PIN AF15 IOSTANDARD LVCMOS33} [get_ports btn0_i]
#set_property -dict {PACKAGE_PIN AG13 IOSTANDARD LVCMOS33} [get_ports btn1_i]
#set_property -dict {PACKAGE_PIN AE14 IOSTANDARD LVCMOS33} [get_ports btn2_i]
#set_property -dict {PACKAGE_PIN AG15 IOSTANDARD LVCMOS33} [get_ports btn3_i]

## PMOD 0   --- JTAG
######################################################################
# JTAG mapping
######################################################################
set_property -dict {PACKAGE_PIN A20 IOSTANDARD LVCMOS33} [get_ports pad_jtag_tms]
set_property -dict {PACKAGE_PIN B20 IOSTANDARD LVCMOS33} [get_ports pad_jtag_tdi]
set_property -dict {PACKAGE_PIN A22 IOSTANDARD LVCMOS33} [get_ports pad_jtag_tdo]
set_property -dict {PACKAGE_PIN A21 IOSTANDARD LVCMOS33} [get_ports pad_jtag_tck]

#set_property -dict {PACKAGE_PIN B21 IOSTANDARD LVCMOS33} [get_ports pad_pmod0_4]
#set_property -dict {PACKAGE_PIN C21 IOSTANDARD LVCMOS33} [get_ports pad_pmod0_5]
#set_property -dict {PACKAGE_PIN C22 IOSTANDARD LVCMOS33} [get_ports pad_pmod0_6]
#set_property -dict {PACKAGE_PIN D21 IOSTANDARD LVCMOS33} [get_ports pad_pmod0_7]

## PMOD 1
#set_property -dict {PACKAGE_PIN D20  IOSTANDARD LVCMOS33} [get_ports pad_pmod1_0]
#set_property -dict {PACKAGE_PIN E20  IOSTANDARD LVCMOS33} [get_ports pad_pmod1_1]
#set_property -dict {PACKAGE_PIN D22  IOSTANDARD LVCMOS33} [get_ports pad_pmod1_2]
#set_property -dict {PACKAGE_PIN E22  IOSTANDARD LVCMOS33} [get_ports pad_pmod1_3]
#set_property -dict {PACKAGE_PIN F20  IOSTANDARD LVCMOS33} [get_ports pad_pmod1_4]
#set_property -dict {PACKAGE_PIN G20  IOSTANDARD LVCMOS33} [get_ports pad_pmod1_5]
#set_property -dict {PACKAGE_PIN J20  IOSTANDARD LVCMOS33} [get_ports pad_pmod1_6]
#set_property -dict {PACKAGE_PIN J19  IOSTANDARD LVCMOS33} [get_ports pad_pmod1_7]

## UART
######################################################################
# UART mapping
######################################################################
set_property -dict {PACKAGE_PIN E13 IOSTANDARD LVCMOS33} [get_ports pad_uart_rx]
set_property -dict {PACKAGE_PIN F13 IOSTANDARD LVCMOS33} [get_ports pad_uart_tx]


#set_property -dict {PACKAGE_PIN D12 IOSTANDARD LVCMOS33} [get_ports pad_uart_rts]
#set_property -dict {PACKAGE_PIN E12 IOSTANDARD LVCMOS33} [get_ports pad_uart_cts]

## LEDs
#set_property -dict {PACKAGE_PIN AG14 IOSTANDARD LVCMOS33} [get_ports led0_o]
#set_property -dict {PACKAGE_PIN AF13 IOSTANDARD LVCMOS33} [get_ports led1_o]
#set_property -dict {PACKAGE_PIN AE13 IOSTANDARD LVCMOS33} [get_ports led2_o]
#set_property -dict {PACKAGE_PIN AJ14 IOSTANDARD LVCMOS33} [get_ports led3_o]

## Switches
#set_property -dict {PACKAGE_PIN AN14 IOSTANDARD LVCMOS33} [get_ports switch0_i]
#set_property -dict {PACKAGE_PIN AP14 IOSTANDARD LVCMOS33} [get_ports switch1_i]
#set_property -dict {PACKAGE_PIN AM14 IOSTANDARD LVCMOS33} [get_ports switch2_i]
#set_property -dict {PACKAGE_PIN AN13 IOSTANDARD LVCMOS33} [get_ports switch3_i]

## I2C Bus
#set_property -dict {PACKAGE_PIN J10 IOSTANDARD LVCMOS33} [get_ports pad_i2c0_scl]
#set_property -dict {PACKAGE_PIN J11 IOSTANDARD LVCMOS33} [get_ports pad_i2c0_sda]

## HDMI CTL
#set_property -dict {PACKAGE_PIN F15 IOSTANDARD LVCMOS33} [get_ports pad_hdmi_scl]
#set_property -dict {PACKAGE_PIN F16 IOSTANDARD LVCMOS33} [get_ports pad_hdmi_sda]


#LED
######################################################################
# JTAG mapping
######################################################################
#set_property PACKAGE_PIN AG14 [get_ports LED]
#set_property IOSTANDARD LVCMOS33 [get_ports LED]

######################################################################
# I2C0 mapping
######################################################################
# PULP pad_i3c2_scl - FPGA T11 - FMC H38
set_property -dict {PACKAGE_PIN T11 IOSTANDARD LVCMOS18} [get_ports FMC_i2c0_scl]
# PULP pad_i3c2_sda - FPGA U11 - FMC H37
set_property -dict {PACKAGE_PIN U11 IOSTANDARD LVCMOS18} [get_ports FMC_i2c0_sda]


######################################################################
# I2S master mapping
######################################################################
# PULP pad_i2s_mst_sck - FPGA K12 - FMC H29
set_property -dict {PACKAGE_PIN K12 IOSTANDARD LVCMOS18} [get_ports FMC_i2s0_sck]
# PULP pad_i2s_mst_ws - FPGA AC7 - FMC C18
set_property -dict {PACKAGE_PIN AC7 IOSTANDARD LVCMOS18} [get_ports FMC_i2s0_ws]
# PULP pad_i2s_slv_sdi0 - FPGA AB4 - FMC D8
set_property -dict {PACKAGE_PIN AB4 IOSTANDARD LVCMOS18} [get_ports FMC_i2s0_sdi]
# PULP pad_i2s_slv_sdi1 - FPGA AC2 - FMC C10
set_property -dict {PACKAGE_PIN AC2 IOSTANDARD LVCMOS18} [get_ports FMC_i2s1_sdi]


######################################################################
# SDIO mapping
######################################################################
# PULP pad_sdio_sdio0 - FPGA D20 - ZCU102 GPIO PMOD HEADER J87.1
set_property -dict {PACKAGE_PIN D20 IOSTANDARD LVCMOS33} [get_ports FMC_sdio_data0]
# PULP pad_sdio_sdio1 - FPGA E20 - ZCU102 GPIO PMOD HEADER J87.3
set_property -dict {PACKAGE_PIN E20 IOSTANDARD LVCMOS33} [get_ports FMC_sdio_data1]
# PULP pad_sdio_sdio2 - FPGA D22 - ZCU102 GPIO PMOD HEADER J87.5
set_property -dict {PACKAGE_PIN D22 IOSTANDARD LVCMOS33} [get_ports FMC_sdio_data2]
# PULP pad_sdio_sdio3 - FPGA E22 - ZCU102 GPIO PMOD HEADER J87.7
set_property -dict {PACKAGE_PIN E22 IOSTANDARD LVCMOS33} [get_ports FMC_sdio_data3]
# PULP pad_sdio_cmd - FPGA F20 - ZCU102 GPIO PMOD HEADER J87.2
set_property -dict {PACKAGE_PIN F20 IOSTANDARD LVCMOS33} [get_ports FMC_sdio_cmd]
# PULP pad_sdio_sck - FPGA G20 - ZCU102 GPIO PMOD HEADER J87.4
set_property -dict {PACKAGE_PIN G20 IOSTANDARD LVCMOS33} [get_ports FMC_sdio_sck]


######################################################################
# QSPI mapping
######################################################################
# PULP pad_qspi_sdio0 - FPGA V1 - FMC  H8
set_property -dict {PACKAGE_PIN V1 IOSTANDARD LVCMOS18} [get_ports FMC_qspi_sdio0]
# PULP pad_qspi_sdio1 - FPGA W6 - FMC G16
set_property -dict {PACKAGE_PIN W6 IOSTANDARD LVCMOS18} [get_ports FMC_qspi_sdio1]
# PULP pad_qspi_sdio2 - FPGA AA2 - FMC H10
set_property -dict {PACKAGE_PIN AA2 IOSTANDARD LVCMOS18} [get_ports FMC_qspi_sdio2]
# PULP pad_qspi_sdio3 - FPGA Y4 - FMC G6
set_property -dict {PACKAGE_PIN Y4 IOSTANDARD LVCMOS18} [get_ports FMC_qspi_sdio3]
# PULP pad_qspi_csn0 - FPGA Y10 - FMC H19
set_property -dict {PACKAGE_PIN Y10 IOSTANDARD LVCMOS18} [get_ports FMC_qspi_csn0]
# PULP pad_qspi_sck - FPGA W7 - FMC G15
set_property -dict {PACKAGE_PIN W7 IOSTANDARD LVCMOS18} [get_ports FMC_qspi_sck]
# GAP pad_spim0_sck - FPGA V2 - FMC H7
set_property -dict {PACKAGE_PIN V2 IOSTANDARD LVCMOS18} [get_ports FMC_qspi_csn1]


######################################################################
# Camera mapping
######################################################################
# PULP pad_cam_pclk - FPGA P11 - FMC D20
set_property -dict {PACKAGE_PIN P11 IOSTANDARD LVCMOS18} [get_ports FMC_cam_pclk]
# PULP pad_cam_hsync - FPGA N11 - FMC D21
set_property -dict {PACKAGE_PIN N11 IOSTANDARD LVCMOS18} [get_ports FMC_cam_hsync]
# PULP pad_cam_data0 - FPGA K16 - FMC D24
set_property -dict {PACKAGE_PIN K16 IOSTANDARD LVCMOS18} [get_ports FMC_cam_data0]
# PULP pad_cam_data1 - FPGA L16 - FMC D23
set_property -dict {PACKAGE_PIN L16 IOSTANDARD LVCMOS18} [get_ports FMC_cam_data1]
# PULP pad_cam_data2 - FPGA N9 - FMC C22
set_property -dict {PACKAGE_PIN N9 IOSTANDARD LVCMOS18} [get_ports FMC_cam_data2]
# PULP pad_cam_data3 - FPGA L15 - FMC D26
set_property -dict {PACKAGE_PIN L15 IOSTANDARD LVCMOS18} [get_ports FMC_cam_data3]
# PULP pad_cam_data4 - FPGA N8 - FMC C23
set_property -dict {PACKAGE_PIN N8 IOSTANDARD LVCMOS18} [get_ports FMC_cam_data4]
# PULP pad_cam_data5 - FPGA K15 - FMC D27
set_property -dict {PACKAGE_PIN K15 IOSTANDARD LVCMOS18} [get_ports FMC_cam_data5]
# PULP pad_cam_data6 - FPGA AC8 - FMC D18
set_property -dict {PACKAGE_PIN AC8 IOSTANDARD LVCMOS18} [get_ports FMC_cam_data6]
# PULP pad_cam_data7 - FPGA L10 - FMC C27
set_property -dict {PACKAGE_PIN L10 IOSTANDARD LVCMOS18} [get_ports FMC_cam_data7]
# PULP pad_cam_vsync - FPGA AC6 - FMC C19
set_property -dict {PACKAGE_PIN AC6 IOSTANDARD LVCMOS18} [get_ports FMC_cam_vsync]

set_property MARK_DEBUG true [get_nets pulp_chip_i/pad_jtag_tdi]
set_property MARK_DEBUG true [get_nets pulp_chip_i/pad_jtag_tdo]
set_property MARK_DEBUG true [get_nets pulp_chip_i/pad_jtag_tck]
set_property MARK_DEBUG true [get_nets pulp_chip_i/pad_jtag_tms]
set_property MARK_DEBUG true [get_nets pulp_chip_i/pad_reset_n]
set_property MARK_DEBUG true [get_nets pulp_chip_i/s_ref_clk]
set_property MARK_DEBUG true [get_nets pulp_chip_i/s_bootsel]

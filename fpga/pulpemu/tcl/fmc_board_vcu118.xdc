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

## Sys clock (ok)
set_property -dict {PACKAGE_PIN AY23 IOSTANDARD LVDS} [get_ports ref_clk_n]
set_property -dict {PACKAGE_PIN AY24 IOSTANDARD LVDS} [get_ports ref_clk_p]

## Reset (ok)
set_property -dict {PACKAGE_PIN L19 IOSTANDARD LVCMOS12} [get_ports pad_reset]

## Buttons (ok)
#set_property -dict {PACKAGE_PIN BF22 IOSTANDARD LVCMOS18} [get_ports btn0_i]
#set_property -dict {PACKAGE_PIN BD23 IOSTANDARD LVCMOS18} [get_ports btn1_i]
#set_property -dict {PACKAGE_PIN BE23 IOSTANDARD LVCMOS18} [get_ports btn2_i]
#set_property -dict {PACKAGE_PIN BB24 IOSTANDARD LVCMOS18} [get_ports btn3_i]

## PMOD 0 (J52 on Virtex) (ok)
## PMOD 0   --- JTAG
######################################################################
# JTAG mapping (OK)
######################################################################
set_property -dict {PACKAGE_PIN AY14 IOSTANDARD LVCMOS18} [get_ports pad_jtag_tms]
set_property -dict {PACKAGE_PIN AY15 IOSTANDARD LVCMOS18} [get_ports pad_jtag_tdi]
set_property -dict {PACKAGE_PIN AW15 IOSTANDARD LVCMOS18} [get_ports pad_jtag_tdo]
set_property -dict {PACKAGE_PIN AV15 IOSTANDARD LVCMOS18} [get_ports pad_jtag_tck]


#set_property -dict {PACKAGE_PIN AV16 IOSTANDARD LVCMOS18} [get_ports pad_pmod0_4]
#set_property -dict {PACKAGE_PIN AU16 IOSTANDARD LVCMOS18} [get_ports pad_pmod0_5]
#set_property -dict {PACKAGE_PIN AT15 IOSTANDARD LVCMOS18} [get_ports pad_pmod0_6]
#set_property -dict {PACKAGE_PIN AT16 IOSTANDARD LVCMOS18} [get_ports pad_pmod0_7]

## PMOD 1 (ok)
#set_property -dict {PACKAGE_PIN N28  IOSTANDARD LVCMOS12} [get_ports pad_pmod1_0]
#set_property -dict {PACKAGE_PIN M30  IOSTANDARD LVCMOS12} [get_ports pad_pmod1_1]
#set_property -dict {PACKAGE_PIN N30  IOSTANDARD LVCMOS12} [get_ports pad_pmod1_2]
#set_property -dict {PACKAGE_PIN P30  IOSTANDARD LVCMOS12} [get_ports pad_pmod1_3]
#set_property -dict {PACKAGE_PIN P29  IOSTANDARD LVCMOS12} [get_ports pad_pmod1_4]
#set_property -dict {PACKAGE_PIN L31  IOSTANDARD LVCMOS12} [get_ports pad_pmod1_5]
#set_property -dict {PACKAGE_PIN M31  IOSTANDARD LVCMOS12} [get_ports pad_pmod1_6]
#set_property -dict {PACKAGE_PIN R29  IOSTANDARD LVCMOS12} [get_ports pad_pmod1_7]

## UART (ok)
######################################################################
# UART mapping
######################################################################
set_property -dict {PACKAGE_PIN AW25  IOSTANDARD LVCMOS18} [get_ports pad_uart_rx]
set_property -dict {PACKAGE_PIN BB21  IOSTANDARD LVCMOS18} [get_ports pad_uart_tx]

#set_property -dict {PACKAGE_PIN BB22  IOSTANDARD LVCMOS18} [get_ports pad_uart_rts]
#set_property -dict {PACKAGE_PIN AY25  IOSTANDARD LVCMOS18} [get_ports pad_uart_cts]

## LEDs (ok)
#set_property -dict {PACKAGE_PIN AT32 IOSTANDARD LVCMOS12} [get_ports led0_o]
#set_property -dict {PACKAGE_PIN AV34 IOSTANDARD LVCMOS12} [get_ports led1_o]
#set_property -dict {PACKAGE_PIN AY30 IOSTANDARD LVCMOS12} [get_ports led2_o]
#set_property -dict {PACKAGE_PIN BB32 IOSTANDARD LVCMOS12} [get_ports led3_o]

## Switches (ok)
#set_property -dict {PACKAGE_PIN B17 IOSTANDARD LVCMOS12} [get_ports switch0_i]
#set_property -dict {PACKAGE_PIN G16 IOSTANDARD LVCMOS12} [get_ports switch1_i]
#set_property -dict {PACKAGE_PIN J16 IOSTANDARD LVCMOS12} [get_ports switch2_i]
#set_property -dict {PACKAGE_PIN D21 IOSTANDARD LVCMOS12} [get_ports switch3_i]

## I2C Bus
#set_property -dict {PACKAGE_PIN J10 IOSTANDARD LVCMOS33} [get_ports pad_i2c0_scl]
#set_property -dict {PACKAGE_PIN J11 IOSTANDARD LVCMOS33} [get_ports pad_i2c0_sda]

## HDMI CTL
#set_property -dict {PACKAGE_PIN F15 IOSTANDARD LVCMOS33} [get_ports pad_hdmi_scl]
#set_property -dict {PACKAGE_PIN F16 IOSTANDARD LVCMOS33} [get_ports pad_hdmi_sda]


######################################################################
# QSPI mapping (OK)
######################################################################
# PULP pad_qspi_sdio0 - FPGA BD11 - FMC  H8  
set_property -dict "PACKAGE_PIN BD11 IOSTANDARD LVCMOS18"   [get_ports FMC_qspi_sdio0]
# PULP pad_qspi_sdio1 - FPGA BC13 - FMC G16
set_property -dict "PACKAGE_PIN BC13 IOSTANDARD LVCMOS18"   [get_ports FMC_qspi_sdio1]
# PULP pad_qspi_sdio2 - FPGA BF12 - FMC H10
set_property -dict "PACKAGE_PIN BF12 IOSTANDARD LVCMOS18"  [get_ports FMC_qspi_sdio2]
# PULP pad_qspi_sdio3 - FPGA AY9 - FMC G6
set_property -dict "PACKAGE_PIN AY9 IOSTANDARD LVCMOS18"   [get_ports FMC_qspi_sdio3]
# PULP pad_qspi_csn0 - FPGA BB16 - FMC H19
set_property -dict "PACKAGE_PIN BB16 IOSTANDARD LVCMOS18"  [get_ports FMC_qspi_csn0]
# PULP pad_qspi_sck - FPGA BC14 - FMC G15
set_property -dict "PACKAGE_PIN BC14 IOSTANDARD LVCMOS18"   [get_ports FMC_qspi_sck]
# GAP pad_spim0_sck - FPGA BC11 - FMC H7
set_property -dict "PACKAGE_PIN BC11 IOSTANDARD LVCMOS18"   [get_ports FMC_qspi_csn1]

######################################################################
# SDIO mapping (TO CHECK)
######################################################################
# PULP pad_sdio_sdio0 - FPGA N28 - ZCU102 GPIO PMOD HEADER J53.1
set_property -dict "PACKAGE_PIN N28 IOSTANDARD LVCMOS18"  [get_ports FMC_sdio_data0]
# PULP pad_sdio_sdio1 - FPGA M30 - ZCU102 GPIO PMOD HEADER J53.3
set_property -dict "PACKAGE_PIN M30 IOSTANDARD LVCMOS18"  [get_ports FMC_sdio_data1]
# PULP pad_sdio_sdio2 - FPGA N30 - ZCU102 GPIO PMOD HEADER J53.5
set_property -dict "PACKAGE_PIN N30 IOSTANDARD LVCMOS18"  [get_ports FMC_sdio_data2]
# PULP pad_sdio_sdio3 - FPGA P30 - ZCU102 GPIO PMOD HEADER J53.7
set_property -dict "PACKAGE_PIN P30 IOSTANDARD LVCMOS18"  [get_ports FMC_sdio_data3]
# PULP pad_sdio_cmd - FPGA P29 - ZCU102 GPIO PMOD HEADER J53.2
set_property -dict "PACKAGE_PIN P29 IOSTANDARD LVCMOS18"  [get_ports FMC_sdio_cmd]
# PULP pad_sdio_sck - FPGA L31 - ZCU102 GPIO PMOD HEADER J53.4
set_property -dict "PACKAGE_PIN L31 IOSTANDARD LVCMOS18"  [get_ports FMC_sdio_sck]

######################################################################
# I2S master mapping (OK)
######################################################################
# PULP pad_i2s_mst_sck - FPGA AR13 - FMC H29
set_property -dict "PACKAGE_PIN AR13 IOSTANDARD LVCMOS18" [get_ports FMC_i2s0_sck]
# PULP pad_i2s_mst_ws - FPGA AW8 - FMC C18
set_property -dict "PACKAGE_PIN AW8 IOSTANDARD LVCMOS18" [get_ports FMC_i2s0_ws]
# PULP pad_i2s_slv_sdi0 - FPGA BB7 - FMC D1 -- not mappable --mapped into H2 (dummy)
set_property -dict "PACKAGE_PIN BB7 IOSTANDARD LVCMOS18" [get_ports FMC_i2s0_sdi]
# PULP pad_i2s_slv_sdi1 - FPGA BD13 - FMC C10
set_property -dict "PACKAGE_PIN BD13 IOSTANDARD LVCMOS18" [get_ports FMC_i2s1_sdi]

######################################################################
# I2C0 mapping (OK)
######################################################################
# PULP pad_i3c2_scl - FPGA AJ12 - FMC H38
set_property -dict "PACKAGE_PIN AJ12 IOSTANDARD LVCMOS18"  [get_ports FMC_i2c0_scl]
# PULP pad_i3c2_sda - FPGA AJ13 - FMC H37
set_property -dict "PACKAGE_PIN AJ13 IOSTANDARD LVCMOS18"  [get_ports FMC_i2c0_sda]

######################################################################
# Camera mapping (OK)
######################################################################
# PULP pad_cam_pclk - FPGA AR14 - FMC D20
set_property -dict "PACKAGE_PIN AR14 IOSTANDARD LVCMOS18" [get_ports FMC_cam_pclk]
# PULP pad_cam_hsync - FPGA AT14 - FMC D21
set_property -dict "PACKAGE_PIN AT14 IOSTANDARD LVCMOS18" [get_ports FMC_cam_hsync]
# PULP pad_cam_data0 - FPGA AP16 - FMC D24
set_property -dict "PACKAGE_PIN AP16 IOSTANDARD LVCMOS18" [get_ports FMC_cam_data0]
# PULP pad_cam_data1 - FPGA AN16 - FMC D23
set_property -dict "PACKAGE_PIN AN16 IOSTANDARD LVCMOS18" [get_ports FMC_cam_data1]
# PULP pad_cam_data2 - FPGA AP12 - FMC C22
set_property -dict "PACKAGE_PIN AP12 IOSTANDARD LVCMOS18"  [get_ports FMC_cam_data2]
# PULP pad_cam_data3 - FPGA AK15 - FMC D26
set_property -dict "PACKAGE_PIN AK15 IOSTANDARD LVCMOS18" [get_ports FMC_cam_data3]
# PULP pad_cam_data4 - FPGA AR12 - FMC C23
set_property -dict "PACKAGE_PIN AR12 IOSTANDARD LVCMOS18"  [get_ports FMC_cam_data4]
# PULP pad_cam_data5 - FPGA AL15 - FMC D27
set_property -dict "PACKAGE_PIN AL15 IOSTANDARD LVCMOS18" [get_ports FMC_cam_data5]
# PULP pad_cam_data6 - FPGA AY7 - FMC D18
set_property -dict "PACKAGE_PIN AY7 IOSTANDARD LVCMOS18" [get_ports FMC_cam_data6]
# PULP pad_cam_data7 - FPGA AM14 - FMC C27
set_property -dict "PACKAGE_PIN AM14 IOSTANDARD LVCMOS18" [get_ports FMC_cam_data7]
# PULP pad_cam_vsync - FPGA AW7 - FMC C19
set_property -dict "PACKAGE_PIN AW7 IOSTANDARD LVCMOS18" [get_ports FMC_cam_vsync]


#LED
#set_property PACKAGE_PIN AG14 [get_ports LED]
#set_property IOSTANDARD LVCMOS33 [get_ports LED]

set_property MARK_DEBUG true [get_nets pulp_chip_i/pad_jtag_tdi]
set_property MARK_DEBUG true [get_nets pulp_chip_i/pad_jtag_tdo]
set_property MARK_DEBUG true [get_nets pulp_chip_i/pad_jtag_tck]
set_property MARK_DEBUG true [get_nets pulp_chip_i/pad_jtag_tms]
set_property MARK_DEBUG true [get_nets pulp_chip_i/pad_reset_n]
set_property MARK_DEBUG true [get_nets pulp_chip_i/s_ref_clk]
set_property MARK_DEBUG true [get_nets pulp_chip_i/s_bootsel]

######################################################################
# Sensorboard J5 HPC0 FMC mapping
######################################################################

######################################################################
# PWM mapping
######################################################################
# GAP pad_pwm0 - FPGA AK17 - FMC  H7
set_property -dict "PACKAGE_PIN AK17 IOSTANDARD LVCMOS25"   [get_ports FMC_pwm0]
# GAP pad_pwm1 - FPGA AB14 - FMC  H20
set_property -dict "PACKAGE_PIN AB14 IOSTANDARD LVCMOS25"   [get_ports FMC_pwm1]
# GAP pad_pwm2 - FPGA AH26 - FMC  H22
set_property -dict "PACKAGE_PIN AH26 IOSTANDARD LVCMOS25"   [get_ports FMC_pwm2]
# GAP pad_pwm3 - FPGA AH27 - FMC  H23
set_property -dict "PACKAGE_PIN AH27 IOSTANDARD LVCMOS25"   [get_ports FMC_pwm3]

######################################################################
# QSPI mapping
######################################################################
# GAP pad_qspi_sdio0 - FPGA AK18 - FMC  H8
set_property -dict "PACKAGE_PIN AK18 IOSTANDARD LVCMOS25"   [get_ports FMC_qspi_sdio0]
# GAP pad_qspi_sdio1 - FPGA AF24 - FMC G16
set_property -dict "PACKAGE_PIN AF24 IOSTANDARD LVCMOS25"   [get_ports FMC_qspi_sdio1]
# GAP pad_qspi_sdio2 - FPGA AJ20 - FMC H10
set_property -dict "PACKAGE_PIN AJ20 IOSTANDARD LVCMOS25"  [get_ports FMC_qspi_sdio2]
# GAP pad_qspi_sdio3 - FPGA AF20 - FMC G6
set_property -dict "PACKAGE_PIN AF20 IOSTANDARD LVCMOS25"   [get_ports FMC_qspi_sdio3]
# GAP pad_qspi_csn0 - FPGA Y22 - FMC H19
set_property -dict "PACKAGE_PIN Y22 IOSTANDARD LVCMOS25"  [get_ports FMC_qspi_cs0]
# GAP pad_qspi_sck - FPGA AF23 - FMC G15
set_property -dict "PACKAGE_PIN AF23 IOSTANDARD LVCMOS25"   [get_ports FMC_qspi_sck]

######################################################################
# SDIO mapping (If use SDIO)
######################################################################
# GAP pad_sdio_sdio0 - FPGA D20 - ZC706 GPIO PMOD HEADER J57.1
#set_property -dict "PACKAGE_PIN D20 IOSTANDARD LVCMOS25"  [get_ports FMC_qspi_sdio0]
# GAP pad_sdio_sdio1 - FPGA E20 - ZC706 GPIO PMOD HEADER J57.3
#set_property -dict "PACKAGE_PIN E20 IOSTANDARD LVCMOS25"  [get_ports FMC_qspi_sdio1]
# GAP pad_sdio_sdio2 - FPGA D22 - ZC706 GPIO PMOD HEADER J57.5
#set_property -dict "PACKAGE_PIN D22 IOSTANDARD LVCMOS25"  [get_ports FMC_qspi_sdio2]
# GAP pad_sdio_sdio3 - FPGA E22 - ZC706 GPIO PMOD HEADER J57.7
#set_property -dict "PACKAGE_PIN E22 IOSTANDARD LVCMOS25"  [get_ports FMC_qspi_sdio3]
# GAP pad_sdio_cmd - FPGA F20 - ZC706 GPIO PMOD HEADER J57.2
#set_property -dict "PACKAGE_PIN F20 IOSTANDARD LVCMOS25"  [get_ports FMC_qspi_cs0]
# GAP pad_sdio_sck - FPGA G20 - ZC706 GPIO PMOD HEADER J57.4
#set_property -dict "PACKAGE_PIN G20 IOSTANDARD LVCMOS25"  [get_ports FMC_qspi_sck]

######################################################################
# SPIM0 mapping
######################################################################
# GAP pad_spim0_sck - FPGA AF19 - FMC G12
set_property -dict "PACKAGE_PIN AF19 IOSTANDARD LVCMOS25"   [get_ports FMC_spim0_sck]
# GAP pad_spim0_csn - FPGA AG19 - FMC G13
set_property -dict "PACKAGE_PIN AG19 IOSTANDARD LVCMOS25"   [get_ports FMC_spim0_cs0]
# GAP pad_spim0_miso - FPGA N27 - FMC G37
set_property -dict "PACKAGE_PIN N27 IOSTANDARD LVCMOS25"  [get_ports FMC_spim0_miso]
# GAP pad_spim0_mosi - FPGA AJ24 - FMC H14
set_property -dict "PACKAGE_PIN AJ24 IOSTANDARD LVCMOS25"   [get_ports FMC_spim0_mosi]

######################################################################
# I3C0 mapping
######################################################################
# GAP pad_i3c0_scl - FPGA AB29 - FMC H34
set_property -dict "PACKAGE_PIN AB29 IOSTANDARD LVCMOS25"  [get_ports FMC_i3c0_scl]
# GAP pad_i3c0_sda - FPGA AE26 - FMC H32
set_property -dict "PACKAGE_PIN AE26 IOSTANDARD LVCMOS25"  [get_ports FMC_i3c0_sda]

######################################################################
# UART0 mapping
######################################################################
# GAP pad_uart0_rx - FPGA G2 - ZC706 GPIO LED DS9
set_property -dict "PACKAGE_PIN G2 IOSTANDARD LVCMOS15" [get_ports FMC_uart0_rx]
# GAP pad_uart0_tx - FPGA W21 - ZC706 GPIO LED DS10
set_property -dict "PACKAGE_PIN W21 IOSTANDARD LVCMOS25" [get_ports FMC_uart0_tx]

######################################################################
# UART1 mapping
######################################################################
# GAP pad_uart1_rx - FPGA AE22 - FMC H4
set_property -dict "PACKAGE_PIN AE22 IOSTANDARD LVCMOS25" [get_ports FMC_uart1_rx]
# GAP pad_uart1_tx - FPGA AF22 - FMC H5
set_property -dict "PACKAGE_PIN AF22 IOSTANDARD LVCMOS25" [get_ports FMC_uart1_tx]

######################################################################
# SPIM1 mapping
######################################################################
# GAP pad_spim1_sck - FPGA AD29 - FMC G34
set_property -dict "PACKAGE_PIN AD29 IOSTANDARD LVCMOS25"  [get_ports FMC_spim1_sck]
# GAP pad_spim1_cs0 - FPGA AF25 - FMC G31
set_property -dict "PACKAGE_PIN AF25 IOSTANDARD LVCMOS25"   [get_ports FMC_spim1_cs0]
# GAP pad_spim1_miso - FPGA N26 - FMC G36
set_property -dict "PACKAGE_PIN N26 IOSTANDARD LVCMOS25"   [get_ports FMC_spim1_miso]
# GAP pad_spim1_mosi - FPGA AC29 - FMC G33
set_property -dict "PACKAGE_PIN AC29 IOSTANDARD LVCMOS25"  [get_ports FMC_spim1_mosi]

######################################################################
# I3C1 mapping
######################################################################
# GAP pad_i3c1_scl - FPGA AG25 - FMC C15
set_property -dict "PACKAGE_PIN AG25 IOSTANDARD LVCMOS25"  [get_ports FMC_i3c1_scl]
# GAP pad_i3c1_sda - FPGA AG24 - FMC C14
set_property -dict "PACKAGE_PIN AG24 IOSTANDARD LVCMOS25"  [get_ports FMC_i3c1_sda]

######################################################################
# I2S master mapping
######################################################################
# GAP pad_i2s_mst_sck - FPGA U30 - FMC H29
set_property -dict "PACKAGE_PIN U30 IOSTANDARD LVCMOS25" [get_ports FMC_i2s_mst_sck]
# GAP pad_i2s_mst_sdi0 - FPGA AB30 - FMC H35
set_property -dict "PACKAGE_PIN AB30 IOSTANDARD LVCMOS25" [get_ports FMC_i2s_mst_sdo0]
# GAP pad_i2s_mst_sdi1 - FPGA AD25 - FMC H31
set_property -dict "PACKAGE_PIN AD25 IOSTANDARD LVCMOS25" [get_ports FMC_i2s_mst_sdo1]
# GAP pad_i2s_mst_ws - FPGA AF30 - FMC H28
set_property -dict "PACKAGE_PIN AF30 IOSTANDARD LVCMOS25" [get_ports FMC_i2s_mst_ws]

######################################################################
# I2S slave mapping
######################################################################
# GAP pad_i2s_slv_sck - FPGA V28 - FMC C26
set_property -dict "PACKAGE_PIN V28 IOSTANDARD LVCMOS25" [get_ports FMC_i2s_slv_sck]
# GAP pad_i2s_slv_sdi0 - FPGA AG22 - FMC C10
set_property -dict "PACKAGE_PIN AG22 IOSTANDARD LVCMOS25" [get_ports FMC_i2s_slv_sdi0]
# GAP pad_i2s_slv_sdi1 - FPGA AC24 - FMC C18
set_property -dict "PACKAGE_PIN AC24 IOSTANDARD LVCMOS25" [get_ports FMC_i2s_slv_sdi1]
# GAP pad_i2s_slv_ws - FPGA AH22 - FMC C11
set_property -dict "PACKAGE_PIN AH22 IOSTANDARD LVCMOS25" [get_ports FMC_i2s_slv_ws]

######################################################################
# SPIM2 mapping
######################################################################
# GAP pad_spim2_sck - FPGA AE25 - FMC G30
set_property -dict "PACKAGE_PIN AE25 IOSTANDARD LVCMOS25"   [get_ports FMC_spim2_sck]
# GAP pad_spim2_csn - FPGA AG29 - FMC G28
set_property -dict "PACKAGE_PIN AG29 IOSTANDARD LVCMOS25"   [get_ports FMC_spim2_cs0]
# GAP pad_spim2_miso - FPGA AF29 - FMC G27
set_property -dict "PACKAGE_PIN AF29 IOSTANDARD LVCMOS25"  [get_ports FMC_spim2_miso]
# GAP pad_spim2_mosi - FPGA AJ19 - FMC G10
set_property -dict "PACKAGE_PIN AJ19 IOSTANDARD LVCMOS25"   [get_ports FMC_spim2_mosi]

######################################################################
# I3C2/I2C0 mapping
######################################################################
# GAP pad_i3c2_scl - FPGA R21 - FMC H38
set_property -dict "PACKAGE_PIN R21 IOSTANDARD LVCMOS25"  [get_ports FMC_i3c2_scl]
# GAP pad_i3c2_sda - FPGA P21 - FMC H37
set_property -dict "PACKAGE_PIN P21 IOSTANDARD LVCMOS25"  [get_ports FMC_i3c2_sda]

######################################################################
# Camera mapping
######################################################################
# GAP pad_cam_pclk - FPGA V23 - FMC D20
set_property -dict "PACKAGE_PIN V23 IOSTANDARD LVCMOS25" [get_ports FMC_cam_pclk]
# GAP pad_cam_hsync - FPGA W24 - FMC D21
set_property -dict "PACKAGE_PIN W24 IOSTANDARD LVCMOS25" [get_ports FMC_cam_hsync]
# GAP pad_cam_data0 - FPGA P26 - FMC D24
set_property -dict "PACKAGE_PIN P26 IOSTANDARD LVCMOS25" [get_ports FMC_cam_data0]
# GAP pad_cam_data1 - FPGA P25 - FMC D23
set_property -dict "PACKAGE_PIN P25 IOSTANDARD LVCMOS25" [get_ports FMC_cam_data1]
# GAP pad_cam_data2 - FPGA W25 - FMC C22
set_property -dict "PACKAGE_PIN W25 IOSTANDARD LVCMOS25"  [get_ports FMC_cam_data2]
# GAP pad_cam_data3 - FPGA R28 - FMC D26
set_property -dict "PACKAGE_PIN R28 IOSTANDARD LVCMOS25" [get_ports FMC_cam_data3]
# GAP pad_cam_data4 - FPGA W26 - FMC C23
set_property -dict "PACKAGE_PIN W26 IOSTANDARD LVCMOS25"  [get_ports FMC_cam_data4]
# GAP pad_cam_data5 - FPGA T28 - FMC D27
set_property -dict "PACKAGE_PIN T28 IOSTANDARD LVCMOS25" [get_ports FMC_cam_data5]
# GAP pad_cam_data6 - FPGA AA23 - FMC D18
set_property -dict "PACKAGE_PIN AA23 IOSTANDARD LVCMOS25" [get_ports FMC_cam_data6]
# GAP pad_cam_data7 - FPGA V29 - FMC C27
set_property -dict "PACKAGE_PIN V29 IOSTANDARD LVCMOS25" [get_ports FMC_cam_data7]
# GAP pad_cam_vsync - FPGA AD24 - FMC C19
set_property -dict "PACKAGE_PIN AD24 IOSTANDARD LVCMOS25" [get_ports FMC_cam_vsync]

######################################################################
# HYPERBUS mapping
######################################################################
# GAP alt2 pad_hyper_ck - FPGA AG21 - FMC D8
set_property -dict "PACKAGE_PIN AG21 IOSTANDARD LVCMOS25"  [get_ports FMC_hyper_ck]
# GAP alt2 pad_hyper_ckn - FPGA AH21 - FMC D9
set_property -dict "PACKAGE_PIN AH21 IOSTANDARD LVCMOS25"  [get_ports FMC_hyper_ckn]
# GAP alt2 pad_hyper_rwds - FPGA AA22 - FMC D17
set_property -dict "PACKAGE_PIN AA22 IOSTANDARD LVCMOS25"  [get_ports FMC_hyper_rwds]
# GAP alt2 pad_hyper_csn0 - FPGA W28 - FMC G25
set_property -dict "PACKAGE_PIN W28 IOSTANDARD LVCMOS25"  [get_ports FMC_hyper_csn0]
# GAP alt2 pad_hyper_csn1 - FPGA V27 - FMC G24
set_property -dict "PACKAGE_PIN V27 IOSTANDARD LVCMOS25"  [get_ports FMC_hyper_csn1]
# GAP alt2 pad_hyper_dq0 - FPGA AH23 - FMC D11
set_property -dict "PACKAGE_PIN AH23 IOSTANDARD LVCMOS25"  [get_ports FMC_hyper_dq0]
# GAP alt2 pad_hyper_dq1 - FPGA AH24 - FMC D12
set_property -dict "PACKAGE_PIN AH24 IOSTANDARD LVCMOS25"  [get_ports FMC_hyper_dq1]
# GAP alt2 pad_hyper_dq2 - FPGA AD21 - FMC D14
set_property -dict "PACKAGE_PIN AD21 IOSTANDARD LVCMOS25"   [get_ports FMC_hyper_dq2]
# GAP alt2 pad_hyper_dq3 - FPGA AE21 - FMC D15
set_property -dict "PACKAGE_PIN AE21 IOSTANDARD LVCMOS25"   [get_ports FMC_hyper_dq3]
# GAP alt2 pad_hyper_dq4 - FPGA AA24 - FMC G18
set_property -dict "PACKAGE_PIN AA24 IOSTANDARD LVCMOS25"  [get_ports FMC_hyper_dq4]
# GAP alt2 pad_hyper_dq5 - FPGA AB24 - FMC G19
set_property -dict "PACKAGE_PIN AB24 IOSTANDARD LVCMOS25" [get_ports FMC_hyper_dq5]
# GAP alt2 pad_hyper_dq6 - FPGA U25 - FMC G21
set_property -dict "PACKAGE_PIN U25 IOSTANDARD LVCMOS25"  [get_ports FMC_hyper_dq6]
# GAP alt2 pad_hyper_dq7 - FPGA V26 - FMC G22
set_property -dict "PACKAGE_PIN V26 IOSTANDARD LVCMOS25"  [get_ports FMC_hyper_dq7]

######################################################################
# Reset mapping
######################################################################
# GAP pad_reset_n - FPGA AJ21 - ZC706 GPIO PMOD HEADER J58.1
set_property -dict "PACKAGE_PIN AJ21 IOSTANDARD LVCMOS25"  [get_ports FMC_reset_n]

######################################################################
# JTAG mapping
######################################################################
# GAP pad_jtag_tdo - FPGA AB16 - ZC706 GPIO PMOD HEADER J58.7
set_property -dict "PACKAGE_PIN AB16 IOSTANDARD LVCMOS25"  [get_ports FMC_jtag_tdo]
# GAP pad_jtag_tck - FPGA Y20 - ZC706 GPIO PMOD HEADER J58.2
set_property -dict "PACKAGE_PIN Y20 IOSTANDARD LVCMOS25"  [get_ports FMC_jtag_tck]
# GAP pad_jtag_tms - FPGA AA20 - ZC706 GPIO PMOD HEADER J58.4
set_property -dict "PACKAGE_PIN AA20 IOSTANDARD LVCMOS25"  [get_ports FMC_jtag_tms]
# GAP pad_jtag_tdi - FPGA AC18 - ZC706 GPIO PMOD HEADER J58.6
set_property -dict "PACKAGE_PIN AC18 IOSTANDARD LVCMOS25"  [get_ports FMC_jtag_tdi]
# GAP pad_jtag_trst - FPGA AC19 - ZC706 GPIO PMOD HEADER J58.8
set_property -dict "PACKAGE_PIN AC19 IOSTANDARD LVCMOS25"  [get_ports FMC_jtag_trst]
# GAP pad_bootmode - FPGA AB21 - ZC706 GPIO PMOD HEADER J58.5
set_property -dict "PACKAGE_PIN AB21 IOSTANDARD LVCMOS25"  [get_ports FMC_bootmode]

#LED
set_property PACKAGE_PIN Y21 [get_ports LED]
set_property IOSTANDARD LVCMOS25 [get_ports LED]

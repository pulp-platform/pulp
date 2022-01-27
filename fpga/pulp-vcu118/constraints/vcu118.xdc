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


#Create constraint for the clock input of the vcu118 board
create_clock -period 8.000 -name ref_clk [get_ports ref_clk_p]
set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets ref_clk]

#I2S and CAM interface are not used in this FPGA port. Set constraints to
#disable the clock
set_case_analysis 0 i_pulp/safe_domain_i/cam_pclk_o
set_case_analysis 0 i_pulp/safe_domain_i/i2s_slave_sck_o
#set_input_jitter tck 1.000

## JTAG
create_clock -period 100.000 -name tck -waveform {0.000 50.000} [get_ports pad_jtag_tck]
set_input_jitter tck 1.000
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets pad_jtag_tck_IBUF_inst/O]


# minimize routing delay
set_input_delay -clock tck -clock_fall 5.000 [get_ports pad_jtag_tdi]
set_input_delay -clock tck -clock_fall 5.000 [get_ports pad_jtag_tms]
set_output_delay -clock tck 5.000 [get_ports pad_jtag_tdo]

set_max_delay -to   [get_ports pad_jtag_tdo] 20.000
set_max_delay -from [get_ports pad_jtag_tms] 20.000
set_max_delay -from [get_ports pad_jtag_tdi] 20.000

set_max_delay -datapath_only -from [get_pins i_pulp/soc_domain_i/pulp_soc_i/i_dmi_jtag/i_dmi_cdc/i_cdc_resp/i_src/data_src_q_reg*/C] -to [get_pins i_pulp/soc_domain_i/pulp_soc_i/i_dmi_jtag/i_dmi_cdc/i_cdc_resp/i_dst/data_dst_q_reg*/D] 20.000
set_max_delay -datapath_only -from [get_pins i_pulp/soc_domain_i/pulp_soc_i/i_dmi_jtag/i_dmi_cdc/i_cdc_resp/i_src/req_src_q_reg/C] -to [get_pins i_pulp/soc_domain_i/pulp_soc_i/i_dmi_jtag/i_dmi_cdc/i_cdc_resp/i_dst/req_dst_q_reg/D] 20.000
set_max_delay -datapath_only -from [get_pins i_pulp/soc_domain_i/pulp_soc_i/i_dmi_jtag/i_dmi_cdc/i_cdc_req/i_dst/ack_dst_q_reg/C] -to [get_pins i_pulp/soc_domain_i/pulp_soc_i/i_dmi_jtag/i_dmi_cdc/i_cdc_req/i_src/ack_src_q_reg/D] 20.000


# reset signal
set_false_path -from [get_ports pad_reset]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets pad_reset_IBUF_inst/O]

# Set ASYNC_REG attribute for ff synchronizers to place them closer together and
# increase MTBF
set_property ASYNC_REG true [get_cells i_pulp/soc_domain_i/pulp_soc_i/soc_peripherals_i/i_apb_adv_timer/u_tim0/u_in_stage/r_ls_clk_sync_reg*]
set_property ASYNC_REG true [get_cells i_pulp/soc_domain_i/pulp_soc_i/soc_peripherals_i/i_apb_adv_timer/u_tim1/u_in_stage/r_ls_clk_sync_reg*]
set_property ASYNC_REG true [get_cells i_pulp/soc_domain_i/pulp_soc_i/soc_peripherals_i/i_apb_adv_timer/u_tim2/u_in_stage/r_ls_clk_sync_reg*]
set_property ASYNC_REG true [get_cells i_pulp/soc_domain_i/pulp_soc_i/soc_peripherals_i/i_apb_adv_timer/u_tim3/u_in_stage/r_ls_clk_sync_reg*]
set_property ASYNC_REG true [get_cells i_pulp/soc_domain_i/pulp_soc_i/soc_peripherals_i/i_apb_timer_unit/s_ref_clk*]
set_property ASYNC_REG true [get_cells i_pulp/soc_domain_i/pulp_soc_i/soc_peripherals_i/i_ref_clk_sync/i_pulp_sync/r_reg_reg*]
set_property ASYNC_REG true [get_cells i_pulp/soc_domain_i/pulp_soc_i/soc_peripherals_i/u_evnt_gen/r_ls_sync_reg*]

set_property ASYNC_REG true [get_cells i_pulp/cluster_domain_i/cluster_i/cluster_peripherals_i/cluster_timer_wrap_i/timer_unit_i/s_ref_clk*]

# Create asynchronous clock group between slow-clk and SoC clock. Those clocks
# are considered asynchronously and proper synchronization regs are in place
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins i_pulp/safe_domain_i/i_slow_clk_gen/slow_clk_o]] -group [get_clocks -of_objects [get_pins i_pulp/soc_domain_i/pulp_soc_i/i_clk_rst_gen/i_fpga_clk_gen/soc_clk_o]] -group [get_clocks -of_objects [get_pins i_pulp/soc_domain_i/pulp_soc_i/i_clk_rst_gen/i_fpga_clk_gen/cluster_clk_o]]

# Create asynchronous clock group between Per Clock  and SoC clock. Those clocks
# are considered asynchronously and proper synchronization regs are in place
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins i_pulp/soc_domain_i/pulp_soc_i/i_clk_rst_gen/clk_per_o]] -group [get_clocks -of_objects [get_pins i_pulp/soc_domain_i/pulp_soc_i/i_clk_rst_gen/clk_soc_o]]

# Create asynchronous clock group between JTAG TCK and SoC clock.
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins i_pulp/pad_jtag_tck]] -group [get_clocks -of_objects [get_pins i_pulp/soc_domain_i/pulp_soc_i/i_clk_rst_gen/clk_soc_o]]

#Hyper bus

create_clock -period 200.000 -name rwds_clk [get_ports FMC_hyper_rwds0]
create_generated_clock -name phy_twotimes -source [get_pins i_pulp/soc_domain_i/pulp_soc_i/i_clk_rst_gen/i_fpga_clk_gen/per_clk_o] -multiply_by 2 [get_pins i_pulp/soc_domain_i/pulp_soc_i/soc_peripherals_i/i_udma/i_hyper/periph_clk_i]

create_generated_clock -name clk_phy -source [get_pins i_pulp/soc_domain_i/pulp_soc_i/soc_peripherals_i/i_udma/i_hyper/periph_clk_i] -divide_by 2 [get_pins i_pulp/soc_domain_i/pulp_soc_i/soc_peripherals_i/i_udma/i_hyper/udma_hyperbus_i/ddr_clk/clk0_o]
create_generated_clock -name hyper_ck_o -source [get_pins i_pulp/soc_domain_i/pulp_soc_i/soc_peripherals_i/i_udma/i_hyper/periph_clk_i] -edges {2 4 6} [get_pins i_pulp/soc_domain_i/pulp_soc_i/soc_peripherals_i/i_udma/i_hyper/udma_hyperbus_i/ddr_clk/clk90_o]

set_max_delay -datapath_only -from [get_pins {i_pulp/soc_domain_i/pulp_soc_i/soc_peripherals_i/i_udma/i_hyper/udma_hyperbus_i/phy_i/i_read_clk_rwds/i_cdc_fifo_hyper/dst_rptr_gray_q_reg[*]/C}] -to [get_pins {i_pulp/soc_domain_i/pulp_soc_i/soc_peripherals_i/i_udma/i_hyper/udma_hyperbus_i/phy_i/i_read_clk_rwds/i_cdc_fifo_hyper/src_rptr_gray_q_reg[*]/D}] 30.000
set_max_delay -datapath_only -from [get_pins {i_pulp/soc_domain_i/pulp_soc_i/soc_peripherals_i/i_udma/i_hyper/udma_hyperbus_i/phy_i/i_read_clk_rwds/i_cdc_fifo_hyper/src_wptr_gray_q_reg[*]/C}] -to [get_pins {i_pulp/soc_domain_i/pulp_soc_i/soc_peripherals_i/i_udma/i_hyper/udma_hyperbus_i/phy_i/i_read_clk_rwds/i_cdc_fifo_hyper/dst_wptr_gray_q_reg[*]/D}] 30.000


# needed as bin is the same as the gray register --> removed by optimization
set_max_delay -datapath_only -from [get_pins {i_pulp/soc_domain_i/pulp_soc_i/soc_peripherals_i/i_udma/i_hyper/udma_hyperbus_i/phy_i/i_read_clk_rwds/i_cdc_fifo_hyper/dst_rptr_bin_q_reg[3]/C}] -to [get_pins {i_pulp/soc_domain_i/pulp_soc_i/soc_peripherals_i/i_udma/i_hyper/udma_hyperbus_i/phy_i/i_read_clk_rwds/i_cdc_fifo_hyper/src_rptr_gray_q_reg[3]/D}] 30.000
set_max_delay -datapath_only -from [get_pins {i_pulp/soc_domain_i/pulp_soc_i/soc_peripherals_i/i_udma/i_hyper/udma_hyperbus_i/phy_i/i_read_clk_rwds/i_cdc_fifo_hyper/dst_rptr_bin_q_reg[4]/C}] -to [get_pins {i_pulp/soc_domain_i/pulp_soc_i/soc_peripherals_i/i_udma/i_hyper/udma_hyperbus_i/phy_i/i_read_clk_rwds/i_cdc_fifo_hyper/src_rptr_gray_q_reg[4]/D}] 30.000
set_max_delay -datapath_only -from [get_pins i_pulp/soc_domain_i/pulp_soc_i/soc_peripherals_i/i_udma/i_hyper/udma_hyperbus_i/phy_i/read_clk_en_reg/C] -to [get_pins i_pulp/soc_domain_i/pulp_soc_i/soc_peripherals_i/i_udma/i_hyper/udma_hyperbus_i/phy_i/i_read_clk_rwds/read_in_valid_reg/CLR] 70

set_max_delay -datapath_only -from [get_pins i_pulp/soc_domain_i/pulp_soc_i/soc_peripherals_i/i_udma/i_hyper/udma_hyperbus_i/phy_i/hyper_dq_oe_o_reg[*]/C] -to [get_ports {FMC_hyper_dqio*}] 100
set_max_delay -datapath_only -from [get_pins i_pulp/soc_domain_i/pulp_soc_i/soc_peripherals_i/i_udma/i_hyper/udma_hyperbus_i/phy_i/hyper_rwds_oe_o_reg[*]/C] -to [get_ports {FMC_hyper_rwds0}] 100

#needed as input is sampled with clk_rwds but output is clk0 - see saved report
set_false_path -from [get_ports FMC_hyper_rwds0] -to [get_ports FMC_hyper_rwds0]
# these are for clock domain crossing
set_false_path -from [get_clocks rwds_clk] -to [get_clocks clk_phy]
set_false_path -from [get_clocks clk_phy] -to [get_clocks rwds_clk]
set_false_path -from [get_clocks hyper_ck_o] -to [get_clocks clk_phy]
set_false_path -from [get_clocks hyper_ck_o] -to [get_clocks rwds_clk]

# Output Delay Constraints

# Input Delay Constraint
 set input_clock         hyper_ck_o;           # Name of input clock
 set skew_bre            0.6;             # Data invalid before the rising clock edge
 set skew_are            0.6;             # Data invalid after the rising clock edge
 set skew_bfe            0.6;             # Data invalid before the falling clock edge
 set skew_afe            0.6;             # Data invalid after the falling clock edge
 set input_ports         {{FMC_hyper_dqio*} FMC_hyper_rwds0};   # List of input ports
 set phy_period          200

 set_input_delay -clock $input_clock -max [expr $phy_period/2 + $skew_afe] [get_ports $input_ports];
 set_input_delay -clock $input_clock -min [expr $phy_period/2 - $skew_bfe] [get_ports $input_ports] -add_delay;
 set_input_delay -clock $input_clock -max [expr $phy_period/2 + $skew_are] [get_ports $input_ports] -clock_fall -add_delay;
 set_input_delay -clock $input_clock -min [expr $phy_period/2 - $skew_bre] [get_ports $input_ports] -clock_fall -add_delay;

# Input Delay Constraint
 set input_clock         rwds_clk;      # Name of input clock
 set skew_bre            0.45+1;             # Data invalid before the rising clock edge
 set skew_are            0.45+1;             # Data invalid after the rising clock edge
 set skew_bfe            0.45+1;             # Data invalid before the falling clock edge
 set skew_afe            0.45+1;             # Data invalid after the falling clock edge
 set input_ports         {FMC_hyper_dqio*};   # List of input ports

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
set_property -dict {PACKAGE_PIN AV16 IOSTANDARD LVCMOS18} [get_ports pad_jtag_trst]


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

####################################################################
# Hyper Bus
####################################################################

set_property -dict "PACKAGE_PIN AV14 IOSTANDARD LVCMOS18"  [get_ports FMC_hyper_csn0]
set_property -dict "PACKAGE_PIN AV13 IOSTANDARD LVCMOS18"  [get_ports FMC_hyper_csn1]
set_property -dict "PACKAGE_PIN BD12 IOSTANDARD LVCMOS18"  [get_ports FMC_hyper_ck]
set_property -dict "PACKAGE_PIN BE12 IOSTANDARD LVCMOS18"  [get_ports FMC_hyper_ckn]
set_property -dict "PACKAGE_PIN BE15 IOSTANDARD LVCMOS18"  [get_ports FMC_hyper_rwds0]
set_property -dict "PACKAGE_PIN BF15 IOSTANDARD LVCMOS18"  [get_ports FMC_hyper_reset]
set_property -dict "PACKAGE_PIN BC9  IOSTANDARD LVCMOS18"  [get_ports FMC_hyper_dqio0]
set_property -dict "PACKAGE_PIN BC8  IOSTANDARD LVCMOS18"  [get_ports FMC_hyper_dqio1]
set_property -dict "PACKAGE_PIN BF11 IOSTANDARD LVCMOS18"  [get_ports FMC_hyper_dqio2]
set_property -dict "PACKAGE_PIN BC15 IOSTANDARD LVCMOS18"  [get_ports FMC_hyper_dqio3]
set_property -dict "PACKAGE_PIN BD15 IOSTANDARD LVCMOS18"  [get_ports FMC_hyper_dqio4]
set_property -dict "PACKAGE_PIN BA16 IOSTANDARD LVCMOS18"  [get_ports FMC_hyper_dqio5]
set_property -dict "PACKAGE_PIN BA15 IOSTANDARD LVCMOS18"  [get_ports FMC_hyper_dqio6]
set_property -dict "PACKAGE_PIN BC16 IOSTANDARD LVCMOS18"  [get_ports FMC_hyper_dqio7]


#set_property -dict {PACKAGE_PIN D20 IOSTANDARD LVCMOS33} [get_ports test_hyper_cko]
#set_property -dict {PACKAGE_PIN E20 IOSTANDARD LVCMOS33} [get_ports test_hyper_cs_no]
#set_property -dict {PACKAGE_PIN D22 IOSTANDARD LVCMOS33} [get_ports test_hyper_dqio0]
#set_property -dict {PACKAGE_PIN E22 IOSTANDARD LVCMOS33} [get_ports test_hyper_rwdso]
#set_property PACKAGE_PIN M15 [get_ports fmc_hyperflash_csn]
#set_property IOSTANDARD LVCMOS18 [get_ports fmc_hyperflash_csn]

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

// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

`include "pulp_soc_defines.sv"

module soc_domain #(
    parameter CORE_TYPE            = 0,
    parameter USE_FPU              = 1,
    parameter USE_HWPE             = 1,
    parameter NB_CL_CORES          = 8,
    parameter AXI_ADDR_WIDTH       = 32,
    parameter AXI_DATA_IN_WIDTH    = 64,
    parameter AXI_DATA_OUT_WIDTH   = 32,
    parameter AXI_ID_IN_WIDTH      = 4,
    parameter AXI_ID_INT_WIDTH     = 8,
    parameter AXI_ID_OUT_WIDTH     = 6,
    parameter AXI_USER_WIDTH       = 6,
    parameter AXI_STRB_IN_WIDTH    = AXI_DATA_IN_WIDTH/8,
    parameter AXI_STRB_OUT_WIDTH   = AXI_DATA_OUT_WIDTH/8,
    parameter C2S_AW_WIDTH         = 1, 
    parameter C2S_W_WIDTH          = 1,
    parameter C2S_B_WIDTH          = 1,
    parameter C2S_AR_WIDTH         = 1,
    parameter C2S_R_WIDTH          = 1,
    parameter S2C_AW_WIDTH         = 1, 
    parameter S2C_W_WIDTH          = 1,
    parameter S2C_B_WIDTH          = 1,
    parameter S2C_AR_WIDTH         = 1,
    parameter S2C_R_WIDTH          = 1,
    parameter LOG_DEPTH            = 3,

    parameter BUFFER_WIDTH         = 8,
    parameter EVNT_WIDTH           = 8,

    parameter int unsigned N_UART  = 1,
    parameter int unsigned N_SPI   = 1,
    parameter int unsigned N_I2C   = 2
)(

    input logic                                       ref_clk_i,
    input logic                                       slow_clk_i,
    input logic                                       test_clk_i,

    input logic                                       rstn_glob_i,

    input logic                                       dft_test_mode_i,
    input logic                                       dft_cg_enable_i,

    input logic                                       mode_select_i,

    input logic [1:0]                                 bootsel_i,

    input logic                                       fc_fetch_en_valid_i,
    input logic                                       fc_fetch_en_i,

    input logic                                       jtag_tck_i,
    input logic                                       jtag_trst_ni,
    input logic                                       jtag_tms_i,
    input logic                                       jtag_tdi_i,
    output logic                                      jtag_tdo_o,

    output logic [`NB_CORES-1:0]                      dbg_irq_valid_o,

    input logic [31:0]                                gpio_in_i,
    output logic [31:0]                               gpio_out_o,
    output logic [31:0]                               gpio_dir_o,
    output logic [191:0]                              gpio_cfg_o,

    output logic [127:0]                              pad_mux_o,
    output logic [383:0]                              pad_cfg_o,

    output logic                                      uart_tx_o,
    input logic                                       uart_rx_i,

    input logic                                       cam_clk_i,
    input logic [7:0]                                 cam_data_i,
    input logic                                       cam_hsync_i,
    input logic                                       cam_vsync_i,

    output logic [3:0]                                timer_ch0_o,
    output logic [3:0]                                timer_ch1_o,
    output logic [3:0]                                timer_ch2_o,
    output logic [3:0]                                timer_ch3_o,

    input logic [N_I2C-1:0]                           i2c_scl_i,
    output logic [N_I2C-1:0]                          i2c_scl_o,
    output logic [N_I2C-1:0]                          i2c_scl_oe_o,
    input logic [N_I2C-1:0]                           i2c_sda_i,
    output logic [N_I2C-1:0]                          i2c_sda_o,
    output logic [N_I2C-1:0]                          i2c_sda_oe_o,

    input logic                                       i2s_slave_sd0_i,
    input logic                                       i2s_slave_sd1_i,
    input logic                                       i2s_slave_ws_i,
    output logic                                      i2s_slave_ws_o,
    output logic                                      i2s_slave_ws_oe,
    input logic                                       i2s_slave_sck_i,
    output logic                                      i2s_slave_sck_o,
    output logic                                      i2s_slave_sck_oe,

    output logic [N_SPI-1:0]                          spi_clk_o,
    output logic [N_SPI-1:0][3:0]                     spi_csn_o,
    output logic [N_SPI-1:0][3:0]                     spi_oen_o,
    output logic [N_SPI-1:0][3:0]                     spi_sdo_o,
    input logic [N_SPI-1:0][3:0]                      spi_sdi_i,

    output logic                                      sdio_clk_o,
    output logic                                      sdio_cmd_o,
    input logic                                       sdio_cmd_i,
    output logic                                      sdio_cmd_oen_o,
    output logic [3:0]                                sdio_data_o,
    input logic [3:0]                                 sdio_data_i,
    output logic [3:0]                                sdio_data_oen_o,

    output logic [1:0]                                hyper_cs_no,
    output logic                                      hyper_ck_o,
    output logic                                      hyper_ck_no,
    output logic [1:0]                                hyper_rwds_o,
    input logic                                       hyper_rwds_i,
    output logic [1:0]                                hyper_rwds_oe_o,
    input logic [15:0]                                hyper_dq_i,
    output logic [15:0]                               hyper_dq_o,
    output logic [1:0]                                hyper_dq_oe_o,
    output logic                                      hyper_reset_no,



    // CLUSTER
    output logic                                      cluster_clk_o,
    output logic                                      cluster_rstn_o,
    input logic                                       cluster_busy_i,
    output logic                                      cluster_irq_o,

    output logic                                      cluster_rtc_o,
    output logic                                      cluster_fetch_enable_o,
    output logic [63:0]                               cluster_boot_addr_o,
    output logic                                      cluster_test_en_o,
    output logic                                      cluster_pow_o,
    output logic                                      cluster_byp_o,

    output logic                                      dma_pe_evt_ack_o,
    input logic                                       dma_pe_evt_valid_i,

    output logic                                      dma_pe_irq_ack_o,
    input logic                                       dma_pe_irq_valid_i,

    output logic                                      pf_evt_ack_o,
    input logic                                       pf_evt_valid_i,

    // EVENT BUS
    output logic [LOG_DEPTH:0]                        async_cluster_events_wptr_o,
    output logic [EVNT_WIDTH-1:0][2**LOG_DEPTH-1:0]   async_cluster_events_data_o,
    input logic [LOG_DEPTH:0]                         async_cluster_events_rptr_i,
  
    // AXI4 SLAVE
    input logic [LOG_DEPTH:0]                         async_data_slave_aw_wptr_i,
    input logic [2**LOG_DEPTH-1:0][C2S_AW_WIDTH-1:0]  async_data_slave_aw_data_i, 
    output logic [LOG_DEPTH:0]                        async_data_slave_aw_rptr_o,
                                             
    // READ ADDRESS CHANNEL                  
    input logic [LOG_DEPTH:0]                         async_data_slave_ar_wptr_i,
    input logic [2**LOG_DEPTH-1:0][C2S_AR_WIDTH-1:0]  async_data_slave_ar_data_i,
    output logic [LOG_DEPTH:0]                        async_data_slave_ar_rptr_o,
                                             
    // WRITE DATA CHANNEL                    
    input logic [LOG_DEPTH:0]                         async_data_slave_w_wptr_i,
    input logic [2**LOG_DEPTH-1:0][C2S_W_WIDTH-1:0]   async_data_slave_w_data_i,
    output logic [LOG_DEPTH:0]                        async_data_slave_w_rptr_o,
                                                     
    // READ DATA CHANNEL                             
    output logic [LOG_DEPTH:0]                        async_data_slave_r_wptr_o,
    output logic [2**LOG_DEPTH-1:0][C2S_R_WIDTH-1:0]  async_data_slave_r_data_o,
    input logic [LOG_DEPTH:0]                         async_data_slave_r_rptr_i,
                                                     
    // WRITE RESPONSE CHANNEL                        
    output logic [LOG_DEPTH:0]                        async_data_slave_b_wptr_o,
    output logic [2**LOG_DEPTH-1:0][C2S_B_WIDTH-1:0]  async_data_slave_b_data_o,
    input logic [LOG_DEPTH:0]                         async_data_slave_b_rptr_i,

    // AXI4 MASTER
    output logic [LOG_DEPTH:0]                        async_data_master_aw_wptr_o,
    output logic [2**LOG_DEPTH-1:0][S2C_AW_WIDTH-1:0] async_data_master_aw_data_o, 
    input logic [LOG_DEPTH:0]                         async_data_master_aw_rptr_i,
                                             
    // READ ADDRESS CHANNEL                  
    output logic [LOG_DEPTH:0]                        async_data_master_ar_wptr_o,
    output logic [2**LOG_DEPTH-1:0][S2C_AR_WIDTH-1:0] async_data_master_ar_data_o,
    input logic [LOG_DEPTH:0]                         async_data_master_ar_rptr_i,
                                             
    // WRITE DATA CHANNEL                    
    output logic [LOG_DEPTH:0]                        async_data_master_w_wptr_o,
    output logic [2**LOG_DEPTH-1:0][S2C_W_WIDTH-1:0]  async_data_master_w_data_o,
    input logic [LOG_DEPTH:0]                         async_data_master_w_rptr_i,
                                                     
    // READ DATA CHANNEL                             
    input logic [LOG_DEPTH:0]                         async_data_master_r_wptr_i,
    input logic [2**LOG_DEPTH-1:0][S2C_R_WIDTH-1:0]   async_data_master_r_data_i,
    output logic [LOG_DEPTH:0]                        async_data_master_r_rptr_o,
                                                     
    // WRITE RESPONSE CHANNEL                        
    input logic [LOG_DEPTH:0]                         async_data_master_b_wptr_i,
    input logic [2**LOG_DEPTH-1:0][S2C_B_WIDTH-1:0]   async_data_master_b_data_i,
    output logic [LOG_DEPTH:0]                        async_data_master_b_rptr_o    );

    pulp_soc #(
        .CORE_TYPE               ( CORE_TYPE          ),
        .USE_FPU                 ( USE_FPU            ),
        .USE_HWPE                ( USE_HWPE           ),
        .NB_CORES                ( NB_CL_CORES        ),
        .AXI_ADDR_WIDTH          ( AXI_ADDR_WIDTH     ),
        .AXI_DATA_IN_WIDTH       ( AXI_DATA_IN_WIDTH  ),
        .AXI_DATA_OUT_WIDTH      ( AXI_DATA_OUT_WIDTH ),
        .AXI_ID_IN_WIDTH         ( AXI_ID_IN_WIDTH    ),
        .AXI_USER_WIDTH          ( AXI_USER_WIDTH     ),
        .EVNT_WIDTH              ( EVNT_WIDTH         ),
        .NGPIO                   ( 32                 ),
        .NPAD                    ( 64                 ),
        .NBIT_PADCFG             ( 6                  ),
        .NBIT_PADMUX             ( 2                  ),
        .N_UART                  ( N_UART             ),
        .N_SPI                   ( N_SPI              ),
        .N_I2C                   ( N_I2C              )
   ) pulp_soc_i (

        .boot_l2_i                    ( 1'b0                         ),
        .cluster_dbg_irq_valid_o      ( dbg_irq_valid_o     ),    //dbg_irq_valid_o
        .*
    );

endmodule

// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


module pad_frame
    (

        input logic [72:0][5:0] pad_cfg_i        ,

        // REF CLOCK
        output logic            ref_clk_o        ,

        // RESET SIGNALS
        output logic            rstn_o           ,

        // JTAG SIGNALS
        output logic            jtag_tck_o       ,
        output logic            jtag_tdi_o       ,
        input  logic            jtag_tdo_i       ,
        output logic            jtag_tms_o       ,
        output logic            jtag_trst_o      ,

        input logic             oe_sdio_clk_i   ,
        input logic             oe_sdio_cmd_i    ,
        input logic             oe_sdio_data0_i   ,
        input logic             oe_sdio_data1_i   ,
        input logic             oe_sdio_data2_i   ,
        input logic             oe_sdio_data3_i   ,
        input logic             oe_spim_sdio0_i  ,
        input logic             oe_spim_sdio1_i  ,
        input logic             oe_spim_sdio2_i  ,
        input logic             oe_spim_sdio3_i  ,
        input logic             oe_spim_csn0_i   ,
        input logic             oe_spim_csn1_i   ,
        input logic             oe_spim_sck_i    ,
        input logic             oe_i2s0_sck_i    ,
        input logic             oe_i2s0_ws_i     ,
        input logic             oe_i2s0_sdi_i    ,
        input logic             oe_i2s1_sdi_i    ,
        input logic             oe_cam_pclk_i    ,
        input logic             oe_cam_hsync_i   ,
        input logic             oe_cam_data0_i   ,
        input logic             oe_cam_data1_i   ,
        input logic             oe_cam_data2_i   ,
        input logic             oe_cam_data3_i   ,
        input logic             oe_cam_data4_i   ,
        input logic             oe_cam_data5_i   ,
        input logic             oe_cam_data6_i   ,
        input logic             oe_cam_data7_i   ,
        input logic             oe_cam_vsync_i   ,
        input logic             oe_i2c0_sda_i    ,
        input logic             oe_i2c0_scl_i    ,
        input logic             oe_uart_rx_i     ,
        input logic             oe_uart_tx_i     ,
        
        input logic[31:0]       oe_gpios_i       ,
        input logic             oe_i2c1_sda_i    ,
        input logic             oe_i2c1_scl_i    ,     

        input logic             oe_hyper_cs0n_i      ,
        input logic             oe_hyper_cs1n_i      ,
        input logic             oe_hyper_ck_i        ,
        input logic             oe_hyper_ckn_i       ,
        input logic             oe_hyper_rwds0_i     ,
        input logic             oe_hyper_rwds1_i     ,
        input logic             oe_hyper_dq0_i       ,
        input logic             oe_hyper_dq1_i       ,
        input logic             oe_hyper_resetn_i    ,
  
        // INPUTS SIGNALS TO THE PADS
        input logic             out_sdio_clk_i  ,
        input logic             out_sdio_cmd_i   ,
        input logic             out_sdio_data0_i  ,
        input logic             out_sdio_data1_i  ,
        input logic             out_sdio_data2_i  ,
        input logic             out_sdio_data3_i  ,
        input logic             out_spim_sdio0_i ,
        input logic             out_spim_sdio1_i ,
        input logic             out_spim_sdio2_i ,
        input logic             out_spim_sdio3_i ,
        input logic             out_spim_csn0_i  ,
        input logic             out_spim_csn1_i  ,
        input logic             out_spim_sck_i   ,
        input logic             out_i2s0_sck_i   ,
        input logic             out_i2s0_ws_i    ,
        input logic             out_i2s0_sdi_i   ,
        input logic             out_i2s1_sdi_i   ,
        input logic             out_cam_pclk_i   ,
        input logic             out_cam_hsync_i  ,
        input logic             out_cam_data0_i  ,
        input logic             out_cam_data1_i  ,
        input logic             out_cam_data2_i  ,
        input logic             out_cam_data3_i  ,
        input logic             out_cam_data4_i  ,
        input logic             out_cam_data5_i  ,
        input logic             out_cam_data6_i  ,
        input logic             out_cam_data7_i  ,
        input logic             out_cam_vsync_i  ,
        input logic             out_i2c0_sda_i   ,
        input logic             out_i2c0_scl_i   ,
        input logic             out_uart_rx_i    ,
        input logic             out_uart_tx_i    ,
        
        input logic[31:0]       out_gpios_i      ,
        input logic             out_i2c1_sda_i   ,
        input logic             out_i2c1_scl_i   ,
        
        input logic             out_hyper_cs0n_i     ,
        input logic             out_hyper_cs1n_i     ,
        input logic             out_hyper_ck_i       ,
        input logic             out_hyper_ckn_i      ,
        input logic             out_hyper_rwds0_i    ,
        input logic             out_hyper_rwds1_i    ,
        input logic  [7:0]      out_hyper_dq0_i      ,
        input logic  [7:0]      out_hyper_dq1_i      ,
        input logic             out_hyper_resetn_i   ,

        // OUTPUT SIGNALS FROM THE PADS
        output logic            in_sdio_clk_o   ,
        output logic            in_sdio_cmd_o    ,
        output logic            in_sdio_data0_o   ,
        output logic            in_sdio_data1_o   ,
        output logic            in_sdio_data2_o   ,
        output logic            in_sdio_data3_o   ,
        output logic            in_spim_sdio0_o  ,
        output logic            in_spim_sdio1_o  ,
        output logic            in_spim_sdio2_o  ,
        output logic            in_spim_sdio3_o  ,
        output logic            in_spim_csn0_o   ,
        output logic            in_spim_csn1_o   ,
        output logic            in_spim_sck_o    ,
        output logic            in_i2s0_sck_o    ,
        output logic            in_i2s0_ws_o     ,
        output logic            in_i2s0_sdi_o    ,
        output logic            in_i2s1_sdi_o    ,
        output logic            in_cam_pclk_o    ,
        output logic            in_cam_hsync_o   ,
        output logic            in_cam_data0_o   ,
        output logic            in_cam_data1_o   ,
        output logic            in_cam_data2_o   ,
        output logic            in_cam_data3_o   ,
        output logic            in_cam_data4_o   ,
        output logic            in_cam_data5_o   ,
        output logic            in_cam_data6_o   ,
        output logic            in_cam_data7_o   ,
        output logic            in_cam_vsync_o   ,
        output logic            in_i2c0_sda_o    ,
        output logic            in_i2c0_scl_o    ,
        output logic            in_uart_rx_o     ,
        output logic            in_uart_tx_o     ,
        
        output logic[31:0]      in_gpios_o       ,
        output logic            in_i2c1_sda_o    ,
        output logic            in_i2c1_scl_o    , 

        output logic            in_hyper_cs0n_o     ,
        output logic            in_hyper_cs1n_o     ,
        output logic            in_hyper_ck_o       ,
        output logic            in_hyper_ckn_o      ,
        output logic            in_hyper_rwds0_o    ,
        output logic            in_hyper_rwds1_o    ,
        output logic  [7:0]     in_hyper_dq0_o      ,
        output logic  [7:0]     in_hyper_dq1_o      ,
        output logic            in_hyper_resetn_o   ,

        output logic [1:0]      bootsel_o        ,

        // EXT CHIP TP PADS
        inout wire              pad_sdio_clk     ,
        inout wire              pad_sdio_cmd     ,
        inout wire              pad_sdio_data0   ,
        inout wire              pad_sdio_data1   ,
        inout wire              pad_sdio_data2   ,
        inout wire              pad_sdio_data3   ,
        inout wire              pad_spim_sdio0   ,
        inout wire              pad_spim_sdio1   ,
        inout wire              pad_spim_sdio2   ,
        inout wire              pad_spim_sdio3   ,
        inout wire              pad_spim_csn0    ,
        inout wire              pad_spim_csn1    ,
        inout wire              pad_spim_sck     ,
        inout wire              pad_i2s0_sck     ,
        inout wire              pad_i2s0_ws      ,
        inout wire              pad_i2s0_sdi     ,
        inout wire              pad_i2s1_sdi     ,
        inout wire              pad_cam_pclk     ,
        inout wire              pad_cam_hsync    ,
        inout wire              pad_cam_data0    ,
        inout wire              pad_cam_data1    ,
        inout wire              pad_cam_data2    ,
        inout wire              pad_cam_data3    ,
        inout wire              pad_cam_data4    ,
        inout wire              pad_cam_data5    ,
        inout wire              pad_cam_data6    ,
        inout wire              pad_cam_data7    ,
        inout wire              pad_cam_vsync    ,
        inout wire              pad_i2c0_sda     ,
        inout wire              pad_i2c0_scl     ,
        inout wire              pad_uart_rx      ,
        inout wire              pad_uart_tx      ,
        
        inout wire [31:0]       pad_gpios        ,
        inout wire              pad_i2c1_sda     ,
        inout wire              pad_i2c1_scl     ,


        inout wire [7:0]        pad_hyper_dq0    ,
        inout wire [7:0]        pad_hyper_dq1    ,
        inout wire              pad_hyper_ck     ,
        inout wire              pad_hyper_ckn    ,
        inout wire              pad_hyper_csn0   ,
        inout wire              pad_hyper_csn1   ,
        inout wire              pad_hyper_rwds0  ,
        inout wire              pad_hyper_rwds1  ,
        inout wire              pad_hyper_reset  ,


        inout wire              pad_reset_n      ,
        inout wire              pad_bootsel0     ,
        inout wire              pad_bootsel1     ,
        inout wire              pad_jtag_tck     ,
        inout wire              pad_jtag_tdi     ,
        inout wire              pad_jtag_tdo     ,
        inout wire              pad_jtag_tms     ,
        inout wire              pad_jtag_trst    ,
        inout wire              pad_xtal_in


    );

    pad_functional_pd padinst_sdio_data0 (.OEN(~oe_sdio_data0_i ), .I(out_sdio_data0_i ), .O(in_sdio_data0_o ), .PAD(pad_sdio_data0 ), .PEN(~pad_cfg_i[22][0]) );
    pad_functional_pd padinst_sdio_data1 (.OEN(~oe_sdio_data1_i ), .I(out_sdio_data1_i ), .O(in_sdio_data1_o ), .PAD(pad_sdio_data1 ), .PEN(~pad_cfg_i[23][0]) );
    pad_functional_pd padinst_sdio_data2 (.OEN(~oe_sdio_data2_i ), .I(out_sdio_data2_i ), .O(in_sdio_data2_o ), .PAD(pad_sdio_data2 ), .PEN(~pad_cfg_i[24][0]) );
    pad_functional_pd padinst_sdio_data3 (.OEN(~oe_sdio_data3_i ), .I(out_sdio_data3_i ), .O(in_sdio_data3_o ), .PAD(pad_sdio_data3 ), .PEN(~pad_cfg_i[25][0]) );
    pad_functional_pd padinst_sdio_clk   (.OEN(~oe_sdio_clk_i  ), .I(out_sdio_clk_i  ), .O(in_sdio_clk_o  ), .PAD(pad_sdio_clk  ), .PEN(~pad_cfg_i[20][0]) );
    pad_functional_pd padinst_sdio_cmd   (.OEN(~oe_sdio_cmd_i  ), .I(out_sdio_cmd_i  ), .O(in_sdio_cmd_o  ), .PAD(pad_sdio_cmd  ), .PEN(~pad_cfg_i[21][0]) );
    pad_functional_pd padinst_spim_sck   (.OEN(~oe_spim_sck_i  ), .I(out_spim_sck_i  ), .O(in_spim_sck_o  ), .PAD(pad_spim_sck  ), .PEN(~pad_cfg_i[6][0] ) );
    pad_functional_pd padinst_spim_sdio0 (.OEN(~oe_spim_sdio0_i), .I(out_spim_sdio0_i), .O(in_spim_sdio0_o), .PAD(pad_spim_sdio0), .PEN(~pad_cfg_i[0][0] ) );
    pad_functional_pd padinst_spim_sdio1 (.OEN(~oe_spim_sdio1_i), .I(out_spim_sdio1_i), .O(in_spim_sdio1_o), .PAD(pad_spim_sdio1), .PEN(~pad_cfg_i[1][0] ) );
    pad_functional_pd padinst_spim_sdio2 (.OEN(~oe_spim_sdio2_i), .I(out_spim_sdio2_i), .O(in_spim_sdio2_o), .PAD(pad_spim_sdio2), .PEN(~pad_cfg_i[2][0] ) );
    pad_functional_pd padinst_spim_sdio3 (.OEN(~oe_spim_sdio3_i), .I(out_spim_sdio3_i), .O(in_spim_sdio3_o), .PAD(pad_spim_sdio3), .PEN(~pad_cfg_i[3][0] ) );
    pad_functional_pd padinst_spim_csn1  (.OEN(~oe_spim_csn1_i ), .I(out_spim_csn1_i ), .O(in_spim_csn1_o ), .PAD(pad_spim_csn1 ), .PEN(~pad_cfg_i[5][0] ) );
    pad_functional_pd padinst_spim_csn0  (.OEN(~oe_spim_csn0_i ), .I(out_spim_csn0_i ), .O(in_spim_csn0_o ), .PAD(pad_spim_csn0 ), .PEN(~pad_cfg_i[4][0] ) );

    pad_functional_pd padinst_i2s1_sdi   (.OEN(~oe_i2s1_sdi_i  ), .I(out_i2s1_sdi_i  ), .O(in_i2s1_sdi_o  ), .PAD(pad_i2s1_sdi  ), .PEN(~pad_cfg_i[38][0]) );
    pad_functional_pd padinst_i2s0_ws    (.OEN(~oe_i2s0_ws_i   ), .I(out_i2s0_ws_i   ), .O(in_i2s0_ws_o   ), .PAD(pad_i2s0_ws   ), .PEN(~pad_cfg_i[36][0]) );
    pad_functional_pd padinst_i2s0_sdi   (.OEN(~oe_i2s0_sdi_i  ), .I(out_i2s0_sdi_i  ), .O(in_i2s0_sdi_o  ), .PAD(pad_i2s0_sdi  ), .PEN(~pad_cfg_i[37][0]) );
    pad_functional_pd padinst_i2s0_sck   (.OEN(~oe_i2s0_sck_i  ), .I(out_i2s0_sck_i  ), .O(in_i2s0_sck_o  ), .PAD(pad_i2s0_sck  ), .PEN(~pad_cfg_i[35][0]) );


    pad_functional_pd padinst_cam_pclk   (.OEN(~oe_cam_pclk_i  ), .I(out_cam_pclk_i  ), .O(in_cam_pclk_o  ), .PAD(pad_cam_pclk  ), .PEN(~pad_cfg_i[9][0] ) );
    pad_functional_pd padinst_cam_hsync  (.OEN(~oe_cam_hsync_i ), .I(out_cam_hsync_i ), .O(in_cam_hsync_o ), .PAD(pad_cam_hsync ), .PEN(~pad_cfg_i[10][0]) );
    pad_functional_pd padinst_cam_data0  (.OEN(~oe_cam_data0_i ), .I(out_cam_data0_i ), .O(in_cam_data0_o ), .PAD(pad_cam_data0 ), .PEN(~pad_cfg_i[11][0]) );
    pad_functional_pd padinst_cam_data1  (.OEN(~oe_cam_data1_i ), .I(out_cam_data1_i ), .O(in_cam_data1_o ), .PAD(pad_cam_data1 ), .PEN(~pad_cfg_i[12][0]) );
    pad_functional_pd padinst_cam_data2  (.OEN(~oe_cam_data2_i ), .I(out_cam_data2_i ), .O(in_cam_data2_o ), .PAD(pad_cam_data2 ), .PEN(~pad_cfg_i[13][0]) );
    pad_functional_pd padinst_cam_data3  (.OEN(~oe_cam_data3_i ), .I(out_cam_data3_i ), .O(in_cam_data3_o ), .PAD(pad_cam_data3 ), .PEN(~pad_cfg_i[14][0]) );
    pad_functional_pd padinst_cam_data4  (.OEN(~oe_cam_data4_i ), .I(out_cam_data4_i ), .O(in_cam_data4_o ), .PAD(pad_cam_data4 ), .PEN(~pad_cfg_i[15][0]) );
    pad_functional_pd padinst_cam_data5  (.OEN(~oe_cam_data5_i ), .I(out_cam_data5_i ), .O(in_cam_data5_o ), .PAD(pad_cam_data5 ), .PEN(~pad_cfg_i[16][0]) );
    pad_functional_pd padinst_cam_data6  (.OEN(~oe_cam_data6_i ), .I(out_cam_data6_i ), .O(in_cam_data6_o ), .PAD(pad_cam_data6 ), .PEN(~pad_cfg_i[17][0]) );
    pad_functional_pd padinst_cam_data7  (.OEN(~oe_cam_data7_i ), .I(out_cam_data7_i ), .O(in_cam_data7_o ), .PAD(pad_cam_data7 ), .PEN(~pad_cfg_i[18][0]) );
    pad_functional_pd padinst_cam_vsync  (.OEN(~oe_cam_vsync_i ), .I(out_cam_vsync_i ), .O(in_cam_vsync_o ), .PAD(pad_cam_vsync ), .PEN(~pad_cfg_i[19][0]) );

    pad_functional_pu padinst_uart_rx    (.OEN(~oe_uart_rx_i   ), .I(out_uart_rx_i   ), .O(in_uart_rx_o   ), .PAD(pad_uart_rx   ), .PEN(~pad_cfg_i[33][0]) );
    pad_functional_pu padinst_uart_tx    (.OEN(~oe_uart_tx_i   ), .I(out_uart_tx_i   ), .O(in_uart_tx_o   ), .PAD(pad_uart_tx   ), .PEN(~pad_cfg_i[34][0]) );
    pad_functional_pu padinst_i2c0_sda   (.OEN(~oe_i2c0_sda_i  ), .I(out_i2c0_sda_i  ), .O(in_i2c0_sda_o  ), .PAD(pad_i2c0_sda  ), .PEN(~pad_cfg_i[7][0] ) );
    pad_functional_pu padinst_i2c0_scl   (.OEN(~oe_i2c0_scl_i  ), .I(out_i2c0_scl_i  ), .O(in_i2c0_scl_o  ), .PAD(pad_i2c0_scl  ), .PEN(~pad_cfg_i[8][0] ) );
    

    pad_functional_pu padinst_hyper_csno0  (.OEN(~oe_hyper_cs0n_i   ), .I( out_hyper_cs0n_i   ), .O( in_hyper_cs0n_o   ), .PAD( pad_hyper_csn0    ), .PEN(1'b1 ) );
    pad_functional_pu padinst_hyper_csno1  (.OEN(~oe_hyper_cs1n_i   ), .I( out_hyper_cs1n_i   ), .O( in_hyper_cs1n_o   ), .PAD( pad_hyper_csn1    ), .PEN(1'b1 ) );
    pad_functional_pu padinst_hyper_ck     (.OEN(~oe_hyper_ck_i     ), .I( out_hyper_ck_i     ), .O( in_hyper_ck_o     ), .PAD( pad_hyper_ck      ), .PEN(1'b1 ) );
    pad_functional_pu padinst_hyper_ckno   (.OEN(~oe_hyper_ckn_i    ), .I( out_hyper_ckn_i    ), .O( in_hyper_ckn_o    ), .PAD( pad_hyper_ckn     ), .PEN(1'b1 ) );
    pad_functional_pu padinst_hyper_rwds0  (.OEN(~oe_hyper_rwds0_i  ), .I( out_hyper_rwds0_i  ), .O( in_hyper_rwds0_o  ), .PAD( pad_hyper_rwds0   ), .PEN(1'b1 ) );
    pad_functional_pu padinst_hyper_rwds1  (.OEN(~oe_hyper_rwds1_i  ), .I( out_hyper_rwds1_i  ), .O( in_hyper_rwds1_o  ), .PAD( pad_hyper_rwds1   ), .PEN(1'b1 ) );
    pad_functional_pu padinst_hyper_resetn (.OEN(~oe_hyper_resetn_i ), .I( out_hyper_resetn_i ), .O( in_hyper_resetn_o ), .PAD( pad_hyper_reset   ), .PEN(1'b1 ) );

    genvar j;
    generate
       for (j=0; j<8; j++) begin
                pad_functional_pu padinst_hyper_dqio0  (.OEN(~oe_hyper_dq0_i   ), .I( out_hyper_dq0_i[j]   ), .O( in_hyper_dq0_o[j]  ), .PAD( pad_hyper_dq0[j]   ), .PEN(1'b1 ) );
		`ifndef PULP_FPGA_EMUL
                pad_functional_pu padinst_hyper_dqio1  (.OEN(~oe_hyper_dq1_i   ), .I( out_hyper_dq1_i[j]   ), .O( in_hyper_dq1_o[j]  ), .PAD( pad_hyper_dq1[j]   ), .PEN(1'b1 ) );
                `endif
        end
    endgenerate
 
    `ifndef PULP_FPGA_EMUL
    genvar i;
    generate
        for (i=0; i < 32; i++) begin
            pad_functional_pu padinst_gpio   (.OEN(~oe_gpios_i[i]  ), .I(out_gpios_i[i]  ), .O(in_gpios_o[i]  ), .PAD(pad_gpios[i]  ), .PEN(~pad_cfg_i[41+i][0] ) );
        end
    endgenerate

    pad_functional_pu padinst_i2c1_sda   (.OEN(~oe_i2c1_sda_i  ), .I(out_i2c1_sda_i  ), .O(in_i2c1_sda_o  ), .PAD(pad_i2c1_sda  ), .PEN(~pad_cfg_i[26][0] ) );
    pad_functional_pu padinst_i2c1_scl   (.OEN(~oe_i2c1_scl_i  ), .I(out_i2c1_scl_i  ), .O(in_i2c1_scl_o  ), .PAD(pad_i2c1_scl  ), .PEN(~pad_cfg_i[27][0] ) );


    pad_functional_pu padinst_bootsel0    (.OEN(1'b1            ), .I(                ), .O(bootsel_o[0]      ), .PAD(pad_bootsel0   ), .PEN(1'b1             ) );
    pad_functional_pu padinst_bootsel1    (.OEN(1'b1            ), .I(                ), .O(bootsel_o[1]      ), .PAD(pad_bootsel1   ), .PEN(1'b1             ) );
    `endif


`ifndef PULP_FPGA_EMUL
  pad_functional_pu padinst_ref_clk    (.OEN(1'b1            ), .I(                ), .O(ref_clk_o      ), .PAD(pad_xtal_in   ), .PEN(1'b1             ) );
  pad_functional_pu padinst_reset_n    (.OEN(1'b1            ), .I(                ), .O(rstn_o         ), .PAD(pad_reset_n   ), .PEN(1'b1             ) );
  pad_functional_pu padinst_jtag_tck   (.OEN(1'b1            ), .I(                ), .O(jtag_tck_o     ), .PAD(pad_jtag_tck  ), .PEN(1'b1             ) );
  pad_functional_pu padinst_jtag_tms   (.OEN(1'b1            ), .I(                ), .O(jtag_tms_o     ), .PAD(pad_jtag_tms  ), .PEN(1'b1             ) );
  pad_functional_pu padinst_jtag_tdi   (.OEN(1'b1            ), .I(                ), .O(jtag_tdi_o     ), .PAD(pad_jtag_tdi  ), .PEN(1'b1             ) );
  pad_functional_pu padinst_jtag_trstn (.OEN(1'b1            ), .I(                ), .O(jtag_trst_o    ), .PAD(pad_jtag_trst ), .PEN(1'b1             ) );
  pad_functional_pd padinst_jtag_tdo   (.OEN(1'b0            ), .I(jtag_tdo_i      ), .O(               ), .PAD(pad_jtag_tdo  ), .PEN(1'b1             ) );

`else
  assign ref_clk_o = pad_xtal_in;
  assign rstn_o = pad_reset_n;

  //JTAG signals
  assign pad_jtag_tdo = jtag_tdo_i;
  assign jtag_trst_o = pad_jtag_trst;
  assign jtag_tms_o = pad_jtag_tms;
  assign jtag_tck_o = pad_jtag_tck;
  assign jtag_tdi_o = pad_jtag_tdi;
`endif

endmodule // pad_frame

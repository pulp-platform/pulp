// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

/*
 * tb_pulp.sv
 * Francesco Conti <fconti@iis.ee.ethz.ch>
 * Antonio Pullini <pullinia@iis.ee.ethz.ch>
 * Igor Loi <igor.loi@unibo.it>
 */

timeunit 1ps;
timeprecision 1ps;

`define EXIT_SUCCESS  0
`define EXIT_FAIL     1
`define EXIT_ERROR   -1

module tb_pulp;

   /* simulation platform parameters */

   // the following parameters can activate instantiation of the verification IPs for SPI, I2C and I2s
   // see the instructions in rtl/vip/{i2c_eeprom,i2s,spi_flash} to download the verification IPs
   parameter  USE_S25FS256S_MODEL = 0;
   parameter  USE_24FC1025_MODEL  = 0;
   parameter  USE_I2S_MODEL       = 0;

   // period of the external reference clock (32.769kHz)
   parameter  REF_CLK_PERIOD = 30517ns;

   // how L2 is loaded. valid values are "JTAG" or "STANDALONE", the latter works only when USE_S25FS256S_MODEL is 1
   parameter  LOAD_L2 = "JTAG";

   // enable DPI-based JTAG
   parameter  ENABLE_DPI = 0;

   // enable DPI-based peripherals
   parameter  ENABLE_DEV_DPI = 1;

   // enable DPI-based debug bridge
   parameter  ENABLE_DEBUG_BRIDGE = 0;

   // UART baud rate in bps
   parameter  BAUDRATE = 625000;

   // use frequency-locked loop to generate internal clock
   parameter  USE_FLL = 1;

   // use camera verification IP
   parameter  USE_SDVT_CPI = 0;

   // files to be used to load the I2S verification IP, if instantiated
   parameter  I2S_FILENAME_0 = "i2s_buffer_0.hex";
   parameter  I2S_FILENAME_1 = "i2s_buffer_1.hex";
   parameter  I2S_FILENAME_2 = "i2s_buffer_2.hex";
   parameter  I2S_FILENAME_3 = "i2s_buffer_3.hex";

   // for PULP, 8 cores
   parameter NB_CORES = 8;

   // SPI standards, do not change
   parameter logic[1:0] SPI_STD     = 2'b00;
   parameter logic[1:0] SPI_QUAD_TX = 2'b01;
   parameter logic[1:0] SPI_QUAD_RX = 2'b10;

   // JTAG mux configuration, do not change
   parameter logic[1:0] JTAG_DPI    = 2'b01;
   parameter logic[1:0] JTAG_BRIDGE = 2'b10;

   /* simulation variables & flags */
   logic                 uart_tb_rx_en = 1'b0;
   logic                 uart_vip_rx_en = 1'b0;
   string                uart_drv_mon_sel = "TB";

   int                   num_stim;
   logic [95:0]          stimuli  [100000:0];                // array for the stimulus vectors

   logic [1:0]           jtag_mux = 2'b00;

   logic                 dev_dpi_en = 0;

   logic [255:0][31:0]   jtag_data;

   logic jtag_enable;

   int                   exit_status = `EXIT_ERROR; // modelsim exit code, will be overwritten when successfull

   /* system wires */
   // the w_/s_ prefixes are used to mean wire/tri-type and logic-type (respectively)

   logic                 s_rst_n = 1'b0;
   wire                  w_rst_n;

   logic                 s_clk_ref;
   wire                  w_clk_ref;

   tri                   w_spi_master_sdio0;
   tri                   w_spi_master_sdio1;
   tri                   w_spi_master_sdio2;
   tri                   w_spi_master_sdio3;
   tri                   w_spi_master_csn0;
   tri                   w_spi_master_csn1;
   tri                   w_spi_master_sck;

   wire                  w_i2c0_scl;
   wire                  w_i2c0_sda;

   tri                   w_i2c1_scl;
   tri                   w_i2c1_sda;

   logic [1:0]           s_padmode_spi_master = SPI_STD;

   tri                   w_uart_rx;
   tri                   w_uart_tx;

   wire                  w_cam_pclk;
   wire [7:0]            w_cam_data;
   wire                  w_cam_hsync;
   wire                  w_cam_vsync;

   // I2S 0
   wire                  w_i2s0_sck;
   wire                  w_i2s0_ws;
   wire                  w_i2s0_sdi;
   // I2S 1
   wire                  w_i2s1_sdi;

   wire                  w_i2s_sck;
   wire                  w_i2s_ws;
   wire           [7:0]  w_i2s_data;

   wire                  w_trstn;
   wire                  w_tck;
   wire                  w_tdi;
   wire                  w_tms;
   wire                  w_tdo;

   logic                 s_vpi_trstn;
   logic                 s_vpi_tck;
   logic                 s_vpi_tdi;
   logic                 s_vpi_tms;

   wire                  w_bridge_trstn;
   wire                  w_bridge_tdo;
   wire                  w_bridge_tck;
   wire                  w_bridge_tdi;
   wire                  w_bridge_tms;

   logic                 s_trstn = 1'b0;
   logic                 s_tck   = 1'b0;
   logic                 s_tdi   = 1'b0;
   logic                 s_tms   = 1'b0;
   logic                 s_tdo;
   logic                 s_mode_select;

   wire w_master_i2s_sck;
   wire w_master_i2s_ws ;

   wire w_bootsel;

   /* DPI interfaces */
   I2S i2s[0:1] (
      {
         { w_i2s0_sdi, w_i2s0_ws, w_i2s0_sck },
         { w_i2s1_sdi, w_i2s0_ws, w_i2s0_sck }
      }
   );
   CPI cpi[0:0] (
      { { w_cam_pclk, w_cam_hsync, w_cam_vsync, w_cam_data[0], w_cam_data[1], w_cam_data[2], w_cam_data[3], w_cam_data[4], w_cam_data[5], w_cam_data[6], w_cam_data[7] } }
   );
   GPIO gpio[0:31] (
      {
         { w_spi_master_sdio0 }, { w_spi_master_sdio1 }, { w_spi_master_sdio2 }, { w_spi_master_sdio3 },
         { w_spi_master_csn0  }, { w_spi_master_csn1  }, { w_spi_master_sck   }, { w_uart_rx          },
         { w_uart_tx          }, { w_cam_pclk       }, { w_cam_hsync      }, { w_cam_data[0]    },
         { w_cam_data[1]    }, { w_cam_data[2]    }, { w_cam_data[3]    }, { w_cam_data[4]    },
         { w_cam_data[5]    }, { w_cam_data[6]    }, { w_cam_data[7]    }, { w_cam_vsync      },
         { s_hyper_ckn      }, { s_hyper_ck       }, { s_hyper_dq0      }, { s_hyper_dq1      },
         { s_hyper_dq2      }, { s_hyper_dq3      }, { w_i2c0_sda       }, { w_i2c0_scl       },
         { w_i2s0_sck       }, { w_i2s0_ws        }, { w_i2s0_sdi       }, { w_i2s1_sdi       }
      }
   );
   JTAG jtag[0:0] (
      { { w_bridge_tdo, w_bridge_trstn, w_bridge_tms, w_bridge_tdi, w_bridge_tck } }
   );

   if (!ENABLE_DEV_DPI) begin
      bufif0 (weak1,weak0) (w_i2c0_sda,1'b1,1'b0);
      bufif0 (weak1,weak0) (w_i2c0_scl,1'b1,1'b0);
   end

   pullup sda1_pullup_i (w_i2c1_sda);
   pullup scl1_pullup_i (w_i2c1_scl);

   assign w_rst_n   = s_rst_n;
   assign w_clk_ref = s_clk_ref;

   assign s_cam_valid = 1'b0;

   assign w_trstn      = (jtag_mux == JTAG_DPI) ? s_vpi_trstn : (jtag_mux == JTAG_BRIDGE) ? w_bridge_trstn : s_trstn;
   assign w_tck        = (jtag_mux == JTAG_DPI) ? s_vpi_tck   : (jtag_mux == JTAG_BRIDGE) ? w_bridge_tck   : s_tck;
   assign w_tdi        = (jtag_mux == JTAG_DPI) ? s_vpi_tdi   : (jtag_mux == JTAG_BRIDGE) ? w_bridge_tdi   : s_tdi;
   assign w_tms        = (jtag_mux == JTAG_DPI) ? s_vpi_tms   : (jtag_mux == JTAG_BRIDGE) ? w_bridge_tms   : s_tms;
   assign s_tdo        = w_tdo;
   assign w_bridge_tdo = w_tdo;

   assign w_uart_tx = w_uart_rx;
   assign w_bootsel = 1'b0;

   /* JTAG DPI-based verification IP */
   generate
      if(ENABLE_DPI == 1) begin
         jtag_dpi #(
            .TIMEOUT_COUNT ( 6'h2 )
         ) i_jtag (
            .clk_i    ( w_clk_ref          ),
            .enable_i ( jtag_mux == JTAG_DPI ),
            .tms_o    ( s_vpi_tms    ),
            .tck_o    ( s_vpi_tck    ),
            .trst_o   ( s_vpi_trstn  ),
            .tdi_o    ( s_vpi_tdi    ),
            .tdo_i    ( s_tdo        )
         );
      end
   endgenerate

   /* DPI */
   generate
      if(ENABLE_DEV_DPI == 1) begin: dev_dpi
         dev_dpi #(
            .N_I2S_CHANNELS  ( 2  ),
            .N_CPI_CHANNELS  ( 1  ),
            .N_GPIO_CHANNELS ( 32 ),
            .N_JTAG_CHANNELS ( 1  )
         ) i_dev_dpi (
            .en_i  ( dev_dpi_en ),
            .i2s   ( i2s        ),
            .cpi   ( cpi        ),
            .gpio  ( gpio       ),
            .jtag  ( jtag       ),
            .reset ( s_rst_n    )
         );
      end
   endgenerate

   /* SPI flash model (not open-source, from Spansion) */
   generate
      if(USE_S25FS256S_MODEL == 1) begin
         s25fs256s #(
            .TimingModel   ( "S25FS256SAGMFI000_F_30pF" ),
            .mem_file_name ( "slm_files/flash_stim.slm" ),
            .UserPreload   (1)
         ) i_spi_flash_csn0 (
            .SI       ( w_spi_master_sdio0 ),
            .SO       ( w_spi_master_sdio1 ),
            .SCK      ( w_spi_master_sck   ),
            .CSNeg    ( w_spi_master_csn0  ),
            .WPNeg    ( w_spi_master_sdio2 ),
            .RESETNeg ( w_spi_master_sdio3 )
         );
      end
      else begin
         assign w_spi_master_sdio1 = 'z;
      end
   endgenerate

   /* UART receiver */
   uart_tb_rx #(
      .BAUD_RATE ( BAUDRATE   ),
      .PARITY_EN ( 0          )
   ) i_rx_mod (
      .rx        ( w_uart_rx       ),
      .rx_en     ( uart_tb_rx_en ),
      .word_done (               )
   );

   if (!ENABLE_DEV_DPI) begin

      /* CPI verification IP */
      if (!USE_SDVT_CPI) begin
         cam_vip #(
            .HRES       ( 320 ),
            .VRES       ( 240 )
         ) i_cam_vip (
            .cam_pclk_o  ( w_cam_pclk  ),
            .cam_vsync_o ( w_cam_vsync ),
            .cam_href_o  ( w_cam_hsync ),
            .cam_data_o  ( w_cam_data  )
         );
      end

      /* I2C memory models */
      if(USE_24FC1025_MODEL) begin
         M24FC1025 i_i2c_mem_0 (
            .A0    ( 1'b0       ),
            .A1    ( 1'b0       ),
            .A2    ( 1'b1       ),
            .WP    ( 1'b0       ),
            .SDA   ( w_i2c0_sda ),
            .SCL   ( w_i2c0_scl ),
            .RESET ( 1'b0       )
         );
         M24FC1025 i_i2c_mem_1 (
            .A0    ( 1'b1       ),
            .A1    ( 1'b0       ),
            .A2    ( 1'b1       ),
            .WP    ( 1'b0       ),
            .SDA   ( w_i2c0_sda ),
            .SCL   ( w_i2c0_scl ),
            .RESET ( 1'b0       )
         );
      end

      /* I2S verification IPs */
      if(USE_I2S_MODEL) begin
         i2s_vip #(
            .I2S_CHAN ( 0              ),
            .FILENAME ( I2S_FILENAME_0 )
         ) i_i2s_vip_ch0 (
            .A0     ( 1'b0          ),
            .A1     ( 1'b1          ),
            .SDA    ( w_i2c0_sda    ),
            .SCL    ( w_i2c0_scl    ),
            .sck_i  ( w_i2s_sck     ),
            .ws_i   ( w_i2s_ws      ),
            .data_o ( w_i2s_data[0] ),
            .sck_o  (               ),
            .ws_o   (               )
         );

         i2s_vip #(
            .I2S_CHAN ( 1              ),
            .FILENAME ( I2S_FILENAME_1 )
         )
         i_i2s_vip_ch1 (
            .A0     ( 1'b1          ),
            .A1     ( 1'b1          ),
            .SDA    ( w_i2c0_sda    ),
            .SCL    ( w_i2c0_scl    ),
            .sck_i  ( w_i2s_sck     ),
            .ws_i   ( w_i2s_ws      ),
            .data_o ( w_i2s_data[1] ),
            .sck_o  (               ),
            .ws_o   (               )
         );

         i2s_vip #(
            .I2S_CHAN ( 2              ),
            .FILENAME ( I2S_FILENAME_2 )
         ) i_i2s_CAM_MASTER_SLAVE (
            .A0     ( 1'b0              ),
            .A1     ( 1'b0              ),
            .SDA    ( w_i2c0_sda        ),
            .SCL    ( w_i2c0_scl        ),
            .sck_i  ( w_i2s_sck         ),
            .ws_i   ( w_i2s_ws          ),
            .data_o ( s_master_i2s_sdi0 ),
            .sck_o  ( w_master_i2s_sck  ),
            .ws_o   ( w_master_i2s_ws   )
         );

         i2s_vip #(
            .I2S_CHAN ( 3              ),
            .FILENAME ( I2S_FILENAME_3 )
         )
         i_i2s_CAM_SLAVE
            (
               .A0     ( 1'b1             ),
               .A1     ( 1'b0             ),
               .SDA    ( w_i2c0_sda       ),
               .SCL    ( w_i2c0_scl       ),
               .sck_i  ( s_slave_i2s_sck  ),
               .ws_i   ( s_slave_i2s_ws   ),
               .data_o ( s_slave_i2s_sdi1 ),
               .sck_o  (                  ),
               .ws_o   (                  )
            );
      end

   end

   /* PULP chip (design under test) */
   pulp i_dut (
      .pad_spim_sdio0     ( w_spi_master_sdio0 ),
      .pad_spim_sdio1     ( w_spi_master_sdio1 ),
      .pad_spim_sdio2     ( w_spi_master_sdio2 ),
      .pad_spim_sdio3     ( w_spi_master_sdio3 ),
      .pad_spim_csn0      ( w_spi_master_csn0  ),
      .pad_spim_csn1      ( w_spi_master_csn1  ),
      .pad_spim_sck       ( w_spi_master_sck   ),

      .pad_uart_rx        ( w_uart_tx          ),
      .pad_uart_tx        ( w_uart_rx          ),

      .pad_cam_pclk       ( w_cam_pclk         ),
      .pad_cam_hsync      ( w_cam_hsync        ),
      .pad_cam_data0      ( w_cam_data[0]      ),
      .pad_cam_data1      ( w_cam_data[1]      ),
      .pad_cam_data2      ( w_cam_data[2]      ),
      .pad_cam_data3      ( w_cam_data[3]      ),
      .pad_cam_data4      ( w_cam_data[4]      ),
      .pad_cam_data5      ( w_cam_data[5]      ),
      .pad_cam_data6      ( w_cam_data[6]      ),
      .pad_cam_data7      ( w_cam_data[7]      ),
      .pad_cam_vsync      ( w_cam_vsync        ),

      .pad_i2c0_sda       ( w_i2c0_sda         ),
      .pad_i2c0_scl       ( w_i2c0_scl         ),

      .pad_i2s0_sck       ( w_i2s0_sck         ),
      .pad_i2s0_ws        ( w_i2s0_ws          ),
      .pad_i2s0_sdi       ( w_i2s0_sdi         ),
      .pad_i2s1_sdi       ( w_i2s1_sdi         ),

      .pad_sdio_clk       (                    ),
      .pad_sdio_cmd       (                    ),
      .pad_sdio_data0     (                    ),
      .pad_sdio_data1     (                    ),
      .pad_sdio_data2     (                    ),
      .pad_sdio_data3     (                    ),

      .pad_reset_n        ( w_rst_n            ),
      .pad_bootsel        ( w_bootsel          ),

      .pad_jtag_tck       ( w_tck              ),
      .pad_jtag_tdi       ( w_tdi              ),
      .pad_jtag_tdo       ( w_tdo              ),
      .pad_jtag_tms       ( w_tms              ),
      .pad_jtag_trst      ( w_trstn            ),

      .pad_xtal_in        ( w_clk_ref          )
   );

   tb_clk_gen #( .CLK_PERIOD(REF_CLK_PERIOD) ) i_ref_clk_gen (.clk_o(s_clk_ref) );

   /* testbench driver process */
   initial
      begin

         force tb_pulp.i_dut.pad_frame_i.padinst_reset_n.O = 1'b0;

         // force fetch enable to 0 when doing JTAG preload (not particularly clean, but works)
         if(LOAD_L2 == "JTAG")
            force tb_pulp.i_dut.soc_domain_i.pulp_soc_i.soc_peripherals_i.apb_soc_ctrl_i.r_fetchen = '0;

         if (ENABLE_DEBUG_BRIDGE) begin
            jtag_mux = JTAG_BRIDGE;
         end
         else begin
            if (USE_FLL)
               $display("[TB] %t - Using FLL", $realtime);
            else
               $display("[TB] %t - Not using FLL", $realtime);

            if (USE_SDVT_CPI)
               $display("[TB] %t - Using CAM SDVT", $realtime);
            else
               $display("[TB] %t - Not using CAM SDVT", $realtime);

            if (LOAD_L2 == "STANDALONE")
               s_mode_select = 1'b1;
            else
               s_mode_select = 1'b0;

            $readmemh("./vectors/stim.txt", stimuli);  // read in the stimuli vectors  == address_value
         end

         $display("[TB] %t - Asserting hard reset", $realtime);

         #1ns

            release tb_pulp.i_dut.pad_frame_i.padinst_reset_n.O;
         uart_tb_rx_en   = 1'b1; // enable uart rx in testbench

         if (ENABLE_DEBUG_BRIDGE == 0) begin

            automatic jtag_pkg::test_mode_if_t test_mode_if = new;
            automatic dbg_pkg::dbg_if_soc_t dbg_if_soc = new;

            jtag_pkg::jtag_reset(
               s_tck,
               s_tms,
               s_trstn,
               s_tdi
            );
            jtag_pkg::jtag_softreset(
               s_tck,
               s_tms,
               s_trstn,
               s_tdi
            );
            #5us;

            if(LOAD_L2 == "JTAG") begin
               $display("[TB] %t - Virtually removing ROM as JTAG boot was selected in testbench", $realtime);
               for(int i=0; i<2048; i++)
                  tb_pulp.i_dut.soc_domain_i.pulp_soc_i.boot_rom_i.rom_mem_i.MEM[i] = 32'h0;
            end

            test_mode_if.init(
               s_tck,
               s_tms,
               s_trstn,
               s_tdi
            );

            $display("[TB] %t - Enabling clock out via jtag", $realtime);
            if (USE_FLL) begin
               test_mode_if.set_confreg(
                  22'h000800,
                  s_tck,
                  s_tms,
                  s_trstn,
                  s_tdi,
                  s_tdo
               );
            end else begin
               test_mode_if.set_confreg(
                  22'h200800,
                  s_tck,
                  s_tms,
                  s_trstn,
                  s_tdi,
                  s_tdo
               );
            end

            if (ENABLE_DPI == 1)
               begin
                  jtag_mux = JTAG_DPI;
               end

            #50us;

            s_rst_n = 1'b1;
            jtag_enable = 1'b0;

            $display("[TB] %t - Releasing hard reset", $realtime);
            #350us;

            jtag_enable = 1'b1;

            wait(tb_pulp.i_dut.soc_domain_i.pulp_soc_i.s_soc_clk == 1);
            wait(tb_pulp.i_dut.soc_domain_i.pulp_soc_i.s_soc_clk == 0);
            wait(tb_pulp.i_dut.soc_domain_i.pulp_soc_i.s_soc_clk == 1);

            $display("[SOC_CLK] %t - SOC_CLK Ready", $realtime);

            dbg_if_soc.init(s_tck, s_tms, s_trstn, s_tdi);
            if(LOAD_L2 == "JTAG") begin
               $display("[TB] %t - Loading L2", $realtime);
               dbg_if_soc.write32(32'h1A104008, 1, 32'h0, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
               dbg_if_soc.write32(32'h1A104004, 1, 32'h1c00_8080, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
               release tb_pulp.i_dut.soc_domain_i.pulp_soc_i.soc_peripherals_i.apb_soc_ctrl_i.r_fetchen;
            end

            #300us;

            if(LOAD_L2 == "JTAG") begin
               $display("[TB] %t - Loading L2", $realtime);
               dbg_pkg::jtag_load_L2(num_stim, stimuli, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
            end

            if (LOAD_L2 != "STANDALONE") begin
               $display("[TB] %t - Triggering fetch enable", $realtime);
               dbg_if_soc.write32(32'h1A104008, 1, 32'h1, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
            end

            // Select UART driver/monitor
            if ($value$plusargs("uart_drv_mon=%s", uart_drv_mon_sel)) begin
               if (uart_drv_mon_sel == "VIP") begin
                  uart_tb_rx_en = 1'b0;
                  uart_vip_rx_en = 1'b1;
               end
            end

            // make sure that we can drive the SSPI lines when not in use
            s_padmode_spi_master = SPI_QUAD_RX;

            jtag_data[0] = 0;

            // wait for end of computation signal
            $display("[TB] %t - Waiting for end of computation", $realtime);
            while(jtag_data[0][31] == 0) begin
               dbg_if_soc.read32(32'h1A1040A0, 1, jtag_data, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
               #50us;
            end

            if (jtag_data[0][30:0] == 0)
               exit_status = `EXIT_SUCCESS;
            else
               exit_status = `EXIT_FAIL;
            $display("[TB] %t - Received status core: 0x%h", $realtime, jtag_data[0][30:0]);

            $stop;

         end
         else begin // ENABLE_DEBUG_BRIDGE != 0
            #1us
               dev_dpi_en <= 1;
         end

      end

   `ifndef USE_NETLIST
      /* File System access */
      logic r_stdout_pready;

      logic        fs_clk;
      logic        fs_rst_n;
      logic        fs_wen;
      logic [0:0]  fs_csn;
      logic [31:0] fs_add;
      logic [3:0]  fs_be;
      logic [31:0] fs_wdata;
      logic [31:0] fs_rdata;

      assign fs_clk = i_dut.soc_domain_i.pulp_soc_i.s_soc_clk;
      assign fs_rst_n = i_dut.soc_domain_i.pulp_soc_i.s_soc_rstn;

      assign fs_csn   = ~(i_dut.soc_domain_i.pulp_soc_i.soc_peripherals_i.s_stdout_bus.psel &
         i_dut.soc_domain_i.pulp_soc_i.soc_peripherals_i.s_stdout_bus.penable &
         r_stdout_pready);
      assign fs_wen   = ~i_dut.soc_domain_i.pulp_soc_i.soc_peripherals_i.s_stdout_bus.pwrite;
      assign fs_add   = i_dut.soc_domain_i.pulp_soc_i.soc_peripherals_i.s_stdout_bus.paddr;
      assign fs_wdata = i_dut.soc_domain_i.pulp_soc_i.soc_peripherals_i.s_stdout_bus.pwdata;
      assign fs_be    = 4'hF;
      assign i_dut.soc_domain_i.pulp_soc_i.soc_peripherals_i.s_stdout_bus.pready  = r_stdout_pready;
      assign i_dut.soc_domain_i.pulp_soc_i.soc_peripherals_i.s_stdout_bus.pslverr = 1'b0;
      assign i_dut.soc_domain_i.pulp_soc_i.soc_peripherals_i.s_stdout_bus.prdata  = fs_rdata;

      always_ff @(posedge fs_clk or negedge fs_rst_n) begin
         if(~fs_rst_n) begin
            r_stdout_pready <= 0;
         end
         else begin
            r_stdout_pready <= (i_dut.soc_domain_i.pulp_soc_i.soc_peripherals_i.s_stdout_bus.psel & i_dut.soc_domain_i.pulp_soc_i.soc_peripherals_i.s_stdout_bus.penable);
         end
      end

      tb_fs_handler #(
         .ADDR_WIDTH ( 32       ),
         .DATA_WIDTH ( 32       ),
         .NB_CORES   ( NB_CORES )
      ) i_fs_handler (
         .clk   ( fs_clk   ),
         .rst_n ( fs_rst_n ),
         .CSN   ( fs_csn   ),
         .WEN   ( fs_wen   ),
         .ADDR  ( fs_add   ),
         .WDATA ( fs_wdata ),
         .BE    ( fs_be    ),
         .RDATA ( fs_rdata )
      );
   `endif

   /* tracing */
   integer               IOFILE[NB_CORES];
   string                FILENAME[NB_CORES];
   string                FILE_ID;

   logic                 is_Read[NB_CORES];

   initial
      begin
         for(int index = 0; index < NB_CORES; index++) begin : _CREATE_IO_FILES_
            FILE_ID.itoa(index);
            FILENAME[index] = { "CORE_", FILE_ID, ".txt" };
            IOFILE[index]   = $fopen(FILENAME[index],"w");
            is_Read[index]  = 0;
         end
      end

endmodule // tb_pulp

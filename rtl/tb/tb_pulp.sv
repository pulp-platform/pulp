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
 * Robert Balas <balasr@iis.ee.ethz.ch>
 */

// timeunit 1ps;
// timeprecision 1ps;

`define EXIT_SUCCESS  0
`define EXIT_FAIL     1
`define EXIT_ERROR   -1
//`define USE_DPI      1


module tb_pulp;

   parameter CONFIG_FILE = "NONE";

   /* simulation platform parameters */

   // Choose your core: 0 for RISCY, 1 for ZERORISCY
   parameter CORE_TYPE            = 0;
   // if RISCY is instantiated (CORE_TYPE == 0), RISCY_FPU enables the FPU
   parameter RISCY_FPU            = 1;

   // Decide whether to use x registers (USE_ZFINX = 1) or f registers (USE_ZFINX = 0) for FP operations
   parameter USE_ZFINX            = 0;

   // the following parameters can activate instantiation of the verification IPs for SPI, I2C and I2s
   // see the instructions in rtl/vip/{i2c_eeprom,i2s,spi_flash} to download the verification IPs
   `ifdef USE_VIPS
     parameter  USE_S25FS256S_MODEL = 1;
     parameter  USE_24FC1025_MODEL  = 1;
     parameter  USE_I2S_MODEL       = 1;
     parameter  USE_HYPER_MODELS    = 1;
   `else
     parameter  USE_S25FS256S_MODEL = 0;
     parameter  USE_24FC1025_MODEL  = 0;
     parameter  USE_I2S_MODEL       = 0;
     parameter  USE_HYPER_MODELS    = 0;
   `endif
    //psram model, cannot be tested simultaneously with the hyperram
   `ifdef USE_PSRAM
     parameter  PSRAM_MODELS        = 1;
   `else
     parameter  PSRAM_MODELS        = 0;
   `endif

   // period of the external reference clock (32.769kHz)
   parameter  REF_CLK_PERIOD = 30517ns;

   // how L2 is loaded. valid values are "JTAG" or "STANDALONE", the latter works only when USE_S25FS256S_MODEL is 1
   parameter  LOAD_L2 = "JTAG";

   // STIM_FROM sets where is the image data.
   // In case any values are not given, the debug module takes over the boot process.
   parameter  STIM_FROM = "JTAG"; // can be "JTAG" "SPI_FLASH", "HYPER_FLASH", or ""

   // enable DPI-based JTAG
   parameter  ENABLE_DPI = 0;

   // enable DPI-based peripherals
   parameter  ENABLE_DEV_DPI = 0;

   // enable DPI-based custom debug bridge
   parameter  ENABLE_EXTERNAL_DRIVER = 0;

   // enable DPI-based openocd debug bridge
   parameter ENABLE_OPENOCD = 0;

   // enable Debug Module Tests
   parameter ENABLE_DM_TESTS = 0;

   // use the pulp tap to access the bus
   parameter USE_PULP_BUS_ACCESS = 1;

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

   // contains the program code
   string stimuli_file;

   /* simulation variables & flags */
   logic                 uart_tb_rx_en = 1'b0;
   logic                 uart_vip_rx_en = 1'b0;
   string                uart_drv_mon_sel = "TB";

   int                   num_stim;
   logic [95:0]          stimuli  [100000:0];                // array for the stimulus vectors

   logic [1:0]           jtag_mux = 2'b00;

   logic                 dev_dpi_en = 0;

   logic [255:0][31:0]   jtag_data;


   int                   exit_status = `EXIT_ERROR; // modelsim exit code, will be overwritten when successfull

   jtag_pkg::test_mode_if_t   test_mode_if = new;
   jtag_pkg::debug_mode_if_t  debug_mode_if = new;
   pulp_tap_pkg::pulp_tap_if_soc_t pulp_tap = new;

   /* system wires */
   // the w_/s_ prefixes are used to mean wire/tri-type and logic-type (respectively)

   logic                 s_rst_n = 1'b0;
   logic                 s_rst_dpi_n;
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

   tri                   w_sdio_data0;

   wire                  w_i2c0_scl;
   wire                  w_i2c0_sda;

   wire [31:0]           w_gpios;

   tri                   w_i2c1_scl;
   tri                   w_i2c1_sda;

   wire [7:0]            w_hyper_dq0    ;
   wire [7:0]            w_hyper_dq1    ;
   wire                  w_hyper_ck     ;
   wire                  w_hyper_ckn    ;
   wire                  w_hyper_csn0   ;
   wire                  w_hyper_csn1   ;
   wire                  w_hyper_rwds0  ;
   wire                  w_hyper_rwds1  ;
   wire                  w_hyper_reset  ;

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

   // jtag openocd bridge signals
   logic                sim_jtag_tck;
   logic                sim_jtag_tms;
   logic                sim_jtag_tdi;
   logic                sim_jtag_trstn;
   logic                sim_jtag_tdo;
   logic [31:0]         sim_jtag_exit;
   logic                sim_jtag_enable;

   // tmp signals for assignment to wires
   logic                tmp_rst_n;
   logic                tmp_clk_ref;
   logic                tmp_trstn;
   logic                tmp_tck;
   logic                tmp_tdi;
   logic                tmp_tms;
   logic                tmp_tdo;
   logic                tmp_bridge_tdo;



   wire w_master_i2s_sck;
   wire w_master_i2s_ws ;

   wire[1:0] w_bootsel;
   logic[1:0] s_bootsel;


   logic [8:0] jtag_conf_reg, jtag_conf_rego; //22bits but actually only the last 9bits are used


   `ifdef USE_DPI
   generate
      if (CONFIG_FILE != "NONE") begin

         CTRL     ctrl();
         JTAG     jtag();
         UART     uart();
         CPI      cpi();

         QSPI     qspi_0  ();
         QSPI_CS  qspi_0_csn [0:1]  ();

         GPIO     gpio_22();

         assign s_rst_dpi_n   = ~ctrl.reset;

         assign w_bridge_tck   = jtag.tck;
         assign w_bridge_tdi   = jtag.tdi;
         assign w_bridge_tms   = jtag.tms;
         assign w_bridge_trstn = jtag.trst;
         assign jtag.tdo       = w_bridge_tdo;

         assign w_uart_tx      = uart.tx;
         assign uart.rx        = w_uart_rx;

         assign w_spi_master_sdio0 = qspi_0.data_0_out;
         assign qspi_0.data_0_in = w_spi_master_sdio0;
         assign w_spi_master_sdio1 = qspi_0.data_1_out;
         assign qspi_0.data_1_in = w_spi_master_sdio1;
         assign w_spi_master_sdio2 = qspi_0.data_2_out;
         assign qspi_0.data_2_in = w_spi_master_sdio2;
         assign w_spi_master_sdio3 = qspi_0.data_3_out;
         assign qspi_0.data_3_in = w_spi_master_sdio3;
         assign qspi_0.sck = w_spi_master_sck;
         assign qspi_0_csn[0].csn = w_spi_master_csn0;
         assign qspi_0_csn[1].csn = w_spi_master_csn1;
         assign w_cam_pclk = cpi.pclk;
         assign w_cam_hsync = cpi.href;
         assign w_cam_vsync = cpi.vsync;
         assign w_cam_data[0] = cpi.data[0];
         assign w_cam_data[1] = cpi.data[1];
         assign w_cam_data[2] = cpi.data[2];
         assign w_cam_data[3] = cpi.data[3];
         assign w_cam_data[4] = cpi.data[4];
         assign w_cam_data[5] = cpi.data[5];
         assign w_cam_data[6] = cpi.data[6];
         assign w_cam_data[7] = cpi.data[7];

         assign w_sdio_data0  = gpio_22.data_out;


         initial
         begin

            automatic tb_driver::tb_driver i_tb_driver = new;

            qspi_0.data_0_out = 'bz;
            qspi_0.data_1_out = 'bz;
            qspi_0.data_2_out = 'bz;
            qspi_0.data_3_out = 'bz;

            i_tb_driver.register_qspim_itf(0, qspi_0, qspi_0_csn);
            i_tb_driver.register_uart_itf(0, uart);
            i_tb_driver.register_jtag_itf(0, jtag);
            i_tb_driver.register_cpi_itf(0, cpi);
            i_tb_driver.register_ctrl_itf(0, ctrl);
            i_tb_driver.register_gpio_itf(22, gpio_22);
            i_tb_driver.build_from_json(CONFIG_FILE);

         end

      end

   endgenerate
   `endif



   pullup sda0_pullup_i (w_i2c0_sda);
   pullup scl0_pullup_i (w_i2c0_scl);

   pullup sda1_pullup_i (w_i2c1_sda);
   pullup scl1_pullup_i (w_i2c1_scl);

  // pullup hyper_rwds0_pu (w_hyper_rwds0);

   always_comb begin
      sim_jtag_enable = 1'b0;

      if (ENABLE_EXTERNAL_DRIVER) begin
         tmp_rst_n      = s_rst_dpi_n;
         tmp_clk_ref    = s_clk_ref;
         tmp_trstn      = w_bridge_trstn;
         tmp_tck        = w_bridge_tck;
         tmp_tdi        = w_bridge_tdi;
         tmp_tms        = w_bridge_tms;
         tmp_tdo        = w_tdo;
         tmp_bridge_tdo = w_tdo;

      end else if (ENABLE_OPENOCD) begin
         tmp_rst_n         = s_rst_n;
         tmp_clk_ref       = s_clk_ref;
         tmp_trstn         = sim_jtag_trstn;
         tmp_tck           = sim_jtag_tck;
         tmp_tdi           = sim_jtag_tdi;
         tmp_tms           = sim_jtag_tms;
         tmp_tdo           = w_tdo;
         tmp_bridge_tdo    = w_tdo;
         sim_jtag_enable = 1'b1;

      end else begin
         tmp_rst_n      = s_rst_n;
         tmp_clk_ref    = s_clk_ref;

         tmp_trstn      = s_trstn;
         tmp_tck        = s_tck;
         tmp_tdi        = s_tdi;
         tmp_tms        = s_tms;
         tmp_tdo        = w_tdo;
         tmp_bridge_tdo = w_tdo;

      end
   end

    assign w_rst_n      = tmp_rst_n;
    assign w_clk_ref    = tmp_clk_ref;
    assign s_cam_valid  = 1'b0;
    assign w_trstn      = tmp_trstn;
    assign w_tck        = tmp_tck;
    assign w_tdi        = tmp_tdi;
    assign w_tms        = tmp_tms;
    assign s_tdo        = tmp_tdo;
    assign w_bridge_tdo = tmp_bridge_tdo;
    assign sim_jtag_tdo = tmp_tdo;


   if (CONFIG_FILE == "NONE") begin
      assign w_uart_tx = w_uart_rx;
   end


   assign w_bootsel = s_bootsel;

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

// Hyperram and hyperflash modules
   generate
      if(USE_HYPER_MODELS == 1) begin
         s27ks0641 #(
            .TimingModel  ("S27KS0641DPBHI020")
         ) hyperram_model (
            .DQ7      ( w_hyper_dq0[7] ),
            .DQ6      ( w_hyper_dq0[6] ),
            .DQ5      ( w_hyper_dq0[5] ),
            .DQ4      ( w_hyper_dq0[4] ),
            .DQ3      ( w_hyper_dq0[3] ),
            .DQ2      ( w_hyper_dq0[2] ),
            .DQ1      ( w_hyper_dq0[1] ),
            .DQ0      ( w_hyper_dq0[0] ),
            .RWDS     ( w_hyper_rwds0  ),
            .CSNeg    ( w_hyper_csn1   ),
            .CK       ( w_hyper_ck     ),
            .CKNeg    ( w_hyper_ckn    ),
            .RESETNeg ( w_hyper_reset  )
         );
         s26ks512s #(
            .TimingModel   ( "S26KS512SDPBHI000"),
            .mem_file_name ( "./vectors/hyper_stim.slm" )
         ) hyperflash_model (
            .DQ7      ( w_hyper_dq0[7] ),
            .DQ6      ( w_hyper_dq0[6] ),
            .DQ5      ( w_hyper_dq0[5] ),
            .DQ4      ( w_hyper_dq0[4] ),
            .DQ3      ( w_hyper_dq0[3] ),
            .DQ2      ( w_hyper_dq0[2] ),
            .DQ1      ( w_hyper_dq0[1] ),
            .DQ0      ( w_hyper_dq0[0] ),
            .RWDS     ( w_hyper_rwds0  ),
            .CSNeg    ( w_hyper_csn0   ),
            .CK       ( w_hyper_ck     ),
            .CKNeg    ( w_hyper_ckn    ),
            .RESETNeg ( w_hyper_reset  )
         );
      end
   endgenerate

   generate
      if(PSRAM_MODELS == 1) begin
         psram_model psram_model_i (
            .xDQ      ( {w_hyper_dq1, w_hyper_dq0} ),
            .xDQSDM   ( {w_hyper_rwds1, w_hyper_rwds0}       ),
            .xCEn     ( w_hyper_csn1 ),
            .xCLK     ( w_hyper_ck   )
         );
      end
   endgenerate
   /* SPI flash model (not open-source, from Spansion) */
   generate
      if(USE_S25FS256S_MODEL == 1) begin
         s25fs256s #(
            .TimingModel   ( "S25FS256SAGMFI000_F_30pF" ),
            .mem_file_name ( "./vectors/qspi_stim.slm" ),
            .UserPreload   ( ( LOAD_L2 == "STANDALONE" ) ? 1 : 0 )
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

   if (CONFIG_FILE == "NONE") begin
      /* UART receiver */
      uart_tb_rx #(
         .BAUD_RATE ( BAUDRATE   ),
         .PARITY_EN ( 0          )
      ) i_rx_mod (
         .rx        ( w_uart_rx       ),
         .rx_en     ( uart_tb_rx_en ),
         .word_done (               )
      );
   end

   /* I2C memory models */
   if (USE_24FC1025_MODEL == 1) begin
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
         .SDA   ( w_i2c1_sda ),
         .SCL   ( w_i2c1_scl ),
         .RESET ( 1'b0       )
      );
   end

   if (!ENABLE_DEV_DPI && CONFIG_FILE == "NONE") begin

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

    // jtag calls from dpi
    SimJTAG #(
        .TICK_DELAY (1)
    )
    i_sim_jtag (
        .clock                ( w_clk_ref            ),
        .reset                ( ~s_rst_n             ),
        .enable               ( sim_jtag_enable      ),
        .init_done            ( s_rst_n              ),
        .jtag_TCK             ( sim_jtag_tck         ),
        .jtag_TMS             ( sim_jtag_tms         ),
        .jtag_TDI             ( sim_jtag_tdi         ),
        .jtag_TRSTn           ( sim_jtag_trstn       ),
        .jtag_TDO_data        ( sim_jtag_tdo         ),
        .jtag_TDO_driven      ( 1'b1                 ),
        .exit                 ( sim_jtag_exit        )
    );


   // GPIO TEST
   genvar i;
   //genvar j;


   assign w_gpios[16] = w_gpios[0]  ? 1'b1 : 1'b0 ;
   assign w_gpios[17] = w_gpios[1]  ? 1'b1 : 1'b0 ;
   assign w_gpios[18] = w_gpios[2]  ? 1'b1 : 1'b0 ;
   assign w_gpios[19] = w_gpios[3]  ? 1'b1 : 1'b0 ;
   assign w_gpios[20] = w_gpios[4]  ? 1'b1 : 1'b0 ;
   assign w_gpios[21] = w_gpios[5]  ? 1'b1 : 1'b0 ;
   assign w_gpios[22] = w_gpios[6]  ? 1'b1 : 1'b0 ;
   assign w_gpios[23] = w_gpios[7]  ? 1'b1 : 1'b0 ;
   assign w_gpios[24] = w_gpios[8]  ? 1'b1 : 1'b0 ;
   assign w_gpios[25] = w_gpios[9]  ? 1'b1 : 1'b0 ;
   assign w_gpios[26] = w_gpios[10] ? 1'b1 : 1'b0 ;
   assign w_gpios[27] = w_gpios[11] ? 1'b1 : 1'b0 ;
   assign w_gpios[28] = w_gpios[12] ? 1'b1 : 1'b0 ;
   assign w_gpios[29] = w_gpios[13] ? 1'b1 : 1'b0 ;
   assign w_gpios[30] = w_gpios[14] ? 1'b1 : 1'b0 ;
   assign w_gpios[31] = w_gpios[15] ? 1'b1 : 1'b0 ;




   // PULP chip (design under test)
   pulp #(
      .CORE_TYPE ( CORE_TYPE ),
      .USE_FPU   ( RISCY_FPU ),
      .USE_ZFINX ( USE_ZFINX )
   )
   i_dut (
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

      .pad_sdio_clk       (                    ),
      .pad_sdio_cmd       (                    ),
      .pad_sdio_data0     ( w_sdio_data0       ),
      .pad_sdio_data1     (                    ),
      .pad_sdio_data2     (                    ),
      .pad_sdio_data3     (                    ),

      .pad_i2c0_sda       ( w_i2c0_sda         ),
      .pad_i2c0_scl       ( w_i2c0_scl         ),

      .pad_gpios          ( w_gpios            ),

      .pad_i2c1_sda       ( w_i2c1_sda         ),
      .pad_i2c1_scl       ( w_i2c1_scl         ),

      .pad_i2s0_sck       ( w_i2s0_sck         ),
      .pad_i2s0_ws        ( w_i2s0_ws          ),
      .pad_i2s0_sdi       ( w_i2s0_sdi         ),
      .pad_i2s1_sdi       ( w_i2s1_sdi         ),

      .pad_hyper_dq0     ( w_hyper_dq0         ),
      .pad_hyper_dq1     ( w_hyper_dq1         ),
      .pad_hyper_ck      ( w_hyper_ck          ),
      .pad_hyper_ckn     ( w_hyper_ckn         ),
      .pad_hyper_csn0    ( w_hyper_csn0        ),
      .pad_hyper_csn1    ( w_hyper_csn1        ),
      .pad_hyper_rwds0   ( w_hyper_rwds0       ),
      .pad_hyper_rwds1   ( w_hyper_rwds1       ),
      .pad_hyper_reset   ( w_hyper_reset       ),

      .pad_reset_n        ( w_rst_n            ),
      .pad_bootsel0       ( w_bootsel[0]       ),
      .pad_bootsel1       ( w_bootsel[1]       ),


      .pad_jtag_tck       ( w_tck              ),
      .pad_jtag_tdi       ( w_tdi              ),
      .pad_jtag_tdo       ( w_tdo              ),
      .pad_jtag_tms       ( w_tms              ),
      .pad_jtag_trst      ( w_trstn            ),

      .pad_xtal_in        ( w_clk_ref          )
   );

   tb_clk_gen #( .CLK_PERIOD(REF_CLK_PERIOD) ) i_ref_clk_gen (.clk_o(s_clk_ref) );

    initial begin: timing_format
        $timeformat(-9, 0, "ns", 9);
    end: timing_format

   // testbench driver process
   initial
      begin

         logic [1:0]  dm_op;
         logic [31:0] dm_data;
         logic [6:0]  dm_addr;
         logic        error;
         int         num_err;
         int         rd_cnt;

         automatic logic [9:0]  FC_CORE_ID = {5'd31, 5'd0};

         int entry_point;
         logic [31:0] begin_l2_instr;

         error   = 1'b0;
         num_err = 0;
         rd_cnt=0;

         // read entry point from commandline
         if ($value$plusargs("ENTRY_POINT=%h", entry_point))
             begin_l2_instr = entry_point;
         else
             begin_l2_instr = 32'h1C008080;
         $display("[TB] %t - Entry point is set to 0x%h", $realtime, begin_l2_instr);

         $display("[TB] %t - Asserting hard reset", $realtime);
         s_rst_n = 1'b0;

         #1ns

         uart_tb_rx_en  = 1'b1; // enable uart rx in testbench

         if (ENABLE_OPENOCD == 1) begin
            // Use openocd to interact with the simulation
            s_bootsel = 2'b01;
            $display("[TB] %t - Releasing hard reset", $realtime);
            s_rst_n = 1'b1;

         end else if (ENABLE_EXTERNAL_DRIVER == 1) begin
            // Use the pulp bridge to interact with the simulation
            #1us
               dev_dpi_en <= 1;

         end else begin
            // Use only the testbench to do the loading and running

            // determine if we want to load the binary with jtag or from flash
            if (LOAD_L2 == "STANDALONE") begin
               // jtag reset needed anyway
               jtag_pkg::jtag_reset(s_tck, s_tms, s_trstn, s_tdi);
               jtag_pkg::jtag_softreset(s_tck, s_tms, s_trstn, s_tdi);
               #5us;

               s_bootsel= (STIM_FROM=="SPI_FLASH") ? 2'b00 : ( (STIM_FROM=="HYPER_FLASH") ? 2'b10 : 2'b00 );

               if (STIM_FROM == "HYPER_FLASH") begin
                   $display("[TB] %t - HyperFlash boot: Setting bootsel to 2'b10", $realtime);
               end else if (STIM_FROM == "SPI_FLASH") begin
                   $display("[TB] %t - QSPI boot: Setting bootsel to 2'b00", $realtime);
               end

            $display("[TB] %t - Releasing hard reset", $realtime);
            s_rst_n = 1'b1;
            debug_mode_if.init_dmi_access(s_tck, s_tms, s_trstn, s_tdi);
            debug_mode_if.set_dmactive(1'b1, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
            #10us;
            end
            else if (LOAD_L2 == "JTAG") begin
               s_bootsel = 2'b01;
            end

            if (LOAD_L2 == "JTAG") begin
               if (USE_FLL)
                  $display("[TB] %t - Using FLL", $realtime);
               else
                  $display("[TB] %t - Not using FLL", $realtime);

               if (USE_SDVT_CPI)
                  $display("[TB] %t - Using CAM SDVT", $realtime);
               else
                  $display("[TB] %t - Not using CAM SDVT", $realtime);

               // read in the stimuli vectors  == address_value
               if ($value$plusargs("stimuli=%s", stimuli_file)) begin
                  $display("Loading custom stimuli from %s", stimuli_file);
                  $readmemh(stimuli_file, stimuli);
               end else begin
                  $display("Loading default stimuli");
                  $readmemh("./vectors/stim.txt", stimuli);
               end

               // before starting the actual boot procedure we do some light
               // testing on the jtag link
               jtag_pkg::jtag_reset(s_tck, s_tms, s_trstn, s_tdi);
               jtag_pkg::jtag_softreset(s_tck, s_tms, s_trstn, s_tdi);
               #5us;

               jtag_pkg::jtag_bypass_test(s_tck, s_tms, s_trstn, s_tdi, s_tdo);
               #5us;

               jtag_pkg::jtag_get_idcode(s_tck, s_tms, s_trstn, s_tdi, s_tdo);
               #5us;

               test_mode_if.init(s_tck, s_tms, s_trstn, s_tdi);

               $display("[TB] %t - Enabling clock out via jtag", $realtime);

               // The boot code installed in the ROM checks the JTAG register value.
               // If jtag_conf_reg is set to 0, the debug module will take over the boot process
               // The image file can be loaded also from SPI flash and Hyper flash
               // even though this is not the stand-alone boot

               jtag_conf_reg = (STIM_FROM == "JTAG")           ? {1'b0, 4'b0, 3'b001, 1'b0}:
                               (STIM_FROM == "SPI_FLASH")      ? {1'b0, 4'b0, 3'b111, 1'b0}:
                               (STIM_FROM == "HYPER_FLASH")    ? {1'b0, 4'b0, 3'b101, 1'b0}: '0;
               test_mode_if.set_confreg(jtag_conf_reg, jtag_conf_rego,
                   s_tck, s_tms, s_trstn, s_tdi, s_tdo);

               $display("[TB] %t - jtag_conf_reg set to %x", $realtime, jtag_conf_reg);

               $display("[TB] %t - Releasing hard reset", $realtime);
               s_rst_n = 1'b1;

               //test if the PULP tap che write to the L2
               pulp_tap.init(s_tck, s_tms, s_trstn, s_tdi);

               $display("[TB] %t - Init PULP TAP", $realtime);

               pulp_tap.write32(begin_l2_instr, 1, 32'hABBAABBA,
                   s_tck, s_tms, s_trstn, s_tdi, s_tdo);

               $display("[TB] %t - Write32 PULP TAP", $realtime);

               #50us;
               pulp_tap.read32(begin_l2_instr, 1, jtag_data,
                   s_tck, s_tms, s_trstn, s_tdi, s_tdo);

               if(jtag_data[0] != 32'hABBAABBA)
                   $display("[JTAG] R/W test of L2 failed: %h != %h", jtag_data[0], 32'hABBAABBA);
               else
                   $display("[JTAG] R/W test of L2 succeeded");

               // From here on starts the actual jtag booting

               // Setup debug module and hart, halt hart and set dpc (return point
               // for boot).
               // Halting the fc hart transfers control of the program execution to
               // the debug module. This might take a bit until the debug request
               // signal is propagated so meanwhile the core is executing stuff
               // from the bootrom. For jtag booting (what we are doing right now),
               // bootsel is low so the code that is being executed in said bootrom
               // is only a busy wait or wfi until the debug unit grabs control.
               debug_mode_if.init_dmi_access(s_tck, s_tms, s_trstn, s_tdi);

               debug_mode_if.set_dmactive(1'b1, s_tck, s_tms, s_trstn, s_tdi, s_tdo);

               debug_mode_if.set_hartsel(FC_CORE_ID, s_tck, s_tms, s_trstn, s_tdi, s_tdo);

               $display("[TB] %t - Halting the Core", $realtime);
               debug_mode_if.halt_harts(s_tck, s_tms, s_trstn, s_tdi, s_tdo);

               $display("[TB] %t - Writing the boot address into dpc", $realtime);
               debug_mode_if.write_reg_abstract_cmd(riscv::CSR_DPC, begin_l2_instr,
                   s_tck, s_tms, s_trstn, s_tdi, s_tdo);

               // long debug module + jtag tests
               if(ENABLE_DM_TESTS == 1) begin
                  debug_mode_if.run_dm_tests(FC_CORE_ID, begin_l2_instr,
                                           error, num_err, s_tck, s_tms, s_trstn, s_tdi, s_tdo);
                  // we don't have any program to load so we finish the testing
                  if (num_err == 0) begin
                     exit_status = `EXIT_SUCCESS;
                  end else begin
                     exit_status = `EXIT_FAIL;
                     $error("Debug Module: %d tests failed", num_err);
                  end
                  $stop;
               end

               $display("[TB] %t - Loading L2", $realtime);
               if (USE_PULP_BUS_ACCESS) begin
                  // use pulp tap to load binary
                  pulp_tap_pkg::load_L2(num_stim, stimuli, s_tck, s_tms, s_trstn, s_tdi, s_tdo);

               end else begin
                  // use debug module to load binary
                  debug_mode_if.load_L2(num_stim, stimuli, s_tck, s_tms, s_trstn, s_tdi, s_tdo);

               end

               // configure for debug module dmi access again
               debug_mode_if.init_dmi_access(s_tck, s_tms, s_trstn, s_tdi);

               // we have set dpc and loaded the binary, we can go now
               $display("[TB] %t - Resuming the CORE", $realtime);
               debug_mode_if.resume_harts(s_tck, s_tms, s_trstn, s_tdi, s_tdo);
            end

            if (ENABLE_DPI == 1) begin
               jtag_mux = JTAG_DPI;
            end


            #500us;

            // Select UART driver/monitor
            if ($value$plusargs("uart_drv_mon=%s", uart_drv_mon_sel)) begin
               if (uart_drv_mon_sel == "VIP") begin
                  uart_tb_rx_en = 1'b0;
                  uart_vip_rx_en = 1'b1;
               end
            end

            // make sure that we can drive the SSPI lines when not in use
            s_padmode_spi_master = SPI_QUAD_RX;

            // enable sb access for subsequent readMem calls
            debug_mode_if.set_sbreadonaddr(1'b1, s_tck, s_tms, s_trstn, s_tdi, s_tdo);

            // wait for end of computation signal
            $display("[TB] %t - Waiting for end of computation", $realtime);

            jtag_data[0] = 0;
            while(jtag_data[0][31] == 0) begin
               // use the error-checking readMem function to avoid getting stuck
               debug_mode_if.readMemNoErrors(32'h1A1040A0, jtag_data[0], s_tck, s_tms, s_trstn, s_tdi, s_tdo);
               #50us;
            end

            if (jtag_data[0][30:0] == 0)
               exit_status = `EXIT_SUCCESS;
            else
               exit_status = `EXIT_FAIL;
            $display("[TB] %t - Received status core: 0x%h", $realtime, jtag_data[0][30:0]);

            $stop;

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

// Local Variables:
// verilog-indent-level: 3
// End:

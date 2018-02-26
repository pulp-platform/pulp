/* 
 * spi_master_padframe.sv
 * Antonio Pullini <pullinia@iis.ee.ethz.ch>
 * Igor Loi <igor.loi@unibo.it>
 *
 * Copyright (C) 2013-2018 ETH Zurich, University of Bologna.
 *
 * Copyright and related rights are licensed under the Solderpad Hardware
 * License, Version 0.51 (the "License"); you may not use this file except in
 * compliance with the License.  You may obtain a copy of the License at
 * http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
 * or agreed to in writing, software, hardware and materials distributed under
 * this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 * CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 *
 */

`define SPI_STD     2'b00
`define SPI_QUAD_TX 2'b01
`define SPI_QUAD_RX 2'b10

module generic_pad
  (
    input  logic in_i,
    output logic out_o,
    inout  logic pad,
    input  logic en_i
  );

  assign out_o = pad;
  assign pad = en_i ? in_i : 1'bZ;

endmodule

module spi_master_padframe
  (
    //PAD TO CORE

    // PAD MODES FROM CORE
    input  logic [1:0] padmode_spi_master,

    // TO SPI MASTER
    input  logic spi_master_csn,
    input  logic spi_master_sck,
    output logic spi_master_sdi0,
    output logic spi_master_sdi1,
    output logic spi_master_sdi2,
    output logic spi_master_sdi3,
    input  logic spi_master_sdo0,
    input  logic spi_master_sdo1,
    input  logic spi_master_sdo2,
    input  logic spi_master_sdo3,

    inout  logic MSPI_SIO0_PAD,
    inout  logic MSPI_SIO1_PAD,
    inout  logic MSPI_SIO2_PAD,
    inout  logic MSPI_SIO3_PAD,
    inout  logic MSPI_CSN_PAD,
    inout  logic MSPI_SCK_PAD
  );


  logic master_dio0_en;
  logic master_dio1_en;
  logic master_dio2_en;
  logic master_dio3_en;
  logic master_output;
  logic master_cs_in;
  logic master_sck_in;
  logic master_dio0_in;
  logic master_dio1_in;
  logic master_dio2_in;
  logic master_dio3_in;
  logic master_cs_out;
  logic master_sck_out;
  logic master_dio0_out;
  logic master_dio1_out;
  logic master_dio2_out;
  logic master_dio3_out;

  logic always_input;
  logic always_output;


  // DIGITAL PAD CELLS


  /////////////////////////////////////////////////////////////////////////////////////////////////
  ////                                                                                         ////
  ////  SPI MASTER                                                                             ////
  ////                                                                                         ////
  /////////////////////////////////////////////////////////////////////////////////////////////////
  //MASTER SDIO0
  generic_pad I_spi_master_sdio0_IO
  (
    .out_o ( master_dio0_in  ),
    .in_i  ( master_dio0_out ),
    .en_i  ( master_dio0_en  ),
    .pad   ( MSPI_SIO0_PAD   )
  );

  //MASTER SDIO1
  generic_pad I_spi_master_sdio1_IO
  (
    .out_o ( master_dio1_in  ),
    .in_i  ( master_dio1_out ),
    .en_i  ( master_dio1_en  ),
    .pad   ( MSPI_SIO1_PAD   )
  );

  //MASTER SDIO2
  generic_pad I_spi_master_sdio2_IO
  (
    .out_o ( master_dio2_in  ),
    .in_i  ( master_dio2_out ),
    .en_i  ( master_dio2_en  ),
    .pad   ( MSPI_SIO2_PAD   )
  );

  //MASTER SDIO3
  generic_pad I_spi_master_sdio3_IO
  (
    .out_o ( master_dio3_in  ),
    .in_i  ( master_dio3_out ),
    .en_i  ( master_dio3_en  ),
    .pad   ( MSPI_SIO3_PAD   )
  );

  //MASTER CSN
  generic_pad I_spi_master_csn_IO
  (
    .out_o ( master_cs_in  ),
    .in_i  ( master_cs_out ),
    .en_i  ( master_output ),
    .pad   ( MSPI_CSN_PAD  )
  );

  //MASTER SCK
  generic_pad I_spi_master_sck_IO
  (
    .out_o ( master_sck_in  ),
    .in_i  ( master_sck_out ),
    .en_i  ( master_output  ),
    .pad   ( MSPI_SCK_PAD   )
    );
  /////////////////////////////////////////////////////////////////////////////////////////////////


  assign always_input  = 1'b0;
  assign always_output = ~always_input;

  always_comb
  begin
    master_cs_out   = spi_master_csn;
    master_sck_out  = spi_master_sck;

      case (padmode_spi_master)
        `SPI_STD:
        begin
          master_dio0_en  = always_output;  // dio0 -> SDO output
          master_dio1_en  = always_input;   // dio1 -> SDI input
          master_dio2_en  = always_input;  // not used
          master_dio3_en  = always_input;  // not used
          master_output   = always_output; // csn and sck are output
          spi_master_sdi0 = master_dio1_in;
          spi_master_sdi1 = 1'b0;
          spi_master_sdi2 = 1'b0;
          spi_master_sdi3 = 1'b0;
          master_dio0_out = spi_master_sdo0;
          master_dio1_out = 1'b0;
          master_dio2_out = 1'b0;
          master_dio3_out = 1'b0;
        end
        `SPI_QUAD_TX:
        begin
          master_dio0_en = always_output;  // dio0 -> SDO0 output
          master_dio1_en = always_output;  // dio1 -> SDO1 output
          master_dio2_en = always_output;  // dio2 -> SDO2 output
          master_dio3_en = always_output;  // dio3 -> SDO3 output
          master_output   = always_output; // csn and sck are output
          spi_master_sdi0 = 1'b0;
          spi_master_sdi1 = 1'b0;
          spi_master_sdi2 = 1'b0;
          spi_master_sdi3 = 1'b0;
          master_dio0_out = spi_master_sdo0;
          master_dio1_out = spi_master_sdo1;
          master_dio2_out = spi_master_sdo2;
          master_dio3_out = spi_master_sdo3;
        end
        `SPI_QUAD_RX:
        begin
          master_dio0_en = always_input;  // dio0 -> SDI0 input
          master_dio1_en = always_input;  // dio1 -> SDI1 input
          master_dio2_en = always_input;  // dio2 -> SDI2 input
          master_dio3_en = always_input;  // dio3 -> SDI3 input
          master_output   = always_output; // csn and sck are output
          spi_master_sdi0 = master_dio0_in;
          spi_master_sdi1 = master_dio1_in;
          spi_master_sdi2 = master_dio2_in;
          spi_master_sdi3 = master_dio3_in;
          master_dio0_out = 1'b0;
          master_dio1_out = 1'b0;
          master_dio2_out = 1'b0;
          master_dio3_out = 1'b0;
        end
        default:
        begin
          master_dio0_en = always_input;  // dio0 -> SDI0 input
          master_dio1_en = always_input;  // dio1 -> SDI1 input
          master_dio2_en = always_input;  // dio2 -> SDI2 input
          master_dio3_en = always_input;  // dio3 -> SDI3 input
          master_output   = always_output; // csn and sck are output
          spi_master_sdi0 = 1'b0;
          spi_master_sdi1 = 1'b0;
          spi_master_sdi2 = 1'b0;
          spi_master_sdi3 = 1'b0;
          master_dio0_out = 1'b0;
          master_dio1_out = 1'b0;
          master_dio2_out = 1'b0;
          master_dio3_out = 1'b0;
        end
      endcase
  end
endmodule

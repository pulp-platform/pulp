/*
 * periph_bus_defines.sv
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

// SOC PERIPHERALS APB BUS PARAMETRES
`define NB_MASTER  11

// MASTER PORT TO FLL
`define FLL_START_ADDR           32'h1A10_0000
`define FLL_END_ADDR             32'h1A10_0FFF

// MASTER PORT TO GPIO
`define GPIO_START_ADDR          32'h1A10_1000
`define GPIO_END_ADDR            32'h1A10_1FFF

// MASTER PORT TO SPI MASTER
`define UDMA_START_ADDR          32'h1A10_2000
`define UDMA_END_ADDR            32'h1A10_3FFF

// MASTER PORT TO SOC CONTROL
`define SOC_CTRL_START_ADDR      32'h1A10_4000
`define SOC_CTRL_END_ADDR        32'h1A10_4FFF

// MASTER PORT TO ADV TIMER
`define ADV_TIMER_START_ADDR     32'h1A10_5000
`define ADV_TIMER_END_ADDR       32'h1A10_5FFF

// MASTER PORT TO SOC EVENT GEN
`define SOC_EVENT_GEN_START_ADDR 32'h1A10_6000
`define SOC_EVENT_GEN_END_ADDR   32'h1A10_6FFF

`define EU_START_ADDR            32'h1A10_9000
`define EU_END_ADDR              32'h1A10_AFFF

`define TIMER_START_ADDR         32'h1A10_B000
`define TIMER_END_ADDR           32'h1A10_BFFF

`define HWPE_START_ADDR          32'h1A10_C000
`define HWPE_END_ADDR            32'h1A10_CFFF

`define STDOUT_START_ADDR        32'h1A10_F000
`define STDOUT_END_ADDR          32'h1A10_FFFF

`define DEBUG_START_ADDR         32'h1A11_0000
`define DEBUG_END_ADDR           32'h1A11_FFFF

`define DUMMY_START_ADDR         32'h1A12_0000
`define DUMMY_END_ADDR           32'h1A12_0008


`define APB_ASSIGN_SLAVE(lhs, rhs)     \
    assign lhs.paddr    = rhs.paddr;   \
    assign lhs.pwdata   = rhs.pwdata;  \
    assign lhs.pwrite   = rhs.pwrite;  \
    assign lhs.psel     = rhs.psel;    \
    assign lhs.penable  = rhs.penable; \
    assign rhs.prdata   = lhs.prdata;  \
    assign rhs.pready   = lhs.pready;  \
    assign rhs.pslverr  = lhs.pslverr

`define APB_ASSIGN_MASTER(lhs, rhs) `APB_ASSIGN_SLAVE(rhs, lhs)

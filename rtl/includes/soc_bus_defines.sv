/*
 * soc_bus_defines.sv
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

// SOC BUS PARAMETRES
`include "pulp_soc_defines.sv"

`define NB_SLAVE  4
`define NB_MASTER 4
`define NB_REGION 4

// MASTER PORT TO CLUSTER(3MB)
`define CLUSTER_DATA_START_ADDR  32'h1000_0000
`define CLUSTER_DATA_END_ADDR    32'h103F_FFFF

// MASTER PORT TO L2
`define SOC_L2_START_ADDR        32'h1C00_0000
`define SOC_L2_END_ADDR          32'h1FFF_FFFF

// MASTER PORT TO L2
`define SOC_L2_PRI_CH0_START_ADDR     32'h1C00_0000
`define SOC_L2_PRI_CH0_END_ADDR       32'h1C00_8000

`define SOC_L2_PRI_CH1_START_ADDR     32'h1C00_8000
`define SOC_L2_PRI_CH1_END_ADDR       32'h1C01_0000

`define SOC_L2_PRI_CH0_SCM_START_ADDR 32'h1C00_6000
`define SOC_L2_PRI_CH0_SCM_END_ADDR   32'h1C00_8000

`define ALIAS_SOC_L2_PRI_CH0_SCM_START_ADDR 32'h0000_6000
`define ALIAS_SOC_L2_PRI_CH0_SCM_END_ADDR   32'h0000_8000


// MASTER PORT TO SOC APB

// REGION TO SOC APB PERIPHERALS
`define SOC_APB_START_ADDR       32'h1A10_0000
`define SOC_APB_END_ADDR         32'h1A10_FFFF

// REGION TO FABRIC CONTROLLER PERIPHERAL INTERCONNECT PERIPHERALS
`define FC_PERIPH_APB_START_ADDR 32'h1B20_0000
`define FC_PERIPH_APB_END_ADDR   32'h1B20_3FFF

// REGION TO FABRIC CONTROLLER APB PERIPHERALS
`define FC_APB_START_ADDR        32'h1B30_0000
`define FC_APB_END_ADDR          32'h1B3F_FFFF

`define AXI_ASSIGN_SLAVE(lhs, rhs)        \
    assign lhs.aw_id     = rhs.aw_id;     \
    assign lhs.aw_addr   = rhs.aw_addr;   \
    assign lhs.aw_len    = rhs.aw_len;    \
    assign lhs.aw_size   = rhs.aw_size;   \
    assign lhs.aw_burst  = rhs.aw_burst;  \
    assign lhs.aw_lock   = rhs.aw_lock;   \
    assign lhs.aw_cache  = rhs.aw_cache;  \
    assign lhs.aw_prot   = rhs.aw_prot;   \
    assign lhs.aw_region = rhs.aw_region; \
    assign lhs.aw_user   = rhs.aw_user;   \
    assign lhs.aw_qos    = rhs.aw_qos;    \
    assign lhs.aw_valid  = rhs.aw_valid;  \
    assign rhs.aw_ready  = lhs.aw_ready;  \
                                          \
    assign lhs.ar_id     = rhs.ar_id;     \
    assign lhs.ar_addr   = rhs.ar_addr;   \
    assign lhs.ar_len    = rhs.ar_len;    \
    assign lhs.ar_size   = rhs.ar_size;   \
    assign lhs.ar_burst  = rhs.ar_burst;  \
    assign lhs.ar_lock   = rhs.ar_lock;   \
    assign lhs.ar_cache  = rhs.ar_cache;  \
    assign lhs.ar_prot   = rhs.ar_prot;   \
    assign lhs.ar_region = rhs.ar_region; \
    assign lhs.ar_user   = rhs.ar_user;   \
    assign lhs.ar_qos    = rhs.ar_qos;    \
    assign lhs.ar_valid  = rhs.ar_valid;  \
    assign rhs.ar_ready  = lhs.ar_ready;  \
                                          \
    assign lhs.w_data    = rhs.w_data;    \
    assign lhs.w_strb    = rhs.w_strb;    \
    assign lhs.w_last    = rhs.w_last;    \
    assign lhs.w_user    = rhs.w_user;    \
    assign lhs.w_valid   = rhs.w_valid;   \
    assign rhs.w_ready   = lhs.w_ready;   \
                                          \
    assign rhs.b_id      = lhs.b_id;      \
    assign rhs.b_resp    = lhs.b_resp;    \
    assign rhs.b_user    = lhs.b_user;    \
    assign rhs.b_valid   = lhs.b_valid;   \
    assign lhs.b_ready   = rhs.b_ready;   \
                                          \
    assign rhs.r_id      = lhs.r_id;      \
    assign rhs.r_data    = lhs.r_data;    \
    assign rhs.r_resp    = lhs.r_resp;    \
    assign rhs.r_last    = lhs.r_last;    \
    assign rhs.r_user    = lhs.r_user;    \
    assign rhs.r_valid   = lhs.r_valid;   \
    assign lhs.r_ready   = rhs.r_ready;

`define AXI_ASSIGN_MASTER(lhs, rhs) `AXI_ASSIGN_SLAVE(rhs, lhs)

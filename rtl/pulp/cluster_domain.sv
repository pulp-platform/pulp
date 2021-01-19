  
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
 * cluster_domain.sv
 * Davide Rossi <davide.rossi@unibo.it>
 * Antonio Pullini <pullinia@iis.ee.ethz.ch>
 * Igor Loi <igor.loi@unibo.it>
 * Francesco Conti <fconti@iis.ee.ethz.ch>
 * Pasquale Davide Schiavone <pschiavo@iss.ee.ethz.ch>
 */

`include "pulp_soc_defines.sv"
`include "cluster_bus_defines.sv"


module cluster_domain
#(
    //CLUSTER PARAMETERS
    parameter NB_CORES              = `NB_CORES,
    parameter NB_HWPE_PORTS         = 9,
    parameter NB_DMAS               = 4,

    parameter TCDM_SIZE             = 64*1024,                 // in Byte, POWER of 2
    parameter NB_TCDM_BANKS         = 16,                      // POWER of 2
    parameter TCDM_BANK_SIZE        = TCDM_SIZE/NB_TCDM_BANKS, // eg 4096
    parameter TCDM_NUM_ROWS         = TCDM_BANK_SIZE/4,        // --> 4 byte, mem are 32 bit wide
    parameter L2_SIZE               = 512*1024,

    //ICACHE PARAMETERS
    parameter SET_ASSOCIATIVE       = 4,
`ifdef MP_ICACHE
    parameter NB_CACHE_BANKS        = 2,
`endif

`ifdef SP_ICACHE
    parameter NB_CACHE_BANKS        = 8,
`endif

`ifdef PRIVATE_ICACHE
    parameter NB_CACHE_BANKS        = 8,
`endif

    parameter CACHE_LINE            = 1,
    parameter CACHE_SIZE            = 4096,
    parameter ICACHE_DATA_WIDTH     = 128,
    parameter L0_BUFFER_FEATURE     = "DISABLED",
    parameter MULTICAST_FEATURE     = "DISABLED",
    parameter SHARED_ICACHE         = "ENABLED",
    parameter DIRECT_MAPPED_FEATURE = "DISABLED",
    
    //CORE PARAMETERS
    parameter ROM_BOOT_ADDR         = 32'h1A000000,
    parameter BOOT_ADDR             = 32'h1C000000,
    parameter INSTR_RDATA_WIDTH     = 128,

    parameter CLUST_FPU               = `CLUST_FPU,
    parameter CLUST_FP_DIVSQRT        = `CLUST_FP_DIVSQRT,
    parameter CLUST_SHARED_FP         = `CLUST_SHARED_FP,
    parameter CLUST_SHARED_FP_DIVSQRT = `CLUST_SHARED_FP_DIVSQRT,

    // AXI PARAMETERS
    parameter AXI_ADDR_WIDTH        = 32,
    parameter AXI_DATA_S2C_WIDTH    = 32,
    parameter AXI_DATA_C2S_WIDTH    = 64,
    parameter AXI_USER_WIDTH        = 6,
    parameter AXI_ID_IN_WIDTH       = 4,
    parameter AXI_ID_OUT_WIDTH      = 6,
    parameter AXI_STRB_S2C_WIDTH    = AXI_DATA_S2C_WIDTH/8,
    parameter AXI_STRB_C2S_WIDTH    = AXI_DATA_C2S_WIDTH/8,
    parameter DC_SLICE_BUFFER_WIDTH = 8,

    //CLUSTER MAIN PARAMETERS
    parameter DATA_WIDTH            = 32,
    parameter ADDR_WIDTH            = 32,
    parameter BE_WIDTH              = DATA_WIDTH/8,

    //TCDM PARAMETERS
    parameter TEST_SET_BIT          = 20, // bits used to indicate a test and set opration during a load in TCDM
    parameter ADDR_MEM_WIDTH        = $clog2(TCDM_BANK_SIZE/4), // Memory datawidth is 4 byte (32bit) --> bits used to address a single bank in SRAM TCDM

    //MCHAN PARAMETERS
    parameter TCDM_ADD_WIDTH        = ADDR_MEM_WIDTH + $clog2(NB_TCDM_BANKS) + 2, // Total bit used to address the whole TCDM ( 2^17 = 128K, TCDM SIZE = 64Kof SRAM + 8K of SCM, ADDR WIDTH = 17 bits )

    //PERIPH PARAMETERS
    parameter LOG_CLUSTER           = 5,  // NOT USED RIGTH NOW
    parameter PE_ROUTING_LSB        = 10, //LSB used as routing BIT in periph interco
    //parameter PE_ROUTING_MSB        = 13, //MSB used as routing BIT in periph interco

    parameter EVNT_WIDTH            = 8, //size of the event bus
`ifdef PULP_HSA
    parameter CLUSTER_ALIAS_BASE    = 12'h1B0
`else
    parameter CLUSTER_ALIAS_BASE    = 12'h000
`endif
)
(
  
   input logic                              clk_i,
   input logic                              rst_ni,
   input logic                              ref_clk_i,
     
   input  logic [DC_SLICE_BUFFER_WIDTH-1:0] ext_events_writetoken_i,
   output logic [DC_SLICE_BUFFER_WIDTH-1:0] ext_events_readpointer_o,
   input  logic            [EVNT_WIDTH-1:0] ext_events_dataasync_i,

   input  logic                             dma_pe_evt_ack_i,
   output logic                             dma_pe_evt_valid_o,

   input  logic                             dma_pe_irq_ack_i,
   output logic                             dma_pe_irq_valid_o,

   input logic  [NB_CORES-1:0] dbg_irq_valid_i,
   
   input  logic                             pf_evt_ack_i,
   output logic                             pf_evt_valid_o,
   
   output logic                             busy_o,

   // AXI4 SLAVE
   //***************************************
   // WRITE ADDRESS CHANNEL
   input  logic [7:0]                       data_slave_aw_writetoken_i,
   input  logic [AXI_ADDR_WIDTH-1:0]        data_slave_aw_addr_i,
   input  logic [2:0]                       data_slave_aw_prot_i,
   input  logic [3:0]                       data_slave_aw_region_i,
   input  logic [7:0]                       data_slave_aw_len_i,
   input  logic [2:0]                       data_slave_aw_size_i,
   input  logic [1:0]                       data_slave_aw_burst_i,
   input  logic                             data_slave_aw_lock_i,
   input  logic [3:0]                       data_slave_aw_cache_i,
   input  logic [3:0]                       data_slave_aw_qos_i,
   input  logic [AXI_ID_IN_WIDTH-1:0]       data_slave_aw_id_i,
   input  logic [AXI_USER_WIDTH-1:0]        data_slave_aw_user_i,
   output logic [7:0]                       data_slave_aw_readpointer_o,
   
   // READ ADDRESS CHANNEL
   input  logic [7:0]                       data_slave_ar_writetoken_i,
   input  logic [AXI_ADDR_WIDTH-1:0]        data_slave_ar_addr_i,
   input  logic [2:0]                       data_slave_ar_prot_i,
   input  logic [3:0]                       data_slave_ar_region_i,
   input  logic [7:0]                       data_slave_ar_len_i,
   input  logic [2:0]                       data_slave_ar_size_i,
   input  logic [1:0]                       data_slave_ar_burst_i,
   input  logic                             data_slave_ar_lock_i,
   input  logic [3:0]                       data_slave_ar_cache_i,
   input  logic [3:0]                       data_slave_ar_qos_i,
   input  logic [AXI_ID_IN_WIDTH-1:0]       data_slave_ar_id_i,
   input  logic [AXI_USER_WIDTH-1:0]        data_slave_ar_user_i,
   output logic [7:0]                       data_slave_ar_readpointer_o,
   
   // WRITE DATA CHANNEL
   input  logic [7:0]                       data_slave_w_writetoken_i,
   input  logic [AXI_DATA_S2C_WIDTH-1:0]    data_slave_w_data_i,
   input  logic [AXI_STRB_S2C_WIDTH-1:0]    data_slave_w_strb_i,
   input  logic [AXI_USER_WIDTH-1:0]        data_slave_w_user_i,
   input  logic                             data_slave_w_last_i,
   output logic [7:0]                       data_slave_w_readpointer_o,
          
   // READ DATA CHANNEL
   output logic [7:0]                       data_slave_r_writetoken_o,
   output logic [AXI_DATA_S2C_WIDTH-1:0]    data_slave_r_data_o,
   output logic [1:0]                       data_slave_r_resp_o,
   output logic                             data_slave_r_last_o,
   output logic [AXI_ID_IN_WIDTH-1:0]       data_slave_r_id_o,
   output logic [AXI_USER_WIDTH-1:0]        data_slave_r_user_o,
   input  logic [7:0]                       data_slave_r_readpointer_i,
   
   // WRITE RESPONSE CHANNEL
   output logic [7:0]                       data_slave_b_writetoken_o,
   output logic [1:0]                       data_slave_b_resp_o,
   output logic [AXI_ID_IN_WIDTH-1:0]       data_slave_b_id_o,
   output logic [AXI_USER_WIDTH-1:0]        data_slave_b_user_o,
   input  logic [7:0]                       data_slave_b_readpointer_i,
   
   // AXI4 MASTER
   //***************************************
   // WRITE ADDRESS CHANNEL
   output logic [7:0]                       data_master_aw_writetoken_o,
   output logic [AXI_ADDR_WIDTH-1:0]        data_master_aw_addr_o,
   output logic [2:0]                       data_master_aw_prot_o,
   output logic [3:0]                       data_master_aw_region_o,
   output logic [7:0]                       data_master_aw_len_o,
   output logic [2:0]                       data_master_aw_size_o,
   output logic [1:0]                       data_master_aw_burst_o,
   output logic                             data_master_aw_lock_o,
   output logic [3:0]                       data_master_aw_cache_o,
   output logic [3:0]                       data_master_aw_qos_o,
   output logic [AXI_ID_OUT_WIDTH-1:0]      data_master_aw_id_o,
   output logic [AXI_USER_WIDTH-1:0]        data_master_aw_user_o,
   input  logic [7:0]                       data_master_aw_readpointer_i,
   
   // READ ADDRESS CHANNEL
   output logic [7:0]                       data_master_ar_writetoken_o,
   output logic [AXI_ADDR_WIDTH-1:0]        data_master_ar_addr_o,
   output logic [2:0]                       data_master_ar_prot_o,
   output logic [3:0]                       data_master_ar_region_o,
   output logic [7:0]                       data_master_ar_len_o,
   output logic [2:0]                       data_master_ar_size_o,
   output logic [1:0]                       data_master_ar_burst_o,
   output logic                             data_master_ar_lock_o,
   output logic [3:0]                       data_master_ar_cache_o,
   output logic [3:0]                       data_master_ar_qos_o,
   output logic [AXI_ID_OUT_WIDTH-1:0]      data_master_ar_id_o,
   output logic [AXI_USER_WIDTH-1:0]        data_master_ar_user_o,
   input  logic [7:0]                       data_master_ar_readpointer_i,
   
   // WRITE DATA CHANNEL
   output logic [7:0]                       data_master_w_writetoken_o,
   output logic [AXI_DATA_C2S_WIDTH-1:0]    data_master_w_data_o,
   output logic [AXI_STRB_C2S_WIDTH-1:0]    data_master_w_strb_o,
   output logic [AXI_USER_WIDTH-1:0]        data_master_w_user_o,
   output logic                             data_master_w_last_o,
   input  logic [7:0]                       data_master_w_readpointer_i,
   
   // READ DATA CHANNEL
   input  logic [7:0]                       data_master_r_writetoken_i,
   input  logic [AXI_DATA_C2S_WIDTH-1:0]    data_master_r_data_i,
   input  logic [1:0]                       data_master_r_resp_i,
   input  logic                             data_master_r_last_i,
   input  logic [AXI_ID_OUT_WIDTH-1:0]      data_master_r_id_i,
   input  logic [AXI_USER_WIDTH-1:0]        data_master_r_user_i,
   output logic [7:0]                       data_master_r_readpointer_o,
   
   // WRITE RESPONSE CHANNEL
   input  logic [7:0]                       data_master_b_writetoken_i,
   input  logic [1:0]                       data_master_b_resp_i,
   input  logic [AXI_ID_OUT_WIDTH-1:0]      data_master_b_id_i,
   input  logic [AXI_USER_WIDTH-1:0]        data_master_b_user_i,
   output logic [7:0]                       data_master_b_readpointer_o
   
`ifdef PULP_FPGA_EMUL
`ifdef TRACE_EXECUTION
   ,
   output logic [NB_CORES*64-1:0]           instr_trace_cycles_o,
   output logic [NB_CORES*32-1:0]           instr_trace_instr_o,
   output logic [NB_CORES*32-1:0]           instr_trace_pc_o,
   output logic [NB_CORES-1:0]              instr_trace_valid_o
`endif
`endif
   
);
   
    pulp_cluster
`ifndef USE_CLUSTER_NETLIST
    #(
        .NB_CORES                     ( NB_CORES                     ),
        .NB_HWPE_PORTS                ( NB_HWPE_PORTS                ),
        .NB_DMAS                      ( NB_DMAS                      ),
        .TCDM_SIZE                    ( TCDM_SIZE                    ),
        .NB_TCDM_BANKS                ( NB_TCDM_BANKS                ),
        .TCDM_BANK_SIZE               ( TCDM_BANK_SIZE               ),
        .TCDM_NUM_ROWS                ( TCDM_NUM_ROWS                ),
        .SET_ASSOCIATIVE              ( SET_ASSOCIATIVE              ),
        .NB_CACHE_BANKS               ( NB_CACHE_BANKS               ),
        .CACHE_LINE                   ( CACHE_LINE                   ),
        .CACHE_SIZE                   ( CACHE_SIZE                   ),
        .ICACHE_DATA_WIDTH            ( ICACHE_DATA_WIDTH            ),
        .L0_BUFFER_FEATURE            ( L0_BUFFER_FEATURE            ),
        .MULTICAST_FEATURE            ( MULTICAST_FEATURE            ),
        .SHARED_ICACHE                ( SHARED_ICACHE                ),
        .DIRECT_MAPPED_FEATURE        ( DIRECT_MAPPED_FEATURE        ),
        .L2_SIZE                      ( L2_SIZE                      ),
        .ROM_BOOT_ADDR                ( ROM_BOOT_ADDR                ),
        .BOOT_ADDR                    ( BOOT_ADDR                    ),
        .INSTR_RDATA_WIDTH            ( INSTR_RDATA_WIDTH            ),
        .CLUST_FPU                    ( CLUST_FPU                    ),
        .CLUST_FP_DIVSQRT             ( CLUST_FP_DIVSQRT             ),
        .CLUST_SHARED_FP              ( CLUST_SHARED_FP              ),
        .CLUST_SHARED_FP_DIVSQRT      ( CLUST_SHARED_FP_DIVSQRT      ),
        .AXI_ADDR_WIDTH               ( AXI_ADDR_WIDTH               ),
        .AXI_DATA_C2S_WIDTH           ( AXI_DATA_C2S_WIDTH           ),
        .AXI_DATA_S2C_WIDTH           ( AXI_DATA_S2C_WIDTH           ),
        .AXI_USER_WIDTH               ( AXI_USER_WIDTH               ),
        .AXI_ID_IN_WIDTH              ( AXI_ID_IN_WIDTH              ),
        .AXI_ID_OUT_WIDTH             ( AXI_ID_OUT_WIDTH             ),
        .AXI_STRB_C2S_WIDTH           ( AXI_STRB_C2S_WIDTH           ),
        .AXI_STRB_S2C_WIDTH           ( AXI_STRB_S2C_WIDTH           ),
        .DC_SLICE_BUFFER_WIDTH        ( DC_SLICE_BUFFER_WIDTH        ),
        .DATA_WIDTH                   ( DATA_WIDTH                   ),
        .ADDR_WIDTH                   ( ADDR_WIDTH                   ),
        .BE_WIDTH                     ( BE_WIDTH                     ),
        .TEST_SET_BIT                 ( TEST_SET_BIT                 ),
        .ADDR_MEM_WIDTH               ( ADDR_MEM_WIDTH               ),
        .TCDM_ADD_WIDTH               ( TCDM_ADD_WIDTH               ),
        .LOG_CLUSTER                  ( LOG_CLUSTER                  ),
        .PE_ROUTING_LSB               ( PE_ROUTING_LSB               ),
        .EVNT_WIDTH                   ( EVNT_WIDTH                   ),
        .CLUSTER_ALIAS_BASE           ( CLUSTER_ALIAS_BASE           )
    )
`endif    
    cluster_i
    (
        .clk_i                        ( clk_i                        ),
        .rst_ni                       ( rst_ni                       ),
        .ref_clk_i                    ( ref_clk_i                    ),

        .pmu_mem_pwdn_i               ( 1'b0                         ),
        
        .base_addr_i                  ( '0                           ),
        
        .ext_events_writetoken_i      ( ext_events_writetoken_i      ),
        .ext_events_readpointer_o     ( ext_events_readpointer_o     ),
        .ext_events_dataasync_i       ( ext_events_dataasync_i       ),
        .dma_pe_evt_ack_i             ( dma_pe_evt_ack_i             ),
        .dma_pe_evt_valid_o           ( dma_pe_evt_valid_o           ),
        .dma_pe_irq_ack_i             ( dma_pe_irq_ack_i             ),
        .dma_pe_irq_valid_o           ( dma_pe_irq_valid_o           ),
        .dbg_irq_valid_i              (  dbg_irq_valid_i             ),
        .pf_evt_ack_i                 ( pf_evt_ack_i                 ),
        .pf_evt_valid_o               ( pf_evt_valid_o               ),
        .en_sa_boot_i                 ( 1'b0                         ),
        .test_mode_i                  ( 1'b0                         ),
        .fetch_en_i                   ( 1'b0                         ),
        .eoc_o                        (                              ),
        .busy_o                       ( busy_o                       ),
        .cluster_id_i                 ( 6'b000000                    ),
        .data_master_aw_addr_o        ( data_master_aw_addr_o        ),
        .data_master_aw_prot_o        ( data_master_aw_prot_o        ),
        .data_master_aw_region_o      ( data_master_aw_region_o      ),
        .data_master_aw_len_o         ( data_master_aw_len_o         ),
        .data_master_aw_size_o        ( data_master_aw_size_o        ),
        .data_master_aw_burst_o       ( data_master_aw_burst_o       ),
        .data_master_aw_lock_o        ( data_master_aw_lock_o        ),
        .data_master_aw_cache_o       ( data_master_aw_cache_o       ),
        .data_master_aw_qos_o         ( data_master_aw_qos_o         ),
        .data_master_aw_id_o          ( data_master_aw_id_o          ),
        .data_master_aw_user_o        ( data_master_aw_user_o        ),
        .data_master_aw_writetoken_o  ( data_master_aw_writetoken_o  ),
        .data_master_aw_readpointer_i ( data_master_aw_readpointer_i ),
        .data_master_ar_addr_o        ( data_master_ar_addr_o        ),
        .data_master_ar_prot_o        ( data_master_ar_prot_o        ),
        .data_master_ar_region_o      ( data_master_ar_region_o      ),
        .data_master_ar_len_o         ( data_master_ar_len_o         ),
        .data_master_ar_size_o        ( data_master_ar_size_o        ),
        .data_master_ar_burst_o       ( data_master_ar_burst_o       ),
        .data_master_ar_lock_o        ( data_master_ar_lock_o        ),
        .data_master_ar_cache_o       ( data_master_ar_cache_o       ),
        .data_master_ar_qos_o         ( data_master_ar_qos_o         ),
        .data_master_ar_id_o          ( data_master_ar_id_o          ),
        .data_master_ar_user_o        ( data_master_ar_user_o        ),
        .data_master_ar_writetoken_o  ( data_master_ar_writetoken_o  ),
        .data_master_ar_readpointer_i ( data_master_ar_readpointer_i ),
        .data_master_w_data_o         ( data_master_w_data_o         ),
        .data_master_w_strb_o         ( data_master_w_strb_o         ),
        .data_master_w_user_o         ( data_master_w_user_o         ),
        .data_master_w_last_o         ( data_master_w_last_o         ),
        .data_master_w_writetoken_o   ( data_master_w_writetoken_o   ),
        .data_master_w_readpointer_i  ( data_master_w_readpointer_i  ),

        .data_master_r_data_i         ( data_master_r_data_i         ),
        .data_master_r_resp_i         ( data_master_r_resp_i         ),
        .data_master_r_last_i         ( data_master_r_last_i         ),
        .data_master_r_id_i           ( data_master_r_id_i           ),
        .data_master_r_user_i         ( data_master_r_user_i         ),
        .data_master_r_writetoken_i   ( data_master_r_writetoken_i   ),
        .data_master_r_readpointer_o  ( data_master_r_readpointer_o  ),

        .data_master_b_resp_i         ( data_master_b_resp_i         ),
        .data_master_b_id_i           ( data_master_b_id_i           ),
        .data_master_b_user_i         ( data_master_b_user_i         ),
        .data_master_b_writetoken_i   ( data_master_b_writetoken_i   ),
        .data_master_b_readpointer_o  ( data_master_b_readpointer_o  ),
 
        .data_slave_aw_addr_i         ( data_slave_aw_addr_i         ),
        .data_slave_aw_prot_i         ( data_slave_aw_prot_i         ),
        .data_slave_aw_region_i       ( data_slave_aw_region_i       ),
        .data_slave_aw_len_i          ( data_slave_aw_len_i          ),
        .data_slave_aw_size_i         ( data_slave_aw_size_i         ),
        .data_slave_aw_burst_i        ( data_slave_aw_burst_i        ),
        .data_slave_aw_lock_i         ( data_slave_aw_lock_i         ),
        .data_slave_aw_cache_i        ( data_slave_aw_cache_i        ),
        .data_slave_aw_qos_i          ( data_slave_aw_qos_i          ),
        .data_slave_aw_id_i           ( data_slave_aw_id_i           ),
        .data_slave_aw_user_i         ( data_slave_aw_user_i         ),
        .data_slave_aw_writetoken_i   ( data_slave_aw_writetoken_i   ),
        .data_slave_aw_readpointer_o  ( data_slave_aw_readpointer_o  ),
  
        .data_slave_ar_addr_i         ( data_slave_ar_addr_i         ),
        .data_slave_ar_prot_i         ( data_slave_ar_prot_i         ),
        .data_slave_ar_region_i       ( data_slave_ar_region_i       ),
        .data_slave_ar_len_i          ( data_slave_ar_len_i          ),
        .data_slave_ar_size_i         ( data_slave_ar_size_i         ),
        .data_slave_ar_burst_i        ( data_slave_ar_burst_i        ),
        .data_slave_ar_lock_i         ( data_slave_ar_lock_i         ),
        .data_slave_ar_cache_i        ( data_slave_ar_cache_i        ),
        .data_slave_ar_qos_i          ( data_slave_ar_qos_i          ),
        .data_slave_ar_id_i           ( data_slave_ar_id_i           ),
        .data_slave_ar_user_i         ( data_slave_ar_user_i         ),
        .data_slave_ar_writetoken_i   ( data_slave_ar_writetoken_i   ),
        .data_slave_ar_readpointer_o  ( data_slave_ar_readpointer_o  ),
  
        .data_slave_w_data_i          ( data_slave_w_data_i          ),
        .data_slave_w_strb_i          ( data_slave_w_strb_i          ),
        .data_slave_w_user_i          ( data_slave_w_user_i          ),
        .data_slave_w_last_i          ( data_slave_w_last_i          ),
        .data_slave_w_writetoken_i    ( data_slave_w_writetoken_i    ),
        .data_slave_w_readpointer_o   ( data_slave_w_readpointer_o   ),
  
        .data_slave_r_data_o          ( data_slave_r_data_o          ),
        .data_slave_r_resp_o          ( data_slave_r_resp_o          ),
        .data_slave_r_last_o          ( data_slave_r_last_o          ),
        .data_slave_r_id_o            ( data_slave_r_id_o            ),
        .data_slave_r_user_o          ( data_slave_r_user_o          ),
        .data_slave_r_writetoken_o    ( data_slave_r_writetoken_o    ),
        .data_slave_r_readpointer_i   ( data_slave_r_readpointer_i   ),
  
        .data_slave_b_resp_o          ( data_slave_b_resp_o          ),
        .data_slave_b_id_o            ( data_slave_b_id_o            ),
        .data_slave_b_user_o          ( data_slave_b_user_o          ),
        .data_slave_b_writetoken_o    ( data_slave_b_writetoken_o    ),
        .data_slave_b_readpointer_i   ( data_slave_b_readpointer_i   )
    );

endmodule

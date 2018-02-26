/* 
 * dev_dpi.sv
 * Germain Haugou <haugoug@iis.ee.ethz.ch>
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

`define N_I2S_PORTS 3
`define N_CPI_PORTS 11
`define N_JTAG_PORTS 5

interface JTAG (
   logic ports[`N_JTAG_PORTS-1:0]
);
endinterface


interface I2S
(
   logic ports[`N_I2S_PORTS-1:0]
);

endinterface


interface CPI
(
   logic ports[`N_CPI_PORTS-1:0]
);
endinterface


interface GPIO
(
   logic port
);
endinterface

module dev_dpi
#(
   parameter N_I2S_CHANNELS = 0,
   parameter N_CPI_CHANNELS = 0,
   parameter N_GPIO_CHANNELS = 0,
   parameter N_JTAG_CHANNELS = 0
)
(
    input logic en_i,
    I2S  i2s [0:N_I2S_CHANNELS-1],
    CPI  cpi [0:N_CPI_CHANNELS-1],
    GPIO gpio[0:N_GPIO_CHANNELS-1],
    JTAG jtag[0:N_JTAG_CHANNELS-1],
    output logic reset
   );

   import "DPI-C"   context function void dpi_conf(chandle handler, string archi_name, int nb_i2s_ports, int nb_cpi_ports, int nb_gpio_ports);

   import "DPI-C"   context function void i2s_conf(chandle handler, int itf_type, int binding);
   import "DPI-C"   context function void i2s_edge(longint timestamp, int itf_type, int port, input logic value, input logic ws, input logic data);

   import "DPI-C"   context function void bridge_conf(chandle handler);

   import "DPI-C"   context function void gpio_conf(chandle handler, int itf_type, int binding);
   import "DPI-C"   context function void gpio_edge(longint timestamp, int itf_type, input logic value);

   import "DPI-C"   context function void cpi_conf(chandle handler, int itf_type, int binding);
   import "DPI-C"   context task     cpi_clock(int timestamp);

   export "DPI-C"   task             dpi_wait;
   export "DPI-C"   task             dpi_wait_ps;
   export "DPI-C"   function         dpi_time;
   export "DPI-C"   function         dpi_start_task;
   export "DPI-C"   function         dpi_print;
   export "DPI-C"   function         dpi_error;
   export "DPI-C"   function         dpi_set_port_sensitivity;
   export "DPI-C"   function         dpi_set_port_direction;
   export "DPI-C"   function         dpi_set_port_value;
   export "DPI-C"   function         dpi_jtag_set;
   export "DPI-C"   function         dpi_jtag_get_tdo;
   export "DPI-C"   function         dpi_reset_set;
   export "DPI-C"   function         dpi_stop;

   logic i2s_outputValues[0:N_I2S_CHANNELS-1][0:`N_I2S_PORTS-1];
   logic i2s_isout[0:N_I2S_CHANNELS-1][0:`N_I2S_PORTS-1];
   logic i2s_nedge[0:N_I2S_CHANNELS-1][0:`N_I2S_PORTS-1];
   logic i2s_pedge[0:N_I2S_CHANNELS-1][0:`N_I2S_PORTS-1];

   logic cpi_outputValues[0:N_CPI_CHANNELS-1][0:`N_CPI_PORTS-1];
   logic cpi_isout[0:N_CPI_CHANNELS-1][0:`N_CPI_PORTS-1];
   logic cpi_nedge[0:N_CPI_CHANNELS-1][0:`N_CPI_PORTS-1];
   logic cpi_pedge[0:N_CPI_CHANNELS-1][0:`N_CPI_PORTS-1];

   logic gpio_outputValues[0:N_GPIO_CHANNELS-1];
   logic gpio_isout       [0:N_GPIO_CHANNELS-1];
   logic gpio_nedge       [0:N_GPIO_CHANNELS-1];
   logic gpio_pedge       [0:N_GPIO_CHANNELS-1];

   logic jtag_tck;
   logic jtag_tdi;
   logic jtag_tms;
   logic jtag_trstn;
   logic jtag_tdo;

   logic dpi_reset;

   event ev;
   logic task_exec;
   
   chandle handler;

   int exit_status = -1;

   function dpi_jtag_get_tdo();
      //$display("[TB] %t :: TDO %x", $realtime, jtag_tdo);

      return jtag_tdo;
   endfunction

   task dpi_wait(input longint t);
      #(t * 1ns);
   endtask

   task dpi_wait_ps(input longint t);
      #(t * 1ps);
   endtask

   function int dpi_time();
      return $realtime*1000;
   endfunction : dpi_time

   function void dpi_start_task();
      task_exec += 1;
      ->ev;
   endfunction : dpi_start_task

   function void dpi_print(chandle handler, input string msg);
      //$display("[TB] %t :: %s", $realtime, msg);
   endfunction : dpi_print

   function void dpi_error(chandle handler, input string msg);
      $error("%s", msg);
      $finish;
   endfunction : dpi_error

   function void dpi_set_port_sensitivity(chandle handler, int itf_type, int bindingId, int id, int _nedge, int _pedge);
      if (itf_type == 0)
         begin
            i2s_nedge[bindingId][id] = _nedge;
            i2s_pedge[bindingId][id] = _pedge;
         end
      else if (itf_type == 1)
         begin
            cpi_nedge[bindingId][id] = _nedge;
            cpi_pedge[bindingId][id] = _pedge;
         end
      else if (itf_type == 2)
         begin
            gpio_nedge[bindingId] = _nedge;
            gpio_pedge[bindingId] = _pedge;
         end
   endfunction : dpi_set_port_sensitivity

   function void dpi_set_port_direction(chandle handler, int itf_type, int bindingId, int id, int dirin, int dirout);
      if (itf_type == 0)
         begin
            if (dirout) i2s_isout[bindingId][id] = 1;
            else i2s_isout[bindingId][id] = 0;
         end
      else if (itf_type == 1)
         begin
            if (dirout) cpi_isout[bindingId][id] = 1;
            else cpi_isout[bindingId][id] = 0;
         end
      else if (itf_type == 2)
         begin
            if (dirout) gpio_isout[bindingId] = 1;
            else gpio_isout[bindingId] = 0;
         end
   endfunction : dpi_set_port_direction

   function void dpi_set_port_value(chandle handler, int itf_type, int bindingId, int portId, logic value );
      if (itf_type == 0)
         begin
            i2s_outputValues[bindingId][portId] = value;
         end
      else if (itf_type == 1)
         begin
            cpi_outputValues[bindingId][portId] = value;
         end
      else if (itf_type == 2)
         begin
            gpio_outputValues[bindingId] = value;
         end
   endfunction : dpi_set_port_value

   function void dpi_jtag_set(logic tck, logic tdi, logic tms, logic trstn);
      //$display("[JTAG] %t :: %d %d %d", $realtime, tdi, tms, trstn);
      jtag_tck = tck;
      jtag_tdi = tdi;
      jtag_tms = tms;
      jtag_trstn = trstn;
   endfunction

   function void dpi_reset_set(logic rst);
      dpi_reset = rst;
   endfunction

   function void dpi_stop(logic status);
      exit_status = status;
      $stop;
   endfunction

   initial
   begin

      dpi_reset = 0;

      task_exec = 0;

      // Global configuration, mainly used for checking user specified configuration
      dpi_conf(handler, "wolfe", N_I2S_CHANNELS, N_CPI_CHANNELS, N_GPIO_CHANNELS);

      for (int i=0; i<N_I2S_CHANNELS; i++)
      begin
         for (int j=0; j<`N_I2S_PORTS; j++)
         begin
            i2s_isout[i][j] = 0;
         end
         i2s_conf(handler, 0, i);
      end

      for (int i=0; i<N_CPI_CHANNELS; i++)
      begin
         for (int j=0; j<`N_CPI_PORTS; j++)
         begin
            cpi_isout[i][j] = 0;
         end
         cpi_conf(handler, 1, i);
      end

      for (int i=0; i<N_GPIO_CHANNELS; i++)
      begin
         gpio_isout[i] = 0;
         gpio_conf(handler, 2, i);
      end

      @(posedge en_i)
      bridge_conf(handler);

   end

   always
   begin
      
      if (task_exec == 0)
         @(ev);

      while (task_exec > 0)
      begin
         task_exec -= 1;
         fork
            cpi_clock($realtime*1000);
         join_none
      end
   end

   generate
   begin

      for (genvar i=0; i<N_I2S_CHANNELS; i++)
      begin
         for (genvar j=0; j<`N_I2S_PORTS; j++)
         begin
            always @(negedge i2s[i].ports[j])
            begin
               if (i2s_nedge[i][j] == 1) i2s_edge($realtime*1000, i, j, i2s[i].ports[0], i2s[i].ports[1], i2s[i].ports[2]);
            end
            always @(posedge i2s[i].ports[j])
            begin
               if (i2s_pedge[i][j] == 1) i2s_edge($realtime*1000, i, j, i2s[i].ports[0], i2s[i].ports[1], i2s[i].ports[2]);
            end
            assign i2s[i].ports[j] = (i2s_isout[i][j] == 1) ? i2s_outputValues[i][j] : 'bz;
         end
      end

      for (genvar i=0; i<N_GPIO_CHANNELS; i++)
      begin
         always @(negedge gpio[i].port)
         begin
            if (gpio_nedge[i] == 1) gpio_edge($realtime*1000, i, gpio[i].port);
         end
         always @(posedge gpio[i].port)
         begin
            if (gpio_pedge[i] == 1) gpio_edge($realtime*1000, i, gpio[i].port);
         end
         assign gpio[i].port = (gpio_isout[i] == 1) ? gpio_outputValues[i] : 'bz;
      end

      for (genvar i=0; i<N_CPI_CHANNELS; i++)
      begin
         for (genvar j=0; j<`N_CPI_PORTS; j++)
         begin
            assign cpi[i].ports[j] = (cpi_isout[i][j] == 1) ? cpi_outputValues[i][j] : 'bz;
         end
      end

      assign jtag[0].ports[0] = jtag_tck;
      assign jtag[0].ports[1] = jtag_tdi;
      assign jtag[0].ports[2] = jtag_tms;
      assign jtag[0].ports[3] = jtag_trstn;
      assign jtag_tdo = jtag[0].ports[4];

      assign reset = dpi_reset;

   end
   endgenerate

endmodule

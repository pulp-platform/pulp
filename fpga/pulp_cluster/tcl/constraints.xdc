## Boundary
set_input_delay 0.5    [all_inputs]
# set_load        0.1    [all_outputs] # only post-synthesis

create_clock -period 10 -name clk_i [get_ports clk_i]

set_false_path -from [all_inputs]
set_false_path -to   [all_outputs]

set_false_path -through [get_pins rstgen_i/s_rst_n_reg/Q]
set_false_path -from [get_clocks tck_i] -to [get_clocks clk_i]

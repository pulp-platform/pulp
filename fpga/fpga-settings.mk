export FC_CLK_PERIOD_NS=100
export CL_CLK_PERIOD_NS=100
export PER_CLK_PERIOD_NS=100
export SLOW_CLK_PERIOD_NS=30517
#Must also change the localparam 'L2_BANK_SIZE' in pulp_soc.sv accordingly
export INTERLEAVED_BANK_SIZE=28672
#Must also change the localparam 'L2_BANK_SIZE_PRI' in pulp_soc.sv accordingly
export PRIVATE_BANK_SIZE=8192
$(info Setting environment variables for $(BOARD) board)
# parameters that will be used for IPs generation
$(info FC_CLK_PERIOD_NS=$(FC_CLK_PERIOD_NS))
$(info CL_CLK_PERIOD_NS=$(CL_CLK_PERIOD_NS))
$(info PER_CLK_PERIOD_NS=$(PER_CLK_PERIOD_NS))

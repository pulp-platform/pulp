export BOARD=zcu102
export XILINX_PART=xczu9eg-ffvb1156-2-e
export XILINX_BOARD=xilinx.com:zcu102:part0:3.3
export XILINX_FPGA_DEV=xczu9_0
export FC_CLK_PERIOD_NS=100
export CL_CLK_PERIOD_NS=100
export PER_CLK_PERIOD_NS=100
export SLOW_CLK_PERIOD_NS=30517
$(info Setting environment variables for $(BOARD) board)
# parameters that will be used for IPs generation
$(info FC_CLK_PERIOD_NS=$(FC_CLK_PERIOD_NS))
$(info CL_CLK_PERIOD_NS=$(CL_CLK_PERIOD_NS))
$(info PER_CLK_PERIOD_NS=$(PER_CLK_PERIOD_NS))

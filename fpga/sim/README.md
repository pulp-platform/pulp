To do the compilation of RTL, Make sure the fpga IPs are already compiled, must source sourceme.sh


1. Create xilinx_libs for modelsim simulation, please wait a few minutes.  
   bash compile_simlibs.sh

2. Use following command to compile your FPGA RTL platform  
   make clean lib build opt  
   clean  - clean all output including work  
   lib    - create all modelsim_libs IP lib  
   build  - build all rtl including testbench  
   build_fpga_pulp_cluster      - build all rtl including testbench, replace pulp_cluster with netlist 
   build_fpga_pulpemu_function  - build all rtl including testbench, replace pulpemu with functional netlist 
   build_fpga_pulpemu_timing    - build all rtl including testbench, replace pulpemu with timing netlist 
   opt    - modelsim optimization  

3. ! For any sdk, do as usual, only change your VSIM_PATH to /Your/pulp/project/fpga/sim 
   export VSIM_PATH=/Your/pulp/project/fpga/sim 

4. (Only for gap_sdk) go to your SDK, source sourceme.sh, then go to your test, add < load=-l JTAG_DEV > in Makefile  
   make clean all run/gui platform=fpga_rtl 


RTL simualtion  
Must do instruction 3. before continuing:  

a. FPGA RTL simulation 
make clean lib build opt 

b. FPGA RTL pulp_cluster netlist simulation 
make clean lib build_fpga_pulp_cluster opt 

c. FPGA RTL pulpemu functional netlist simulation 
make clean lib build_fpga_pulpemu_function opt 

d. FPGA RTL pulpemu timing netlist simulation (need sdf) 
make clean lib build_fpga_pulpemu_timing opt 


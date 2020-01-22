1. Load environment variable according the fpga board, now support only zc706 and zcu102  
source sourceme.sh

2. To make all fpga necessary IPs, for both FPGA RTL simulation and FPGA emulation  
make ips

3. For FPGA RTL simulation, go to ./sim

4. For FPGA emulation  

   - build cluster netlist  
     make synth-ulpcluster

   - build all SoC  
     make synth-pulpemu

   - If it is successful, you can find BOOT.bin in ./pulpemu/board
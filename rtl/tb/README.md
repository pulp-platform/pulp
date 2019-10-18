# PULPissimo Testbench

This is the testbench that is used to simulate PULPissimo. It provides
three execution modes:

- Load and execute programs through JTAG (boot from JTAG)
- Execute preloaded programs on flash
- Load no program and wait for OpenOCD to connect

## JTAG TAPs and Flash
When running tests or developing programs, we normally use the first mode to do
that. No special configuration is required to do that, just follow the PULP-SDK
documentation. By setting `LOAD_L2` to "STANDALONE" or "JTAG" you can boot from
flash or via JTAG respectively. Internally this sets the `s_bootsel` signal
accordingly.

Currently we have two JTAG TAPs chained together: the first one is
[standard](https://github.com/riscv/riscv-debug-spec/blob/0.13-test-release/riscv-debug-spec.pdf)
compliant JTAG DTM (Debug Transport Module), while the second one is our custom
PULP TAP. Both can be used to access the L2 memory to load data into it. The
`USE_PULP_BUS_ACCESS` parameter can be used to choose which one to use. By
default we use the PULP TAP because it is much faster in simulation.

## OpenOCD
If you wish to interact with the testbench through GDB and OpenOCD you can do
this by setting the `ENABLE_OPENOCD=1` parameter. Careful OpenOCD and GDB need a
long time to establish a connection with the testbench (due to simulation being
slow) so timeouts have to be set accordingly.

We recommend to do this with the following steps
1. Compile and run your program using the pulp-sdk with the following command:
   `make conf CONFIG_OPT="vsim/tcl_args=-sv_lib vsim/tcl_args="${VSIM_PATH}"/../rtl/tb/remote_bitbang/librbs vsim/tcl_args=-gENABLE_OPENOCD=1" clean all run`
2. If done correctly you get the following message:
   ```
   This emulator compiled with JTAG Remote Bitbang client.
   Listening on port 42087
   Attempting to accept client socket
   ```

   Set now the environment variable `JTAG_VPI_PORT` to the port the server is
   listening to by calling `export JTAG_VPI_PORT=[portname]`. The server will
   accept commands from openocd redirect those through DPI to the JTAG module in
   the testbench.
3. Call `openocd -f pulpissimo_debug.cfg`. After a while you will be prompted
   with an address you can connect gdb to, normally `localhost:3333`

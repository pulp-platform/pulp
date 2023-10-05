# PULP FPGA Port

PULP has been implemented on FPGA for various Xilinx FPGA boards. Please check the corresponding
subdirectory for the various supported boards:

* Xilinx ZCU102
* Xilinx VCU118 (untested)

## Bitstream Generation and Flashing

### Vivado Versions
Tested with Vivado 2022.1. If the board part is not found (e.g., `xilinx.com:zcu102:part0:3.3`), you may need to change the version (for older versions of Vivado, for example from `3.3` to `3.2`).

The scripts assume that the `vivado` command points to the vivado binary. On IIS systems using SEPP packages, run commands as 
```
vitis-2022.1 make <target>
```
using the appropriate `vitis-<VERSION>` or `vivado-<VERSION>` command.

### Generating the Bitstream
In order to generate the PULP bitstream for a supported target FPGA board, first fetch the required
dependencies and generate the corresponding scripts with bender in the project root directory. To
do this, run the followin commands in the project root directory:

```bash
make checkout
make scripts
```

These commands will generate the sourcing scripts for the FPGA files in the
`fpga/pulp/tcl/generated` folder. 

To run the synthesis command, switch to this directory (fpga) and run the Makefile target for your
corresponding device, e.g. the ZCU102:

```bash
make zcu102
```

This will synthesize PULP for the corresponding target and generate the bitstream. Please not that
the top level file used for generation is within the corresponding target's folder. Furthermore,
the required sub-IPs are generated and synthesized for the target platform. 

The generated bitstream will be copied directly to the root of the corresponding target's folder.

Note: if using a different command to launch vivado, you can set the `$(VIVADO)` environment variable.

### Bitstream Flashing

To flash the bitstream, use the `make flash_zcu102` (tested) and `make flash_vcu118` (untested** commands after running the corresponding bitstream generation targets. Of course, make sure the board is correctly:
* powered on, and
* connected via USB

## Compiling and Running Programs on FPGA

The following instructions are based on commit `ddebe93` of the PULP SDK. This is an old version. The changes to make it work with FPGA were:
* The `pos_init_fll` function now returns the `ARCHI_FPGA_FREQUENCY` instead of trying to configure the FLL, and all FLLs are registered as running with that frequency.
* `ARCHI_FPGA_FREQUENCY` was changed to 10 MHz, matching the configuration of the FPGA port.

To run your program on the FPGA platform, you need the following ingredients:
* A USB-JTAG adapter connected correctly to the FPGA board
* A running OpenOCD instance connected to the emulated PULP system via that adapter
* GNU `gdb` to manage the execution

### Compilation

Using a suitable version of the PULP SDK, run the following command in your software project (`io=uart` is not strictly necessary in the referenced commit but it doesn't hurt to have it there):
```
make build platform=fpga io=uart -j4
```
### Connecting to the FPGA Board
To connect an ARM 20-pin JTAG header to the PULP system's JTAG interface on ZCU102/VCU118, connect the following pins:


| Signal | ARM Pin | ZCU102/VCU118 PMOD0 Pin |
|--------|---------|-------------------------|
| TMS    | 7       | 0                       |
| TDI    | 5       | 1                       |
| TDO    | 13      | 2                       |
| TCK    | 9       | 3                       |
| TRSTN  | 3       | 4 (not used)            |


Now you can connect to the board with OpenOCD (assuming you are using ZCU102 and have an Olimex JTAG interface):
```
openocd -f pulp-zcu102/openocd-zcu102-olimex-arm-usb-ocd-h.cfg
```

### Running Your Program

To flash your program with JTAG, you can now use `gdb` - in the `fpga` folder, an example GDB script that flashes the program is provided as `do.gdb`. You can copy it to your C project for convenience. Then, from your C project directory and with the SDK correctly configured, run:
```
alias rvgdb=${PULP_RISCV_GCC_TOOLCHAIN}/bin/riscv32-unknown-elf-gdb
rvgdb -x do.gdb ${PATH_TO_BINARY}
```
where `$PATH_TO_BINARY` is the location of your compiled RISCV binary, usually something like `BUILD/PULP/GCC_RISCV/test/test` if your application name is `test`.

For UART input/output, PULP's UART RX/TX pins are mapped to connect to the onboard USB-UART bridge, so connecting a USB cable to the appropriate USB port is sufficient. On ZCU102, it is connected to UART port 2 of the CP2108 USB-UART chip. To find out which `/dev/ttyUSB*` this corresponds to, run 
```
dmesg | grep tty
```
to get an output like:
```
[...]
[15626159.946345] usb 1-2: cp210x converter now attached to ttyUSB0
[15626159.947768] usb 1-2: cp210x converter now attached to ttyUSB2
[15626159.949614] usb 1-2: cp210x converter now attached to ttyUSB3
[15626159.951680] usb 1-2: cp210x converter now attached to ttyUSB4
[...]
```

In this case, UART0 is `ttyUSB0`, UART1 is `ttyUSB2` and UART2 is `ttyUSB3`. Note that the numbering needn't be linear, depending on what other devices you have attached to your computer.

To connect to PULP with UART using `screen`, in the above case we would thus run:

`screen /dev/ttyUSB3 115200,cs8`

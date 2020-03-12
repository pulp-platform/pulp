# FPGA

PULP has been implemented on FPGA for various Xilinx FPGA boards


### CurrentlySupported Boards

* Xilinx ZCU102
* Xilinx VCU118

### Bitstream Generation
In order to generate the PULP bitstream for a supported target FPGA board
first generate the necessary synthesis include scripts by starting the
`update-ips` script in the pulpissimo root directory:

```Shell
./update-ips
```
This will parse the ips_list.yml using the PULP IPApproX IP management tool to
generate tcl scripts for all the IPs used in the PULP project. These files
are later on sourced by Vivado to generate the bitstream for PULP.

Now switch to the fpga subdirectory and source the right board:

```Shell
cd fpga
source sourceme.sh
```
Choose the platfom.

### Bitstream Flashing
Start Vivado then:

```
Open Hardware Manager
Open Target
Program device
```
Be sure you are loading ".bit" file to the fpga board.

### Compiling Applications for the FPGA Target
To run or debug applications for the FPGA you need to use a recent version of
the PULP-SDK (tag 2019.11.05 is fully stable for FPGA). Configure the SDK for the FPGA
platform by running the following commands within the SDK's root directory:

```Shell
source configs/pulp.sh
source configs/fpgas/pulp/genesys2.sh
```

In order for the SDK to be able to configure clock dividers (e.g. the ones for
the UART module) to the right values it needs to know which frequencies
PULP is running at. You can find the default frequencies in the above
mentioned board specific README files.

In our application we need to override two weakly defined variables in our
source code to configure the SDK to use these frequencies:
```C
#include <stdio.h>
#include <rt/rt_api.h>

int __rt_fpga_fc_frequency = <Core Frequency> // e.g. 20000000 for 20MHz;
int __rt_fpga_periph_frequency = <SoC Frequency> // e.g. 10000000 for 10MHz;

int main()
{
...
}
```

By default, the baudrate of the UART is set to `115200`.

Add the following global variable declaration to your application in case
you want to change it:

```C
unsigned int __rt_iodev_uart_baudrate = your baudrate;
```

Compile your application with

```Shell
make clean all io=uart
```
This command builds the ELF binary with UART as the default io peripheral.
The binary will be stored at `build/pulp/[app_name]/[app_name]`.

### GDB and OpenOCD
In order to execute our application on the FPGA we need to load the binary into
PULPissimo's L2 memory. To do so we can use OpenOCD in conjunction with GDB to
communicate with the internal RISC-V debug module.

PULP uses JTAG as a communication channel between OpenOCD and the Core.
Have a look at the board specific README file on how to connect your PC with
PULP's JTAG port.

Due to a long outstanding issue in the RISC-V OpenOCD project (issue #359) the
riscv/riscv-openocd does not work with PULPissimo. However there is a small
workaround that we incorporated in a patched version of openocd. If you have
access to the artifactory server, the patched openocd binary is installed by
default with the `make deps` command in the SDK. If you don't have access to the
precompiled binaries you can automatically download and compile the patched
OPENOCD from source. You will need to install the following dependencies on your
machine before you can compile OpenOCD:

- `autoconf` >= 2.64
- `automake` >= 1.14
- `texinfo`
- `make`
- `libtool`
- `pkg-config` >= 0.23 (or compatible)
- `libusb-1.0`
- `libftdi`
- `libusb-0.1` or `libusb-compat-0.1` for some older drivers

After installing those dependecies with you OS' package manager you can
download, apply the patch and compile OpenOCD with:

```Shell
source sourceme.sh && ./pulp-tools/bin/plpbuild checkout build --p openocd --stdout
```

The SDK will automatically set the environment variable `OPENOCD` to the
installation path of this patched version.

Launch openocd with one of the provided or your own configuration file for the
target board as an argument.

E.g.:

```Shell
$OPENOCD/bin/openocd -f pulp/fpga/openocd-zcu102-olimex-arm-usb-ocd-h.cfg
```
In a seperate terminal launch gdb from your `pulp_riscv_gcc` installation passing
the ELF file as an argument with:

`$PULP_RISCV_GCC_TOOLCHAIN_CI/bin/riscv32-unknown-elf-gdb  PATH_TO_YOUR_ELF_FILE`

In gdb, run:

```
(gdb) target remote localhost:3333
```

to connect to the OpenOCD server.

In a third terminal launch a serial port client (e.g. `screen` or `minicom`) on
Linux to riderect the UART output from PULPissimo with e.g.:

```Shell
screen /dev/ttyUSB0 115200
```

the ttyUSB0 target may change.

Now you are ready to debug!

In gdb, load the program into L2:

```
(gdb) load
```
and run the programm:

```
(gdb) continue
```
Of course you can also benefit from the debug capabilities that GDB provides.

E.g. see the disasembled binary:
```
(gdb) disas
```
List the current C function, set a break point at line 25, continue and have fun!

```
(gdb) list
21
22  int main()
23  {
24    while (1) {
25      printf("Hello World!\n\r");
26     for (volatile int i=0; i<1000000; i++);
27    }
28    return 0;
29  }

(gdb) b 25
Breakpoint 1 at 0x1c0083d2: file test.c, line 25.
(gdb) c
Continuing.

Breakpoint 1, main () at test.c:25
25      printf("Hello World!\n\r");


(gdb) disas
Dump of assembler code for function main:
   0x1c0083d4 <+22>:    li  a1,1
   0x1c0083d6 <+24>:    blt s0,a5,0x1c0083e8 <main+42>
=> 0x1c0083da <+28>:    lw  a5,12(sp)
   0x1c0083dc <+30>:    slli    a1,a1,0x1
   0x1c0083de <+32>:    addi    a5,a5,1
   0x1c0083e0 <+34>:    sw  a5,12(sp)

(gdb) monitor reg a5
a5 (/32): 0x000075B7

```
Not all gdb commands work as expected on the riscv-dbg target.
To get a list of available gdb commands execute:
```
monitor help
```

Most notably the command `info registers` does not work. Use `monitor reg`
instead which has the same effect.


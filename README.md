# PULPissimo

![](doc/pulpissimo_archi.png)

PULPissimo is the microcontroller architecture of the more recent PULP chips,
part of the ongoing "PULP platform" collaboration between ETH Zurich and the
University of Bologna - started in 2013.

PULPissimo, like PULPino, is a single-core platform. However, it represents a
significant step ahead in terms of completeness and complexity with respect to
PULPino - in fact, the PULPissimo system is used as the main System-on-Chip
controller for all recent multi-core PULP chips, taking care of autonomous I/O,
advanced data pre-processing, external interrupts, etc.
The PULPissimo architecture includes:

- Either the RI5CY core or the Ibex one as main core
- Autonomous Input/Output subsystem (uDMA)
- New memory subsystem
- Support for Hardware Processing Engines (HWPEs)
- New simple interrupt controller
- New peripherals
- New SDK

RISCY is an in-order, single-issue core with 4 pipeline stages and it has
an IPC close to 1, full support for the base integer instruction set (RV32I),
compressed instructions (RV32C) and multiplication instruction set extension
(RV32M). It can be configured to have single-precision floating-point
instruction set extension (RV32F). It implements several ISA extensions
such as: hardware loops, post-incrementing load and store instructions,
bit-manipulation instructions, MAC operations, support fixed-point operations,
packed-SIMD instructions and the dot product. It has been designed to increase
the energy efficiency of in ultra-low-power signal processing applications.
RISCY implementes a subset of the 1.10 privileged specification.
It includes an optional PMP and the possibility to have a subset of the USER MODE.
RISCY implement the RISC-V Debug spec 0.13.
Further information about the core can be found at
http://ieeexplore.ieee.org/abstract/document/7864441/
and in the documentation of the IP.

Ibex, formely Zero-riscy, is an in-order, single-issue core with 2 pipeline
stages. It has full support for the base integer instruction set (RV32I
version 2.1) and compressed instructions (RV32C version 2.0).
It can be configured to support the multiplication instruction set extension
(RV32M version 2.0) and the reduced number of registers extension (RV32E
version 1.9). Ibex implementes the Machine ISA version 1.11 and has RISC-V
External Debug Support version 0.13.2. Ibex has been originally designed at
ETH to target ultra-low-power and ultra-low-area constraints. Ibex is now
maintained and further developed by the non-for-profit community interest
company lowRISC. Further information about the core can be found at
http://ieeexplore.ieee.org/document/8106976/
and in the documentation of the IP at
https://ibex-core.readthedocs.io/en/latest/index.html

PULPissimo includes a new efficient I/O subsystem via a uDMA (micro-DMA) which
communicates with the peripherals autonomously. The core just needs to program
the uDMA and wait for it to handle the transfer.
Further information about the core can be found at
http://ieeexplore.ieee.org/document/8106971/
and in the documentation of the IP.

PULPissimo supports I/O on interfaces such as:

- SPI (as master)
- I2S
- Camera Interface (CPI)
- I2C
- UART
- JTAG

PULPissimo also supports integration of hardware accelerators (Hardware
Processing Engines) that share memory with the RI5CY core and are programmed on
the memory map. An example accelerator, performing multiply-accumulate on a
vector of fixed-point values, can be found in `ips/hwpe-mac-engine` (after
updating the IPs: see below in the Getting Started section).
The `ips/hwpe-stream` and `ips/hwpe-ctrl` folders contain the IPs necessary to
plug streaming accelerators into a PULPissimo or PULP system on the data and
control plane.
For further information on how to design and integrate such accelerators,
see `ips/hwpe-stream/doc` and https://arxiv.org/abs/1612.05974.

## Getting Started

### Prerequisites
To be able to use the PULPissimo platform, you need to have installed the software
development kit for PULP/PULPissimo.

First install the system dependencies indicated here:
https://github.com/pulp-platform/pulp-builder/blob/master/README.md

Then execute the following commands:
```
git clone https://github.com/pulp-platform/pulp-builder.git
cd pulp-builder
git checkout 7bd925324fcecae2aad9875f4da45b27d8356796
source configs/pulpissimo.sh
./scripts/clean
./scripts/update-runtime
./scripts/build-runtime
source sdk-setup.sh
source configs/rtl.sh
cd ..
```

### Building the RTL simulation platform
To build the RTL simulation platform, start by getting the latest version of the
IPs composing the PULP system:
```
./update-ips
```
This will download all the required IPs, solve dependencies and generate the
scripts by calling `./generate-scripts`.

After having access to the SDK, you can build the simulation platform by doing
the following:
```
source setup/vsim.sh
make clean build
```
This command builds a version of the simulation platform with no dependencies on
external models for peripherals. See below (Proprietary verification IPs) for
details on how to plug in some models of real SPI, I2C, I2S peripherals.

### Downloading and running tests
Finally, you can download and run the tests; for that you can checkout the
following repositories:

Runtime tests: https://github.com/pulp-platform/pulp-rt-examples

Now you can change directory to your favourite test e.g.: for an hello world
test, run
```
cd pulp-rt-examples/hello
make clean all run
```
The open-source simulation platform relies on JTAG to emulate preloading of the
PULP L2 memory. If you want to simulate a more realistic scenario (e.g.
accessing an external SPI Flash), look at the sections below.

In case you want to see the Modelsim GUI, just type
```
make run gui=1
```
before starting the simulation.

If you want to save a (compressed) VCD for further examination, type
```
make run vsim/script=export_run.tcl
```
before starting the simulation. You will find the VCD in
`build/<SRC_FILE_NAME>/pulpissimo/export.vcd.gz` where
`<SRC_FILE_NAME>` is the name of the C source of the test.

### Building and using the virtual platform

Once the RTL platform is installed, the following commands can be executed to
install and use the virtual platform:
```
git clone https://github.com/pulp-platform/pulp-builder.git
cd pulp-builder
git checkout 7bd925324fcecae2aad9875f4da45b27d8356796
source configs/pulpissimo.sh
./scripts/build-gvsoc
source sdk-setup.sh
source configs/gvsoc.sh
cd ..
```

Then tests can be compiled and run as for the RTL platform. When switching from
one platform to another, it may be needed to regenrate the test configuration
with this command:
```
make conf
```

More information is available in the documentation here: pulp-builder/install/doc/vp/index.html

## FPGA

PULPissimo has been implemented on FPGA for the various Xilinx FPGA boards.

### Supported Boards
At the moment the following boards are supported:
* Digilent Genesys2
* Xilinx ZCU104
* Digilent Nexys Video

In the release section you find precompiled bitstreams for all of the above
mentionied boards. If you want to use the latest development version PULPissimo
follow the section below to generate the bitstreams yourself.

### Bitstream Generation
In order to generate the PULPissimo bitstream for a supported target FPGA board
first generate the necessary synthesis include scripts by starting the
`update-ips` script in the pulpissimo root directory:

```Shell
./update-ips
```

This will parse the ips_list.yml using the PULP IPApproX IP management tool to
generate tcl scripts for all the IPs used in the PULPissimo project. These files
are later on sourced by Vivado to generate the bitstream for PULPissimo.

Now switch to the fpga subdirectory and start the apropriate make target to
generate the bitstream:

```Shell
cd fpga
make <board_target>
```
In order to show a list of all available board targets call:

```Shell
make help
```

This process might take a while. If everything goes well your fpga directory
should now contain two files:

- `pulpissimo_<board_target>.bit` the bitstream file for JTAG configuration of
  the FPGA.
- `pulpissimo_<board_target>.bin` the binary configuration file to flash to a
  non-volatile configuration memory.


If your invocation command to start Vivado isn't `vivado` you can use the Make
variable `VIVADO` to specify the right command (e.g. `make genesys2
VIVADO='vivado-2018.3 vivado'` for ETH CentOS machines.) Boot from ROM is not
available yet. The ROM will always return the `jal x0,0` to trap the core until
the debug module takes over control and loads the programm into L2 memory. Once
the bitstream `pulpissimo_genesys2.bit` is generated in the fpga folder, you can
open Vivado `vivado` (we tried the 2018.3 version) and load the bitstream into
the fpga or use the Configuration File (`pulpissimo_genesys2.bin`) to flash it
to the on-board Configuration Memory.

### Bitstream Flashing
Start Vivado then:

```
Open Hardware Manager
Open Target
Program device
```

Now your FPGA is ready to emulate PULPissimo!

### Board Specific Information
Have a look at the board specific README.md files in
`fpga/pulpissimo-<board_target>/README.md` for a description of peripheral
mappings and default clock frequencies.

### Compiling Applications for the FPGA Target
To run or debug applications for the FPGA you need to use a recent version of
the PULP-SDK (commit id 3256fe7 or newer.'). Configure the SDK for the FPGA
platform by running the following commands within the SDK's root directory:

```Shell
source configs/pulpissimo.sh
source configs/fpgas/pulpissimo/<board_target>.sh
```

If you updated the SDK don't forget to recompile the SDK and the dependencies.

In order for the SDK to be able to configure clock dividers (e.g. the ones for
the UART module) to the right values it needs to know which frequencies
PULPissimo is running at. You can find the default frequencies in the above
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
make clean all
```

This command builds the ELF binary with UART as the default io peripheral.
The binary will be stored at `build/pulpissimo/[app_name]/[app_name]`.

### Core selection
By default, PULPissimo is configured to use the RI5CY core with floating-point
support being enabled. To switch to Ibex (and disable floating-point support),
the following steps need to be performed.

1. Switch hardware configuration

   Open the file `fpga/pulpissimo-<board_target>/rtl/xilinx_pulpissimo.v` and
   change the `CORE_TYPE` parameter to the preferred value. Change the value
   of the `USE_FPU` parameter from `1` to `0`. Save the file and regenerate
   the FPGA bitstream.

2. Switch SDK configuration

   Instead of sourcing `configs/pulpissimo.sh` when configuring the SDK,
   source `configs/pulpissimo_ibex.sh`.

### GDB and OpenOCD
In order to execute our application on the FPGA we need to load the binary into
PULPissimo's L2 memory. To do so we can use OpenOCD in conjunction with GDB to
communicate with the internal RISC-V debug module.

PULPissimo uses JTAG as a communication channel between OpenOCD and the Core.
Have a look at the board specific README file on how to connect your PC with
PULPissimo's JTAG port.

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
$OPENOCD/bin/openocd -f pulpissimo/fpga/pulpissimo-genesys2/openocd-genesys2.cfg
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


## Proprietary verification IPs
The full simulation platform can take advantage of a few models of commercial
SPI, I2C, I2S peripherals to attach to the open-source PULP simulation platform.
In `rtl/vip/spi_flash`, `rtl/vip/i2c_eeprom`, `rtl/vip/i2s` you find the
instructions to install SPI, I2C and I2S models.

When the SPI flash model is installed, it will be possible to switch to a more
realistic boot simulation, where the internal ROM of PULP is used to perform an
initial boot and to start to autonomously fetch the program from the SPI flash.
To do this, the `LOAD_L2` parameter of the testbench has to be switched from
`JTAG` to `STANDALONE`.

## PULP platform structure
After being fully setup as explained in the Getting Started section, this root
repository is structured as follows:
- `rtl/tb` contains the main platform testbench and the related files.
- `rtl/vip` contains the verification IPs used to emulate external peripherals,
  e.g. SPI flash and camera.
- `rtl` could also contain other material (e.g. global includes, top-level
  files)
- `ips` contains all IPs downloaded by `update-ips` script. Most of the actual
  logic of the platform is located in these IPs.
- `sim` contains the ModelSim/QuestaSim simulation platform.
- `pulp-sdk` contains the PULP software development kit; `pulp-sdk/tests`
  contains all tests released with the SDK.
- `ipstools` contains the utils to download and manage the IPs and their
  dependencies.
- `ips_list.yml` contains the list of IPs required directly by the platform.
  Notice that each of them could in turn depend on other IPs, so you will
  typically find many more IPs in the `ips` directory than are listed in
  this file.
- `rtl_list.yml` contains the list of places where local RTL sources are found
  (e.g. `rtl/tb`, `rtl/vip`).

## Requirements
The RTL platform has the following requirements:
- Relatively recent Linux-based operating system; we tested *Ubuntu 16.04* and
  *CentOS 7*.
- Mentor ModelSim in reasonably recent version (we tested it with version *10.6b*
-- the free version provided by Altera is only partially working, see issue #12).
- Python 3.4, with the `pyyaml` module installed (you can get that with
  `pip3 install pyyaml`).
- The SDK has its own dependencies, listed in
  https://github.com/pulp-platform/pulp-sdk/blob/master/README.md

## Repository organization
The PULP and PULPissimo platforms are highly hierarchical and the Git
repositories for the various IPs follow the hierarchy structure to keep maximum
flexibility.
Most of the complexity of the IP updating system are hidden behind the
`update-ips` and `generate-scripts` Python scripts; however, a few details are
important to know:
- Do not assume that the `master` branch of an arbitrary IP is stable; many
  internal IPs could include unstable changes at a certain point of their
  history. Conversely, in top-level platforms (`pulpissimo`, `pulp`) we always
  use *stable* versions of the IPs. Therefore, you should be able to use the
  `master` branch of `pulpissimo` safely.
- By default, the IPs will be collected from GitHub using HTTPS. This makes it
  possible for everyone to clone them without first uploading an SSH key to
  GitHub. However, for development it is often easier to use SSH instead,
  particularly if you want to push changes back.
  To enable this, just replace `https://github.com` with `git@github.com` in the
  `ipstools_cfg.py` configuration file in the root of this repository.

The tools used to collect IPs and create scripts for simulation have many
features that are not necessarily intended for the end user, but can be useful
for developers; if you want more information, e.g. to integrate your own
repository into the flow, you can find documentation at
https://github.com/pulp-platform/IPApproX/blob/master/README.md

## External contributions
The supported way to provide external contributions is by forking one of our
repositories, applying your patch and submitting a pull request where you
describe your changes in detail, along with motivations.
The pull request will be evaluated and checked with our regression test suite
for possible integration.
If you want to replace our version of an IP with your GitHub fork, just add
`group: YOUR_GITHUB_NAMESPACE` to its entry in `ips_list.yml` or
`ips/pulp_soc/ips_list.yml`.
While we are quite relaxed in terms of coding style, please try to follow these
recommendations:
https://github.com/pulp-platform/ariane/blob/master/CONTRIBUTING.md

## Known issues
The current version of the PULPissimo platform does not include yet an FPGA port
or example scripts for ASIC synthesis; both things may be deployed in the
future.
The `ipstools` includes only partial support for simulation flows different from
ModelSim/QuestaSim.

## Support & Questions
For support on any issue related to this platform or any of the IPs, please add
an issue to our tracker on https://github.com/pulp-platform/pulpissimo/issues

## Citing
If you are using PULP in your academic work you can cite us:
```
@ARTICLE{8715500,
  author={Pullini, Antonio and Rossi, Davide and Loi, Igor and Tagliavini, Giuseppe and Benini, Luca},
  journal={IEEE Journal of Solid-State Circuits}, 
  title={Mr.Wolf: An Energy-Precision Scalable Parallel Ultra Low Power SoC for IoT Edge Processing}, 
  year={2019},
  volume={54},
  number={7},
  pages={1970-1981},
  doi={10.1109/JSSC.2019.2912307}}
```

# PULP

PULP (Parallel Ultra-Low-Power) is an open-source multi-core computing platform 
part of the of the ongoing collaboration between ETH Zurich and the University 
of Bologna - started in 2013.

The PULP architecture targets IoT end-node applications requiring flexible 
processing of data streams generated by multiple sensors, such as accelerometers, 
low-resolution cameras, microphone arrays, vital signs monitors.

PULP consists of an advanced microcontroller architecture representing a significant 
step ahead in terms of completeness and complexity with respect to
PULPino, taking care of autonomous I/O, advanced data pre-processing, external interrupts, 
and including a tightly-coupled cluster of processors to which compute-intensive kernels 
can be offloaded from a main processor.
The PULP architecture includes:

- Either the RI5CY core or the zero-riscy one as main core
- Autonomous Input/Output subsystem (uDMA)
- New memory subsystem
- Support for Hardware Processing Engines (HWPEs)
- New simple interrupt controller
- New peripherals
- New parallel computing cluster
- New system DMA
- New event unit
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
RISCY implementes a subset of the 1.9 privileged specification.
Further information about the core can be found at
http://ieeexplore.ieee.org/abstract/document/7864441/
and in the documentation of the IP.

zero-riscy is an in-order, single-issue core with 2 pipeline stages and it
has full support for the base integer instruction set (RV32I) and
compressed instructions (RV32C).
It can be configured to have multiplication instruction set extension (RV32M)
and the reduced number of registers extension (RV32E). It has been designed to
target ultra-low-power and ultra-low-area constraints. zero-riscy implementes
a subset of the 1.9 privileged specification.
Further information about the core can be found at
http://ieeexplore.ieee.org/document/8106976/
and in the documentation of the IP.

PULP includes a new efficient I/O subsystem via a uDMA (micro-DMA) which
communicates with the peripherals autonomously. The core just needs to program
the uDMA and wait for it to handle the transfer.
Further information about the core can be found at
http://ieeexplore.ieee.org/document/8106971/
and in the documentation of the IP.

PULP supports I/O on interfaces such as:

- SPI (as master)
- I2S
- Camera Interface (CPI)
- I2C
- UART
- JTAG

PULP also supports integration of hardware accelerators (Hardware
Processing Engines) that share memory with the RI5CY core and are programmed on
the memory map. An example accelerator, performing multiply-accumulate on a
vector of fixed-point values, can be found in `hwpe-mac-engine` (after
updating the IPs: see below in the Getting Started section).
The `hwpe-stream` and `hwpe-ctrl` folders contain the IPs necessary to
plug streaming accelerators into a PULP system on the data and control plane.
For further information on how to design and integrate such accelerators,
see `hwpe-stream/doc` and https://arxiv.org/abs/1612.05974.

## Getting Started

### Prerequisites
To be able to use the PULP platform, you need the PULP toolchain.
The instructions to get it can be found here: https://github.com/pulp-platform/pulp-riscv-gnu-toolchain.


### Building the RTL simulation platform
To build the RTL simulation platform, start by getting the latest version of the
IPs composing the PULP system:
```
source setup/vsim.sh

make checkout

make scripts

make build
```
**NOTE:** An error might occur running the scripts (*Failed to spawn child process.Too many open files (os error 24).*) while a fix is WIP a workaround is to increase the number of processes avilable to your machine by setting for example ulimit to 4096 (ulimit -n 4096).

This command builds a version of the simulation platform with no dependencies on
external models for peripherals. See below (Proprietary verification IPs) for
details on how to plug in some models of real SPI, I2C, I2S peripherals.

Default dependency management is done using bender to gather IPs. If you would like to 
use the legacy IPApproX tool, set the `IPAPPROX` environment variable, 
e.g. by running `export IPAPPROX=1`, and continue at your own risk.

#### Working on IPs
The easiest way to work on an individual IP is to clone it using bender with the following command:
```
./bender clone $IP
```
This will checkout the IP to the `working_dir` directory, where it can be modified and the changes committed and pushed.
The correct link will be set through an override in the `Bender.local` file, forcing the bender tool to use this version of the dependency.
To build the platform, make sure to start at the `make scripts` step above after calling `./bender clone`. 

Once the changes are complete, please ensure the `Bender.yml` files in the packages calling the IP dependency are accordingly updated with the new version.
The `bender parents` command can assist in determining which dependencies' `Bender.yml` files need updating.
Please note that when modifying dependency versions, the `./bender update` command needs to be called to re-resolve the correct versions.
Once the update is complete, the corresponding line from Bender.local can be removed to revert to normal dependency resolution, no longer using the version in `working_dir` (be sure to call `./bender update`). 
For more information check out the [bender documentation](https://github.com/pulp-platform/bender).


### Downloading and running simple C regression tests
Finally, you can download and run the tests; for that you can checkout the
following repositories:

- Runtime tests: https://github.com/pulp-platform/regression_tests

- Pulp runtime:  https://github.com/pulp-platform/pulp-runtime

Now you can change directory to your favourite test e.g.: for an hello world
test, run

```
git clone https://github.com/pulp-platform/regression_tests.git

git clone https://github.com/pulp-platform/pulp-runtime.git

source pulp-runtime/configs/pulp.sh

export PATH=*path to riscv gcc toolchain*/bin:$PATH

export PULP_RISCV_GCC_TOOLCHAIN= *path to riscv gcc toolchain*

cd regression_tests/hello

mae clean all run gui=1

```
The open-source simulation platform relies on JTAG to emulate preloading of the
PULP L2 memory. If you want to simulate a more realistic scenario (e.g.
accessing an external SPI Flash), look at the sections below.

In case you want to see the Modelsim GUI, just type
```
make conf gui=1
```
before starting the simulation.

If you want to save a (compressed) VCD for further examination, type
```
make conf vsim/script=export_run.tcl
```
before starting the simulation. You will find the VCD in
`build/<SRC_FILE_NAME>/pulp/export.vcd.gz` where 
`<SRC_FILE_NAME>` is the name of the C source of the test.

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

## PULP-SDK

If you are a software developer, you can find the PULP-SDK here: https://github.com/pulp-platform/pulp-sdk.

## PULP platform structure
After being fully setup as explained in the Getting Started section, this root
repository is structured as follows:
- `rtl/tb` contains the main platform testbench and the related files.
- `rtl/vip` contains the verification IPs used to emulate external peripherals,
  e.g. SPI flash and camera.
- `rtl` could also contain other material (e.g. global includes, top-level
  files)
- `sim` contains the ModelSim/QuestaSim simulation platform.
- `pulp-sdk` contains the PULP software development kit; `pulp-sdk/tests`
  contains all tests released with the SDK.
- `Bender.yml` contains all dependency and source file information for the bender tool.

## Requirements
The RTL platform has the following requirements:
- Relatively recent Linux-based operating system; we tested *Ubuntu 16.04* and
  *CentOS 7*.
- ModelSim in reasonably recent version (we tested it with version *10.6b*).
- Python 3.4, with the `pyyaml` module installed (you can get that with
  `pip3 install pyyaml`).
- The SDK has its own dependencies, listed in
  https://github.com/pulp-platform/pulp-sdk/blob/master/README.md

## Repository organization
The PULP platforms is highly hierarchical and the Git repositories for the various 
IPs follow the hierarchy structure to keep maximum flexibility.
Most of the complexity of the IP updating system are hidden behind the bender tool; 
however, a few details are important to know:
- Do not assume that the `master` branch of an arbitrary IP is stable; many
  internal IPs could include unstable changes at a certain point of their
  history. Conversely, in top-level platforms (`pulpissimo`, `pulp`) we always
  use *stable* versions of the IPs. Therefore, you should be able to use the
  `master` branch of `pulpissimo` safely.
- By default, the IPs will be collected from GitHub using HTTPS. This makes it
  possible for everyone to clone them without first uploading an SSH key to
  GitHub. However, for development it is often easier to use SSH instead,
  particularly if you want to push changes back.

The tools used to collect IPs and create scripts for simulation have many
features that are not necessarily intended for the end user, but can be useful
for developers; if you want more information, e.g. to integrate your own
repository into the flow, you can find documentation at
https://github.com/pulp-platform/bender/blob/master/README.md

## External contributions
The supported way to provide external contributions is by forking one of our
repositories, applying your patch and submitting a pull request where you
describe your changes in detail, along with motivations.
The pull request will be evaluated and checked with our regression test suite
for possible integration.
If you want to replace our version of an IP with your GitHub fork, just add it 
to the corresponding Bender.yml file, or use an override in a Bender.local in 
the top repository.
While we are quite relaxed in terms of coding style, please try to follow these
recommendations:
https://github.com/pulp-platform/ariane/blob/master/CONTRIBUTING.md

## Known issues
The current version of the PULP platform does not include yet an FPGA port
or example scripts for ASIC synthesis; both things may be deployed in the
future.
Simulation flows different from ModelSim/QuestaSim have only have limited testing.

## Support & Questions
For support on any issue related to this platform or any of the IPs, please add
an issue to our tracker on https://github.com/pulp-platform/pulpissimo/issues


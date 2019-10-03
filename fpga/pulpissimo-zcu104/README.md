# PULPissimo on the Xilinx ZCU104 Board
[\[Datasheet\]](https://www.xilinx.com/support/documentation/boards_and_kits/zcu104/ug1267-zcu104-eval-bd.pdf)

## Bitstream Generation
In the fpga folder, run
```Shell
make zcu104
```
which will generate `pulpissimo_zcu104.bit`.
Use Vivado to load it into the FPGA.

## Default SoC and Core Frequencies

By default the clock generating IPs are synthesized to provide the following frequencies to PULPissimo:

| Clock Domain   | Default Frequency on ZCU104 board  |
|----------------|------------------------------------|
| Core Frequency | 20 MHz                             |
| SoC Frequency  | 10 MHz                             |


## Peripherals
Most peripherals of are connected to the ARM processing system domain of the SoC and cannot be used from the programmable logic domain.
The peripherals available to PULPissimo are thus very limited.

### Reset Button
The CPU RESET button (SW20) resets the RISC-V CPU.

### UART
PULPissimo's UART port is mapped to Channel D of the FT4232HL chip.
When connecting the board to a computer using the USB/JTAG/UART micro-USB connector (J164), it is the last of the four detected serial devices.

### JTAG
Unfortunately, only one channel of the FT4232HL chip is connected to the programmable logic domain.
Since we are using that channel for UART, the micro-USB connector on the board cannot be used to communicate with the RISC-V debug module over JTAG.
Instead, you need to connect a separate JTAG adapter to the GPIO port (PMOD0 header) of the board:

| JTAG Signal | FPGA Port | J55 Pin  |
|-------------|-----------|----------|
| tms         | PMOD0_0   | Pin 1    |
| tdi         | PMOD0_1   | Pin 3    |
| tdo         | PMOD0_2   | Pin 5    |
| tck         | PMOD0_3   | Pin 7    |
| gnd         | GND       | Pin 9    |
| vdd         | 3V3       | Pin 11   |

An OpenOCD configuration file for the Digilent JTAG-HS1 adapter is included.
To use it, run

```Shell
$OPENOCD/bin/openocd -f pulpissimo/home/meggiman/projects/pulp/pulpissimo/fpga/pulpissimo-zcu104/openocd-zcu104-digilent-jtag-hs1.cfg
```

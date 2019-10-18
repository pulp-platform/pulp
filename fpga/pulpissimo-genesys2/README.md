# PULPissimo on the Digilent Genesys2 Board
[\[Documentation\]](https://reference.digilentinc.com/reference/programmable-logic/genesys-2/start)

## Bitstream Generation
In the fpga folder, run
```Shell
make genesys2
```
which will generate `pulpissimo_genesys2.bit`.
Use Vivado to load it into the FPGA.

## Default SoC and Core Frequencies

By default the clock generating IPs are synthesized to provide the following frequencies to PULPissimo:

| Clock Domain   | Default Frequency on Genesys2 board |
|----------------|-------------------------------------|
| Core Frequency | 20 MHz                              |
| SoC Frequency  | 10 MHz                              |


## Peripherals
PULPissimo is connected to the following board peripherals:


| PULPissimo Pin | Mapped Board Peripheral                             |
|----------------|-----------------------------------------------------|
| `SPIM0` pins   | QSPI Flash                                          |
| `I2C0` pins    | I2C Bus (connects to Board Current Measurement ICs) |
| `spim_csn1`    | LED0                                                |
| `cam_pclk`     | LED1                                                |
| `cam_hsync`    | LED2                                                |
| `cam_data0`    | LED3                                                |
| `cam_data1`    | Switch 1                                            |
| `cam_data2`    | Switch 2                                            |
| `cam_data3`    | Button C                                            |
| `cam_data4`    | Button D                                            |
| `cam_data5`    | Button L                                            |
| `cam_data6`    | Button R                                            |
| `cam_data7`    | Button U                                            |

### Reset Button
The USER RESET button (BTN1) resets the RISC-V CPU.

### UART
PULPissimo's UART port is mapped to the onboard FTDI FT232R USB-UART bridge and thus accessible through the UART micro-USB connector J15.

### JTAG
PULPIssimo's JTAG plug is connected to Channel 0 of the onboard FTDI USB JTAG
programmer. Therefore we can attach OpenOCD withouth the need of an external
JTAG programmer. Just attach a micro-USB cable to the JTAG SW17 micro-USB connector and use the
provided OpenOCD configuration file:

```Shell
$OPENOCD/bin/openocd -f pulpissimo/fpga/pulpissimo-genesys2/openocd-genesys2.cfg
```

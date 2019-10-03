# PULPissimo on the Digilent Nexys Video Board
[\[Documentation\]](https://reference.digilentinc.com/reference/programmable-logic/nexys-video/start)

## Bitstream Generation
In the fpga folder, run
```Shell
make nexys_video
```
which will generate `pulpissimo_nexys_video.bit`.
Use Vivado to load it into the FPGA.

## Default SoC and Core Frequencies

By default the clock generating IPs are synthesized to provide the following frequencies to PULPissimo:

| Clock Domain   | Default Frequency on Nexys Video board |
|----------------|----------------------------------------|
| Core Frequency | 10 MHz                                 |
| SoC Frequency  |  5 MHz                                 |


## Peripherals
PULPissimo is connected to the following board peripherals:


| PULPissimo Pin | Mapped Board Peripheral                             |
|----------------|-----------------------------------------------------|
| `SPIM0` pins   | QSPI Flash                                          |
| `I2C0` pins    | I2C Bus (connects to the ADAU1761 audio codec)      |
| `spim_csn1`    | LED0                                                |
| `cam_pclk`     | LED1                                                |
| `cam_hsync`    | LED2                                                |
| `cam_data0`    | LED3                                                |
| `cam_data1`    | Switch 0                                            |
| `cam_data2`    | Switch 1                                            |
| `cam_data3`    | Button C                                            |
| `cam_data4`    | Button D                                            |
| `cam_data5`    | Button L                                            |
| `cam_data6`    | Button R                                            |
| `cam_data7`    | Button U                                            |

### Reset Button
The CPU RESET button (G4) resets the RISC-V CPU.

### UART
PULPissimo's UART port is mapped to the onboard FTDI FT232R USB-UART bridge and thus accessible through the UART micro-USB connector (J13).

### JTAG
PULPIssimo's JTAG plug is connected to Channel 0 of the onboard FTDI USB JTAG programmer.
Therefore we can attach OpenOCD withouth the need of an external JTAG programmer.
Just attach a micro-USB cable to the PROG micro-USB connector (J12) and use the provided OpenOCD configuration file:

```Shell
$OPENOCD/bin/openocd -f pulpissimo/fpga/pulpissimo-nexys_video/openocd-nexys_video.cfg
```

# PULP FPGA Port

PULP has been implemented on FPGA for various Xilinx FPGA boards. Please check the corresponding
subdirectory for the various supported boards:

* Xilinx ZCU102

### Bitstream Generation
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

TODO: describe bitstream flashing

### Compiling and running on fpga

TODO: describe compiling and running on fpga





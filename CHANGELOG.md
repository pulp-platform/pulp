# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- Use new `udma`
- Update `README.m` with FPGA usage instructions
- Move tests to subfolder `tests`
- Allow setting entry point with `-gENTRY_POINT`
- Update to sdk-release 2019.11.02
- Bump `pulp_soc` to `v1.1.0`

### Added
- DPI models for peripherals
- PMP support in RI5CY
- Debug module compliant with [RISC-V External Debug Support v0.13.1](https://github.com/riscv/riscv-debug-spec)
- Support for Xcelium
- ~~FPGA support for genesys2~~ (WIP)
- ~~FPGA support for Xilinx ZCU104~~ (WIP)
- ~~FPGA support for Xilinx ZCU102~~ (WIP)
- ~~FPGA support for Nexys Video~~ (WIP)
- ~~FPGA support for Zedboard~~ (WIP)
- [ibex](https://github.com/lowRISC/ibex/) support
- Improved software debugging (disassembly in simulator window)
- Gitlab CI (fpga synthesis, software tests, debug module tests)
- Automatic handling of VIPs (installing and compiling)
- CHANGELOG.md
- CI support for pulp-runtime to run tests, using bwruntest.py and
  tests/runtime-tests.yaml
- Bender integration

### Removed
- Support for custom debug module
- zero-riscy support in the fabric controller

### Fixed
- JTAG issues
- Bad pad mux configuration
- Various jenkins CI issues
- Bootsel behavior
- Bugs in debug module integration
- AXI width issues
- USE_HWPE parameter propagation
- I2C EEPROM can now be concurrently used with I2C DPI model
- Small quartus compatibility fixes
- Many minor tb issues
- Properly propagate NB_CORES

## [1.0.0] - 2018-02-09

### Added
- Initial release

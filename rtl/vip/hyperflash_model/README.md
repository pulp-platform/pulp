This folder is just a placeholder.
The verilog model of the Spansion S26KS512S flash is proprietary code of CypressSemiconductor Corporation, which can currently be downloaded from here: https://www.cypress.com/verilog/s26ks512s-verilog

Once the package has been downloaded, the following steps are necessary to integrate the model in the platform:
1. unzip it (it might be necessary to rename it 260016.zip first)
2. execute `S26KS512S.exe` (it is a Windows executable, but it can be run on Linux by using Wine)
3. accept the EULA license agreement
4. move the newly created `S26KS512S` directory in this directory
5. uncomment the S25fs256s section in the `rtl/vip/src_files.yml` file
6. modify `rtl/tb/tb_pulp.sv` so that the parameter `USE_HYPER_MODEL` is 1
7. regenerate scripts with `generate-scripts` with the relative option `--hyper-vip` and rebuild the simulation platform



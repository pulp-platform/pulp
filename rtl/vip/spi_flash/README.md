This folder is just a placeholder.
The verilog model of the Spansion S25FS256S flash is proprietary code of CypressSemiconductor Corporation, which can currently be downloaded from here: http://www.cypress.com/file/260016

Once the package has been downloaded, the following steps are necessary to integrate the model in the platform:
1. unzip it (it might be necessary to rename it 260016.zip first)
2. execute `S25fs256s.exe` (it is a Windows executable, but it can be run on Linux by using Wine)
3. accept the EULA license agreement
4. move the newly created `S25fs256s` directory in this directory
5. uncomment the S25fs256s section in the `rtl/vip/src_files.yml` file
6. modify `rtl/tb/tb_pulp.sv` so that the parameter `USE_S25FS256S_MODEL` is 1
7. regenerate scripts with `generate-scripts` and rebuild the simulation platform

When the SPI flash is active, it is possible to use it for a more realistic boot simulation, where the PULP chip boots from ROM and then 
fetches its own program from the flash drive. See the main README.md for details.


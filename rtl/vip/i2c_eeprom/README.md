This folder is just a placeholder.
The verilog model of the Microchip 24FC1025 I2C serial EEPROM is proprietary code of Microchip Technology Inc., distributed under license from Young Engineering. It can currently be downloaded from here: http://ww1.microchip.com/downloads/en/DeviceDoc/24xx1025_Verilog_Model.zip

Once the package has been downloaded, the following steps are necessary to integrate the model in the platform:
1. unzip it
2. there is no EULA, but using this file implies implicitly accepting the license agreement
3. move the newly created files in this directory
4. uncomment the 24FC1025 section in the `rtl/vip/src_files.yml` file
5. modify `rtl/tb/tb_pulp.sv` so that the parameter `USE_24FC1025_MODEL` is 1
6. regenerate the scripts with `generate-scripts` and rebuild the simulation platform

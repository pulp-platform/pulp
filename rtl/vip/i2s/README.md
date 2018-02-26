This folder is partially a placeholder; the `i2s` verification IP is incomplete without using part of the I2C model to implement the IC control memory.
We reuse the verilog model of the Microchip 24FC1025 I2C serial EEPROM that can be downloaded for the `i2c_eeprom` verification IP.

Once the package has been downloaded, the following steps are necessary to integrate the model in the platform:
1. follow the instructions in `rtl/vip/i2c_eeprom` to download and extract the I2C verification IP.
2. do `cp ../i2c_eeprom/24FC1025.v i2c_if.v` .
3. open the newly created `i2c_if.v` file and remove/comment lines from 614 to 671.
4. do `patch i2c_if.v < i2c_if.patch`
5. uncomment the I2S section in the `rtl/vip/src_files.yml` file
6. modify `rtl/tb/tb_pulp.sv` so that the parameter `USE_I2S_MODEL` is 1
7. regenerate the scripts with `generate-scripts` and rebuild the simulation platform


#######################################
# SDVT support
if {[info exists ::env(SMARTDV_HOME)]} {
    quietly set SMARTDV_HOME $::env(SMARTDV_HOME)
} {
    quietly set SMARTDV_HOME ./
}

quietly set use_sdvt ""
if {[info exists ::env(USE_SDVT)]} {
  if {$::env(USE_SDVT) == "YES"} {
    quietly set use_sdvt "-pli $VSIM_TB_PATH/smartdv_vip_models/sdvt_license_fl_mti_64.so"
  } 
} 

# SMARTDV  Debug level 1 - verbose, 2 - debug, 3 - info, 4 - warning, 5 - error
quietly set sdvt_debug_level ""
if {[info exists ::env(SDVT_DEBUG_LEVEL)]} {
  quietly set sdvt_debug_level "+sdvt_debug=$::env(SDVT_DEBUG_LEVEL)"
} 

#######################################
#### SDVT CPI support
quietly set use_sdvt_cpi "-gUSE_SDVT_CPI=0"
if {[info exists ::env(SDVT_CPI)]} {
  if {$::env(SDVT_CPI) == "YES"} {
    quietly set use_sdvt_cpi "-gUSE_SDVT_CPI=1"
  } 
} 

quietly set sdvt_cpi_test "" 
if {[info exists ::env(SDVT_CPI_TEST)]} {
  quietly set sdvt_cpi_test "+sdvt_cpi_test=$::env(SDVT_CPI_TEST)"
} 

## camera number of images to be transmitted
quietly set sdvt_cpi_cmds "" 
if {[info exists ::env(SDVT_CPI_CMDS)]} {
  quietly set sdvt_cpi_cmds "+sdvt_cpi_cmds=$::env(SDVT_CPI_CMDS)"
} 

quietly set sdvt_cpi_checker_ena ""
if {[info exists ::env(SDVT_CPI_CHECKER_ENA)]} {
  if {$::env(SDVT_CPI_CHECKER_ENA) == "YES"} {
    quietly set sdvt_cpi_checker_ena "+SDVT_CPI_CHECKER_ENA"
  } 
} 

quietly set sdvt_cpi_hres "" 
if {[info exists ::env(SDVT_CPI_H_RES)]} {
  quietly set sdvt_cpi_hres "+sdvt_cpi_hres=$::env(SDVT_CPI_H_RES)"
} 

quietly set sdvt_cpi_vres "" 
if {[info exists ::env(SDVT_CPI_V_RES)]} {
  quietly set sdvt_cpi_vres "+sdvt_cpi_vres=$::env(SDVT_CPI_V_RES)"
} 
#######################################
#### SDVT I2S support
quietly set use_sdvt_i2s "-gUSE_SDVT_I2S=0"
if {[info exists ::env(SDVT_I2S)]} {
  if {$::env(SDVT_I2S) == "YES"} {
    quietly set use_sdvt_i2s "-gUSE_SDVT_I2S=1"
  } 
} 

quietly set sdvt_i2s_test "" 
if {[info exists ::env(SDVT_I2S_TEST)]} {
  quietly set sdvt_i2s_test "+sdvt_i2s_test=$::env(SDVT_I2S_TEST)"
} 

## camera number of images to be transmitted
quietly set sdvt_i2s_cmds "" 
if {[info exists ::env(SDVT_I2S_CMDS)]} {
  quietly set sdvt_i2s_cmds "+sdvt_i2s_cmds=$::env(SDVT_I2S_CMDS)"
} 

#######################################
#### SDVT SPI support
quietly set use_sdvt_spi "-gUSE_SDVT_SPI=0"
if {[info exists ::env(SDVT_SPI)]} {
  if {$::env(SDVT_SPI) == "YES"} {
    quietly set use_sdvt_spi "-gUSE_SDVT_SPI=1"
  } 
} 

quietly set sdvt_spi_test "" 
if {[info exists ::env(SDVT_SPI_TEST)]} {
  quietly set sdvt_spi_test "+sdvt_spi_test=$::env(SDVT_SPI_TEST)"
} 

## camera number of images to be transmitted
quietly set sdvt_spi_cmds "" 
if {[info exists ::env(SDVT_SPI_CMDS)]} {
  quietly set sdvt_spi_cmds "+sdvt_spi_cmds=$::env(SDVT_SPI_CMDS)"
} 


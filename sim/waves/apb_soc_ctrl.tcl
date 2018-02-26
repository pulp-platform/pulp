# add PAD
set apb_soc_ctrl [find instances -recursive -bydu apb_soc_ctrl -nodu]

if {$apb_soc_ctrl ne ""} {
  add wave -group "APB_SOC_CTRL"                              $apb_soc_ctrl/*
}

configure wave -namecolwidth  250
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -timelineunits ns
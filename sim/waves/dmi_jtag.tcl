# add dmi_jtag
set dmi [find instances -recursive -bydu dmi_jtag -nodu]
set dmi_tap  [find instances -recursive -bydu dmi_jtag_tap -nodu]

if {$dmi ne ""} {
  add wave -group "DMI"                                     $dmi/*
}
if {$dmi_tap ne ""} {
  add wave -group "DMI" -group "dmi_tap"                    $dmi_tap/*
}


configure wave -namecolwidth  250
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -timelineunits ns

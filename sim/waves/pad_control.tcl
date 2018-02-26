# add PAD
set pad_control [find instances -recursive -bydu pad_control -nodu]

if {$pad_control ne ""} {
  add wave -group "pad_control"                                     $pad_control/*
}

configure wave -namecolwidth  250
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -timelineunits ns
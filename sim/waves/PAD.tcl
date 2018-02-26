# add PAD
set pad_frame [find instances -recursive -bydu pad_frame -nodu]

if {$pad_frame ne ""} {
  add wave -group "PAD"                                     $pad_frame/*
}

configure wave -namecolwidth  250
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -timelineunits ns
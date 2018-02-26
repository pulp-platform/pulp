# add PAD
set pulpissimo [find instances -recursive -bydu pulpissimo -nodu]

if {$pulpissimo ne ""} {
  add wave -group "PULPissimo"                                     $pulpissimo/*
}

configure wave -namecolwidth  250
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -timelineunits ns
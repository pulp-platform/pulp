# add fc
set fc_subsystem [find instances -recursive -bydu fc_subsystem -nodu]

if {$fc_subsystem ne ""} {
  add wave -group "FC"                                     $fc_subsystem/*
}

configure wave -namecolwidth  250
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -timelineunits ns
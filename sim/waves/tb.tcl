# add fc
set tb [find instances -recursive -bydu tb_pulp -nodu]

if {$tb ne ""} {
  add wave -group "TB"                                     $tb/*
}

configure wave -namecolwidth  250
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -timelineunits ns
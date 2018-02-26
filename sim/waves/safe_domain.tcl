# add PAD
set safe_domain [find instances -recursive -bydu safe_domain -nodu]

if {$safe_domain ne ""} {
  add wave -group "safe_domain"                                     $safe_domain/*
}

configure wave -namecolwidth  250
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -timelineunits ns
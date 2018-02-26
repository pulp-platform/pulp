# add fc
set ulpsoc [find instances -recursive -bydu ulpsoc -nodu]

if {$ulpsoc ne ""} {
  add wave -group "ULPSOC"                                    $ulpsoc/*
}

configure wave -namecolwidth  250
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -timelineunits ns
#!/usr/bin/tclsh

set fileName [lindex $argv 0]

catch {set fptr [open $fileName r]} ;

set contents [read -nonewline $fptr] ;#Read the file contents
close $fptr ;#Close the file since it has been read now

set splitCont [split $contents "\n"] ;#Split the files contents on new line

set linecount 1
set found_magic 0
set found_res   0
set found_max   0
set pixel_count 0
set pixel_comp  0
set line ""
set pixel_val 0
set checksum 0
foreach ele $splitCont {
    if {$found_magic == 1} {
    	if {[string index $ele 0] != "#"} {
    		if {$found_res == 1} {
    			if {$found_max == 1} {
    				if {$pixel_comp == 2} {
    					set pixel_comp 0
						set pixel_val [expr $pixel_val + ($ele & 0xF8)]
    					incr pixel_count
    					set line "${line}[format %02X $ele]"
    					#puts "$line"
						set checksum [expr $checksum + ($pixel_val >> 2)]
    					set line ""
						set pixel_val 0
    				} else {
    					set line "${line}[format %02X $ele]"
						if {$pixel_comp == 1} {
							set pixel_val [expr $pixel_val + ($ele & 0xFC)]						
						} else {
							set pixel_val [expr $pixel_val + ($ele & 0xF8)]						
						}
     					incr pixel_comp
   				}
    			} else {
    				#puts "Found Max $ele"
    				set found_max 1
    			}
    		} else {
    			#puts "Found res $ele"
    			set found_res 1
    		}
    	}
    } else {
    	if {$ele == "P3"} {
    		set found_magic 1
    		#puts "Found magic at line ${linecount}"
    	}
    }
    incr linecount
}

puts "The checksum is [format %8X $checksum]"

#puts "Found $pixel_count pixels"





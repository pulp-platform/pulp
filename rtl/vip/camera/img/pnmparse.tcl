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
foreach ele $splitCont {
    if {$found_magic == 1} {
    	if {[string index $ele 0] != "#"} {
    		if {$found_res == 1} {
    			if {$found_max == 1} {
    				if {$pixel_comp == 2} {
    					set pixel_comp 0
    					incr pixel_count
    					set line "${line}[format %02X $ele]"
    					puts "$line"
    					set line ""
    				} else {
    					incr pixel_comp
    					set line "${line}[format %02X $ele]"
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

#puts "Found $pixel_count pixels"





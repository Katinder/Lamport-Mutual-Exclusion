set ns [new Simulator]

#trace files
set tracefd [open out.tr w]
$ns trace-all $tracefd

#nam file
set namfd [open out.name w]
$ns namtrace-all $namfd

proc finish {} {
	global ns
	global namfd
	global total_cs
	global nmsg
	global t_sd
	
	set av_m [expr $nmsg/$total_cs]
	puts "------------final Statistics------------"
 	puts "total no of messages $nmsg, msg/cs $av_m"
 	puts "total no of process in Cs $total_cs" 
 	
 	$ns flush-trace
 	close $namfd
 	exit 0
	
}

proc requestcs {r ts} {
#send request to all sites
#append to its own request queue
	global ns
	global x
	global nmsg
	global RQ1
	global RQ2
	global RQ3
	global RQ4
	global RQ0
	global RQ1ts
	global RQ2ts
	global RQ3ts
	global RQ4ts
	global RQ0ts
	
	if {$r==1} {
		lappend RQ1ts $ts
		set RQ1ts [lsort $RQ1ts]
		#insert sorted
		#foreach
		set i [lsearch -exact $RQ1ts $ts]
		if {$i==-1} {
			lappend RQ1 $r
		} else {
			set RQ1 [linsert $RQ1 $i $r]
		}
		
	} elseif {$r==2} {
		lappend RQ2ts $ts
		set RQ2ts [lsort $RQ2ts]
		
		set i [lsearch -exact $RQ2ts $ts]
		if {$i==-1} {
			lappend RQ2 $r
		} else {
			set RQ2 [linsert $RQ2 $i $r]
		}
	} elseif {$r==3} {
		lappend RQ3ts $ts
		set RQ3ts [lsort $RQ3ts]
		
		set i [lsearch -exact $RQ3ts $ts]
		if {$i==-1} {
			lappend RQ3 $r
		} else {
			set RQ3 [linsert $RQ3 $i $r]
		}
	} elseif {$r==4} {
		lappend RQ4ts $ts
		set RQ4ts [lsort $RQ4ts]
		
		set i [lsearch -exact $RQ4ts $ts]
		if {$i==-1} {
			lappend RQ4 $r
		} else {
			set RQ4 [linsert $RQ4 $i $r]
		}
	} elseif {$r==0} {
		lappend RQ0ts $ts
		set RQ0ts [lsort $RQ0ts]
		
		set i [lsearch $RQ0ts $ts]
		if {$i==-1} {
			lappend RQ0 $r
		} else {
			set RQ0 [linsert $RQ0 $i $r]
		}
	}
	
	#send msg to all other sites
	for {set t 0} {$t < $x} {incr t} {
              if {$t != $r} {
                set now [$ns now]
                puts "***$r sending request to $t at $now***"
                #say recieved after a random channel delay
                set rd [expr rand()]
                set t1 [expr $now+$rd]
                #puts "t1 for $t =$t1"
                incr nmsg
                $ns at $t1 "recrequest $r $t $ts"
               }
            }
}

proc recrequest {sen rec ts} {
global ns
global x
global nmsg
#all rq
global RQ1
global RQ2
global RQ3
global RQ4
global RQ0
#all rq-ts
global RQ1ts
global RQ2ts
global RQ3ts
global RQ4ts
global RQ0ts



	set reqts [$ns now]
	puts "Request received by $rec from $sen at $reqts"
	
	if {$rec==1} {
		lappend RQ1ts $ts
		set RQ1ts [lsort $RQ1ts]
		
		set i [lsearch -exact $RQ1ts $ts]
		if {$i==-1} {
			lappend RQ1 $sen
		} else {
			set RQ1 [linsert $RQ1 $i $sen]
		}
		
	} elseif {$rec==2} {
		lappend RQ2ts $ts
		set RQ2ts [lsort $RQ2ts]
		
		set i [lsearch -exact $RQ2ts $ts]
		if {$i==-1} {
			lappend RQ2 $sen
		} else {
			set RQ2 [linsert $RQ2 $i $sen]
		}
	} elseif {$rec==3} {
		lappend RQ3ts $ts
		set RQ3ts [lsort $RQ3ts]
		
		set i [lsearch -exact $RQ3ts $ts]
		if {$i==-1} {
			lappend RQ3 $sen
		} else {
			set RQ3 [linsert $RQ3 $i $sen]
		}
	} elseif {$rec==4} {
		lappend RQ4ts $ts
		set RQ4ts [lsort $RQ4ts]
		
		set i [lsearch $RQ4ts $ts]
		if {$i==-1} {
			lappend RQ4 $sen
		} else {
			set RQ4 [linsert $RQ4 $i $sen]
		}
	}  elseif {$rec==0} {
		lappend RQ0ts $ts
		set RQ0ts [lsort $RQ0ts]
		
		set i [lsearch -exact $RQ0ts $ts]
		if {$i==-1} {
			lappend RQ0 $sen
		} else {
			set RQ0 [linsert $RQ0 $i $sen]
		}
	}
	
	puts "Queue Status after Requests sent"
	puts "RQ1= $RQ1"
	puts "Rq1ts= $RQ1ts"
	puts "RQ2= $RQ2"
	puts "Rq2ts= $RQ2ts"
	puts "RQ3= $RQ3"
	puts "Rq3ts= $RQ3ts"
	puts "RQ4= $RQ4"
	puts "Rq4ts= $RQ4ts"
	puts "RQ0= $RQ0"
	puts "Rq0ts= $RQ0ts"

	
	
	set repts [$ns now]
	#send direct reply
	$ns at $repts "recreply $rec $sen"
	incr nmsg

}

proc recreply {sen rec} {

	global ns
	global x
	global Reps
	global RQ1
	global RQ2
	global RQ3
	global RQ4
	global RQ0
	global RQ1ts
	global RQ2ts
	global RQ3ts
	global RQ4ts
	global RQ0ts
	
	
	set repts [$ns now]
	puts "Reply by $sen sent to $rec at $repts"
	
	#record replies in respective arrays
	set Reps($rec$sen) 1
	#parray Reps
	
	set count 0
	for {set i 0} {$i<$x} {incr i} {
		if {$rec!=$i} {
			if {$Reps($rec$i)} {
				incr count
			}
		}	
	}
	
	set max [expr $x-1]
	if {$count==$max} {
		puts "All replies received for $rec"
		
		if {$rec==1} {
		puts $RQ1
		puts $RQ1ts
			if {[lindex $RQ1 0]==$rec} {
				puts "process on top of RQ = $rec"
				puts "----------Executing CS for site $rec-----------"
				executecs $rec
			}
		} elseif {$rec==2} {
		puts $RQ2
		puts $RQ2ts
			if {[lindex $RQ2 0]==$rec} {
				puts "process on top of RQ = $rec"
				puts "----------Executing CS for site $rec-----------"
				executecs $rec
			}
		} elseif {$rec==3} {
		puts $RQ3
		puts $RQ3ts
			if {[lindex $RQ3 0]==$rec} {
				puts "process on top of RQ = $rec"
				puts "----------Executing CS for site $rec-----------"
				executecs $rec
			}
		} elseif {$rec==4} {
		puts $RQ4
		puts $RQ4ts
			if {[lindex $RQ4 0]==$rec} {
				puts "process on top of RQ = $rec"
				puts "----------Executing CS for site $rec-----------"
				executecs $rec
			}
		} elseif {$rec==0} {
		puts $RQ0
		puts $RQ0ts
			if {[lindex $RQ0 0]==$rec} {
				puts "process on top of RQ = $rec"
				puts "----------Executing CS for site $rec-----------"
				executecs $rec
			}
		}
		
		
	}
}
	
	
proc executecs {site} {

	global ns
	global x
	global total_cs
	
	incr total_cs
	set now [$ns now]
	puts "-----------------Site $site executing CS at $now--------------------"
        #say cs executed for a random time
        set rd [expr rand()]
        set t1 [expr $now+$rd]
        incr nmsg
        $ns at $t1 "exitcs $site"

}

proc exitcs {site} {
	
	global ns
	global x
	global nmsg
	global Reps
	global RQ1
	global RQ2
	global RQ3
	global RQ4
	global RQ0
	global RQ1ts
	global RQ2ts
	global RQ3ts
	global RQ4ts
	global RQ0ts
	
	
	
	set now [$ns now]
	puts "----------------$site exiting cs at $now-------------"
	
	#remove from your own list
	if {$site==1} {
		set RQ1 [lreplace $RQ1 0 0]
		set RQ1ts [lreplace $RQ1ts 0 0]
		
	} elseif {$site==2} {
		set RQ2 [lreplace $RQ2 0 0]
		set RQ2ts [lreplace $RQ2ts 0 0]
		
	} elseif {$site==3} {
		set RQ3 [lreplace $RQ3 0 0]
		set RQ3ts [lreplace $RQ3ts 0 0]
		
	} elseif {$site==4} {
		set RQ4 [lreplace $RQ4 0 0]
		set RQ4ts [lreplace $RQ4ts 0 0]
		
	} elseif {$site==0} {
		set RQ0 [lreplace $RQ0 0 0]
		set RQ0ts [lreplace $RQ0ts 0 0]	
	} 	
		
	#clear response array
	for {set i 0} {$i<$x} {incr i} {
		set Reps($site$i) 0
	}
	
	#send release message to all sites
	for {set i 0} {$i<$x} {incr i} {
		if {$i!=$site} {
			set now [$ns now]
			puts "Sending Release msg to site $i at $now"
			incr nmsg
			set now [$ns now]
			#say channel delay for release msg to reach
			set rd [expr rand()]
			set t1 [expr $now+$rd]
			$ns at $t1 "recrelease $site $i"
		}
	} 
}

#receive release message
proc recrelease {sen rec} {
	global ns
	global x
	global nmsg
	global Reps
	global RQ1
	global RQ2
	global RQ3
	global RQ4
	global RQ0
	global RQ1ts
	global RQ2ts
	global RQ3ts
	global RQ4ts
	global RQ0ts

	set now [$ns now]
	puts "Release msg recieved by $rec by $sen at $now"

	#remove si's request from this sites request queue
	if {$rec==1} {
		set idx [lsearch $RQ1 $sen]
		set RQ1 [lreplace $RQ1 $idx $idx]
		set RQ1ts [lreplace $RQ1ts $idx $idx]
		
	} elseif {$rec==2} {
		set idx [lsearch $RQ2 $sen]
		set RQ2 [lreplace $RQ2 $idx $idx]
		set RQ2ts [lreplace $RQ2ts $idx $idx]
		
	} elseif {$rec==3} {
		set idx [lsearch $RQ3 $sen]
		set RQ3 [lreplace $RQ3 $idx $idx]
		set RQ3ts [lreplace $RQ3ts $idx $idx]
		
	} elseif {$rec==4} {
		set idx [lsearch $RQ4 $sen]
		set RQ4 [lreplace $RQ4 $idx $idx]
		set RQ4ts [lreplace $RQ4ts $idx $idx]
		
	} elseif {$rec==0} {
		set idx [lsearch $RQ0 $sen]
		set RQ0 [lreplace $RQ0 $idx $idx]
		set RQ0ts [lreplace $RQ0ts $idx $idx]	
	} 
	puts "Queue Status after release msg received"
	puts "RQ1= $RQ1"
	puts "Rq1ts= $RQ1ts"
	puts "RQ2= $RQ2"
	puts "Rq2ts= $RQ2ts"
	puts "RQ3= $RQ3"
	puts "Rq3ts= $RQ3ts"
	puts "RQ4= $RQ4"
	puts "Rq4ts= $RQ4ts"
	puts "RQ0= $RQ0"
	puts "Rq0ts= $RQ0ts"
	
	
	#check if this site can now execute cs, if not then wait
	#check if top of rq
	if {$rec==1} {
		if {[lindex $RQ1 0]==$rec} {
			#check if all replies recieved
			set count 0
			for {set i 0} {$i<$x} {incr i} {
				if {$rec!=$i} {
					if {$Reps($rec$i)} {
						incr count
					}
				}	
			}
			
			set max [expr $x-1]
			if {$count==$max} {
				puts "-------$rec can execute CS now------"
				executecs $rec
			}
			
		}		
	} elseif {$rec==2} {
		if {[lindex $RQ2 0]==$rec} {
			#check if all replies recieved
			set count 0
			for {set i 0} {$i<$x} {incr i} {
				if {$rec!=$i} {
					if {$Reps($rec$i)} {
						incr count
					}
				}	
			}
			
			set max [expr $x-1]
			if {$count==$max} {
				puts "-------$rec can execute CS now------"
				executecs $rec
			}
			
		}
		
	} elseif {$rec==3} {
		if {[lindex $RQ3 0]==$rec} {
			#check if all replies recieved
			set count 0
			for {set i 0} {$i<$x} {incr i} {
				if {$rec!=$i} {
					if {$Reps($rec$i)} {
						incr count
					}
				}	
			}
			
			set max [expr $x-1]
			if {$count==$max} {
				puts "-------$rec can execute CS now------"
				executecs $rec
			}
			
		}
		
	} elseif {$rec==4} {
		if {[lindex $RQ4 0]==$rec} {
			#check if all replies recieved
			set count 0
			for {set i 0} {$i<$x} {incr i} {
				if {$rec!=$i} {
					if {$Reps($rec$i)} {
						incr count
					}
				}	
			}
			
			set max [expr $x-1]
			if {$count==$max} {
				puts "-------$rec can execute CS now------"
				executecs $rec
			}
			
		}
		
	} elseif {$rec==0} {
		if {[lindex $RQ0 0]==$rec} {
			#check if all replies recieved
			set count 0
			for {set i 0} {$i<$x} {incr i} {
				if {$rec!=$i} {
					if {$Reps($rec$i)} {
						incr count
					}
				}	
			}
			
			set max [expr $x-1]
			if {$count==$max} {
				puts "-------$rec can execute CS now------"
				executecs $rec
				
			}
			
		}
	} 	
}






set RQ1 {}
set RQ2 {}
set RQ3 {}
set RQ4 {}
set RQ0 {}
set RQ1ts {}
set RQ2ts {}
set RQ3ts {}
set RQ4ts {}
set RQ0ts {}

set x 5
set total_cs 0
set nmsg 0
set reqsites { 0 1 2 3 4}

set rng [new RNG]
$rng seed 0
set r2 [new RandomVariable/Exponential]
$r2 set avg_ 0.5
$r2 use-rng $rng

set i 0

for {set i 0} {$i<$x} {incr i} {
	for {set j 0} {$j<$x} {incr j} {
		set Reps($i$j) 0
	}
}


for {set i 0} {$i < $x} {incr i} {
	set index [expr {int(rand() * [llength $reqsites])}]
	set site [lindex $reqsites $index]
	set reqsites [lreplace $reqsites $index $index]
	set r1 [expr [$r2 value]]
	puts "request initiated at $r1"
	puts "requesting site $site"
	set rt($site) 0
	set t_wt 0
	$ns at $r1 "requestcs $site $r1"
}



$ns run
finish

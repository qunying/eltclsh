#
# Copyright (c) 2000 LAAS/CNRS 
#
# Anthony Mallet - Thu Feb 10 2000
#
# $Id$
#

# List of known packages

# GenoM and Co. ---------------------------------------------------------

package ifneeded genom 1.0 {
    load ${roottclserv}/packages/genom/$tcl_platform(target)/genom$tcl_platform(shext)
    package provide genom 1.0
}

package ifneeded rackTab 1.0 {
    load ${roottclserv}/packages/rackTab/$tcl_platform(target)/rackTab$tcl_platform(shext)
    package provide rackTab 1.0
}


# GDHE ------------------------------------------------------------------

package ifneeded gdhe 1.0 {
    load $env(GDHE)/bin/$tcl_platform(target)/gdhe$tcl_platform(shext)
    package provide gdhe 1.0
}

package ifneeded tkjpeg 1.0 {
    load $env(GDHE)/lib/$tcl_platform(target)/tkjpeg$tcl_platform(shext)
    package provide tkjpeg 1.0
}


# Packages for picoweb --------------------------------------------------

#set picopath /usr/local/robots/lama/web
set picopath /home/mallet/robots/lama/web

# basic cgi interaction
package ifneeded webimage 1.0 { source $picopath/tcl/webimage.tcl }
package ifneeded sonycntrl 1.0 { source $picopath/tcl/sonycntrl.tcl }
package ifneeded steo 1.0 { source $picopath/tcl/steo.tcl }
package ifneeded weblane 1.0 { source $picopath/tcl/lane.tcl }

# integrated clients
package ifneeded webcam 1.0 { source $picopath/clients/webcam.tcl }
package ifneeded sonycam 1.0 { source $picopath/clients/sonycam.tcl }
package ifneeded lama-telop 1.0 { source $picopath/clients/lama-telop.tcl }


# Preload packages ------------------------------------------------------

while {[set i [lsearch -exact $argv -package]] >= 0} {
    set pkgname [lindex $argv [expr $i+1]]
    if {[catch {package require $pkgname}]} {
	puts "no such package: $pkgname"
    } else {
	puts "loaded $pkgname package"
    }
    set argv [lreplace $argv $i [expr $i+1]]
}
unset i
catch { unset pkgname }

#eof

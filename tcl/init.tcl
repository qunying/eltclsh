#	$LAAS$

#
#  Copyright (c) 2001-2003 LAAS/CNRS                  --  Sat Oct  6 2001
#  All rights reserved.                                    Anthony Mallet
#
#
# Redistribution  and  use in source   and binary forms,  with or without
# modification, are permitted provided that  the following conditions are
# met:
#
#   1. Redistributions  of  source code must  retain  the above copyright
#      notice, this list of conditions and the following disclaimer.
#   2. Redistributions in binary form must  reproduce the above copyright
#      notice,  this list of  conditions and  the following disclaimer in
#      the  documentation   and/or  other  materials   provided with  the
#      distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE  AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY  EXPRESS OR IMPLIED WARRANTIES, INCLUDING,  BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES   OF MERCHANTABILITY AND  FITNESS  FOR  A PARTICULAR
# PURPOSE ARE DISCLAIMED.  IN NO  EVENT SHALL THE AUTHOR OR  CONTRIBUTORS
# BE LIABLE FOR ANY DIRECT, INDIRECT,  INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING,  BUT  NOT LIMITED TO, PROCUREMENT  OF
# SUBSTITUTE  GOODS OR SERVICES;  LOSS   OF  USE,  DATA, OR PROFITS;   OR
# BUSINESS  INTERRUPTION) HOWEVER CAUSED AND  ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE  USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

# Make packages in that directory available
lappend auto_path [file join $eltcl_library ..]

# Install default signal handlers (if the signal command exists)
if { [info command signal] != "" } { namespace eval el {
    proc sighandler { signal severity } {
	switch $severity {
	    "fatal" {
		puts ""
		puts "*** Got signal SIG$signal"
		while { 1 } {
		    puts -nonewline "*** Choose 1: continue, 2: exit > "
		    flush stdout
		    set c [el::getc]
		    switch $c {
			1 { puts $c; break }
			2 { puts $c; exit }
			"\n" { }
			"\r" { }
			default { puts $c }
		    }
		}
	    }
	}
    }

    signal INT [namespace code "sighandler INT fatal"]
}}

# Require command-line completion
if { [ catch {
    package require el::tools
    package require el::complete
} ] } {
    puts $errorInfo
}

# By default, let events be processed in the middle of a line editing
#fconfigure stdin -blocking 0

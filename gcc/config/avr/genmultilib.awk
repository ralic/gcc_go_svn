# Copyright (C) 2011-2017 Free Software Foundation, Inc.
#
# This file is part of GCC.
#
# GCC is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 3, or (at your option) any later
# version.
#
# GCC is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License
# along with GCC; see the file COPYING3.  If not see
# <http://www.gnu.org/licenses/>.

##################################################################
#  
# Transform Core/Device Information from avr-mcus.def to a
# Representation that is understood by GCC's multilib Machinery.
#
# The Script works as a Filter from STDIN to STDOUT.
# It generates a Makefile Snippet that sets some
# MULTILIB_* Variables as needed.
#
##################################################################

BEGIN {
    FS ="[(, \t]+"
    option[""] = ""
    comment = 1

    dir_tiny = "tiny-stack"
    opt_tiny = "msp8"

    dir_rcall = "short-calls"
    opt_rcall = "mshort-calls"

    #    awk Variable         Makefile Variable  
    #  ------------------------------------------
    #    m_options     <->    MULTILIB_OPTIONS
    #    m_dirnames    <->    MULTILIB_DIRNAMES
    #    m_required    <->    MULTILIB_REQUIRED
    m_sep = ""
    m_options    = "\nMULTILIB_OPTIONS = "
    m_dirnames   = "\nMULTILIB_DIRNAMES ="
    m_required   = "\nMULTILIB_REQUIRED ="
}

##################################################################
# Add some Comments to the generated Files and copy-paste
# Copyright Notice from above.
##################################################################

/^#/ {
    if (!comment)
	next
    else if (comment == 1)
    {
	print "# Auto-generated Makefile Snip"
	print "# Generated by    : ./gcc/config/avr/genmultilib.awk"
	print "# Generated from  : ./gcc/config/avr/avr-mcus.def"
	print "# Used by         : tmake_file from Makefile and genmultilib"
	print ""
    }

    comment = 2;

    print
}

/^$/ {
    # The first empty line stops copy-pasting the GPL comments
    # from this file to the generated file.

    comment = 0
}

##################################################################
# Run over all AVR_MCU Lines.  If we encounter a required multilib
# variant, add according combination of options to m_required,
# but onyl once.  Add encountered cores to m_dirnames and
# according -mmcu= options to m_options.
##################################################################

/^AVR_MCU/ {
    name = $2
    gsub ("\"", "", name)

    if ($5 == "NULL")
    {
	core = name

	# avr1 is supported for Assembler only:  It gets no multilib
	if (core == "avr1")
	    next

	option[core] = "mmcu=" core

	m_options  = m_options m_sep option[core]
	m_dirnames = m_dirnames " " core
	m_sep = "/"

	next
    }

    # avr1 is supported for Assembler only:  Its Devices are ignored
    if (core == "avr1")
	next

    opts = option[core]

    # split device specific feature list
    n = split($4,dev_attribute,"|")

    for (i=1; i <= n; i++)
    {
      if (dev_attribute[i] == "AVR_SHORT_SP")
        opts = opts "/" opt_tiny
      if (dev_attribute[i] == "AVR_ISA_RCALL")
        opts = opts "/" opt_rcall
    }

    if (!have[opts])
    {
	have[opts] = 1
	# Some special handling for the default mmcu: Remove a
	# leading "mmcu=avr2/" in order not to confuse genmultilib.
	gsub (/^mmcu=avr2\//, "", opts)
	if (opts != "mmcu=avr2")
	    m_required = m_required " \\\n\t" opts
    }
}

##################################################################
# 
##################################################################

END {
    ############################################################
    # Output that Stuff
    ############################################################

    # Intended Target: ./gcc/config/avr/t-multilib

    print m_options  " " opt_tiny " " opt_rcall
    print m_dirnames " " dir_tiny " " dir_rcall
    print m_required
}

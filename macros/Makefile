#Copyright (C) 1989, 1990, 1991 Free Software Foundation, Inc.
#     Written by James Clark (jjc@jclark.uucp)
#
#This file is part of groff.
#
#groff is free software; you can redistribute it and/or modify it under
#the terms of the GNU General Public License as published by the Free
#Software Foundation; either version 1, or (at your option) any later
#version.
#
#groff is distributed in the hope that it will be useful, but WITHOUT ANY
#WARRANTY; without even the implied warranty of MERCHANTABILITY or
#FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
#for more details.
#
#You should have received a copy of the GNU General Public License along
#with groff; see the file LICENSE.  If not, write to the Free Software
#Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

MACRODIR=/usr/local/lib/groff/tmac
TMAC_S=gs

all: tmac.e.strip

tmac.e.strip: tmac.e
	-rm -f $@
	sed -e '/%beginstrip%/,$$s/[	 ]*\\".*//' -e '/^\.$$/d' tmac.e >$@

clean:
	-rm -f tmac.e.strip

distclean: clean
realclean: distclean

TAGS:

install.nobin: all
	-[ -d $(MACRODIR) ] || mkdir $(MACRODIR)
	-rm -f $(MACRODIR)/tmac.an
	cp tmac.an $(MACRODIR)
	-rm -f $(MACRODIR)/tmac.e
	cp tmac.e.strip $(MACRODIR)/tmac.e
	-rm -f $(MACRODIR)/tmac.$(TMAC_S)
	cp tmac.s $(MACRODIR)/tmac.$(TMAC_S)
	-rm -f $(MACRODIR)/tmac.pic
	cp tmac.pic $(MACRODIR)
	-rm -f $(MACRODIR)/tmac.doc
	cp tmac.doc $(MACRODIR)
	-rm -f $(MACRODIR)/tmac.andoc
	cp tmac.andoc $(MACRODIR)

install.bin:

install: install.bin install.nobin

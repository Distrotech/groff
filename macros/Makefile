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
MACROMODE=444
TMAC_S=gs
STRIP=sed -e '/%beginstrip%/,$$s/[	 ]*\\".*//' -e '/^\.$$/d'

all:
clean:
distclean: clean
realclean: distclean
TAGS:

install.nobin: all
	-[ -d $(MACRODIR) ] || mkdir $(MACRODIR)
	-for file in tmac.an tmac.andoc tmac.pic; do \
	  rm -f $(MACRODIR)/$$file; \
	  cp $$file $(MACRODIR)/$$file; \
	  chmod $(MACROMODE) $(MACRODIR)/$$file; \
	done
	-for file in tmac.e tmac.doc tmac.doc.old; do \
	  rm -f $(MACRODIR)/$$file; \
	  $(STRIP) $$file >$(MACRODIR)/$$file; \
	  chmod $(MACROMODE) $(MACRODIR)/$$file; \
	done
	-rm -f $(MACRODIR)/tmac.$(TMAC_S)
	cp tmac.s $(MACRODIR)/tmac.$(TMAC_S)
	chmod $(MACROMODE) $(MACRODIR)/tmac.$(TMAC_S)
	-[ -d $(MACRODIR)/mdoc ] || mkdir $(MACRODIR)/mdoc
	-for file in doc-common doc-ditroff doc-nroff doc-syms; do \
	  rm -f $(MACRODIR)/mdoc/$$file; \
	  $(STRIP) $$file >$(MACRODIR)/mdoc/$$file; \
	  chmod $(MACROMODE) $(MACRODIR)/mdoc/$$file; \
	done

install.bin:
install: install.bin install.nobin

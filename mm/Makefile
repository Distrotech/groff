#Copyright (C) 1991 Free Software Foundation, Inc.
#     Written by Joergen Haegg (jh@efd.lth.se)
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
MMDIR=$(MACRODIR)/mm
#TMAC_M=gm
TMAC_M=m
# MAN7EXT is the man section for macros
MAN7EXT=7
MAN7DIR=/usr/local/man/man$(MAN7EXT)
# MAN1EXT is the man section for user commands
MAN1EXT=1
SHELL=/bin/sh

FILES=0.MT ms.MT ms.cov se_ms.cov 

.SUFFIXES: .man .n

.man.n:
	@echo Making $@ from $<
	@-rm -f $@
	@sed -e	"s;@MACRODIR@;$(MACRODIR);g" \
	-e "s;@MAN1EXT@;$(MAN1EXT);g" \
	-e "s;@MAN7EXT@;$(MAN7EXT);g" \
	-e "s;@TMAC_MDIR@;$(MMDIR);g" \
	-e "s;@TMAC_M@;$(TMAC_M);g" \
	-e "s;@VERSION@;`cat ../VERSION`;g" \
	-e "s;@MDATE@;`$(SHELL) ../man/mdate.sh $<`;g" \
	$< >$@
	@chmod 444 $@

all: groff_mm.n groff_mmse.n

groff_mm.n: ../VERSION

tar:
	tar cvf mm.tar tmac* mm *.man Makefile ChangeLog README
clean:
	-rm -f groff_mm.n groff_mmse.n

distclean: clean
realclean: distclean

TAGS:

install.nobin: install.m all
	-[ -d $(MACRODIR)/mm ] || mkdir $(MACRODIR)/mm
	for f in $(FILES); do \
	rm -f $(MACRODIR)/mm/$$f; \
	cp mm/$$f $(MACRODIR)/mm; \
	done
	-[ -d $(MAN7DIR) ] || mkdir $(MAN7DIR)
	-rm -f $(MAN7DIR)/groff_mm.$(MAN7EXT)
	cp groff_mm.n $(MAN7DIR)/groff_mm.$(MAN7EXT)
	-rm -f $(MAN7DIR)/groff_mmse.$(MAN7EXT)
	cp groff_mmse.n $(MAN7DIR)/groff_mmse.$(MAN7EXT)

install.m:
	-[ -d $(MACRODIR) ] || mkdir $(MACRODIR)
	-rm -f $(MACRODIR)/tmac.$(TMAC_M)
	cp tmac.m $(MACRODIR)/tmac.$(TMAC_M)
	-rm -f $(MACRODIR)/tmac.$(TMAC_M)se
	sed 's/@TMAC_M@/$(TMAC_M)/' tmac.mse >$(MACRODIR)/tmac.$(TMAC_M)se

install.bin:

install: install.bin install.nobin

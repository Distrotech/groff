# Copyright (C) 1989-2002 Free Software Foundation, Inc.
#      Written by James Clark (jjc@jclark.com)
#
# This file is part of groff.
#
# groff is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 2, or (at your option) any later
# version.
#
# groff is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with groff; see the file COPYING.  If not, write to the Free Software
# Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

# This is set up so you can do:
#   make -f generate/Makefile
# in the parent directory of the directory containing this file.

# Note that the following font files have manually added kerning values for
# `` and '': B, BI, I, R.

srcdir=generate
tfmdir=/usr/local/lib/groff-tfm
gfdir=/usr/local/lib/groff-gf

TFMTODIT=tfmtodit
FONTS=TR TI TB TBI CW CWI MI S EX HR HI HB HBI SA SB
SPECIALFLAG=-s

all: $(FONTS)

# TR is special because it contains \(pl \(eq

TR: $(srcdir)/texr.map
	$(TFMTODIT) $(SPECIALFLAG) -g $(gfdir)/cmr10.300gf \
	  $(tfmdir)/cmr10.tfm $(srcdir)/texr.map $@

# TI is special because it contains \(Po

TI: $(srcdir)/texi.map
	$(TFMTODIT) $(SPECIALFLAG) -g $(gfdir)/cmti10.300gf \
	  $(tfmdir)/cmti10.tfm $(srcdir)/texi.map $@

TB: $(srcdir)/texb.map
	$(TFMTODIT) -g $(gfdir)/cmbx10.300gf \
	  $(tfmdir)/cmbx10.tfm $(srcdir)/texb.map $@

TBI: $(srcdir)/texi.map
	$(TFMTODIT) -g $(gfdir)/cmbxti10.300gf \
	  $(tfmdir)/cmbxti10.tfm $(srcdir)/texi.map $@

# CW is special because it contains "

CW: $(srcdir)/textt.map
	$(TFMTODIT) $(SPECIALFLAG) \
	  $(tfmdir)/cmtt10.tfm $(srcdir)/textt.map $@

CWI: $(srcdir)/textt.map
	$(TFMTODIT) \
	  $(tfmdir)/cmitt10.tfm $(srcdir)/textt.map $@

MI: $(srcdir)/texmi.map
	$(TFMTODIT) $(SPECIALFLAG) -k 0177 \
	  $(tfmdir)/cmmi10.tfm $(srcdir)/texmi.map $@

S: $(srcdir)/texsy.map
	$(TFMTODIT) $(SPECIALFLAG) -k 060 \
	  $(tfmdir)/cmsy10.tfm $(srcdir)/texsy.map $@

EX: $(srcdir)/texex.map
	$(TFMTODIT) $(SPECIALFLAG) \
	  $(tfmdir)/cmex10.tfm $(srcdir)/texex.map $@

HR: $(srcdir)/texb.map
	$(TFMTODIT) -g $(gfdir)/cmss10.300gf \
	  $(tfmdir)/cmss10.tfm $(srcdir)/texb.map $@

HB: $(srcdir)/texb.map
	$(TFMTODIT) -g $(gfdir)/cmssbx10.300gf \
	  $(tfmdir)/cmssbx10.tfm $(srcdir)/texb.map $@

HI: $(srcdir)/texb.map
	$(TFMTODIT) -g $(gfdir)/cmssi10.300gf \
	  $(tfmdir)/cmssi10.tfm $(srcdir)/texb.map $@

HBI: $(srcdir)/texb.map
	$(TFMTODIT) -g $(gfdir)/cmssbxo10.300gf \
	  $(tfmdir)/cmssbxo10.tfm $(srcdir)/texb.map $@

SA: $(srcdir)/msam.map
	$(TFMTODIT) $(SPECIALFLAG) \
	  $(tfmdir)/msam10.tfm $(srcdir)/msam.map $@

SB: $(srcdir)/msbm.map
	$(TFMTODIT) $(SPECIALFLAG) \
	  $(tfmdir)/msbm10.tfm $(srcdir)/msbm.map $@

clean:

realclean:
	-rm -f $(FONTS)

extraclean: realclean
	-rm -f core *~ "#*"

.PHONY: clean realclean extraclean all

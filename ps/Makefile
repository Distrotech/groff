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

# define PAGE to be letter if your PostScript printer uses 8.5x11 paper (USA)
# and define it to be A4, if it uses A4 paper (rest of the world)
PAGE=A4
#PAGE=letter
BINDIR=/usr/local/bin
CC=g++
BROKEN_SPOOLER_FLAGS=0
CFLAGS=-g
OLDCC=gcc
OLDCFLAGS=-g
MLIBS=-lm
INCLUDES=-I../driver -I../lib
LDFLAGS=-g
OBJECTS=ps.o psrm.o
SOURCES=ps.c psrm.c ps.h
MISC=Makefile devgps
BINDIR=/usr/local/bin
FONTDIR=/usr/local/lib/groff/font
MACRODIR=/usr/local/lib/groff/tmac
ETAGS=etags
ETAGSFLAGS=-p

.c.o:
	$(CC) -c $(INCLUDES) $(CFLAGS) $<

all: grops psbb pfbtops devps 

grops: $(OBJECTS) ../driver/libdriver.a ../lib/libgroff.a
	$(CC) $(LDFLAGS) -o $@ $(OBJECTS) \
	../driver/libdriver.a ../lib/libgroff.a $(MLIBS)

ps.o: broken.h ps.h ../driver/printer.h ../driver/driver.h ../lib/font.h \
      ../lib/stringclass.h ../lib/cset.h

psrm.o: ps.h ../driver/printer.h ../driver/driver.h ../lib/font.h \
      ../lib/stringclass.h ../lib/cset.h

broken.h: FORCE
	@echo \#define BROKEN_SPOOLER_FLAGS $(BROKEN_SPOOLER_FLAGS) >broken.h.n
	@cmp -s broken.h broken.h.n || cp broken.h.n broken.h
	@rm -f broken.h.n

psbb: psbb.o
	$(OLDCC) $(LDFLAGS) -o $@ psbb.o

psbb.o: psbb.c
	$(OLDCC) $(OLDCFLAGS) -c psbb.c

pfbtops: pfbtops.o
	$(OLDCC) $(LDFLAGS) -o $@ pfbtops.o

pfbtops.o: pfbtops.c
	$(OLDCC) $(OLDCFLAGS) -c pfbtops.c

saber_grops:
	#load $(INCLUDES) $(CFLAGS) $(DEFINES) ps.c psrm.c \
	../driver/libdriver.a ../lib/libgroff.a -lm

install.bin: grops psbb
	-[ -d $(BINDIR) ] || mkdir $(BINDIR)
	-rm -f $(BINDIR)/grops $(BINDIR)/psbb
	cp grops psbb pfbtops $(BINDIR)
	@cd devps; \
	$(MAKE) \
	"FONTDIR=$(FONTDIR)" "PAGE=$(PAGE)" "BINDIR=$(BINDIR)" install.bin

install.nobin:
	-[ -d $(MACRODIR) ] || mkdir $(MACRODIR)
	-rm -f $(MACRODIR)/tmac.ps
	cp tmac.ps $(MACRODIR)
	-rm -f $(MACRODIR)/tmac.psatk
	cp tmac.psatk $(MACRODIR)
	@echo Making install.nobin in devps
	@cd devps; \
	$(MAKE) \
	"FONTDIR=$(FONTDIR)" "PAGE=$(PAGE)" "BINDIR=$(BINDIR)" install.nobin

install: install.bin install.nobin


TAGS : $(SOURCES)
	$(ETAGS) $(ETAGSFLAGS) $(SOURCES)

clean:
	-rm -f *.o psbb core grops broken.h

distclean: clean
	-rm -f TAGS

realclean: distclean

devps: FORCE
	@echo Making all in devps
	@cd devps; $(MAKE) "FONTDIR=$(FONTDIR)" "PAGE=$(PAGE)" all

FORCE:

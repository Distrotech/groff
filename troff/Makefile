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

MACROPATH=.:/usr/local/lib/groff/tmac:/usr/lib/tmac
# DEVICE is the default device
DEVICE=ps
HYPHENFILE=/usr/local/lib/groff/hyphen
BINDIR=/usr/local/bin
INCLUDES=-I../lib
CC=g++
MLIBS=-lm
CFLAGS=-g -O -Wall #-DOP_DELETE_BROKEN
LDFLAGS=-g
ETAGS=etags
ETAGSFLAGS=-p
OBJECTS=env.o node.o input.o div.o column.o symbol.o dictionary.o \
	reg.o number.o majorminor.o # dump.o unexec.o

SOURCES=env.c node.c input.c div.c column.c symbol.c dictionary.c \
	number.c reg.c majorminor.c

HEADERS=troff.h hvunits.h symbol.h dictionary.h env.h reg.h  \
	token.h charinfo.h div.h node.h request.h

TROFF_H=troff.h ../lib/errarg.h ../lib/error.h ../lib/cset.h ../lib/lib.h

.c.o:
	$(CC) -c $(INCLUDES) $(CFLAGS) $<

all: troff

troff: $(OBJECTS) ../lib/libgroff.a
	$(CC) $(LDFLAGS) -o $@ $(OBJECTS) ../lib/libgroff.a $(MLIBS)

majorminor.c: ../VERSION
	@echo Making $@
	@-rm -f $@
	@echo const char \*major_version = \
	\"`sed -e 's/^\(.*\)\..*$$/\1/' ../VERSION`\"\; >$@
	@echo const char \*minor_version = \
	\"`sed -e 's/^.*\.\(.*\)$$/\1/' ../VERSION`\"\; >>$@

dictionary.o: dictionary.h $(TROFF_H) symbol.h
symbol.o: $(TROFF_H) symbol.h
number.o: div.h env.h $(TROFF_H) hvunits.h symbol.h token.h
reg.o : $(TROFF_H) symbol.h dictionary.h token.h request.h reg.h
div.o: dictionary.h div.h env.h $(TROFF_H) hvunits.h \
	node.h reg.h request.h symbol.h token.h
env.o:  charinfo.h dictionary.h div.h env.h $(TROFF_H) \
	hvunits.h node.h reg.h request.h symbol.h token.h
input.o: config.h charinfo.h dictionary.h div.h env.h $(TROFF_H) \
	hvunits.h node.h reg.h request.h symbol.h token.h
node.o: charinfo.h dictionary.h env.h reg.h \
	$(TROFF_H) hvunits.h node.h request.h symbol.h \
	token.h ../lib/font.h
column.o: dictionary.h div.h env.h $(TROFF_H) hvunits.h \
	node.h reg.h request.h symbol.h token.h ../lib/stringclass.h

config.h: FORCE
	@echo \#define MACROPATH \"$(MACROPATH)\" >config.h.n
	@echo \#define HYPHENFILE \"$(HYPHENFILE)\" >>config.h.n
	@echo \#define DEVICE \"$(DEVICE)\" >>config.h.n
	@cmp -s config.h config.h.n || cp config.h.n config.h
	@rm -f config.h.n

TAGS : $(SOURCES)
	$(ETAGS) $(ETAGSFLAGS) $(SOURCES) $(HEADERS)

saber_troff:
	@#load $(INCLUDES) $(CFLAGS) $(DEFINES) $(SOURCES) \
	../lib/libgroff.a -lm

clean:
	-rm -f *.o core troff gmon.out mon.out majorminor.c config.h

distclean: clean
	-rm -f TAGS

realclean: distclean

install.bin : troff
	-[ -d $(BINDIR) ] || mkdir $(BINDIR)
	-rm -f $(BINDIR)/gtroff
	cp troff $(BINDIR)/gtroff

install.nobin:  hyphen
	-rm -f $(HYPHENFILE)
	cp hyphen $(HYPHENFILE)

install: install.bin install.nobin

# dump.o: dump.c config.h
#	cc -g $(DUMPFLAG) -c dump.c
#
# unexec.o: unexec.c config.h
#	cc -g $(DUMPFLAG) -I../lib -c unexec.c

FORCE:

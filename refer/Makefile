#Copyright (C) 1991 Free Software Foundation, Inc.
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

# BINDIR says where to install the executables.
BINDIR=/usr/local/bin
# CC is the C++ compiler.
CC=g++
# OLDCC is the C compiler.
OLDCC=gcc
# Suffix to be used for index files.
INDEX_SUFFIX=.i
# Directory containing the default index.
DEFAULT_INDEX_DIR=/usr/dict/papers
# The filename (without suffix) of the default index.
DEFAULT_INDEX_NAME=Ind
# COMMON_WORDS_FILE is a file containing a list of common words.
# If your system provides /usr/lib/eign it will be copied onto this,
# otherwise the supplied eign file will be used.
COMMON_WORDS_FILE=/usr/local/lib/groff/eign
# Uncomment this if the POSIX pathconf() function is missing.
PATHCONF_MISSING=#-DPATHCONF_MISSING

CFLAGS=-g -O -Wall #-DHAVE_MMAP -DHAVE_RENAME -DPATHCONF_MISSING
LDFLAGS=-g
INCLUDES=-I../lib
OLDCFLAGS=-g
LIBS=
MLIBS=$(LIBS) -lm
# YACC can be either yacc or bison -y
YACC=bison -y
YACCFLAGS=-v
ETAGS=etags
ETAGSFLAGS=-p

PROGS=refer lookbib indxbib lkbib

INDXBIB_OBJECTS=indxbib.o common.o dirnamemax.o ../lib/libgroff.a
LOOKBIB_OBJECTS=lookbib.o search.o linear.o index.o common.o \
	../lib/libgroff.a
REFER_OBJECTS=refer.o ref.o token.o search.o linear.o index.o \
	label.tab.o command.o common.o ../lib/libgroff.a
LKBIB_OBJECTS=lkbib.o search.o linear.o index.o common.o ../lib/libgroff.a

.c.o:
	$(CC) -c $(INCLUDES) $(CFLAGS) $<

all: $(PROGS)

refer: $(REFER_OBJECTS)
	$(CC) $(LDFLAGS) -o $@ $(REFER_OBJECTS) $(MLIBS)

indxbib: $(INDXBIB_OBJECTS)
	$(CC) $(LDFLAGS) -o $@ $(INDXBIB_OBJECTS) $(MLIBS)

lookbib: $(LOOKBIB_OBJECTS)
	$(CC) $(LDFLAGS) -o $@ $(LOOKBIB_OBJECTS) $(MLIBS)

lkbib: $(LKBIB_OBJECTS)
	$(CC) $(LDFLAGS) -o $@ $(LKBIB_OBJECTS) $(MLIBS)

label.tab.c: label.y
	$(YACC) $(YACCFLAGS) label.y
	mv y.tab.c label.tab.c

dirnamemax.o: dirnamemax.c
	defs=; \
	if [ -f /usr/include/limits.h ]; \
	then defs=-DHAVE_LIMITS_H; \
	fi; \
	if [ -f /usr/include/dirent.h ]; \
	then defs="$$defs -DHAVE_DIRENT_H"; \
	elif [ -f /usr/include/sys/dir.h ]; \
	then defs="$$defs -DHAVE_SYS_DIR_H"; \
	fi; \
	$(OLDCC) $(OLDCFLAGS) -c $$defs $(PATHCONF_MISSING) dirnamemax.c

suffix.h: FORCE
	@$(SHELL) ../gendef $@ "INDEX_SUFFIX=\"$(INDEX_SUFFIX)\""

path.h: FORCE
	@$(SHELL) ../gendef $@ \
	"COMMON_WORDS_FILE=\"$(COMMON_WORDS_FILE)\"" \
	"DEFAULT_INDEX_DIR=\"$(DEFAULT_INDEX_DIR)\"" \
	"DEFAULT_INDEX_NAME \"$(DEFAULT_INDEX_NAME)\""

index.o: refid.h search.h index.h suffix.h ../lib/lib.h ../lib/cset.h \
	../lib/cmap.h ../lib/errarg.h ../lib/error.h
indxbib.o: refer.h path.h index.h suffix.h \
	../lib/errarg.h ../lib/error.h ../lib/cset.h ../lib/cmap.h \
	../lib/stringclass.h ../lib/lib.h
linear.o: refid.h search.h ../lib/lib.h ../lib/errarg.h \
	../lib/error.h ../lib/cset.h ../lib/cmap.h
lookbib.o: refid.h search.h ../lib/errarg.h ../lib/error.h \
	../lib/lib.h ../lib/cset.h
ref.o: refer.h path.h refid.h ref.h token.h ../lib/errarg.h \
	../lib/error.h ../lib/lib.h ../lib/stringclass.h \
	../lib/cset.h ../lib/cmap.h
refer.o: refer.h path.h refid.h ref.h token.h search.h command.h \
	../lib/errarg.h ../lib/error.h ../lib/lib.h \
	../lib/stringclass.h ../lib/cset.h ../lib/cmap.h
command.o: refer.h path.h command.h refid.h search.h ../lib/lib.h \
	../lib/cset.h ../lib/cmap.h ../lib/errarg.h ../lib/error.h
search.o: refid.h search.h ../lib/lib.h ../lib/errarg.h \
	../lib/error.h
token.o: refer.h path.h token.h ../lib/errarg.h ../lib/error.h \
	../lib/lib.h ../lib/stringclass.h ../lib/cset.h \
	../lib/cmap.h
label.tab.o: refer.h path.h refid.h ref.h token.h \
	../lib/errarg.h ../lib/error.h ../lib/lib.h \
	../lib/stringclass.h ../lib/cset.h ../lib/cmap.h
lkbib.o: refer.h path.h refid.h search.h ../lib/errarg.h ../lib/error.h \
	../lib/lib.h ../lib/cset.h ../lib/cmap.h \
	../lib/stringclass.h 

clean:
	-rm -f *.o $(PROGS) core a.out *.n gmon.out path.h suffix.h y.output

distclean: clean
	-rm -f TAGS

realclean: distclean
	-rm -f label.tab.c
	
install.bin: $(PROGS)
	-[ -d $(BINDIR) ] || mkdir $(BINDIR)
	-rm -f $(BINDIR)/grefer
	cp refer $(BINDIR)/grefer
	-rm -f $(BINDIR)/gindxbib
	cp indxbib $(BINDIR)/gindxbib
	-rm -f $(BINDIR)/glookbib
	cp lookbib $(BINDIR)/glookbib
	-rm -f $(BINDIR)/lkbib
	cp lkbib $(BINDIR)/lkbib


install.nobin:
	@if [ -f /usr/lib/eign ]; \
	then echo cp /usr/lib/eign $(COMMON_WORDS_FILE); \
	rm -f $(COMMON_WORDS_FILE); \
	cp /usr/lib/eign $(COMMON_WORDS_FILE); \
	else echo cp eign $(COMMON_WORDS_FILE); \
	rm -f $(COMMON_WORDS_FILE); \
	cp eign $(COMMON_WORDS_FILE); fi

install: install.bin install.nobin

FORCE:

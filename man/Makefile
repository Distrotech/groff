#Copyright (C) 1990, 1991 Free Software Foundation, Inc.
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

MANROOT=/usr/local/man
# MAN1EXT is the man section for user commands
MAN1EXT=1
MAN1DIR=$(MANROOT)/man$(MAN1EXT)
# MAN5EXT is the man section for file formats
MAN5EXT=5
MAN5DIR=$(MANROOT)/man$(MAN5EXT)
# MAN7EXT is the man section for macros
MAN7EXT=7
MAN7DIR=$(MANROOT)/man$(MAN7EXT)
# FONTDIR says where to install dev*/*
FONTDIR=/usr/local/lib/groff/font
# FONTPATH says where to look for dev*/*
FONTPATH=.:$(FONTDIR):/usr/lib/font
MACRODIR=/usr/local/lib/groff/tmac
# MACROPATH says where to look for tmac.* macro files
MACROPATH=.:$(MACRODIR):/usr/lib/tmac
# DEVICE is the default device
DEVICE=ps
# HYPHENFILE is the file containing the hyphenation patterns
HYPHENFILE=/usr/local/lib/groff/hyphen
# Suffix to be used for refer index files.
INDEX_SUFFIX=.i
# Directory containing the default refer index.
DEFAULT_INDEX_DIR=/usr/dict/papers
# The filename (without suffix) of the default refer index.
DEFAULT_INDEX_NAME=Ind
# COMMON_WORDS_FILE is a file containing a list of common words.
COMMON_WORDS_FILE=/usr/local/lib/eign
TMAC_S=gs
BROKEN_SPOOLER_FLAGS=0
SHELL=/bin/sh
MAN1PAGES=gtroff.n gpic.n grops.n groff.n geqn.n gtbl.n psbb.n gsoelim.n \
	addftinfo.n grodvi.n grotty.n tfmtodit.n afmtodit.n grog.n \
	grefer.n gindxbib.n glookbib.n lkbib.n pfbtops.n
MAN5PAGES=groff_font.n groff_out.n
MAN7PAGES=groff_me.n groff_ms.n
MANPAGES= $(MAN1PAGES) $(MAN5PAGES) $(MAN7PAGES)

.SUFFIXES: .man .n

.man.n:
	@echo Making $@ from $<
	@-rm -f $@
	@sed -e "s;@HYPHENFILE@;$(HYPHENFILE);g" \
	-e "s;@FONTDIR@;$(FONTDIR);g" \
	-e "s;@FONTPATH@;$(FONTPATH);g" \
	-e "s;@MACRODIR@;$(MACRODIR);g" \
	-e "s;@MACROPATH@;$(MACROPATH);g" \
	-e "s;@DEVICE@;$(DEVICE);g" \
	-e "s;@DEFAULT_INDEX@;$(DEFAULT_INDEX_DIR)/$(DEFAULT_INDEX_NAME);g" \
	-e "s;@DEFAULT_INDEX_NAME@;$(DEFAULT_INDEX_NAME);g" \
	-e "s;@INDEX_SUFFIX@;$(INDEX_SUFFIX);g" \
	-e "s;@COMMON_WORDS_FILE@;$(COMMON_WORDS_FILE);g" \
	-e "s;@MAN1EXT@;$(MAN1EXT);g" \
	-e "s;@MAN5EXT@;$(MAN5EXT);g" \
	-e "s;@MAN7EXT@;$(MAN7EXT);g" \
	-e "s;@TMAC_S@;$(TMAC_S);g" \
	-e "s;@BROKEN_SPOOLER_FLAGS@;$(BROKEN_SPOOLER_FLAGS);g" \
	-e "s;@VERSION@;`cat ../VERSION`;g" \
	-e "s;@MDATE@;`$(SHELL) mdate.sh $<`;g" \
	$< >$@
	@chmod 444 $@

all: $(MANPAGES)

install.nobin: $(MANPAGES)
	-[ -d $(MAN1DIR) ] || mkdir $(MAN1DIR)
	-[ -d $(MAN5DIR) ] || mkdir $(MAN5DIR)
	-[ -d $(MAN7DIR) ] || mkdir $(MAN7DIR)
	@for page in $(MAN1PAGES) ; do \
	target=$(MAN1DIR)/`basename $$page .n`.$(MAN1EXT); \
	rm -f $$target ; \
	echo cp $$page $$target ; \
	cp $$page $$target ; \
	done
	@for page in $(MAN5PAGES) ; do \
	target=$(MAN5DIR)/`basename $$page .n`.$(MAN5EXT); \
	rm -f $$target ; \
	echo cp $$page $$target ; \
	cp $$page $$target ; \
	done
	@for page in $(MAN7PAGES) ; do \
	target=$(MAN7DIR)/`basename $$page .n`.$(MAN7EXT); \
	rm -f $$target ; \
	echo cp $$page $$target ; \
	cp $$page $$target ; \
	done

$(MANPAGES): ../VERSION

install.bin:

install: install.bin install.nobin

clean:
	-rm -f $(MANPAGES)

distclean: clean

realclean: clean

TAGS:

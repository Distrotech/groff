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

# Read this Makefile up to the line that says:
# End of configuration section.

# Define PAGE to be letter if your PostScript printer uses 8.5x11 paper (USA)
# and define it to be A4, if it uses A4 paper (rest of the world).
PAGE=A4
#PAGE=letter

# BINDIR says where to install executables.
BINDIR=/usr/local/bin

GROFFLIBDIR=/usr/local/lib/groff

# FONTDIR says where to install dev*/*.
FONTDIR=$(GROFFLIBDIR)/font

# FONTPATH says where to look for dev*/*.
FONTPATH=.:$(FONTDIR):/usr/local/lib/font:/usr/lib/font

# MACRODIR says where to install macros.
MACRODIR=$(GROFFLIBDIR)/tmac

# MACROPATH says where to look for macro files.
MACROPATH=.:$(MACRODIR):/usr/lib/tmac

# DEVICE is the default device.
DEVICE=ps

# PSPRINT is the command to use for printing a PostScript file.
# It must be a simple command, not a pipeline.
PSPRINT=lpr

# DVIPRINT is the command to use for printing a TeX dvi file.
# It must be a simple command, not a pipeline.
DVIPRINT=lpr -d

# HYPHENFILE is the file containing the hyphenation patterns.
HYPHENFILE=$(GROFFLIBDIR)/hyphen

# Suffix to be used for refer index files.  Index files are not
# shareable between different architectures, so you might want to use
# different suffixes for different architectures.  Choose a suffix
# that doesn't conflict with refer or any other indexing program.
INDEX_SUFFIX=.i

# Directory containing the default index for refer.
DEFAULT_INDEX_DIR=/usr/dict/papers

# The filename (without suffix) of the default index for refer.
DEFAULT_INDEX_NAME=Ind

# COMMON_WORDS_FILE is a file containing a list of common words.
# If your system provides /usr/lib/eign it will be copied onto this,
# otherwise the supplied eign file will be used.
COMMON_WORDS_FILE=$(GROFFLIBDIR)/eign

# MANROOT is the root of the man page directory tree.
MANROOT=/usr/local/man

# MAN1EXT is the man section for user commands.
MAN1EXT=1
MAN1DIR=$(MANROOT)/man$(MAN1EXT)

# MAN5EXT is the man section for file formats.
MAN5EXT=5
MAN5DIR=$(MANROOT)/man$(MAN5EXT)

# MAN7EXT is the man section for macros.
MAN7EXT=7
MAN7DIR=$(MANROOT)/man$(MAN7EXT)

# The groff ms macros will be available as -m$(TMAC_S).
# If you use `TMAC_S=s', you can use the Unix ms macros by using
# groff -ms -M/usr/lib/tmac.
TMAC_S=gs

# Similarily, the groff mm macros will be available as -m$(TMAC_M).
TMAC_M=gm

# Normally the Postscript driver, grops, produces output that conforms
# to version 3.0 of the Adobe Document Structuring Conventions.
# Unfortunately some spoolers and previewers can't handle such output.
# The BROKEN_SPOOLER_FLAGS variable tells grops what it should do to
# make its output acceptable to such programs.  This variable controls
# only the default behaviour of grops; the behaviour can be changed at
# runtime by the grops -b option (and so by groff -P-b).
# Use a value of 0 if your spoolers and previewers are able to handle
# conforming PostScript correctly.
# Add 1 if no %%{Begin,End}DocumentSetup comments should be generated;
# this is needed for early versions of TranScript that get confused by
# anything between the %%EndProlog line and the first %%Page: comment.
# Add 2 if lines in included files beginning with %! should be
# stripped out; this is needed for Sun's pageview previewer.
# Add 4 if %%Page, %%Trailer and %%EndProlog comments should be
# stripped out of included files; this is needed for spoolers that
# don't understand the %%{Begin,End}Document comments. I suspect this
# includes early versions of TranScript.
# A value of 7 is equivalent to -DBROKEN_SPOOLER of earlier releases.
BROKEN_SPOOLER_FLAGS=7

# Uncomment the next line if you are using AT&T C++ 2.0 with an ANSI C
# compiler backend.
D1=#-DCFRONT_ANSI_BUG

# Uncomment the next line if you have vfork().
D2=#-DHAVE_VFORK

# Uncomment the next line if you have sys_siglist[].
D3=#-DHAVE_SYS_SIGLIST

# Uncomment the next line if you have the mmap() system call (and you
# want to use it).
D4=#-DHAVE_MMAP

# Uncomment the next line if you have the rename() system call.
D5=#-DHAVE_RENAME

# Uncomment the next line if the argument to localtime() is a long*
# rather than a time_t*.
D6=#-DLONG_FOR_TIME_T

# Uncomment the next line if wait is declared by your C++ header files
# to take an argument of type union wait *.
D7=#-DHAVE_UNION_WAIT

# Uncoment the next line if your C++ header files declare a type pid_t
# which is used as the return type of fork() and wait().
D8=#-DHAVE_PID_T

# Uncomment the next line if the 0200 bit of the status returned by
# wait() indicates whether a core image was produced for a process
# that was terminated by a signal.  This is true for traditional Unix
# implementations, but not necessarily for all POSIX systems.
D9=-DWAIT_COREDUMP_0200

# Uncomment the next line if <sys/wait.h> should not be included
# when using wait().  Use this with the libg++ header files.
D10=-DNO_SYS_WAIT_H

# Uncomment the next line if you do not have the POSIX pathconf()
# function.  You will need this on old UNIX systems that do not
# support POSIX.
PATHCONF_MISSING=#-DPATHCONF_MISSING

# Uncomment the next line if you don't have fmod in your math library.
# I believe this is needed on old versions of Ultrix and BSD 4.3.
FMOD=#fmod.o

# Uncomment the next line if you don't have strtol in your C library.
# I believe this is needed on BSD 4.3.
STRTOL=#strtol.o

# Uncomment the next line if you don't have getcwd in your library.
# An emulation in terms of getwd() will be provided. I believe this
# is needed on BSD 4.3.
GETCWD=#getcwd.o

# Additional flags needed to compile the GNU Emacs malloc.
# Use this with BSD.
# MALLOCFLAGS=-DBSD
# Use this with System V
# MALLOCFLAGS=-DUSG
# Use this with SunOS 4.1 and 4.1.1.
MALLOCFLAGS=-DBSD -DSUNOS_LOCALTIME_BUG

# Comment this out if the GNU malloc gives you problems, or if you would
# prefer to use the system malloc.
MALLOC=malloc.o

GROFF=
# Comment the next line out if groff.c gives problems.
GROFF=groff

# There is a new version of the grog program written in perl.  This is
# a little more capable than the previous version which was written in
# shell; in particular, it can distinguish files that need to be run
# through pic/eqn/tbl from files that have already been run through
# pic/eqn/tbl.  You can only use this version if you have perl
# available.  The first line of the perl program is `#!/usr/bin/perl';
# if your system doesn't support `#!' or if there is no link to perl
# in /usr/bin you'll have to edit etc/grog.pl by hand.
# The next line should be uncommented if you want to use the old shell
# version.
GROG=grog.sh
# The next line should be uncommented if you want to use the new perl
# version.
# GROG=grog.pl

# CC is the C++ compiler
CC=g++
# I'm told that -fno-inline is needed on a 68030-based Apollo
# CC=g++ -fno-inline

# OLDCC is the C compiler.
OLDCC=gcc

PROFILE_FLAG=
DEBUG_FLAG=
OPTIMIZE_FLAG=-O
WARNING_FLAGS=#-Wall -Wcast-qual -Wwrite-strings

# Use this to pass additional flags on the command line.
XCFLAGS=

# CFLAGS are passed to sub makes
CFLAGS=$(PROFILE_FLAG) $(DEBUG_FLAG) $(OPTIMIZE_FLAG) $(WARNING_FLAGS) \
$(D1) $(D2) $(D3) $(D4) $(D5) $(D6) $(D7) $(D8) $(D9) $(D10) $(XCFLAGS)

XOLDCFLAGS=
# OLDCFLAGS are passed to sub makes
OLDCFLAGS=$(DEBUG_FLAG) $(PROFILE_FLAG) $(OPTIMIZE_FLAG) $(XOLDCFLAGS)

XLDFLAGS=
LDFLAGS=$(PROFILE_FLAG) $(DEBUG_FLAG) $(XLDFLAGS)
# Libraries needed for linking C++ programs.
LIBS=
# Libraries needed for linking C++ programs that use libm.a.
MLIBS=$(LIBS) -lm

AR=ar

# Define RANLIB to be empty if you don't have ranlib.
RANLIB=ranlib

# YACC can be either yacc or bison -y
YACC=bison -y
YACCFLAGS=-v

ETAGS=etags
# Flag to make etags treat *.[ch] files as C++
ETAGSFLAGS=-p

# End of configuration section.
# You shouldn't need to change anything after this point.

SHELL=/bin/sh

SUBDIRS=lib troff pic tbl eqn refer etc driver ps tty dvi macros man mm

# SUBFLAGS says what flags to pass to sub makes
SUBFLAGS="SHELL=$(SHELL)" "CC=$(CC)" "CFLAGS=$(CFLAGS)" "LDFLAGS=$(LDFLAGS)" \
	"OLDCC=$(OLDCC)" "OLDCFLAGS=$(OLDCFLAGS)" \
	"YACC=$(YACC)" "YACCFLAGS=$(YACCFLAGS)" \
	"DEVICE=$(DEVICE)" "FONTPATH=$(FONTPATH)" "MACROPATH=$(MACROPATH)" \
	"MALLOCFLAGS=$(MALLOCFLAGS)" "MALLOC=$(MALLOC)" \
	"FMOD=$(FMOD)" "STRTOL=$(STRTOL)" "GETCWD=$(GETCWD)" "GROG=$(GROG)" \
	"AR=$(AR)" "RANLIB=$(RANLIB)" "LIBS=$(LIBS)" "MLIBS=$(MLIBS)" \
	"FONTDIR=$(FONTDIR)" "BINDIR=$(BINDIR)" "PAGE=$(PAGE)" \
	"MACRODIR=$(MACRODIR)" "HYPHENFILE=$(HYPHENFILE)" \
	"TMAC_S=$(TMAC_S)" "TMAC_M=$(TMAC_M)" "MAN1EXT=$(MAN1EXT)" \
	"MAN1DIR=$(MAN1DIR)" "MAN5EXT=$(MAN5EXT)" "MAN5DIR=$(MAN5DIR)" \
	"MAN7EXT=$(MAN7EXT)" "MAN7DIR=$(MAN7DIR)" \
	"BROKEN_SPOOLER_FLAGS=$(BROKEN_SPOOLER_FLAGS)" \
	"INDEX_SUFFIX=$(INDEX_SUFFIX)" \
	"DEFAULT_INDEX_DIR=$(DEFAULT_INDEX_DIR)" \
	"DEFAULT_INDEX_NAME=$(DEFAULT_INDEX_NAME)" \
	"COMMON_WORDS_FILE=$(COMMON_WORDS_FILE)" \
	"PATHCONF_MISSING=$(PATHCONF_MISSING)"

INCLUDES=-Ilib

.c.o:
	$(CC) -c $(INCLUDES) $(CFLAGS) $<

all: $(SUBDIRS) $(GROFF) shgroff

$(SUBDIRS): FORCE
	@cd $@; \
	echo Making all in $@; \
	$(MAKE) $(SUBFLAGS) all

troff pic tbl eqn refer etc ps tty dvi: lib
ps tty dvi: driver

TAGS: FORCE
	@for dir in $(SUBDIRS); do \
	echo Making TAGS in $$dir; \
	(cd $$dir; $(MAKE) "ETAGSFLAGS=$(ETAGSFLAGS)" "ETAGS=$(ETAGS)" TAGS); \
	done

topclean: FORCE
	-rm -f shgroff
	-rm -f groff *.o core device.h

clean: topclean FORCE
	@for dir in $(SUBDIRS) doc; do \
	echo Making clean in $$dir; \
	(cd $$dir; $(MAKE) clean); done

distclean: topclean FORCE
	@for dir in $(SUBDIRS) doc; do \
	echo Making distclean in $$dir; \
	(cd $$dir; $(MAKE) distclean); done

# You really don't want to use this target.
realclean: topclean FORCE
	@for dir in $(SUBDIRS) doc; do \
	echo Making realclean in $$dir; \
	(cd $$dir; $(MAKE) realclean); done

install.nobin: FORCE shgroff
	-[ -d $(BINDIR) ] || mkdir $(BINDIR)
	-[ -d $(GROFFLIBDIR) ] || mkdir $(GROFFLIBDIR)
	-[ -d $(MANROOT) ] || mkdir $(MANROOT)
	@for dir in $(SUBDIRS); do \
	echo Making install.nobin in $$dir; \
	(cd $$dir; $(MAKE) $(SUBFLAGS) install.nobin); done
	-if [ -z "$(GROFF)" ] ; \
	then rm -f $(BINDIR)/groff ; \
	cp shgroff $(BINDIR)/groff ; fi

install.bin: FORCE $(GROFF)
	-[ -d $(BINDIR) ] || mkdir $(BINDIR)
	@for dir in $(SUBDIRS); do \
	echo Making install.bin in $$dir; \
	(cd $$dir; $(MAKE) $(SUBFLAGS) install.bin); done
	-if [ -n "$(GROFF)" ] ; \
	then rm -f $(BINDIR)/groff ; \
	cp groff $(BINDIR)/groff ; fi

install: install.bin install.nobin

install.dwbmm: FORCE
	-[ -d $(GROFFLIBDIR) ] || mkdir $(GROFFLIBDIR)
	-[ -d $(MACRODIR) ] || mkdir $(MACRODIR)
	-rm -f $(MACRODIR)/tmac.m
	sed -f macros/fixmacros.sed -e 's;/usr/lib/tmac;$(MACRODIR);' \
	    /usr/lib/macros/mmt >$(MACRODIR)/tmac.m
	-rm -f $(MACRODIR)/sys.name
	sed -f macros/fixmacros.sed /usr/lib/tmac/sys.name \
	    >$(MACRODIR)/sys.name
	patch -s $(MACRODIR)/tmac.m macros/mm.diff

shgroff: groff.sh
	@echo Making $@ from groff.sh
	@-rm -f $@
	@sed -e "s;@BINDIR@;$(BINDIR);g" \
	-e "s;@DEVICE@;$(DEVICE);g" \
	-e "s;@PROG_PREFIX@;$(PROG_PREFIX);g" \
	-e "s;@FONTDIR@;$(FONTDIR);g" \
	-e "s;@PSPRINT@;$(PSPRINT);g" \
	-e "s;@DVIPRINT@;$(DVIPRINT);g" \
	groff.sh >$@ || rm -f $@
	@chmod +x $@

groff: groff.o lib/libgroff.a
	$(CC) $(LDFLAGS) -o $@ groff.o lib/libgroff.a $(LIBS)

lib/libgroff.a: lib

device.h: FORCE
	@$(SHELL) gendef $@ \
	"DEVICE=\"$(DEVICE)\"" \
	"PSPRINT=`$(SHELL) stringify $(PSPRINT)`" \
	"DVIPRINT=`$(SHELL) stringify $(DVIPRINT)`"

groff.o: device.h lib/lib.h lib/errarg.h lib/error.h lib/stringclass.h \
	lib/font.h

bindist: all VERSION Makefile.bd README.bd FORCE
	-[ -d bindist ] || mkdir bindist
	@topdir=`pwd`; \
	for dir in $(SUBDIRS); do \
	(cd $$dir; $(MAKE) $(SUBFLAGS) "BINDIR=$$topdir/bindist" install.bin); done
	cp README.bd bindist/README
	cp VERSION bindist
	-if [ -n "$(GROFF)" ] ; then cp groff bindist/groff ; fi
	@echo Making bindist/Makefile
	@sed -e "s;@GROFFLIBDIR@;$(GROFFLIBDIR);g" \
	-e "s;@FONTDIR@;$(FONTDIR);g" \
	-e "s;@FONTPATH@;$(FONTPATH);g" \
	-e "s;@MACRODIR@;$(MACRODIR);g" \
	-e "s;@MACROPATH@;$(MACROPATH);g" \
	-e "s;@HYPHENFILE@;$(HYPHENFILE);g" \
	-e "s;@DEVICE@;$(DEVICE);g" \
	-e "s;@GROFF@;$(GROFF);g" \
	Makefile.bd >bindist/Makefile

FORCE:

# Copyright (C) 1989-2006, 2009-2014
#   Free Software Foundation, Inc.
#      Original Makefile.in written by James Clark (jjc@jclark.com)
#      Migrated to Automake by Bertrand Garrigues
#
# Last update: Aug 2014
#
# This file is part of groff.
#
# groff is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# groff is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# Makefile.am
#

# The variables that are listed in the following comments will be
# automatically set by automake in the generated Makefile.in

# SHELL 

# PACKAGE_TARNAME

# srcdir

# top_srcdir

# VPATH

# top_builddir

# HOST
# `HOST' is the canonical host specification,
#    CPU_TYPE-MANUFACTURER-OPERATING_SYSTEM
# or
#    CPU_TYPE-MANUFACTURER-KERNEL-OPERATING_SYSTEM

# `RT_SEP' is the operating system's native PATH SEPARATOR CHAR, which
# is to be used in runtime PATHs compiled into groff executables.
RT_SEP=@GROFF_PATH_SEPARATOR@

# `SH_SEP' is a alternative PATH SEPARATOR CHAR, to be used in shell
# scripts and makefile rules; it may be the same as `RT_SEP', but,
# particularly in some Microsoft environments, it may differ.
SH_SEP=@PATH_SEPARATOR@

# GLIBC2
# `GLIBC21' is yes if the host operating system uses GNU libc 2.1 or newer,
# otherwise no.


# VERSION is set by automake, based on what is passed to AC_INIT.  We
# pass GROFF_VERSION_STRING to it, which skips the revision if set to
# 0.

# PAGE
# Define `page' to be letter if your PostScript printer uses 8.5x11
# paper (USA) and define it to be A4, if it uses A4 paper (rest of the
# world).

# GHOSTSCRIPT
# The name of the ghostscript program. Normally, gs, on GNU/Linux
# but it might be different on MS-DOS/MS-WIN32 systems.

# ALT_GHOSTSCRIPT_PROGS
# `ALT_GHOSTSCRIPT_PROGS' specifies a list alternative names,
# which can be tried if `GHOSTSCRIPT' cannot be found at run time.

# ALT_AWK_PROGS
# Similarly, `ALT_AWK_PROGS' specifies a list of alternative names,
# which can be tried at run time, to identify the awk program.

# BROKEN_SPOOLER_FLAGS
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
# stripped out; this is needed for the OpenWindows 2.0 pageview previewer.
# Add 4 if %%Page, %%Trailer and %%EndProlog comments should be
# stripped out of included files; this is needed for spoolers that
# don't understand the %%{Begin,End}Document comments. I suspect this
# includes early versions of TranScript.
# Add 8 if the first line of the PostScript output should be %!PS-Adobe-2.0
# rather than %!PS-Adobe-3.0; this is needed when using Sun's Newsprint
# with a printer that requires page reversal.


# `DEVICE' is the default device.
DEVICE=ps

# XDEVIDIRS
# `XDEVDIRS' is either `font/devX{75,100}{,-12}' or empty.

# XPROGDIRS
# `XPROGDIRS' is either `src/devices/xditview src/utils/xtotroff' or empty.

# XLIBDIRS
# `XLIBDIRS' is either `src/libs/libxutil' or empty.

# `TTYDEVDIRS' is either `font/devascii font/devlatin1' (for
# ASCII) or `font/devcp1047' (for EBCDIC) plus font/devutf8.
TTYDEVDIRS=@TTYDEVDIRS@ font/devutf8

# OTHERDEVDIRS
# `OTHERDEVDIRS' is either `font/devlj4 font/devlbp' (for ASCII) or
# empty (for EBCDIC).

# PSPRINT
# `PSPRINT' is the command to use for printing a PostScript file,
# for example `lpr'.

# DVIPRINT
# `DVIPRINT' is the command to use for printing a TeX dvi file,
# for example `lpr -d'.

# g
# Prefix for names of programs that have Unix counterparts.
# For example, if `g' is `g' then troff will be installed as
# gtroff.  This doesn't affect programs like grops or groff that have
# no Unix counterparts.  Note that the groff versions of eqn and tbl
# will not work with Unix troff.

# prefix
# exec_prefix
# Common prefix for installation directories.
# Used in definitions of exec_prefix, datasubdir, fontpath, manroot.
# This must already exist when you do make install.

# bindir
# `bindir' says where to install executables.

# libdir
# `libdir' says where to install platform-dependent data.

# libprogramdir
# `libprogramdir' is $(libdir)/groff

# `datasubdir' says where to install platform-independent data files.
# datadir
# datarootdir
dataprogramdir=$(datadir)/groff
datasubdir=$(dataprogramdir)/$(VERSION)

# infodir
# `infodir' says where to install info files.

# docdir
# `docdir' says where to install documentation files.  The default
# location is ${datarootdir}/doc/${PACKAGE}, but we add the version
docdir=$(datarootdir)/doc/${PACKAGE}-$(VERSION)

# `exampledir' says where to install example files.
exampledir=$(docdir)/examples

# `htmldocdir' says where to install documentation in HTML format.
htmldocdir=$(docdir)/html

# `pdfdocdir' says where to install documentation in PDF format.
pdfdocdir=$(docdir)/pdf

# `fontdir' says where to install dev*/*.
fontdir=$(datasubdir)/font

# `oldfontdir' says where to install old font sets (as dev*/*).
oldfontdir=$(datasubdir)/oldfont

# `localfontdir' says where local fonts will be installed (as dev*/*).
localfontdir=$(dataprogramdir)/site-font

# `legacyfontdir' is for compatibility with non-GNU troff.
legacyfontdir=/usr/lib/font

# `fontpath' says where to look for dev*/*.
fontpath=$(localfontdir)$(RT_SEP)$(fontdir)$(RT_SEP)$(legacyfontdir)

# `tmacdir' says where to install macros.
tmacdir=$(datasubdir)/tmac

# `systemtmacdir' says where to install platform-dependent macros.
systemtmacdir=$(libprogramdir)/site-tmac

# `localtmacdir' says where local files will be installed.
localtmacdir=$(dataprogramdir)/site-tmac

# appresdir
# `appresdir' says where to install the application resource file for
# gxditview.

# groffer_dir
# glilypond_dir
# grog_dir
# gpinyin_dir

# `tmacpath' says where to look for macro files.
# The current directory will be prepended in unsafe mode only; the home
# directory will be always added.
# `troffrc' and `troffrc-end' (and `eqnrc') are searched neither in the
# current nor in the home directory.
tmacpath=$(systemtmacdir)$(RT_SEP)$(localtmacdir)$(RT_SEP)$(tmacdir)

# sys_tmac_prefix
# `sys_tmac_prefix' is prefix (if any) for system macro packages.

# pnmtops_nosetpage
# `pnmtops_nosetpage' is the command to be run to generate an eps
# file.  Some versions of pnmtops provide the -nosetpage option.
# We detect this and use it if present.

# tmac_wrap
# `tmac_wrap' is list of system macro packages that should be made
# available to groff by creating a corresponding macro package
# in the groff macro directory that references the system macro
# package.

# If there is a groff version of a macro package listed in $(tmac_wrap),
# then the groff version will be installed with a prefix of this.
# Don't make this empty.
tmac_prefix=g

# The groff -mm macros will be available as -m$(tmac_m_prefix)m.
tmac_m_prefix=\
 `for i in $(tmac_wrap) ""; do case "$$i" in m) echo $(tmac_prefix);; esac; done`
# The groff -ms macros will be available as -m$(tmac_s_prefix)s.
tmac_s_prefix=\
 `for i in $(tmac_wrap) ""; do case "$$i" in s) echo $(tmac_prefix);; esac; done`
# The groff -man macros will be available as -m$(tmac_an_prefix)an.
tmac_an_prefix=\
 `for i in $(tmac_wrap) ""; do case "$$i" in an) echo $(tmac_prefix);; esac; done`

# Extension to be used for refer index files.  Index files are not
# sharable between different architectures, so you might want to use
# different suffixes for different architectures.  Choose an extension
# that doesn't conflict with refer or any other indexing program.
indexext=.i

# Directory containing the default index for refer.
indexdir=/usr/dict/papers

# The filename (without suffix) of the default index for refer.
indexname=Ind

# common_words_file is a file containing a list of common words.
# If your system provides /usr/lib/eign it will be copied onto this,
# otherwise the supplied eign file will be used.
common_words_file=$(datasubdir)/eign

# mandir
# `manroot' is the root of the man page directory tree.
manroot=$(mandir)

# `man1ext' is the man section for user commands.
man1ext=1
man1dir=$(manroot)/man$(man1ext)

# `man5ext' is the man section for file formats.
man5ext=5
man5dir=$(manroot)/man$(man5ext)

# `man7ext' is the man section for macros.
man7ext=7
man7dir=$(manroot)/man$(man7ext)

# doc_dist_target_ok
# `dist' target is disallowed in some `configure' combinations.

# The configure script checks whether the user wants the info documentation.
# For the repo version this mechanism also suppresses building via `makeinfo'.
# make_infodoc
# make_install_infodoc
# make_uninstall_infodoc

# The configure script checks whether all necessary utility programs for
# grohtml are available -- only then we can build the HTML documentation.
# make_htmldoc
# make_install_htmldoc
# make_uninstall_htmldoc

# make_htmlexamples
# make_install_htmlexamples
# make_uninstall_htmlexamples

# The configure script also checks whether all necessary utility programs
# for pdfroff are available -- only then we can build PDF documentation.
# make_pdfdoc
# make_install_pdfdoc
# make_uninstall_pdfdoc

# make_pdfexamples
# make_install_pdfexamples
# make_uninstall_pdfexamples

# `other' documentation, e.g., `meref.me' and `pic.ms', as well as their
# generated counterparts..
# make_otherdoc
# make_install_otherdoc
# make_uninstall_otherdoc

# `examples' -- a generic switch, but the generated examples are furtherly
# subdivided to catch HTML and PDF production availability.
# make_examples
# make_install_examples
# make_uninstall_examples

# All the previous installation directories, when used, are prefixed with
# $(DESTDIR) during install and uninstall, to support staged installations.

# config.h might set the following defines:
#
# WORDS_BIGENDIAN		if your target platform is big-endian
# IS_EBCDIC_HOST		if the host's encoding is EBCDIC
#
# HAVE_DIRECT_H		if you have <direct.h>
# HAVE_DIRENT_H		if you have <dirent.h>
# HAVE_CC_INTTYPES_H		if you have a C++ <inttypes.h>
# HAVE_PROCESS_H		if you have <process.h>
# HAVE_LIMITS_H		if you have <limits.h>
# HAVE_CC_LIMITS_H		if you have a C++ <limits.h>
# HAVE_MATH_H			if you have <math.h>
# HAVE_CC_OSFCN_H		if you have a C++ <osfcn.h>
# HAVE_STDDEF_H		if you have <stddef.h>
# HAVE_STDLIB_H		if you have <stdlib.h>
# HAVE_STRING_H		if you have <string.h>
# HAVE_STRINGS_H		if you have <strings.h>
# HAVE_SYS_DIR_H		if you have <sys/dir.h>
# HAVE_SYS_PARAM_H		if you have <sys/param.h>
# HAVE_SYS_STAT_H		if you have <sys/stat.h>
# HAVE_SYS_TIME_H		if you have <sys/time.h>
# HAVE_SYS_TYPES_H		if you have <sys/types.h>
# HAVE_UNISTD_H		if you have <unistd.h>
#
# HAVE_FMOD			if you have fmod()
# HAVE_GETCWD			if you have getcwd()
# HAVE_GETTIMEOFDAY		if you have gettimeofday()
# HAVE_ICONV			if you have iconv()
# HAVE_ISATTY			if you have isatty()
# HAVE_KILL			if you have kill()
# HAVE_LANGINFO_CODESET	if you have nl_langinfo()
# HAVE_MKSTEMP		if you have mkstemp()
# HAVE_MMAP			if you have mmap()
# HAVE_PUTENV			if you have putenv()
# HAVE_RENAME			if you have rename()
# HAVE_SETLOCALE		if you have setlocale()
# HAVE_SNPRINTF		if you have snprintf()
# HAVE_STRCASECMP		if you have strcasecmp()
# HAVE_STRNCASECMP		if you have strncasecmp()
# HAVE_STRERROR		if you have strerror()
# HAVE_STRSEP			if you have strsep()
# HAVE_STRTOL			if you have strtol()
# HAVE_SYMLINK		if you have symlink()
# HAVE_VSNPRINTF		if you have vsnprintf()
#
# NEED_DECLARATION_GETTIMEOFTODAY
#				if your C++ <sys/time.h> doesn't declare
#				gettimeofday()
# NEED_DECLARATION_HYPOT	if your C++ <math.h> doesn't declare hypot()
# NEED_DECLARATION_PCLOSE	if your C++ <stdio.h> doesn't declare pclose()
# NEED_DECLARATION_POPEN	if your C++ <stdio.h> doesn't declare popen()
# NEED_DECLARATION_PUTENV	if your C++ <stdlib.h> doesn't declare
#				putenv()
# NEED_DECLARATION_RAND	if your C++ <stdlib.h> doesn't declare rand()
# NEED_DECLARATION_SNPRINTF	if your C++ <stdio.h> doesn't declare
# 				snprintf()
# NEED_DECLARATION_SRAND	if your C++ <stdlib.h> doesn't declare srand()
# NEED_DECLARATION_STRCASECMP	if your C++ <string.h> doesn't declare
#				strcasecmp()
# NEED_DECLARATION_STRNCASECMP
#				if your C++ <string.h> doesn't declare
#				strncasecmp()
# NEED_DECLARATION_VFPRINTF	if your C++ <stdio.h> doesn't declare
#				vfprintf()
# NEED_DECLARATION_VSNPRINTF	if your C++ <stdio.h> doesn't declare
#				vsnprintf()
#
# HAVE_DECL_GETC_UNLOCKED	if you have getc_unlocked()
# HAVE_DECL_SYS_SIGLIST	if you have sys_siglist[]
#
# HAVE_STRUCT_EXCEPTION	if <math.h> defines struct exception
# HAVE_SYS_NERR		if you have sysnerr in <errno.h> or <stdio.h>
# HAVE_SYS_ERRLIST		if you have sys_errlist in <errno.h> or
#				<stdio.h>
# ICONV_CONST=const		if declaration of iconv() needs const
# LONG_FOR_TIME_T		if localtime() takes a long * not a time_t *
# RETSIGTYPE=int		if signal handlers return int not void
# RET_TYPE_SRAND_IS_VOID	if srand() returns void not int
#
# WCOREFLAG=0200		if the 0200 bit of the status returned by
#				wait() indicates whether a core image was
#				produced for a process that was terminated
#				by a signal
#
# HAVE_WORKING_O_NOATIME      define if <fcntl.h>'s O_NOATIME flag works
# HAVE_WORKING_O_NOFOLLOW     define if <fcntl.h>'s O_NOFOLLOW flag works
#
# uintmax_t=<value>		define to `unsigned long' or `unsigned long
#				long' if <inttypes.h> does not exist
#
# TRADITIONAL_CPP		if your C++ compiler uses a traditional
#				(Reiser) preprocessor
# ARRAY_DELETE_NEEDS_SIZE	if your C++ doesn't understand `delete []'
#
# PAGE=A4			if the the printer's page size is A4
# GHOSTSCRIPT=gs		the name (and directory if required) of the
#				ghostscript program

# Include
#
#   {fmod,getcwd,mkstemp,putenv,snprintf,strcasecmp,
#    strerror,strncasecmp,strtol}.$(OBJEXT)
#
# LIBOBJS
# in LIBOBJS if your C library is missing the corresponding function.
# vsnprintf is defined in the snprintf.$(OBJEXT) module.

# `CCC' is the compiler for C++ (.cpp) files.
CCC=@CXX@
# CC
# CFLAGS
# CPPFLAGS
# LDFLAGS

# X_CFLAGS
# X_LIBS
# X_EXTRA_LIBS
# X_PRE_LIBS

# YACC

# GREP
# EGREP

# MAKEINFO

# EXEEXT
# OBJEXT
# LIBEXT
# LIBS
# LIBM
# LIBICONV
# RANLIB
# INSTALL
# INSTALL_PROGRAM
# INSTALL_SCRIPT
# INSTALL_DATA
# INSTALL_INFO
# LN_S

AR=ar
ETAGS=etags
ETAGSFLAGS=
# Flag that tells etags to assume C++.
ETAGSCCFLAG=-C
# Full path to perl.
# PERL
# PERLVERSION
# Sed command with which to edit sh scripts.
# SH_SCRIPT_SED_CMD
# Sed script to deal with OS dependencies in sh scripts.
SH_DEPS_SED_SCRIPT=$(top_builddir)/shdeps.sed

# The program to create directory hierarchies.
# mkinstalldirs is now in gnulib/build-aux

PURIFY=purify
PURIFYCCFLAGS=
#PURIFYCCFLAGS=-g++=yes \
#  -collector=`dirname \`$(CCC) -print-libgcc-file-name\``/ld

# Add groff and gnulib m4 macros
ACLOCAL_AMFLAGS = -I m4 -I gnulib_m4

# Common preprocessor flags: gnulib includes, common includes in
# src/include, and config.h that is generated in the build tree
AM_CPPFLAGS = \
  -I$(top_srcdir)/src/include \
  -I$(top_srcdir)/lib \
  -I$(top_builddir)/src/include \
  -I$(top_builddir)/lib

# The following Automake variables will be overloaded by the various
# .am files
bin_PROGRAMS =
nobase_bin_PROGRAMS =
bin_SCRIPTS = 
dist_bin_SCRIPTS = 
MOSTLYCLEANFILES =
MOSTLYCLEANADD =
noinst_LIBRARIES =
BUILT_SOURCES =
CLEANFILES =
# gnulib asks to include this file
EXTRA_DIST = gnulib_m4/gnulib-cache.m4
FONTFILES =
man1_MANS =
man5_MANS =
man7_MANS =

# for lex/yacc
AM_YFLAGS = -d -v

SUFFIXES =

# tests launched by make check
check_SCRIPTS =
check_PROGRAMS =
TESTS =
AM_TESTS_ENVIRONMENT = \
  abs_top_srcdir=$(abs_top_srcdir) \
  abs_top_builddir=$(abs_top_builddir) \
  export abs_top_srcdir abs_top_builddir;

# Path to binaries and flags used by contribs and doc to generated doc.
# These may be overridden if cross-compiling.
GROFFBIN = $(abs_top_builddir)/groff
GROFF_BIN_PATH = $(abs_top_builddir)
PDFMOMBIN = $(abs_top_builddir)/pdfmom
FFLAG=-F$(abs_top_builddir)/font -F$(abs_top_srcdir)/font
TFLAG=-M$(abs_top_builddir)/tmac -M$(abs_top_srcdir)/tmac

# Non-recursive makefile system. See Automake manual '7.3 An
# Alternative Approach to Subdirectories'. We use a single Makefile.am
# that includes other .am files, rather than using SUBDIRS.  Note that
# relative paths in the following .am files are relative to the top
# source directory.

include $(top_srcdir)/lib/gnulib.mk
include $(top_srcdir)/arch/misc/misc.am
include $(top_srcdir)/contrib/chem/chem.am
include $(top_srcdir)/contrib/eqn2graph/eqn2graph.am
include $(top_srcdir)/contrib/gdiffmk/gdiffmk.am
include $(top_srcdir)/contrib/gideal/gideal.am
include $(top_srcdir)/contrib/glilypond/glilypond.am
include $(top_srcdir)/contrib/gperl/gperl.am
include $(top_srcdir)/contrib/gpinyin/gpinyin.am
include $(top_srcdir)/contrib/grap2graph/grap2graph.am
include $(top_srcdir)/contrib/groff_filenames/groff_filenames.am
include $(top_srcdir)/contrib/groffer/groffer.am
include $(top_srcdir)/contrib/hdtbl/hdtbl.am
include $(top_srcdir)/contrib/mm/mm.am
include $(top_srcdir)/contrib/pic2graph/pic2graph.am
include $(top_srcdir)/font/devX100/devX100.am
include $(top_srcdir)/font/devX100-12/devX100-12.am
include $(top_srcdir)/font/devX75/devX75.am
include $(top_srcdir)/font/devX75-12/devX75-12.am
include $(top_srcdir)/font/devascii/devascii.am
include $(top_srcdir)/font/devcp1047/devcp1047.am
include $(top_srcdir)/font/devdvi/devdvi.am
include $(top_srcdir)/font/devhtml/devhtml.am
include $(top_srcdir)/font/devlatin1/devlatin1.am
include $(top_srcdir)/font/devlbp/devlbp.am
include $(top_srcdir)/font/devlj4/devlj4.am
include $(top_srcdir)/font/devpdf/devpdf.am
include $(top_srcdir)/font/devps/devps.am
include $(top_srcdir)/font/devutf8/devutf8.am
include $(top_srcdir)/font/scripts/scripts.am
include $(top_srcdir)/man/man.am
include $(top_srcdir)/src/include/include.am
include $(top_srcdir)/src/libs/libbib/libbib.am
include $(top_srcdir)/src/libs/libdriver/libdriver.am
include $(top_srcdir)/src/libs/libgroff/libgroff.am
include $(top_srcdir)/src/libs/libxutil/libxutil.am
include $(top_srcdir)/src/devices/grodvi/grodvi.am
include $(top_srcdir)/src/devices/grohtml/grohtml.am
include $(top_srcdir)/src/devices/grolbp/grolbp.am
include $(top_srcdir)/src/devices/grolj4/grolj4.am
include $(top_srcdir)/src/devices/gropdf/gropdf.am
include $(top_srcdir)/src/devices/grops/grops.am
include $(top_srcdir)/src/devices/grotty/grotty.am
include $(top_srcdir)/src/devices/xditview/xditview.am
include $(top_srcdir)/src/preproc/eqn/eqn.am
include $(top_srcdir)/src/preproc/grn/grn.am
include $(top_srcdir)/src/preproc/html/html.am
include $(top_srcdir)/src/preproc/pic/pic.am
include $(top_srcdir)/src/preproc/preconv/preconv.am
include $(top_srcdir)/src/preproc/refer/refer.am
include $(top_srcdir)/src/preproc/soelim/soelim.am
include $(top_srcdir)/src/preproc/tbl/tbl.am
include $(top_srcdir)/src/roff/groff/groff.am
include $(top_srcdir)/src/roff/grog/grog.am
include $(top_srcdir)/src/roff/nroff/nroff.am
include $(top_srcdir)/src/roff/troff/troff.am
include $(top_srcdir)/src/utils/addftinfo/addftinfo.am
include $(top_srcdir)/src/utils/afmtodit/afmtodit.am
include $(top_srcdir)/src/utils/hpftodit/hpftodit.am
include $(top_srcdir)/src/utils/indxbib/indxbib.am
include $(top_srcdir)/src/utils/lkbib/lkbib.am
include $(top_srcdir)/src/utils/lookbib/lookbib.am
include $(top_srcdir)/src/utils/pfbtops/pfbtops.am
include $(top_srcdir)/src/utils/tfmtodit/tfmtodit.am
include $(top_srcdir)/src/utils/xtotroff/xtotroff.am
include $(top_srcdir)/tmac/tmac.am

# Adding defs.h to BUILT_SOURCES will ensure that it will be built on
# make all or make check before all other targets. However, if another
# target is built from a clean build tree, (for example make groff)
# the files in BUILT_SOURCES will not be built first. That is why
# additional dependencies where added in the .am files that lists
# objects that use defs (for exmaple in groff.am:
# src/roff/groff/groff.$(OBJEXT): defs.h)
BUILT_SOURCES += defs.h

# Same thing for gnulib's localcharset.c and configmake.h: gnulib uses
# BUILT_SOURCES only, adding the following makes 'make lib/libgnu.a'
# possible
lib/localcharset.$(OBJEXT): lib/configmake.h

# File used by contrib/hdtbl and contrib/pdfmark
gnu.eps:
	if test -f $(top_srcdir)/doc/gnu.eps; then \
	  cp $(top_srcdir)/doc/gnu.eps . ; \
	elif test -f $(top_builddir)/doc/gnu.eps; then \
	  cp $(top_builddir)/doc/gnu.eps . ; \
	else \
	  xpmtoppm $(top_srcdir)/doc/gnu.xpm | pnmdepth 15 \
	    | $(pnmtops_nosetpage) -noturn -rle >$@ ; \
	fi

# directories specific to groff
uninstall-hook: uninstall_groffdirs
uninstall_groffdirs:
	if test -d $(DESTDIR)$(datasubdir); then \
	  rm -rf $(DESTDIR)$(fontdir); \
	  rm -rf $(DESTDIR)$(oldfontdir); \
	  rmdir $(DESTDIR)$(datasubdir); \
	fi
	if test -d $(DESTDIR)$(dataprogramdir); then \
	  rmdir $(DESTDIR)$(dataprogramdir); \
	fi
	if test -d $(DESTDIR)$(grog_dir); then \
	  rmdir $(DESTDIR)$(grog_dir); \
	fi
	if test -d $(DESTDIR)$(libprogramdir); then \
	  rmdir $(DESTDIR)$(libprogramdir); \
	fi
	if test -d $(DESTDIR)$(docdir); then \
	  if test -d $(DESTDIR)$(exampledir); then \
	    rmdir $(DESTDIR)$(exampledir); \
	  fi; \
	  rmdir $(DESTDIR)$(docdir); \
	fi

# Other files that should be present in the distribution tarball.
EXTRA_DIST += \
  BUG-REPORT \
  ChangeLog.115 \
  ChangeLog.116 \
  ChangeLog.117 \
  ChangeLog.118 \
  ChangeLog.119 \
  ChangeLog.120 \
  ChangeLog.121 \
  FDL \
  FOR-RELEASE \
  gendef.sh \
  INSTALL.REPO \
  INSTALL.extra \
  INSTALL.gen \
  LICENSES \
  MANIFEST \
  mdate.sh \
  MORE.STUFF \
  PROBLEMS \
  PROJECTS \
  README.MinGW \
  arch/djgpp

MOSTLYCLEANFILES += $(man1_MANS) $(man5_MANS) $(man7_MANS) $(bin_SCRIPTS) gnu.eps

# Rule to build .man files. The brackets around the @ are used to prevent the 
# substitution of the variable by automake. 
.man.n:
	@echo Making $@ from $<
	rm -f $@
	$(MKDIR_P) `dirname $@`
	@LC_ALL=C \
	 sed -e "s|[@]APPRESDIR[@]|$(appresdir)|g" \
	     -e "s|[@]BINDIR[@]|$(bindir)|g" \
	     -e "s|[@]BROKEN_SPOOLER_FLAGS[@]|$(BROKEN_SPOOLER_FLAGS)|g" \
	     -e "s|[@]COMMON_WORDS_FILE[@]|$(common_words_file)|g" \
	     -e "s|[@]DATASUBDIR[@]|$(datasubdir)|g" \
	     -e "s|[@]DEFAULT_INDEX[@]|$(indexdir)/$(indexname)|g" \
	     -e "s|[@]DEFAULT_INDEX_NAME[@]|$(indexname)|g" \
	     -e "s|[@]DEVICE[@]|$(DEVICE)|g" \
	     -e "s|[@]DOCDIR[@]|$(docdir)|g" \
	     -e "s|[@]EXAMPLEDIR[@]|$(exampledir)|g" \
	     -e "s|[@]FONTDIR[@]|$(fontdir)|g" \
	     -e "s|[@]g[@]|$(g)|g" \
	     -e "s![@]G[@]!`echo $(g) | tr [a-z] [A-Z]`!g" \
	     -e "s|[@]HTMLDOCDIR[@]|$(htmldocdir)|g" \
	     -e "s|[@]INDEX_SUFFIX[@]|$(indexext)|g" \
	     -e "s|[@]LEGACYFONTDIR[@]|$(legacyfontdir)|g" \
	     -e "s|[@]LOCALFONTDIR[@]|$(localfontdir)|g" \
	     -e "s|[@]LOCALMACRODIR[@]|$(localtmacdir)|g" \
	     -e "s|[@]MACRODIR[@]|$(tmacdir)|g" \
	     -e "s|[@]MAN1EXT[@]|$(man1ext)|g" \
	     -e "s|[@]MAN5EXT[@]|$(man5ext)|g" \
	     -e "s|[@]MAN7EXT[@]|$(man7ext)|g" \
	     -e "s|[@]MDATE[@]|`$(SHELL) $(top_srcdir)/mdate.sh $<`|g" \
	     -e "s|[@]OLDFONTDIR[@]|$(oldfontdir)|g" \
	     -e "s|[@]PDFDOCDIR[@]|$(pdfdocdir)|g" \
	     -e "s|[@]SYSTEMMACRODIR[@]|$(systemtmacdir)|g" \
	     -e "s|[@]TMAC_AN_PREFIX[@]|$(tmac_an_prefix)|g" \
	     -e "s|[@]TMAC_M_PREFIX[@]|$(tmac_m_prefix)|g" \
	     -e "s|[@]TMAC_MDIR[@]|$(tmacdir)/mm|g" \
	     -e "s|[@]TMAC_S_PREFIX[@]|$(tmac_s_prefix)|g" \
	     -e "s|[@]VERSION[@]|$(VERSION)|g" \
	 $< >$@

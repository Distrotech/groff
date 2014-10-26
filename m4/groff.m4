# Autoconf macros for groff.
# Copyright (C) 1989-2014  Free Software Foundation, Inc.
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

AC_DEFUN([GROFF_PRINT],
  [if test -z "$PSPRINT"; then
     AC_CHECK_PROGS([LPR], [lpr])
     AC_CHECK_PROGS([LP], [lp])
     if test -n "$LPR" && test -n "$LP"; then
       # HP-UX provides an lpr command that emulates lpr using lp,
       # but it doesn't have lpq; in this case we want to use lp
       # rather than lpr.
       AC_CHECK_PROGS([LPQ], [lpq])
       test -n "$LPQ" || LPR=
     fi
     if test -n "$LPR"; then
       PSPRINT="$LPR"
     elif test -n "$LP"; then
       PSPRINT="$LP"
     fi
   fi
   AC_SUBST([PSPRINT])
   AC_MSG_CHECKING([for command to use for printing PostScript files])
   AC_MSG_RESULT([$PSPRINT])

   # Figure out DVIPRINT from PSPRINT.
   AC_MSG_CHECKING([for command to use for printing dvi files])
   if test -n "$PSPRINT" && test -z "$DVIPRINT"; then
     if test "x$PSPRINT" = "xlpr"; then
       DVIPRINT="lpr -d"
     else
       DVIPRINT="$PSPRINT"
     fi
   fi
   AC_SUBST([DVIPRINT])
   AC_MSG_RESULT([$DVIPRINT])])

# Bison generated parsers have problems with C++ compilers other than g++.
# So byacc is preferred over bison.

AC_DEFUN([GROFF_PROG_YACC],
  [AC_CHECK_PROGS([YACC], [byacc 'bison -y'], [yacc])])


# We need Perl 5.6.1 or newer.

AC_DEFUN([GROFF_PERL],
  [PERLVERSION=v5.6.1
   AC_PATH_PROG([PERL], [perl], [no])
   if test "x$PERL" = "xno"; then
     AC_MSG_ERROR([perl binary not found], 1)
   fi
   AX_PROG_PERL_VERSION([$PERLVERSION], true, \
     AC_MSG_ERROR([perl version is too old], 1))])


# It is possible to fine-tune generation of documentation.

AC_DEFUN([GROFF_DOC_CHECK],
  [AC_ARG_WITH([doc],
    [AS_HELP_STRING([--with-doc[[=TYPE]]],
      [choose which manuals (beside man pages) are desirable. \
       TYPE can be `yes' or `no', or a comma-separated list of \
       one or multiple of `html', `info', `other', `pdf', and \
       `examples', to restrict what is produced])],
    [doc="$withval"],
    [doc=yes])
  test "x$doc" = xno && doc=''
  if test "x$doc" = xyes; then
    doc_dist_target_ok=yes
    docadd_html=yes
    docadd_info=yes
    docadd_other=yes
    docadd_pdf=yes
    docadd_examples=yes
  else
    # Don't use case/esac, verify input.
    doc_dist_target_ok=no
    docadd_html=no
    docadd_info=no
    docadd_other=no
    docadd_pdf=no
    docadd_examples=no
    OFS=$IFS
    IFS=','
    set -- $doc
    IFS=$OFS
    for i
    do
      test "x$i" = xhtml     && { docadd_html=yes; continue; }
      test "x$i" = xinfo     && { docadd_info=yes; continue; }
      test "x$i" = xother    && { docadd_other=yes; continue; }
      test "x$i" = xpdf      && { docadd_pdf=yes; continue; }
      test "x$i" = xexamples && { docadd_examples=yes; continue; }
      AC_MSG_WARN([Invalid `--with-doc' argument:] $i)
    done
  fi
  if test $docadd_html = yes; then
    make_install_shipped_htmldoc=install_shipped_htmldoc
    make_uninstall_shipped_htmldoc=uninstall_shipped_htmldoc
  else
    make_install_shipped_htmldoc=
    make_uninstall_shipped_htmldoc=
  fi
  if test $docadd_other = yes; then
    make_otherdoc=otherdoc
    make_install_otherdoc=install_otherdoc
    make_uninstall_otherdoc=uninstall_otherdoc
  else
    make_otherdoc=
    make_install_otherdoc=
    make_uninstall_otherdoc=
  fi
  if test $docadd_examples = yes; then
    make_examples=examples
    make_install_examples=install_examples
    make_uninstall_examples=uninstall_examples
  else
    make_examples=
    make_install_examples=
    make_uninstall_examples=
  fi
  AC_SUBST([doc_dist_target_ok])
  AC_SUBST([make_install_shipped_htmldoc])
  AC_SUBST([make_uninstall_shipped_htmldoc])
  AC_SUBST([make_otherdoc])
  AC_SUBST([make_install_otherdoc])
  AC_SUBST([make_uninstall_otherdoc])
  AC_SUBST([make_examples])
  AC_SUBST([make_install_examples])
  AC_SUBST([make_uninstall_examples])])


# We need makeinfo 4.8 or newer.

AC_DEFUN([GROFF_MAKEINFO],
  [if test $docadd_info = yes; then
     missing=
     AC_CHECK_PROG([MAKEINFO], [makeinfo], [makeinfo])
     if test -z "$MAKEINFO"; then
       missing="\`makeinfo' is missing."
     else
       AC_MSG_CHECKING([for makeinfo version])
       # We need an additional level of quoting to make sed's regexps work.
       [makeinfo_version=`$MAKEINFO --version 2>&1 \
        | sed -e 's/^.* \([^ ][^ ]*\)$/\1/' -e '1q'`]
       AC_MSG_RESULT([$makeinfo_version])
       # Consider only the first two numbers in version number string.
       makeinfo_version_major=`IFS=.; set x $makeinfo_version; echo 0${2}`
       makeinfo_version_minor=`IFS=.; set x $makeinfo_version; echo 0${3}`
       makeinfo_version_numeric=`
         expr ${makeinfo_version_major}000 \+ ${makeinfo_version_minor}`
       if test $makeinfo_version_numeric -lt 4008; then
         missing="\`makeinfo' is too old."
       fi
     fi

     if test -n "$missing"; then
       infofile=doc/groff.info
       test -f ${infofile} || infofile=${srcdir}/${infofile}
       if test ! -f ${infofile} \
	|| test ${srcdir}/doc/groff.texinfo -nt ${infofile}; then
	 AC_MSG_ERROR($missing
[Get the `texinfo' package version 4.8 or newer.])
       else
	 AC_MSG_WARN($missing
[Get the `texinfo' package version 4.8 or newer if you want to convert
`groff.texinfo' into a PDF or HTML document.])
       fi
     fi

     make_infodoc=infodoc
     make_install_infodoc=install_infodoc
     make_uninstall_infodoc=uninstall_infodoc
   else
     make_infodoc=
     make_install_infodoc=
     make_uninstall_infodoc=
     MAKEINFO=
   fi
   AC_SUBST([MAKEINFO])
   AC_SUBST([make_infodoc])
   AC_SUBST([make_install_infodoc])
   AC_SUBST([make_uninstall_infodoc])])


# The following programs are needed for grohtml.

AC_DEFUN([GROFF_HTML_PROGRAMS],
  [make_htmldoc=
   make_install_htmldoc=
   make_uninstall_htmldoc=
   make_htmlexamples=
   make_install_htmlexamples=
   make_uninstall_htmlexamples=
   AC_REQUIRE([GROFF_GHOSTSCRIPT_PATH])

   missing=
   AC_FOREACH([groff_prog],
     [pnmcut pnmcrop pnmtopng psselect pnmtops],
     [AC_CHECK_PROG(groff_prog, groff_prog, [found], [missing])
      if test $[]groff_prog = missing; then
	missing="$missing \`groff_prog'"
      fi;])

   test "$GHOSTSCRIPT" = "missing" && missing="$missing \`gs'"

   if test -z "$missing"; then
     if test $docadd_html = yes; then
       make_htmldoc=htmldoc
       make_install_htmldoc=install_htmldoc
       make_uninstall_htmldoc=uninstall_htmldoc
       if test $docadd_examples = yes; then
         make_htmlexamples=html_examples
         make_install_htmlexamples=install_htmlexamples
         make_uninstall_htmlexamples=uninstall_htmlexamples
       fi
     fi
   else
     plural=`set $missing; test $[#] -gt 1 && echo s`
     missing=`set $missing
       missing=""
       while test $[#] -gt 0
	 do
	   case $[#] in
	     1) missing="$missing$[1]" ;;
	     2) missing="$missing$[1] and " ;;
	     *) missing="$missing$[1], " ;;
	   esac
	   shift
	 done
	 echo $missing`

     docnote=.
     test $docadd_html = yes && docnote=';
  therefore, it will neither be possible to prepare, nor to install,
  documentation in HTML format.'

     AC_MSG_WARN([missing program$plural:

  The program$plural
     $missing
  cannot be found in the PATH.
  Consequently, groff's HTML backend (grohtml) will not work properly$docnote
     ])
     doc_dist_target_ok=no
   fi
   AC_SUBST([make_htmldoc])
   AC_SUBST([make_install_htmldoc])
   AC_SUBST([make_uninstall_htmldoc])
   AC_SUBST([make_htmlexamples])
   AC_SUBST([make_install_htmlexamples])
   AC_SUBST([make_uninstall_htmlexamples])])


# To produce PDF docs, we need both awk and ghostscript.

AC_DEFUN([GROFF_PDFDOC_PROGRAMS],
  [make_pdfdoc=
   make_install_pdfdoc=
   make_uninstall_pdfdoc=
   make_pdfexamples=
   make_install_pdfexamples=
   make_uninstall_pdfexamples=
   AC_REQUIRE([GROFF_AWK_PATH])
   AC_REQUIRE([GROFF_GHOSTSCRIPT_PATH])

   missing=""
   test "$AWK" = missing && missing="\`awk'"
   test "$GHOSTSCRIPT" = missing && missing="$missing \`gs'"
   if test -z "$missing"; then
     if test $docadd_pdf = yes; then
       make_pdfdoc=pdfdoc
       make_install_pdfdoc=install_pdfdoc
       make_uninstall_pdfdoc=uninstall_pdfdoc
       if test $docadd_examples = yes; then
         make_pdfexamples=pdfexamples
         make_install_pdfexamples=install_pdfexamples
         make_uninstall_pdfexamples=uninstall_pdfexamples
       fi
     fi
   else
     plural=`set $missing; test $[#] -eq 2 && echo s`
     test x$plural = xs \
       && missing=`set $missing; echo "$[1] and $[2]"` \
       || missing=`echo $missing`

     docnote=.
     test $docadd_pdf = yes && docnote=';
  therefore, it will neither be possible to prepare, nor to install,
  documentation and most of the examples in PDF format.'

     AC_MSG_WARN([missing program$plural:

  The program$plural $missing cannot be found in the PATH.
  Consequently, groff's PDF formatter (pdfroff) will not work properly$docnote
     ])
     doc_dist_target_ok=no
   fi
   AC_SUBST([make_pdfdoc])
   AC_SUBST([make_install_pdfdoc])
   AC_SUBST([make_uninstall_pdfdoc])
   AC_SUBST([make_pdfexamples])
   AC_SUBST([make_install_pdfexamples])
   AC_SUBST([make_uninstall_pdfexamples])])


# Check whether pnmtops can handle the -nosetpage option.

AC_DEFUN([GROFF_PNMTOPS_NOSETPAGE],
  [AC_MSG_CHECKING([whether pnmtops can handle the -nosetpage option])
   if echo P2 2 2 255 0 1 2 0 | pnmtops -nosetpage > /dev/null 2>&1 ; then
     AC_MSG_RESULT([yes])
     pnmtops_nosetpage="pnmtops -nosetpage"
   else
     AC_MSG_RESULT([no])
     pnmtops_nosetpage="pnmtops"
   fi
   AC_SUBST([pnmtops_nosetpage])])


# Check location of `gs'; allow `--with-gs=PROG' option to override.

AC_DEFUN([GROFF_GHOSTSCRIPT_PATH],
  [AC_REQUIRE([GROFF_GHOSTSCRIPT_PREFS])
   AC_ARG_WITH([gs],
     [AS_HELP_STRING([--with-gs=PROG],
       [actual [/path/]name of ghostscript executable])],
     [GHOSTSCRIPT=$withval],
     [AC_CHECK_TOOLS(GHOSTSCRIPT, [$ALT_GHOSTSCRIPT_PROGS], [missing])])
   test "$GHOSTSCRIPT" = "no" && GHOSTSCRIPT=missing])

# Preferences for choice of `gs' program...
# (allow --with-alt-gs="LIST" to override).

AC_DEFUN([GROFF_GHOSTSCRIPT_PREFS],
  [AC_ARG_WITH([alt-gs],
    [AS_HELP_STRING([--with-alt-gs=LIST],
      [alternative names for ghostscript executable])],
    [ALT_GHOSTSCRIPT_PROGS="$withval"],
    [ALT_GHOSTSCRIPT_PROGS="gs gswin32c gsos2"])
   AC_SUBST([ALT_GHOSTSCRIPT_PROGS])])


# Check location of `awk'; allow `--with-awk=PROG' option to override.

AC_DEFUN([GROFF_AWK_PATH],
  [AC_REQUIRE([GROFF_AWK_PREFS])
   AC_ARG_WITH([awk],
     [AS_HELP_STRING([--with-awk=PROG],
       [actual [/path/]name of awk executable])],
     [AWK=$withval],
     [AC_CHECK_TOOLS(AWK, [$ALT_AWK_PROGS], [missing])])
   test "$AWK" = "no" && AWK=missing])


# Preferences for choice of `awk' program; allow --with-alt-awk="LIST"
# to override.

AC_DEFUN([GROFF_AWK_PREFS],
  [AC_ARG_WITH([alt-awk],
    [AS_HELP_STRING([--with-alt-awk=LIST],
      [alternative names for awk executable])],
    [ALT_AWK_PROGS="$withval"],
    [ALT_AWK_PROGS="gawk mawk nawk awk"])
   AC_SUBST([ALT_AWK_PROGS])])


# GROFF_CSH_HACK(if hack present, if not present)

AC_DEFUN([GROFF_CSH_HACK],
  [AC_MSG_CHECKING([for csh hash hack])

cat <<EOF >conftest.sh
#! /bin/sh
true || exit 0
export PATH || exit 0
exit 1
EOF

   chmod +x conftest.sh
   if echo ./conftest.sh | (csh >/dev/null 2>&1) >/dev/null 2>&1; then
     AC_MSG_RESULT([yes])
     $1
   else
     AC_MSG_RESULT([no])
     $2
   fi
   rm -f conftest.sh])


# From udodo!hans@relay.NL.net (Hans Zuidam)

AC_DEFUN([GROFF_ISC_SYSV3],
  [AC_MSG_CHECKING([for ISC 3.x or 4.x])
   if grep ['[34]\.'] /usr/options/cb.name >/dev/null 2>&1
   then
     AC_MSG_RESULT([yes])
     AC_DEFINE([_SYSV3], [1], [Define if you have ISC 3.x or 4.x.])
   else
     AC_MSG_RESULT([no])
   fi])

AC_DEFUN([GROFF_POSIX],
  [AC_MSG_CHECKING([whether -D_POSIX_SOURCE is necessary])
   AC_LANG_PUSH([C++])
   AC_COMPILE_IFELSE([
       AC_LANG_PROGRAM([[

#include <stdio.h>
extern "C" { void fileno(int); }

       ]])
     ],
     [AC_MSG_RESULT([yes])
      AC_DEFINE([_POSIX_SOURCE], [1],
	[Define if -D_POSIX_SOURCE is necessary.])],
     [AC_MSG_RESULT([no])])
   AC_LANG_POP([C++])])


# srand() of SunOS 4.1.3 has return type int instead of void

AC_DEFUN([GROFF_SRAND],
  [AC_LANG_PUSH([C++])
   AC_MSG_CHECKING([for return type of srand])
   AC_COMPILE_IFELSE([
       AC_LANG_PROGRAM([[

#include <stdlib.h>
extern "C" { void srand(unsigned int); }

       ]])
     ],
     [AC_MSG_RESULT([void])
      AC_DEFINE([RET_TYPE_SRAND_IS_VOID], [1],
	[Define if srand() returns void not int.])],
     [AC_MSG_RESULT([int])])
   AC_LANG_POP([C++])])


# In April 2005, autoconf's AC_TYPE_SIGNAL is still broken.

AC_DEFUN([GROFF_TYPE_SIGNAL],
  [AC_MSG_CHECKING([for return type of signal handlers])
   for groff_declaration in \
     'extern "C" void (*signal (int, void (*)(int)))(int);' \
     'extern "C" void (*signal (int, void (*)(int)) throw ())(int);' \
     'void (*signal ()) ();' 
   do
     AC_COMPILE_IFELSE([
	 AC_LANG_PROGRAM([[

#include <sys/types.h>
#include <signal.h>
#ifdef signal
# undef signal
#endif
$groff_declaration

	 ]],
	 [[

int i;

	 ]])
       ],
       [break],
       [continue])
   done

   if test -n "$groff_declaration"; then
     AC_MSG_RESULT([void])
     AC_DEFINE([RETSIGTYPE], [void],
       [Define as the return type of signal handlers
	(`int' or `void').])
   else
     AC_MSG_RESULT([int])
     AC_DEFINE([RETSIGTYPE], [int],
       [Define as the return type of signal handlers
	(`int' or `void').])
   fi])


AC_DEFUN([GROFF_SYS_NERR],
  [AC_LANG_PUSH([C++])
   AC_MSG_CHECKING([for sys_nerr in <errno.h>, <stdio.h>, or <stdlib.h>])
   AC_COMPILE_IFELSE([
       AC_LANG_PROGRAM([[

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>

       ]],
       [[

int k;
k = sys_nerr;

       ]])
     ],
     [AC_MSG_RESULT([yes])
      AC_DEFINE([HAVE_SYS_NERR], [1],
	[Define if you have sys_nerr in <errno.h>, <stdio.h>, or <stdio.h>.])],
     [AC_MSG_RESULT([no])])
   AC_LANG_POP([C++])])

AC_DEFUN([GROFF_SYS_ERRLIST],
  [AC_MSG_CHECKING([for sys_errlist[] in <errno.h>, <stdio.h>, or <stdlib.h>])
   AC_COMPILE_IFELSE([
       AC_LANG_PROGRAM([[

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>

       ]],
       [[

int k;
k = (int)sys_errlist[0];

       ]])
     ],
     [AC_MSG_RESULT([yes])
      AC_DEFINE([HAVE_SYS_ERRLIST], [1],
	[Define if you have sys_errlist in <errno.h>, <stdio.h>, or <stdlib.h>.])],
     [AC_MSG_RESULT([no])])])

AC_DEFUN([GROFF_OSFCN_H],
  [AC_LANG_PUSH([C++])
   AC_MSG_CHECKING([C++ <osfcn.h>])
   AC_COMPILE_IFELSE([
       AC_LANG_PROGRAM([[

#include <osfcn.h>

       ]],
       [[

read(0, 0, 0);
open(0, 0);

       ]])
     ],
     [AC_MSG_RESULT([yes])
      AC_DEFINE([HAVE_CC_OSFCN_H], [1],
	[Define if you have a C++ <osfcn.h>.])],
     [AC_MSG_RESULT([no])])
   AC_LANG_POP([C++])])


AC_DEFUN([GROFF_LIMITS_H],
  [AC_LANG_PUSH([C++])
   AC_MSG_CHECKING([C++ <limits.h>])
   AC_COMPILE_IFELSE([
       AC_LANG_PROGRAM([[

#include <limits.h>

       ]],
       [[

int x = INT_MIN;
int y = INT_MAX;
int z = UCHAR_MAX;

       ]])
     ],
     [AC_MSG_RESULT([yes])
      AC_DEFINE([HAVE_CC_LIMITS_H], [1],
	[Define if you have a C++ <limits.h>.])],
     [AC_MSG_RESULT([no])])
   AC_LANG_POP([C++])])

AC_DEFUN([GROFF_TIME_T],
  [AC_LANG_PUSH([C++])
   AC_MSG_CHECKING([for declaration of time_t])
   AC_COMPILE_IFELSE([
       AC_LANG_PROGRAM([[

#include <time.h>

       ]],
       [[

time_t t = time(0);
struct tm *p = localtime(&t);

       ]])
     ],
     [AC_MSG_RESULT([yes])],
     [AC_MSG_RESULT([no])
      AC_DEFINE([LONG_FOR_TIME_T], [1],
	[Define if localtime() takes a long * not a time_t *.])])
   AC_LANG_POP([C++])])

AC_DEFUN([GROFF_STRUCT_EXCEPTION],
  [AC_MSG_CHECKING([struct exception])
   AC_COMPILE_IFELSE([
       AC_LANG_PROGRAM([[

#include <math.h>

       ]],
       [[

struct exception e;

       ]])
     ],
     [AC_MSG_RESULT([yes])
      AC_DEFINE([HAVE_STRUCT_EXCEPTION], [1],
	[Define if <math.h> defines struct exception.])],
     [AC_MSG_RESULT([no])])])

AC_DEFUN([GROFF_ARRAY_DELETE],
  [AC_LANG_PUSH([C++])
   AC_MSG_CHECKING([whether ANSI array delete syntax is supported])
   AC_COMPILE_IFELSE([
       AC_LANG_PROGRAM(, [[

char *p = new char[5];
delete [] p;

       ]])
     ],
     [AC_MSG_RESULT([yes])],
     [AC_MSG_RESULT([no])
      AC_DEFINE([ARRAY_DELETE_NEEDS_SIZE], [1],
	[Define if your C++ doesn't understand `delete []'.])])
   AC_LANG_POP([C++])])

AC_DEFUN([GROFF_TRADITIONAL_CPP],
  [AC_LANG_PUSH([C++])
   AC_MSG_CHECKING([traditional preprocessor])
   AC_COMPILE_IFELSE([
       AC_LANG_PROGRAM([[

#define name2(a, b) a/**/b

       ]],
       [[

int name2(foo, bar);

       ]])
     ],
     [AC_MSG_RESULT([yes])
      AC_DEFINE([TRADITIONAL_CPP], [1],
	[Define if your C++ compiler uses a traditional (Reiser) preprocessor.])],
     [AC_MSG_RESULT([no])])
   AC_LANG_POP([C++])])

AC_DEFUN([GROFF_WCOREFLAG],
  [AC_MSG_CHECKING([w_coredump])
   AC_RUN_IFELSE([
       AC_LANG_PROGRAM([[

#include <sys/types.h>
#include <sys/wait.h>

       ]],
       [[

main()
{
#ifdef WCOREFLAG
  exit(1);
#else
  int i = 0;
  ((union wait *)&i)->w_coredump = 1;
  exit(i != 0200);
#endif
}

       ]])
     ],
     [AC_MSG_RESULT([yes])
      AC_DEFINE(WCOREFLAG, 0200,
	[Define if the 0200 bit of the status returned by wait() indicates
	 whether a core image was produced for a process that was terminated
	 by a signal.])],
     [AC_MSG_RESULT([no])],
     [AC_MSG_RESULT([no])])])


AC_DEFUN([GROFF_BROKEN_SPOOLER_FLAGS],
  [AC_MSG_CHECKING([default value for grops -b option])
   test -n "${BROKEN_SPOOLER_FLAGS}" || BROKEN_SPOOLER_FLAGS=0
   AC_MSG_RESULT([$BROKEN_SPOOLER_FLAGS])
   AC_SUBST([BROKEN_SPOOLER_FLAGS])])


AC_DEFUN([GROFF_PAGE],
  [AC_MSG_CHECKING([default paper size])
   groff_prefix=$prefix
   test "x$prefix" = "xNONE" && groff_prefix=$ac_default_prefix
   if test -z "$PAGE"; then
     descfile=
     if test -r $groff_prefix/share/groff/font/devps/DESC; then
       descfile=$groff_prefix/share/groff/font/devps/DESC
     elif test -r $groff_prefix/lib/groff/font/devps/DESC; then
       descfile=$groff_prefix/lib/groff/font/devps/DESC
     else
       for f in $groff_prefix/share/groff/*/font/devps/DESC; do
	 if test -r $f; then
	   descfile=$f
	   break
	 fi
       done
     fi

     if test -n "$descfile"; then
       if grep ['^paperlength[	 ]\+841890'] $descfile >/dev/null 2>&1; then
	 PAGE=A4
       elif grep ['^papersize[	 ]\+[aA]4'] $descfile >/dev/null 2>&1; then
	 PAGE=A4
       fi
     fi
   fi

   if test -z "$PAGE"; then
     dom=`awk '([$]1 == "dom" || [$]1 == "search") { print [$]2; exit}' \
	 /etc/resolv.conf 2>/dev/null`
     if test -z "$dom"; then
       dom=`(domainname) 2>/dev/null | tr -d '+'`
       if test -z "$dom" \
	  || test "$dom" = '(none)'; then
	 dom=`(hostname) 2>/dev/null | grep '\.'`
       fi
     fi
     # If the top-level domain is two letters and it's not `us' or `ca'
     # then they probably use A4 paper.
     case "$dom" in
     [*.[Uu][Ss]|*.[Cc][Aa])]
       ;;
     [*.[A-Za-z][A-Za-z])]
       PAGE=A4 ;;
     esac
   fi

   test -n "$PAGE" || PAGE=letter
   if test "x$PAGE" = "xA4"; then
     AC_DEFINE([PAGEA4], [1],
       [Define if the printer's page size is A4.])
   fi
   AC_MSG_RESULT([$PAGE])
   AC_SUBST([PAGE])])


AC_DEFUN([GROFF_CXX_CHECK],
  [AC_REQUIRE([AC_PROG_CXX])
   AC_LANG_PUSH([C++])
   if test "$cross_compiling" = no; then
     AC_MSG_CHECKING([that C++ compiler can compile simple program])
   fi
   AC_RUN_IFELSE([
       AC_LANG_SOURCE([[

int main() {
  return 0;
}

       ]])
     ],
     [AC_MSG_RESULT([yes])],
     [AC_MSG_RESULT([no])
      AC_MSG_ERROR([a working C++ compiler is required])],
     [:])

   if test "$cross_compiling" = no; then
     AC_MSG_CHECKING([that C++ static constructors and destructors are called])
   fi
   AC_RUN_IFELSE([
       AC_LANG_SOURCE([[

extern "C" {
  void _exit(int);
}

int i;
struct A {
  char dummy;
  A() { i = 1; }
  ~A() { if (i == 1) _exit(0); }
};

A a;

int main()
{
  return 1;
}

       ]])
     ],
     [AC_MSG_RESULT([yes])],
     [AC_MSG_RESULT([no])
      AC_MSG_ERROR([a working C++ compiler is required])],
     [:])

   AC_MSG_CHECKING([that header files support C++])
   AC_LINK_IFELSE([
       AC_LANG_PROGRAM([[

#include <stdio.h>

       ]],
       [[

fopen(0, 0);

       ]])
     ],
     [AC_MSG_RESULT([yes])],
     [AC_MSG_RESULT([no])
      AC_MSG_ERROR([header files do not support C++
		   (if you are using a version of gcc/g++ earlier than 2.5,
		   you should install libg++)])])
   AC_LANG_POP([C++])])


AC_DEFUN([GROFF_TMAC],
  [AC_MSG_CHECKING([for prefix of system macro packages])
   sys_tmac_prefix=
   sys_tmac_file_prefix=
   for d in /usr/share/lib/tmac /usr/lib/tmac; do
     for t in "" tmac.; do
       for m in an s m; do
	 f=$d/$t$m
	 if test -z "$sys_tmac_prefix" \
	    && test -f $f \
	    && grep '^\.if' $f >/dev/null 2>&1; then
	   sys_tmac_prefix=$d/$t
	   sys_tmac_file_prefix=$t
	 fi
       done
     done
   done
   AC_MSG_RESULT([$sys_tmac_prefix])
   AC_SUBST([sys_tmac_prefix])

   AC_MSG_CHECKING([which system macro packages should be made available])
   tmac_wrap=
   if test "x$sys_tmac_file_prefix" = "xtmac."; then
     for f in $sys_tmac_prefix*; do
       suff=`echo $f | sed -e "s;$sys_tmac_prefix;;"`
       case "$suff" in
       e)
	 ;;
       *)
	 grep "Copyright.*Free Software Foundation" $f >/dev/null \
	      || tmac_wrap="$tmac_wrap $suff" ;;
       esac
     done
   elif test -n "$sys_tmac_prefix"; then
     files=`echo $sys_tmac_prefix*`
     grep "\\.so" $files >conftest.sol
     for f in $files; do
       case "$f" in
       ${sys_tmac_prefix}e)
	 ;;
       *.me)
	 ;;
       */ms.*)
	 ;;
       *)
	 b=`basename $f`
	 if grep "\\.so.*/$b\$" conftest.sol >/dev/null \
	    || grep -l "Copyright.*Free Software Foundation" $f >/dev/null; then
	   :
	 else
	   suff=`echo $f | sed -e "s;$sys_tmac_prefix;;"`
	   case "$suff" in
	   tmac.*)
	     ;;
	   *)
	     tmac_wrap="$tmac_wrap $suff" ;;
	   esac
	 fi
       esac
     done
     rm -f conftest.sol
   fi
   AC_MSG_RESULT([$tmac_wrap])
   AC_SUBST([tmac_wrap])])


AC_DEFUN([GROFF_G],
  [AC_MSG_CHECKING([for existing troff installation])
   if test "x`(echo .tm '|n(.g' | tr '|' '\\\\' | troff -z -i 2>&1) 2>/dev/null`" = x0; then
     AC_MSG_RESULT([yes])
     g=g
   else
     AC_MSG_RESULT([no])
     g=
   fi
   AC_SUBST([g])])


# We need the path to install-sh to be absolute.

AC_DEFUN([GROFF_INSTALL_SH],
  [AC_REQUIRE([AC_CONFIG_AUX_DIR_DEFAULT])
   ac_dir=`cd $ac_aux_dir; pwd`
   ac_install_sh="$ac_dir/install-sh -c"])


# Test whether install-info is available.

AC_DEFUN([GROFF_INSTALL_INFO],
  [if test $docadd_info = yes; then
     AC_CHECK_PROGS([INSTALL_INFO], [install-info], [:])
   fi])


# At least one UNIX system, Apple Macintosh Rhapsody 5.5,
# does not have -lm ...

AC_DEFUN([GROFF_LIBM],
  [AC_CHECK_LIB([m], [sin], [LIBM=-lm])
   AC_SUBST([LIBM])])


# ... while the MinGW implementation of GCC for Microsoft Win32
# does not seem to have -lc.

AC_DEFUN([GROFF_LIBC],
  [AC_CHECK_LIB([c], [main], [LIBC=-lc])
   AC_SUBST([LIBC])])


# Check for EBCDIC -- stolen from the OS390 Unix LYNX port

AC_DEFUN([GROFF_EBCDIC],
  [AC_MSG_CHECKING([whether character set is EBCDIC])
   AC_COMPILE_IFELSE([
       AC_LANG_PROGRAM([[

/* Treat any failure as ASCII for compatibility with existing art.
   Use compile-time rather than run-time tests for cross-compiler
   tolerance. */
#if '0' != 240
make an error "Character set is not EBCDIC"
#endif

       ]])
     ],
     [groff_cv_ebcdic="yes"
      TTYDEVDIRS="font/devcp1047"
      AC_MSG_RESULT([yes])
      AC_DEFINE(IS_EBCDIC_HOST, 1,
	[Define if the host's encoding is EBCDIC.])],
     [groff_cv_ebcdic="no"
     TTYDEVDIRS="font/devascii font/devlatin1"
     OTHERDEVDIRS="font/devlj4 font/devlbp"
     AC_MSG_RESULT([no])])
   AC_SUBST([TTYDEVDIRS])
   AC_SUBST([OTHERDEVDIRS])])


# Check for OS/390 Unix.  We test for EBCDIC also -- the Linux port (with
# gcc) to OS/390 uses ASCII internally.

AC_DEFUN([GROFF_OS390],
  [if test "$groff_cv_ebcdic" = "yes"; then
     AC_MSG_CHECKING([for OS/390 Unix])
     case `uname` in
     OS/390)
       CFLAGS="$CFLAGS -D_ALL_SOURCE"
       AC_MSG_RESULT([yes]) ;;
     *)
       AC_MSG_RESULT([no]) ;;
     esac
   fi])


# Check whether Windows scripts like `afmtodit.cmd' should be installed.

AC_DEFUN([GROFF_CMD_FILES],
  [AC_MSG_CHECKING([whether to install .cmd wrapper scripts for Windows])
   case "$host_os" in
   *mingw*)
     make_winscripts=winscripts
     make_install_winscripts=install_winscripts
     make_uninstall_winscripts=uninstall_winscripts
     AC_MSG_RESULT([yes]) ;;
   *)
     make_winscripts=
     make_install_winscripts=
     make_uninstall_winscripts=
     AC_MSG_RESULT([no]) ;;
   esac
   AC_SUBST([make_winscripts])
   AC_SUBST([make_install_winscripts])
   AC_SUBST([make_uninstall_winscripts])])


# Check whether we need a declaration for a function.
#
# Stolen from GNU bfd.

AC_DEFUN([GROFF_NEED_DECLARATION],
  [AC_MSG_CHECKING([whether $1 must be declared])
   AC_LANG_PUSH([C++])
   AC_CACHE_VAL([groff_cv_decl_needed_$1],
     [AC_COMPILE_IFELSE([
	  AC_LANG_PROGRAM([[

#include <stdio.h>
#ifdef HAVE_STRING_H
#include <string.h>
#endif
#ifdef HAVE_STRINGS_H
#include <strings.h>
#endif
#ifdef HAVE_STDLIB_H
#include <stdlib.h>
#endif
#ifdef HAVE_SYS_TIME_H
#include <sys/time.h>
#endif
#ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif
#ifdef HAVE_MATH_H
#include <math.h>
#endif

	  ]],
	  [[

#ifndef $1
  char *p = (char *) $1;
#endif

	  ]])
      ],
      [groff_cv_decl_needed_$1=no],
      [groff_cv_decl_needed_$1=yes])])
   AC_MSG_RESULT([$groff_cv_decl_needed_$1])
   if test $groff_cv_decl_needed_$1 = yes; then
     AC_DEFINE([NEED_DECLARATION_]translit($1, [a-z], [A-Z]), [1],
       [Define if your C++ doesn't declare ]$1[().])
   fi
   AC_LANG_POP([C++])])


# If mkstemp() isn't available, use our own mkstemp.cpp file.

AC_DEFUN([GROFF_MKSTEMP],
  [AC_MSG_CHECKING([for mkstemp])
   AC_LANG_PUSH([C++])
   AC_LIBSOURCE([mkstemp.cpp])
   AC_LINK_IFELSE([
       AC_LANG_PROGRAM([[

#include <stdlib.h>
#include <unistd.h>
int (*f) (char *);

       ]],
       [[

f = mkstemp;

       ]])
     ],
     [AC_MSG_RESULT([yes])
      AC_DEFINE([HAVE_MKSTEMP], [1], [Define if you have mkstemp().])],
     [AC_MSG_RESULT([no])
      _AC_LIBOBJ([mkstemp])])
   AC_LANG_POP([C++])])


# Test whether <inttypes.h> exists, doesn't clash with <sys/types.h>,
# and declares uintmax_t.  Taken from the fileutils package.

AC_DEFUN([GROFF_INTTYPES_H],
  [AC_LANG_PUSH([C++])
   AC_MSG_CHECKING([C++ <inttypes.h>])
   AC_COMPILE_IFELSE([
       AC_LANG_PROGRAM([[

#include <sys/types.h>
#include <inttypes.h>

       ]],
       [[

uintmax_t i = (uintmax_t)-1;

       ]])
     ],
     [groff_cv_header_inttypes_h=yes
      AC_DEFINE([HAVE_CC_INTTYPES_H], [1],
	[Define if you have a C++ <inttypes.h>.])],
     [groff_cv_header_inttypes_h=no])
   AC_MSG_RESULT([$groff_cv_header_inttypes_h])
   AC_LANG_POP([C++])])


# Test for working `unsigned long long'.  Taken from the fileutils package.

AC_DEFUN([GROFF_UNSIGNED_LONG_LONG],
  [AC_LANG_PUSH([C++])
   AC_MSG_CHECKING([for unsigned long long])
   AC_LINK_IFELSE([
       AC_LANG_PROGRAM([[

unsigned long long ull = 1;
int i = 63;
unsigned long long ullmax = (unsigned long long)-1;

       ]],
       [[

return ull << i | ull >> i | ullmax / ull | ullmax % ull;

       ]])
     ],
     [groff_cv_type_unsigned_long_long=yes],
     [groff_cv_type_unsigned_long_long=no])
   AC_MSG_RESULT([$groff_cv_type_unsigned_long_long])
   AC_LANG_POP([C++])])


# Define uintmax_t to `unsigned long' or `unsigned long long'
# if <inttypes.h> does not exist.  Taken from the fileutils package.

AC_DEFUN([GROFF_UINTMAX_T],
  [AC_REQUIRE([GROFF_INTTYPES_H])
   if test $groff_cv_header_inttypes_h = no; then
     AC_REQUIRE([GROFF_UNSIGNED_LONG_LONG])
     test $groff_cv_type_unsigned_long_long = yes \
	  && ac_type='unsigned long long' \
	  || ac_type='unsigned long'
     AC_DEFINE_UNQUOTED([uintmax_t], [$ac_type],
       [Define uintmax_t to `unsigned long' or `unsigned long long' if
	<inttypes.h> does not exist.])
   fi])


# Identify PATH_SEPARATOR character to use in GROFF_FONT_PATH and
# GROFF_TMAC_PATH which is appropriate for the target system (POSIX=':',
# MS-DOS/Win32=';').
#
# The logic to resolve this test is already encapsulated in
# `${srcdir}/src/include/nonposix.h'.

AC_DEFUN([GROFF_TARGET_PATH_SEPARATOR],
  [AC_MSG_CHECKING([separator character to use in groff search paths])
   cp ${srcdir}/src/include/nonposix.h conftest.h
   AC_COMPILE_IFELSE([
       AC_LANG_PROGRAM([[
	
#include <ctype.h>
#include "conftest.h"

       ]],
       [[

#if PATH_SEP_CHAR == ';'
make an error "Path separator is ';'"
#endif

       ]])
     ],
     [GROFF_PATH_SEPARATOR=":"],
     [GROFF_PATH_SEPARATOR=";"])
   AC_MSG_RESULT([$GROFF_PATH_SEPARATOR])
   AC_SUBST(GROFF_PATH_SEPARATOR)])


# Check for X11.

AC_DEFUN([GROFF_X11],
  [AC_REQUIRE([AC_PATH_XTRA])
   groff_no_x=$no_x
   if test -z "$groff_no_x"; then
     OLDCFLAGS=$CFLAGS
     OLDLDFLAGS=$LDFLAGS
     OLDLIBS=$LIBS
     CFLAGS="$CFLAGS $X_CFLAGS"
     LDFLAGS="$LDFLAGS $X_LIBS"
     LIBS="$LIBS $X_PRE_LIBS -lX11 $X_EXTRA_LIBS"

     LIBS="$LIBS -lXaw"
     AC_MSG_CHECKING([for Xaw library and header files])
     AC_LINK_IFELSE([
	 AC_LANG_PROGRAM([[

#include <X11/Intrinsic.h>
#include <X11/Xaw/Simple.h>

	 ]],
	 [])
       ],
       [AC_MSG_RESULT([yes])],
       [AC_MSG_RESULT([no])
	groff_no_x="yes"])

     LIBS="$LIBS -lXmu"
     AC_MSG_CHECKING([for Xmu library and header files])
     AC_LINK_IFELSE([
	 AC_LANG_PROGRAM([[

#include <X11/Intrinsic.h>
#include <X11/Xmu/Converters.h>

	 ]],
	 [])
       ],
       [AC_MSG_RESULT([yes])],
       [AC_MSG_RESULT([no])
	groff_no_x="yes"])

     CFLAGS=$OLDCFLAGS
     LDFLAGS=$OLDLDFLAGS
     LIBS=$OLDLIBS
   fi

   if test "x$groff_no_x" = "xyes"; then
     AC_MSG_NOTICE([gxditview and xtotroff won't be built])
   else
     XDEVDIRS="font/devX75 font/devX75-12 font/devX100 font/devX100-12"
     XPROGDIRS="src/devices/xditview src/utils/xtotroff"
     XLIBDIRS="src/libs/libxutil"
   fi

   AC_SUBST([XDEVDIRS])
   AC_SUBST([XPROGDIRS])
   AC_SUBST([XLIBDIRS])])


# Set up the `--with-appresdir' command line option.

# Don't quote AS_HELP_STRING!
AC_DEFUN([GROFF_APPRESDIR_OPTION],
  [AC_ARG_WITH([appresdir],
     AS_HELP_STRING([--with-appresdir=DIR],
		    [X11 application resource files]))])


# Get a default value for the application resource directory.
#
# We ignore the `XAPPLRES' and `XUSERFILESEARCHPATH' environment variables.
#
# By default if --with-appresdir is not used, we will install the
# gxditview resources in $prefix/lib/X11/app-defaults.
#
# Note that if --with-appresdir was passed to `configure', no prefix is
# added to `appresdir'.

AC_DEFUN([GROFF_APPRESDIR_DEFAULT],
  [if test -z "$groff_no_x"; then
     if test "x$with_appresdir" = "x"; then
       if test "x$prefix" = "xNONE"; then
         appresdir=$ac_default_prefix/lib/X11/app-defaults
       else
         appresdir=$prefix/lib/X11/app-defaults
       fi
     else
       appresdir=$with_appresdir
     fi
   fi
   AC_SUBST([appresdir])])

# Emit warning if --with-appresdir hasn't been used.

AC_DEFUN([GROFF_APPRESDIR_CHECK],
  [if test -z "$groff_no_x"; then
     if test "x$with_appresdir" = "x"; then
       AC_MSG_NOTICE([
  The application resource files for gxditview (GXditview and
  GXditview-color) will be installed in:

    $appresdir

  (existing files will be saved by appending `.old' to the file
  name).

  To install them into a different directory, say,
  `/etc/X11/app-defaults', add
  `--with-appresdir=/etc/X11/app-defaults' to the configure script
  command line options and rerun it (`prefix' value has no effect on
  a --with-appresdir option).

  If the gxditview resources are installed in a directory that is not
  one of the default X11 resources directories (common default
  directories are /usr/lib/X11/app-defaults,
  /usr/share/X11/app-defaults and /etc/X11/app-defaults), you will
  have to set the environment variable XFILESEARCHPATH to this
  path.  More details can be found in the X(7) manual page, or in "X
  Toolkit Intrinsics - C Language Interface manual"
       ])
     fi
   fi])


# Set up the `--with-grofferdir' command line option.

AC_DEFUN([GROFF_GROFFERDIR_OPTION],
  [AC_ARG_WITH([grofferdir],
     AS_HELP_STRING([--with-grofferdir=DIR],
		    [groffer files location]))])


AC_DEFUN([GROFF_GROFFERDIR_DEFAULT],
  [if test "x$with_grofferdir" = "x"; then
    groffer_dir=$libprogramdir/groffer
  else
    groffer_dir=$with_grofferdir
  fi
  AC_SUBST([groffer_dir])])


AC_DEFUN([GROFF_LIBPROGRAMDIR_DEFAULT],
  libprogramdir=$libdir/groff
  AC_SUBST([libprogramdir]))


AC_DEFUN([GROFF_GLILYPONDDIR_DEFAULT],
  glilypond_dir=$libprogramdir/glilypond
  AC_SUBST([glilypond_dir]))


AC_DEFUN([GROFF_GPINYINDIR_DEFAULT],
  gpinyin_dir=$libprogramdir/gpinyin
  AC_SUBST([gpinyin_dir]))


AC_DEFUN([GROFF_GROGDIR_DEFAULT],
  grog_dir=$libprogramdir/grog
  AC_SUBST([grog_dir]))

AC_DEFUN([GROFF_REFERDIR_DEFAULT],
  referdir=$libprogramdir/refer
  AC_SUBST([referdir]))

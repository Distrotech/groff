// -*- C++ -*-
/* Copyright (C) 1989, 1990, 1991, 1992 Free Software Foundation, Inc.
     Written by James Clark (jjc@jclark.com)

This file is part of groff.

groff is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free
Software Foundation; either version 2, or (at your option) any later
version.

groff is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License along
with groff; see the file COPYING.  If not, write to the Free Software
Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA. */

#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <stdlib.h>

#include "posix.h"
#include "lib.h"
#include "errarg.h"
#include "error.h"

extern "C" {
  // Sun's stdlib.h fails to declare this.
  char *mktemp(char *);
  int mkstemp(char *);
}

// If this is set, create temporary files there
#define GROFF_TMPDIR_ENVVAR "GROFF_TMPDIR"
// otherwise if this is set, create temporary files there
#define TMPDIR_ENVVAR "TMPDIR"
// otherwise create temporary files here.
#define DEFAULT_TMPDIR "/tmp"
// Use this as the prefix for temporary filenames.
#define TMPFILE_PREFIX  "groff"

/*
 *  Generate a temporary name template with a postfix
 *  immediately after the TMPFILE_PREFIX.
 *  It uses the groff preferences for a temporary directory.
 *  Note that no file name is either created or opened,
 *  only the *template* is returned.
 */

char *xtmptemplate(char *postfix=0)
{
  const char *dir = getenv(GROFF_TMPDIR_ENVVAR);
  int postlen = 0;

  if (postfix)
    postlen = strlen(postfix);
    
  if (!dir) {
    dir = getenv(TMPDIR_ENVVAR);
    if (!dir)
      dir = DEFAULT_TMPDIR;
  }
  
  const char *p = strrchr(dir, '/');
  int needs_slash = (!p || p[1]);
  char *templ = new char[strlen(dir) + needs_slash
		+ sizeof(TMPFILE_PREFIX) - 1 + 6 + 1 + postlen];
  strcpy(templ, dir);
  if (needs_slash)
    strcat(templ, "/");
  strcat(templ, TMPFILE_PREFIX);
  if (postlen > 0)
    strcat(templ, postfix);
  strcat(templ, "XXXXXX");

  return( templ );
}

// Open a temporary file and with fatal error on failure.

#ifndef _MSC_VER

FILE *xtmpfile(char **namep=0, char *postfix=0, int do_unlink=1)
{
  char *templ = xtmptemplate(postfix);

#ifdef HAVE_MKSTEMP
  errno = 0;
  int fd = mkstemp(templ);
  if (fd < 0)
    fatal("cannot create temporary file: %1", strerror(errno));
  errno = 0;
  FILE *fp = fdopen(fd, "w+");
  if (!fp)
    fatal("fdopen: %1", strerror(errno));
#else /* not HAVE_MKSTEMP */
  if (!mktemp(templ) || !templ[0])
    fatal("cannot create file name for temporary file");
  errno = 0;
  FILE *fp = fopen(templ, "w+");
  if (!fp)
    fatal("cannot open `%1': %2", templ, strerror(errno));
#endif /* not HAVE_MKSTEMP */
  if ((do_unlink) && (unlink(templ) < 0))
    error("cannot unlink `%1': %2", templ, strerror(errno));
  if ((namep != 0) && ((*namep) != 0)) {
    *namep = templ;
  } else {
    a_delete templ;
  }
  return fp;
}

#else

// If you're not running Unix, the following will do:
FILE *xtmpfile(char **namep, char *postfix=0, int do_unlink=1)
{
  FILE *fp = tmpfile();
  if (!fp)
    fatal("couldn't create temporary file");
  return fp;
}

#endif /* _MSC_VER */

// -*- C++ -*-
/* Copyright (C) 1999 Free Software Foundation, Inc.
 *
 *  Gaius Mulley (gaius@glam.ac.uk) wrote post-html.cc
 *  but it owes a huge amount of ideas and raw code from
 *  James Clark (jjc@jclark.com) grops/ps.cc.
 */

/*
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

#include "driver.h"
#include "stringclass.h"
#include "cset.h"

#include <time.h>

#ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif

#include <stdio.h>
#include <fcntl.h>

#if !defined(TRUE)
#   define TRUE  (1==1)
#endif
#if !defined(FALSE)
#   define FALSE (1==0)
#endif

printer *make_printer()
{
  // return new html_printer;
  return( 0 );
}

static void usage();

int main(int argc, char **argv)
{
  program_name = argv[0];
  static char stderr_buf[BUFSIZ];
  setbuf(stderr, stderr_buf);
  int c;
  while ((c = getopt(argc, argv, "F:atTvdgmx?I:r:")) != EOF)
    switch(c) {
    case 'v':
      {
	extern const char *Version_string;
	fprintf(stderr, "post-grohtml version %s\n", Version_string);
	fflush(stderr);
	break;
      }
    case 'F':
      font::command_line_font_dir(optarg);
      break;
    case '?':
      usage();
      break;
    default:
      assert(0);
    }
  if (optind >= argc) {
    do_file("-");
  } else {
    for (int i = optind; i < argc; i++)
      do_file(argv[i]);
  }
  delete pr;
  return 0;
}

static void usage()
{
  fprintf(stderr, "usage: %s [-avdgmt?] [-r resolution] [-F dir] [-I imagetype] [files ...]\n",
	  program_name);
  exit(1);
}

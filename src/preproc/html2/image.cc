// -*- C++ -*-
/* Copyright (C) 2000 Free Software Foundation, Inc.
     Written by Gaius Mulley (gaius@glam.ac.uk) but owes much
     of the code from James Clark (jjc@jclark.com).

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
#include <signal.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>
#include <stdlib.h>
#include <errno.h>
#include "lib.h"
#include "errarg.h"
#include "error.h"
#include "stringclass.h"
#include "posix.h"

#include <errno.h>
#include <sys/types.h>
#ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif

#ifdef _POSIX_VERSION
#include <sys/wait.h>
#define PID_T pid_t
#else /* not _POSIX_VERSION */
#define PID_T int
#endif /* not _POSIX_VERSION */

extern char *strerror();

static char *file_contents;
static int   stdoutfd  =1;      // output file descriptor - normally 1 but might move
                                // -1 means closed

#define DEBUGGING

/*
 *  eventually it would be nice to have the choice of image devices.
 *  This could be implemented once we have a -Tpng or -Tpdf device driver.
 *  For now we use what is available.. postscript, ghostscript + png utils.
 */

#define IMAGEDEVICE    "-Tps"


static int do_file(const char *filename);

/*
 *  sys_fatal - writes a fatal error message. Taken from src/roff/groff/pipeline.c
 */

static void sys_fatal(const char *s)
{
  fprintf(stderr, "%s: %s: %s", program_name, s, strerror(errno));
}

    sprintf(buffer,
	    "echo showpage | gs -q -dSAFER -sDEVICE=%s -r%d -g%dx%d -sOutputFile=- %s - 2> /dev/null > %s.png \n",
	    image_device,
	    image_res,
	    (end_region_hpos-start_region_hpos)*image_res/font::res+IMAGE_BOARDER_PIXELS,
	    (end_region_vpos-start_region_vpos)*image_res/font::res+IMAGE_BOARDER_PIXELS,
	    ps_src, image_name);


/*
 *  the class and methods for retaining ascii text
 */

struct char_block {
  enum { SIZE = 256 };
  char          buffer[SIZE];
  int           used;
  char_block   *next;

  char_block();
};

char_block::char_block()
: used(0), next(0)
{
}

class char_buffer {
public:
  char_buffer();
  ~char_buffer();
  int  read_file(FILE *fp);
  int  do_html(int argc, char *argv[]);
  int  do_image(int argc, char *argv[]);
  int  write_file(int is_html);
private:
  char_block *head;
  char_block *tail;
};

char_buffer::char_buffer()
: head(0), tail(0)
{
}

char_buffer::~char_buffer()
{
  while (head != 0) {
    char_block *temp = head;
    head = head->next;
    delete temp;
  }
}

int char_buffer::read_file (FILE *fp)
{
  int i=0;
  unsigned int old_used;
  int n;

  while (! feof(fp)) {
    if (tail == 0) {
      tail = new char_block;
      head = tail;
    } else {
      if (tail->used == char_block::SIZE) {
	tail->next = new char_block;
	tail       = tail->next;
      }
    }
    // at this point we have a tail which is ready for the the next SIZE bytes of the file

    n = fread(tail->buffer, sizeof(char), char_block::SIZE-tail->used, fp);
    if (n <= 0) {
      // error
      return( 0 );
    } else {
      tail->used += n*sizeof(char);
    }
  }
  return( 1 );
}

/*
 *  writeNbytes - writes n bytes to stdout.
 */

static void writeNbytes (char *s, int l)
{
  int n=0;
  int r;

  while (n<l) {
    r = write(stdoutfd, s, l-n);
    if (r<0) {
      sys_fatal("write");
    }
    n += r;
    s += r;
  }
}

/*
 *  writeString - writes a string to stdout.
 */

static void writeString (char *s)
{
  writeNbytes(s, strlen(s));
}

/*
 *  write_file - writes the buffer to stdout (troff).
 *               It prepends the number register set to 1 if stdout is
 *               connected to troff -Thtml and 0 if connected to troff -Tps
 */

int char_buffer::write_file (int is_html)
{
  char_block *t=head;
  int r;

  fprintf(stderr, "output to pipeline\n");
  if (is_html) {
    writeString(".nr htmlflip 1\n");
  } else {
    writeString(".nr htmlflip 0\n");
    fprintf(stderr, ".nr htmlflip 0\n");
  }
  if (t != 0) {
    do {
      writeNbytes(t->buffer, t->used);
      fprintf(stderr, "hunk..\n");
      t = t->next;
    } while ((t != head) && (t != 0));
  }
  if (close(stdoutfd) < 0)
    sys_fatal("close");

  // now we grab fd=1 so that the next pipe cannot use fd=1
  if (stdoutfd == 1) {
    if (dup(2) != stdoutfd) {
      sys_fatal("dup failed to use fd=1");
    }
  }

  return( 1 );
}

/*
 *  replaceFd - replace a file descriptor, was, with, willbe.
 */

static void replaceFd (int was, int willbe)
{
  int dupres;

  if (was != willbe) {
    if (close(was)<0) {
      sys_fatal("close");
    }
    dupres = dup(willbe);
    if (dupres != was) {
      sys_fatal("dup");
      fprintf(stderr, "trying to replace fd=%d with %d dup used %d\n", was, willbe, dupres);
      if (willbe == 1) {
	fprintf(stderr, "likely that stdout should be opened before %d\n", was);
      }
      exit(1);
    }
    if (close(willbe) < 0) {
      sys_fatal("close");
    }
  }
}

/*
 *  waitForChild - waits for child, pid, to exit.
 */

static void waitForChild (PID_T pid)
{
  PID_T waitpd;
  int   status;

  waitpd = wait(&status);
  if (waitpd != pid)
    sys_fatal("wait");
}

/*
 *  do_html - sets the troff number htmlflip and
 *            writes out the buffer to troff -Thtml
 */

int char_buffer::do_html(int argc, char *argv[])
{
  int pdes[2];
  PID_T pid;

  if (pipe(pdes) < 0)
    sys_fatal("pipe");

  argv++;   // skip pre-grohtml argv[0]
  pid = fork();
  if (pid < 0)
    sys_fatal("fork");

  if (pid == 0) {
    // child
    replaceFd(0, pdes[0]);
    // close end we are not using
    if (close(pdes[1])<0)
      sys_fatal("close");

    execvp(argv[0], argv);
    error("couldn't exec %1: %2", argv[0], strerror(errno), (char *)0);
    fflush(stderr);		/* just in case error() doesn't */
    exit(1);
  } else {
    // parent

    replaceFd(1, pdes[1]);
    // close end we are not using
    if (close(pdes[0])<0)
      sys_fatal("close");

    write_file(1);
    waitForChild(pid);
  }
  return( 0 );
}

/*
 *  alterToDeviceImage - manipulates the argv to include IMAGEDEVICE rather than -Thtml2
 */

static void alterToDeviceImage (int argc, char *argv[])
{
  int i=0;

  while (i < argc) {
    if (strcmp(argv[i], "-Thtml2") == 0) {
      argv[i] = IMAGEDEVICE;
    }
    i++;
  }
  argv[1] = "groff";  /* rather than troff */
}

/*
 *  do_image - sets the troff number htmlflip and
 *             writes out the buffer to troff -Tps
 */

int char_buffer::do_image(int argc, char *argv[])
{
  PID_T pid;
  int pdes[2];

  if (pipe(pdes) < 0)
    sys_fatal("pipe");

  alterToDeviceImage(argc, argv);
  argv++;   // skip pre-grohtml argv[0]

  pid = fork();
  if (pid == 0) {
    // child

#if defined(DEBUGGING)
    int psFd     = creat("/tmp/prehtml-ps",     S_IWUSR|S_IRUSR);
    int regionFd = creat("/tmp/prehtml-region", S_IWUSR|S_IRUSR);
#else
    int psFd     = mkstemp(xtmptemplate("-ps-"));
    int regionFd = mkstemp(xtmptemplate("-regions-"));
#endif

    fprintf(stderr, "about to exec %s\n", argv[0]);
    replaceFd(1, psFd);
    replaceFd(0, pdes[0]);
    replaceFd(2, regionFd);

    // close end we are not using
    if (close(pdes[1])<0)
      sys_fatal("close");

    execvp(argv[0], argv);
    error("couldn't exec %1: %2", argv[0], strerror(errno), (char *)0);
    fflush(stderr);		/* just in case error() doesn't */
    exit(1);
  } else {
    // parent

    replaceFd(1, pdes[1]);
    write_file(0);
    waitForChild(pid);
  }
  return( 0 );
}

static char_buffer inputFile;


/*
 *  usage - emit usage arguments and exit.
 */

void usage()
{
  fprintf(stderr, "usage: %s troffname [ troff flags ] [ files ]\n", program_name);
  exit(1);
}

int main(int argc, char **argv)
{
  program_name = argv[0];
  int i; // skip over troff name
  int found=0;
  int ok=1;

  for (i = 2; i < argc; i++) {
    if (argv[i][0] == '-') {
      if (argv[i][1] == 'v') {
	extern const char *Version_string;
	fprintf(stderr, "GNU pre-grohtml version %s\n", Version_string);
	fflush(stderr);
      }
    } else {
      ok = do_file(argv[i]);
      if (! ok) {
	return( 0 );
      }
      found = 1;
    }
  }

  if (! found) {
    do_file("-");
  }
  ok = inputFile.do_html(argc, argv);
  if (ok == 0) {
    ok = inputFile.do_image(argc, argv);
    if (ok == 0) {
      // generateImages();
    }
  }
  return ok;
}

static int do_file(const char *filename)
{
  FILE *fp;

  current_filename = filename;
  if (strcmp(filename, "-") == 0) {
    fp = stdin;
  } else {
    fp = fopen(filename, "r");
    if (fp == 0) {
      error("can't open `%1': %2", filename, strerror(errno));
      return 0;
    }
  }

  if (inputFile.read_file(fp)) {
  }

  if (fp != stdin)
    fclose(fp);
  current_filename = 0;
  return 1;
}

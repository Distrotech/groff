// -*- C++ -*-
/* Copyright (C) 1989, 1990, 1991, 1992 Free Software Foundation, Inc.
     Written by Gaius Mulley (gaius@glam.ac.uk).

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

#define PREHTMLC

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

#include "pre-html.h"
#include "pushbackbuffer.h"

#define POSTSCRIPTRES          72000   // maybe there is a better way to find this? --fixme--
#define DEFAULT_IMAGE_RES         80
#define IMAGE_BOARDER_PIXELS      10

// #define TRANSPARENT  "-background \"#FFF\" -transparent \"#FFF\""
#define TRANSPARENT  ""

#define DEBUGGING

#if !defined(TRUE)
#   define TRUE (1==1)
#endif
#if !defined(FALSE)
#   define FALSE (1==0)
#endif

void stop() {}


static int   stdoutfd      =1;                  // output file descriptor - normally 1 but might move
                                                // -1 means closed
static char *psFileName    =0;                  // name of postscript file
static char *regionFileName=0;                  // name of file containing all image regions
static char *image_device  = "pnmraw";
static int   image_res     = DEFAULT_IMAGE_RES;


/*
 *  Images are generated via postscript, gs and the pnm utilities.
 */

#define IMAGEDEVICE    "-Tps"


static int do_file(const char *filename);

/*
 *  sys_fatal - writes a fatal error message. Taken from src/roff/groff/pipeline.c
 */

void sys_fatal (const char *s)
{
  fprintf(stderr, "%s: %s: %s", program_name, s, strerror(errno));
}

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
  void write_file_html(void);
  void write_file_troff(void);
  void write_upto_newline (char_block **t, int *i);
  int  can_see(char_block **t, int *i, char *string);
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
    // at this point we have a tail which is ready for the next SIZE bytes of the file

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
 *  write_upto_newline - writes the contents of the buffer until a newline is seen.
 */

void char_buffer::write_upto_newline (char_block **t, int *i)
{
  int j=*i;

  if (*t) {
    while ((j < (*t)->used) && ((*t)->buffer[j] != '\n')) {
      j++;
    }
    if ((j < (*t)->used) && ((*t)->buffer[j] == '\n')) {
      j++;
    }
    writeNbytes((*t)->buffer+(*i), j-(*i));
    if (j == (*t)->used) {
      *i = 0;
      *t = (*t)->next;
      write_upto_newline(t, i);
    } else {
      // newline was seen
      *i = j;
    }
  }
}

/*
 *  can_see - returns TRUE if we can see string in t->buffer[i] onwards
 */

int char_buffer::can_see(char_block **t, int *i, char *string)
{
  int j         = 0;
  int l         = strlen(string);
  int k         = *i;
  char_block *s = *t;

  while (s) {
    while ((k<s->used) && (j<l) && (s->buffer[k] == string[j])) {
      j++;
      k++;
    }
    if (j == l) {
      *i = k;
      *t = s;
      return( TRUE );
    } else if ((k<s->used) && (s->buffer[k] != string[j])) {
      return( FALSE );
    }
    s = s->next;
    k = 0;
  }
  return( FALSE );
}

/*
 *  write_file_troff - writes the buffer to stdout (troff).
 *                     It prepends the number register set to 0.
 */

void char_buffer::write_file_troff (void)
{
  char_block *t=head;
  int r;

  writeString(".nr html2enable 0\n");
  writeString(".nr htmlflip 0\n");
  if (t != 0) {
    do {
      writeNbytes(t->buffer, t->used);
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
}

/*
 *  the image class remembers the position of all images in the postscript file
 *  and assigns names for each image.
 */

struct imageItem {
  imageItem  *next;
  int         X1;
  int         Y1;
  int         X2;
  int         Y2;
  char       *imageName;
  int         resolution;
  int         pageNo;

  imageItem (int x1, int y1, int x2, int y2, int page, int res, char *name);
  ~imageItem ();
};

/*
 *  imageItem - constructor
 */

imageItem::imageItem (int x1, int y1, int x2, int y2, int page, int res, char *name)
{
  X1         = x1;
  Y1         = y1;
  X2         = x2;
  Y2         = y2;
  pageNo     = page;
  resolution = res;
  imageName  = name;
  next       = 0;
}

/*
 *  imageItem - deconstructor
 */

imageItem::~imageItem ()
{
}

/*
 *  imageList - class containing a list of imageItems.
 */

class imageList {
private:
  imageItem *head;
  imageItem *tail;
  int        count;
public:
  imageList();
  ~imageList();
  void  add(int x1, int y1, int x2, int y2, int page, int res);
  char *get(int i);
};

/*
 *  imageList - constructor.
 */

imageList::imageList ()
  : head(0), tail(0), count(0)
{
}

/*
 *  imageList - deconstructor.
 */

imageList::~imageList ()
{
  while (head != 0) {
    imageItem *i = head;
    head = head->next;
    delete i;
  }
}

/*
 *  createImage - generates a png file from the information held in, i, and
 *                the postscript file.
 */

static void createImage (imageItem *i)
{
  if (i->X1 != -1) {
    char buffer[4096];

    sprintf(buffer,
	    "echo showpage | gs -q -dFirstPage=%d -dLastPage=%d -dSAFER -sDEVICE=%s -r%d -sOutputFile=- %s - 2> /dev/null | pnmcut %d %d %d %d | pnmtopng %s > %s.png \n",
	    i->pageNo, i->pageNo,
	    image_device,
	    image_res,
	    psFileName,
	    i->X1*image_res/POSTSCRIPTRES-IMAGE_BOARDER_PIXELS,
	    i->Y1*image_res/POSTSCRIPTRES-IMAGE_BOARDER_PIXELS,
	    (i->X2-i->X1)*image_res/POSTSCRIPTRES+2*IMAGE_BOARDER_PIXELS,
	    (i->Y2-i->Y1)*image_res/POSTSCRIPTRES+2*IMAGE_BOARDER_PIXELS,
	    TRANSPARENT,
	    i->imageName);
    // fprintf(stderr, buffer);
    system(buffer);
  } else {
    fprintf(stderr, "ignoring image as x1 coord is -1\n");
    fflush(stderr);
  }
}

/*
 *  add - an image description to the imageList.
 */

void imageList::add (int x1, int y1, int x2, int y2, int page, int res)
{
  char *name = (char *)malloc(50);

  if (name == 0)
    sys_fatal("malloc");

  if (x1 == -1) {
    name[0] = (char)0;
  } else {
    count++;
    sprintf(name, "grohtml-%d", count);
  }
  imageItem *i = new imageItem(x1, y1, x2, y2, page, res, name);

  if (head == 0) {
    head = i;
    tail = i;
  } else {
    tail->next = i;
    tail = i;
  }
  createImage(i);
}

/*
 *  get - returns the name for image number, i.
 */

char *imageList::get(int i)
{
  imageItem *t=head;

  while (i>0) {
    if (i == 1) {
      if (t->X1 == -1) {
	return( NULL );
      } else {
	return( t->imageName );
      }
    }
    t = t->next;
    i--;
  }
}

static imageList listOfImages;  // list of images defined by the region file.

/*
 *  write_file_html - writes the buffer to stdout (troff).
 *                    It prepends the number register set to 1 and writes
 *                    out the file replacing template image names with
 *                    actual image names.
 */

void char_buffer::write_file_html (void)
{
  char_block *t      =head;
  int         imageNo=0;
  char       *name;
  int         i=0;

  writeString(".nr html2enable 1\n");
  writeString(".nr htmlflip 1\n");
  if (t != 0) {
    stop();
    do {
      if (can_see(&t, &i, ".if '\\*(.T'html2' .IMAGE <pre-html-image>\n")) {
	imageNo++;
	name = listOfImages.get(imageNo);
	if (name != 0) {
	  writeString(".if '\\*(.T'html2' .IMAGE \"");
	  writeString(name);
	  writeString(".png\"\n");
	}
      } else {
	write_upto_newline(&t, &i);
      }
    } while (t != 0);
  }
  if (close(stdoutfd) < 0)
    sys_fatal("close");

  // now we grab fd=1 so that the next pipe cannot use fd=1
  if (stdoutfd == 1) {
    if (dup(2) != stdoutfd) {
      sys_fatal("dup failed to use fd=1");
    }
  }
}

/*
 *  generateImages - parses the region file and generates images
 *                   from the postscript file. The region file
 *                   contains the x1,y1  x2,y2 extents of each
 *                   image.
 */

static void generateImages (char *regionFileName)
{
  pushBackBuffer *f=new pushBackBuffer(regionFileName);
  char ch;

  if (f->putPB('\n') == '\n') {
  }
  while (f->putPB(f->getPB()) != eof) {
    if (f->isString("\ngrohtml-info:page")) {
      int page= f->readInt();
      int x1  = f->readInt();
      int y1  = f->readInt();
      int x2  = f->readInt();
      int y2  = f->readInt();
      int res = POSTSCRIPTRES;  // --fixme--    prefer (f->readInt()) providing that troff can discover the value
      listOfImages.add(x1, y1, x2, y2, page, res);
    }
    ch = f->getPB();
  }
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
 *  alterDeviceTo - if toImage is set then the arg list is altered to include
 *                     IMAGEDEVICE and we invoke groff rather than troff.
 *                  else 
 *                     set -Thtml2 and troff
 */

static void alterDeviceTo (int argc, char *argv[], int toImage)
{
  int i=0;

  if (toImage) {
    while (i < argc) {
      if (strcmp(argv[i], "-Thtml2") == 0) {
	argv[i] = IMAGEDEVICE;
      }
      i++;
    }
    argv[1] = "groff";  /* rather than troff */
  } else {
    while (i < argc) {
      if (strcmp(argv[i], IMAGEDEVICE) == 0) {
	argv[i] = "-Thtml2";
      }
      i++;
    }
    argv[1] = "troff";  /* use troff */
  }
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

  alterDeviceTo(argc, argv, 0);
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

    write_file_html();
    waitForChild(pid);
  }
  return( 0 );
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

  alterDeviceTo(argc, argv, 1);
  argv++;   // skip pre-grohtml argv[0]

  pid = fork();
  if (pid == 0) {
    // child

#if defined(DEBUGGING)
    int psFd     = creat(psFileName,     S_IWUSR|S_IRUSR);
    int regionFd = creat(regionFileName, S_IWUSR|S_IRUSR);
#else
    int psFd     = mkstemp(psFileName);
    int regionFd = mkstemp(regionFileName);
#endif

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
    write_file_troff();
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

/*
 *  makeTempFiles - name the temporary files
 */

static void makeTempFiles (void)
{
#if defined(DEBUGGING)
  psFileName     = "/tmp/prehtml-ps";
  regionFileName = "/tmp/prehtml-region";
#else
  psFileName     = xtmptemplate("-ps-");
  regionFileName = xtmptemplate("-regions-");
#endif
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
  makeTempFiles();
  ok = inputFile.do_image(argc, argv);
  if (ok == 0) {
    generateImages(regionFileName);
    ok = inputFile.do_html(argc, argv);
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

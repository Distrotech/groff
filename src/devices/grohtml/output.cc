// -*- C++ -*-
/* Copyright (C) 2000, 2001 Free Software Foundation, Inc.
 *
 *  Gaius Mulley (gaius@glam.ac.uk) wrote output.cc
 *  but it owes a huge amount of ideas and raw code from
 *  James Clark (jjc@jclark.com) grops/ps.cc.
 *
 *  output.cc
 *
 *  provide the simple low level output routines needed by html.cc
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
#include "html.h"

#ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif

#if !defined(TRUE)
#   define TRUE  (1==1)
#endif
#if !defined(FALSE)
#   define FALSE (1==0)
#endif

/*
 *  the classes and methods for simple_output manipulation
 */

simple_output::simple_output(FILE *f, int n)
: fp(f), max_line_length(n), col(0), need_space(0), fixed_point(0), newlines(0)
{
}

simple_output &simple_output::set_file(FILE *f)
{
  if (fp)
    fflush(fp);
  fp = f;
  return *this;
}

simple_output &simple_output::copy_file(FILE *infp)
{
  int c;
  while ((c = getc(infp)) != EOF)
    putc(c, fp);
  return *this;
}

simple_output &simple_output::end_line()
{
  if (col != 0) {
    putc('\n', fp);
    col = 0;
    need_space = 0;
  }
  return *this;
}

simple_output &simple_output::special(const char *s)
{
  return *this;
}

simple_output &simple_output::simple_comment(const char *s)
{
  if (col != 0)
    putc('\n', fp);
  fputs("<!-- ", fp);
  fputs(s, fp);
  fputs(" -->\n", fp);
  col = 0;
  need_space = 0;
  return *this;
}

simple_output &simple_output::begin_comment(const char *s)
{
  if (col != 0)
    putc('\n', fp);
  fputs("<!-- ", fp);
  fputs(s, fp);
  need_space = 0;
  col = 5 + strlen(s);
  return *this;
}

simple_output &simple_output::end_comment()
{
  if (need_space) {
    putc(' ', fp);
  }
  fputs("-->\n", fp);
  col = 0;
  need_space = 0;
  return *this;
}

simple_output &simple_output::comment_arg(const char *s)
{
  int len = strlen(s);
  int i   = 0;

  if (col + len + 1 > max_line_length) {
    fputs("\n ", fp);
    col = 1;
  }
  while (i < len) {
    if (s[i] != '\n') {
      putc(s[i], fp);
      col++;
    }
    i++;
  }
  need_space = 1;
  return *this;
}

/*
 *  check_newline - checks to see whether we are able to issue
 *                  a newline and that one is needed.
 */

simple_output &simple_output::check_newline(int n)
{
  if ((col + n > max_line_length) && (newlines)) {
    fputc('\n', fp);
    need_space = 0;
    col = 0;
  }
}

/*
 *  space_or_newline - will emit a newline or a space later on
 *                     depending upon the current column.
 */

simple_output &simple_output::space_or_newline (void)
{
  if ((col + 1 > max_line_length) && (newlines)) {
    fputc('\n', fp);
    need_space = 0;
    col = 0;
  } else {
    need_space = 1;
  }
}

/*
 *  write_newline - writes a newline providing that we
 *                  are not in the first column.
 */

simple_output &simple_output::write_newline (void)
{
  if (col != 0) {
    fputc('\n', fp);
    need_space = 0;
    col = 0;
  }
}

simple_output &simple_output::set_fixed_point(int n)
{
  assert(n >= 0 && n <= 10);
  fixed_point = n;
  return *this;
}

simple_output &simple_output::put_raw_char(char c)
{
  putc(c, fp);
  col++;
  need_space = 0;
  return *this;
}

/*
 *  check_space - writes a space if required.
 */

simple_output &simple_output::check_space (int n)
{
  check_newline(n);
  if (need_space) {
    fputc(' ', fp);
    need_space = 0;
    col++;
  }
}

simple_output &simple_output::put_string(const char *s, int n)
{
  int i=0;

  check_space(n);

  while (i<n) {
    fputc(s[i], fp);
    i++;
  }
#if defined(DEBUGGING)
  fflush(fp);   // just for testing
#endif
  col += n;
  return *this;
}

simple_output &simple_output::put_translated_string(const char *s)
{
  int i=0;

  check_space(strlen(s));

  while (s[i] != (char)0) {
    if ((s[i] & 0x7f) == s[i]) {
      fputc(s[i], fp);
    }
    i++;
  }
#if defined(DEBUGGING)
  fflush(fp);   // just for testing
#endif
  col += i;
  return *this;
}

simple_output &simple_output::put_string(const char *s)
{
  int i=0;
  int j=0;

  check_space(strlen(s));

  while (s[i] != '\0') {
    fputc(s[i], fp);
    if (s[i] == '\n') {
      col = 0;
      j   = 0;
    } else {
      j++;
    }
    i++;
  }
  col += j;
#if defined(DEBUGGING)
  fflush(fp);   // just for testing
#endif
  return *this;
}

simple_output &simple_output::put_number(int n)
{
  char buf[1 + INT_DIGITS + 1];
  sprintf(buf, "%d", n);
  int len = strlen(buf);
  put_string(buf, len);
  return *this;
}

simple_output &simple_output::put_float(double d)
{
  char buf[128];

  sprintf(buf, "%.4f", d);
  int len = strlen(buf);
  put_string(buf, len);
  need_space = 1;
  return *this;
}

simple_output &simple_output::put_symbol(const char *s)
{
  int len = strlen(s);

  if (need_space) {
    putc(' ', fp);
    col++;
  }
  fputs(s, fp);
  col += len;
  need_space = 1;
  return *this;
}

simple_output &simple_output::enable_newlines (int auto_newlines)
{
  newlines = auto_newlines;
  check_newline(0);
}

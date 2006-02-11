// -*- C++ -*-
/* Copyright (C) 1989, 1990, 1991, 1992, 2000, 2001, 2002, 2003, 2004, 2006
   Free Software Foundation, Inc.
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
Foundation, 51 Franklin St - Fifth Floor, Boston, MA 02110-1301, USA. */

#include "lib.h"

#include <ctype.h>
#include <assert.h>
#include <stdlib.h>
#include "errarg.h"
#include "error.h"
#include "font.h"
#include "ptable.h"

declare_ptable(int)
implement_ptable(int)

class character_indexer {
public:
  character_indexer();
  ~character_indexer();
  glyph_t ascii_char_index(unsigned char);
  glyph_t named_char_index(const char *);
  glyph_t numbered_char_index(int);
private:
  enum { NSMALL = 256 };
  int next_index;
  glyph_t ascii_index[256];
  glyph_t small_number_index[NSMALL];
  PTABLE(int) table;
};

character_indexer::character_indexer()
: next_index(0)
{
  int i;
  for (i = 0; i < 256; i++)
    ascii_index[i] = glyph_t(-1, NULL);
  for (i = 0; i < NSMALL; i++)
    small_number_index[i] = glyph_t(-1, NULL);
}

character_indexer::~character_indexer()
{
}

glyph_t character_indexer::ascii_char_index(unsigned char c)
{
  if (ascii_index[c].index < 0) {
    char buf[4+3+1];
    memcpy(buf, "char", 4);
    strcpy(buf + 4, i_to_a(c));
    ascii_index[c] = glyph_t(next_index++, strsave(buf));
  }
  return ascii_index[c];
}

glyph_t character_indexer::numbered_char_index(int n)
{
  if (n >= 0 && n < NSMALL) {
    if (small_number_index[n].index < 0)
      small_number_index[n] = glyph_t(next_index++, NULL);
    return small_number_index[n];
  }
  // Not the most efficient possible implementation.
  char buf[1 + 1 + INT_DIGITS + 1];
  buf[0] = ' ';
  strcpy(buf + 1, i_to_a(n));
  int *np = table.lookup(buf);
  if (!np) {
    np = new int[1];
    *np = next_index++;
    table.define(buf, np);
  }
  return glyph_t(*np, NULL);
}

glyph_t character_indexer::named_char_index(const char *s)
{
  int *np = table.lookupassoc(&s);
  if (!np) {
    np = new int[1];
    *np = next_index++;
    s = table.define(s, np);
  }
  return glyph_t(*np, s);
}

static character_indexer indexer;

glyph_t font::number_to_index(int n)
{
  return glyph_t(indexer.numbered_char_index(n));
}

glyph_t font::name_to_index(const char *s)
{
  assert(s != 0 && s[0] != '\0' && s[0] != ' ');
  if (s[1] == '\0')
    return glyph_t(indexer.ascii_char_index(s[0]));
  /* char128 and \200 are synonyms */
  if (s[0] == 'c' && s[1] == 'h' && s[2] == 'a' && s[3] == 'r') {
    char *val;
    long n = strtol(s + 4, &val, 10);
    if (val != s + 4 && *val == '\0' && n >= 0 && n < 256)
      return glyph_t(indexer.ascii_char_index((unsigned char)n));
  }
  return glyph_t(indexer.named_char_index(s));
}


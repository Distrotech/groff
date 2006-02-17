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
#include "itable.h"

// Every glyphinfo is actually a charinfo.
class charinfo : glyphinfo {
private:
  const char *name;	// The glyph name, or NULL.
public:
  friend class character_indexer;
  friend class glyph;
};

declare_ptable(charinfo)
implement_ptable(charinfo)

declare_itable(charinfo)
implement_itable(charinfo)

class character_indexer {
public:
  character_indexer();
  ~character_indexer();
  glyph ascii_char_index(unsigned char);
  glyph named_char_index(const char *);
  glyph numbered_char_index(int);
private:
  enum { NSMALL = 256 };
  int next_index;
  glyph ascii_index[256];
  glyph small_number_index[NSMALL];
  PTABLE(charinfo) table;
  ITABLE(charinfo) ntable;
};

character_indexer::character_indexer()
: next_index(0)
{
  int i;
  for (i = 0; i < 256; i++)
    ascii_index[i] = UNDEFINED_GLYPH;
  for (i = 0; i < NSMALL; i++)
    small_number_index[i] = UNDEFINED_GLYPH;
}

character_indexer::~character_indexer()
{
}

glyph character_indexer::ascii_char_index(unsigned char c)
{
  if (ascii_index[c] == UNDEFINED_GLYPH) {
    char buf[4+3+1];
    memcpy(buf, "char", 4);
    strcpy(buf + 4, i_to_a(c));
    charinfo *ci = new charinfo;
    ci->index = next_index++;
    ci->number = -1;
    ci->name = strsave(buf);
    ascii_index[c] = glyph(ci);
  }
  return ascii_index[c];
}

glyph character_indexer::numbered_char_index(int n)
{
  if (n >= 0 && n < NSMALL) {
    if (small_number_index[n] == UNDEFINED_GLYPH) {
      charinfo *ci = new charinfo;
      ci->index = next_index++;
      ci->number = n;
      ci->name = NULL;
      small_number_index[n] = glyph(ci);
    }
    return small_number_index[n];
  }
  charinfo *ci = ntable.lookup(n);
  if (ci == NULL) {
    ci = new charinfo[1];
    ci->index = next_index++;
    ci->number = n;
    ci->name = NULL;
    ntable.define(n, ci);
  }
  return glyph(ci);
}

glyph character_indexer::named_char_index(const char *s)
{
  charinfo *ci = table.lookupassoc(&s);
  if (ci == NULL) {
    ci = new charinfo[1];
    ci->index = next_index++;
    ci->number = -1;
    ci->name = table.define(s, ci);
  }
  return glyph(ci);
}

static character_indexer indexer;

glyph number_to_glyph(int n)
{
  return indexer.numbered_char_index(n);
}

glyph name_to_glyph(const char *s)
{
  assert(s != 0 && s[0] != '\0' && s[0] != ' ');
  if (s[1] == '\0')
    return indexer.ascii_char_index(s[0]);
  /* char128 and \200 are synonyms */
  if (s[0] == 'c' && s[1] == 'h' && s[2] == 'a' && s[3] == 'r') {
    char *val;
    long n = strtol(s + 4, &val, 10);
    if (val != s + 4 && *val == '\0' && n >= 0 && n < 256)
      return indexer.ascii_char_index((unsigned char)n);
  }
  return indexer.named_char_index(s);
}

const char *glyph::glyph_name()
{
  charinfo *ci = (charinfo *)ptr; // Every glyphinfo is actually a charinfo.
  return ci->name;
}

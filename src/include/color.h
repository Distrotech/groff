// -*- C++ -*-
/* Copyright (C) 2001, 2002 Free Software Foundation, Inc.
     Written by Gaius Mulley <gaius@glam.ac.uk>

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


enum color_scheme {DEFAULT, CMY, CMYK, RGB, GRAY};

class color {
private:
  color_scheme scheme;
  unsigned int components[4];

  int read_encoding(color_scheme cs, const char *s, unsigned int n);

public:
  enum {MAX_COLOR_VAL = 0xffff};
  color();

  int operator==(const color & c) const;
  int operator!=(const color & c) const;

  int is_default() { return scheme == DEFAULT; }

  void set_default();
  void set_rgb(unsigned int r, unsigned int g, unsigned int b);
  void set_cmy(unsigned int c, unsigned int m, unsigned int y);
  void set_cmyk(unsigned int c, unsigned int m,
		unsigned int y, unsigned int k);
  void set_gray(unsigned int g);
	  
  int read_rgb(const char *s);
  int read_cmy(const char *s);
  int read_cmyk(const char *s);
  int read_gray(const char *s);

  color_scheme get_components(unsigned int *c);

  void get_rgb(unsigned int *r, unsigned int *g, unsigned int *b);
  void get_cmy(unsigned int *c, unsigned int *m, unsigned int *y);
  void get_cmyk(unsigned int *c, unsigned int *m,
		unsigned int *y, unsigned int *k);
  void get_gray(unsigned int *g);
};

#define Cyan components[0]
#define Magenta components[1]
#define Yellow components[2]
#define Black components[3]

#define Red components[0]
#define Green components[1]
#define Blue components[2]

#define Gray components[0]

extern color default_color;

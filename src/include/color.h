// -*- C++ -*-
/* Copyright (C) 2001 Free Software Foundation, Inc.
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


enum color_scheme {NONE, CMY, CMYK, RGB, GRAY};

// colors are internally held as CMYK values.

class color {
private:
  unsigned int cyan;
  unsigned int magenta;
  unsigned int yellow;
  unsigned int black;
  color_scheme scheme;		// how was the color originally defined?
  // and now the data structures necessary for the state machine
  // inside the read routines
  unsigned int color_space_num;	// how many numbers have been read?
  enum {REAL, HEX, UNDEFINED} encoding;
  unsigned int hex_length;
  unsigned int c[4];
  double d[4];

  int read_encoding(const char *s, unsigned int n);

 public:
  enum {MAX_COLOR_VAL = 0xffff};
  color();
  int is_equal(color *c);
  int is_gray (void);

  void set_rgb(unsigned int r, unsigned int g, unsigned int b);
  void set_cmy(unsigned int c, unsigned int m, unsigned int y);
  void set_cmyk(unsigned int c, unsigned int m,
		unsigned int y, unsigned int k);
  void set_gray(unsigned int l);
	  
  void set_rgb(double r, double g, double b);
  void set_cmy(double c, double m, double y);
  void set_cmyk(double c, double m, double y, double k);
  void set_gray(double l);
	  
  int read_rgb(const char *s);
  int read_cmy(const char *s);
  int read_cmyk(const char *s);
  int read_gray(const char *s);

  void get_rgb(unsigned int *r, unsigned int *g, unsigned int *b);
  void get_cmy(unsigned int *c, unsigned int *m, unsigned int *y);
  void get_cmyk(unsigned int *c, unsigned int *m,
		unsigned int *y, unsigned int *k);
  void get_gray(unsigned int *l);

  void get_rgb(double *r, double *g, double *b);
  void get_cmy(double *c, double *m, double *y);
  void get_cmyk(double *c, double *m, double *y, double *k);
  void get_gray(double *l);
};

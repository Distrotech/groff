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

#include "color.h"
#include "cset.h"
#ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif

#include <assert.h>
#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include "errarg.h"
#include "error.h"

static inline unsigned int min(unsigned int a, unsigned int b)
{
  if (a < b)
    return a;
  else
    return b;
}

color::color()
: cyan(0), magenta(0), yellow(0), black(0), scheme(NONE),
  color_space_num(0), encoding(UNDEFINED), hex_length(0)
{
}

int color::is_equal(color *c)
{
  return (c->cyan == cyan)
	 && (c->magenta == magenta)
	 && (c->yellow == yellow)
	 && (c->black == black);
}

int color::is_gray(void)
{
  return (scheme == GRAY)
	 || ((magenta == cyan) && (cyan == yellow));
}

void color::set_rgb(unsigned int r, unsigned int g, unsigned int b)
{
  scheme = RGB;
  r = min(MAX_COLOR_VAL, r);
  g = min(MAX_COLOR_VAL, g);
  b = min(MAX_COLOR_VAL, b);
  black = min(MAX_COLOR_VAL - r, min(MAX_COLOR_VAL - g, MAX_COLOR_VAL - b));
  if (MAX_COLOR_VAL - black == 0) {
    cyan = MAX_COLOR_VAL;
    magenta = MAX_COLOR_VAL;
    yellow = MAX_COLOR_VAL;
  }
  else {
    cyan = (MAX_COLOR_VAL * (MAX_COLOR_VAL - r - black))
	   / (MAX_COLOR_VAL - black);
    magenta = (MAX_COLOR_VAL * (MAX_COLOR_VAL - g - black))
	      / (MAX_COLOR_VAL - black);
    yellow = (MAX_COLOR_VAL * (MAX_COLOR_VAL - b - black))
	     / (MAX_COLOR_VAL - black);
  }
}

void color::set_cmy(unsigned int c, unsigned int m, unsigned int y)
{
  scheme = CMY;
  c = min(MAX_COLOR_VAL, c);
  m = min(MAX_COLOR_VAL, m);
  y = min(MAX_COLOR_VAL, y);
  black = min(c, min(m, y));
  if (MAX_COLOR_VAL - black == 0) {
    cyan = MAX_COLOR_VAL;
    magenta = MAX_COLOR_VAL;
    yellow = MAX_COLOR_VAL;
  }
  else {
    cyan = (MAX_COLOR_VAL * (c - black)) / (MAX_COLOR_VAL - black);
    magenta = (MAX_COLOR_VAL * (m - black)) / (MAX_COLOR_VAL - black);
    yellow = (MAX_COLOR_VAL * (y - black)) / (MAX_COLOR_VAL - black);
  }
}

void color::set_cmyk(unsigned int c, unsigned int m,
		     unsigned int y, unsigned int k)
{
  scheme = CMYK;
  cyan = c;
  magenta = m;
  yellow = y;
  black = k;
}

void color::set_gray(unsigned int b)
{
  scheme = GRAY;
  cyan = 0;
  magenta = 0;
  yellow = 0;
  black = min(MAX_COLOR_VAL, b);
}

void color::set_rgb(double r, double g, double b)
{
  set_rgb((unsigned int)(r * MAX_COLOR_VAL),
	  (unsigned int)(g * MAX_COLOR_VAL),
	  (unsigned int)(b * MAX_COLOR_VAL));
}

void color::set_cmy(double c, double m, double y)
{
  set_cmy((unsigned int)(c * MAX_COLOR_VAL),
	  (unsigned int)(m * MAX_COLOR_VAL),
	  (unsigned int)(y * MAX_COLOR_VAL));
}

void color::set_cmyk(double c, double m, double y, double k)
{
  set_cmyk((unsigned int)(c * MAX_COLOR_VAL),
	   (unsigned int)(m * MAX_COLOR_VAL),
	   (unsigned int)(y * MAX_COLOR_VAL),
	   (unsigned int)(k * MAX_COLOR_VAL));
}

void color::set_gray(double l)
{
  set_gray((unsigned int)(l * MAX_COLOR_VAL));
}

/*
 *  atoh - computes the value of the hex number S in N.  Returns 1 if
 *         successful.
 */

static int atoh(unsigned int *n, const char *s, unsigned int length)
{
  unsigned int i = 0;
  unsigned int val = 0;
  while ((i < length) && csxdigit(s[i])) {
    if (!s[i])
      return 0;
    if (csdigit(s[i]))
      val = val*0x10 + (s[i]-'0');
    else if (csupper(s[i]))
      val = val*0x10 + (s[i]-'A') + 10;
    else
      val = val*0x10 + (s[i]-'a') + 10;
    i++;
  }
  *n = val;
  return 1;
}

/*
 *  read_encoding - read the next component of the color encoding from S.
 *                  Returns 1 when finished.
 */

int color::read_encoding(const char *s, unsigned int n)
{
  if ((scheme == NONE) && (color_space_num == 0)) {
    if (*s == '#') {
      s++;
      encoding = HEX;
      if (*s == '#') {
	hex_length = 4;
	s++;
      }
      else
	hex_length = 2;
    }
    else
      encoding = REAL;
  }
  if (encoding == REAL) {
    d[color_space_num] = atof(s);
    color_space_num++;
    return (color_space_num == n);
  }
  else {
    for (unsigned int i = 0; i < n; i++) {
      if (!atoh(&c[i], s, hex_length))
	return 0;
      if (hex_length == 2)
	c[i] *= 0x101;	// scale up -- 0xff should become 0xffff
      s += hex_length;
    }
    return 1;
  }
}

/*
 *  read_rgb - read an rgb color description from S.  It returns 1
 *             when the complete color has been read.
 */

int color::read_rgb(const char *s)
{
  assert(scheme == NONE);
  int finished = read_encoding(s, 3);
  if (finished) {
    if (encoding == HEX)
      set_rgb(c[0], c[1], c[2]);
    else
      set_rgb(d[0], d[1], d[2]);
  }
  return finished;
}

/*
 *  read_cmy - read a cmy color description from S.  It returns 1
 *             when the complete color has been read.
 */

int color::read_cmy(const char *s)
{
  assert(scheme == NONE);
  int finished = read_encoding(s, 3);
  if (finished) {
    if (encoding == HEX)
      set_cmy(c[0], c[1], c[2]);
    else
      set_cmy(d[0], d[1], d[2]);
  }
  return finished;
}

/*
 *  read_cmyk - read a cmyk color description from S.  It returns 1
 *              when the complete color has been read.
 */

int color::read_cmyk(const char *s)
{
  assert(scheme == NONE);
  int finished = read_encoding(s, 4);
  if (finished) {
    if (encoding == HEX)
      set_cmyk(c[0], c[1], c[2], c[3]);
    else
      set_cmyk(d[0], d[1], d[2], d[3]);
  }
  return finished;
}

/*
 *  read_gray - read a gray scale from S.  It returns 1.
 */

int color::read_gray(const char *s)
{
  assert(scheme == NONE);
  int finished = read_encoding(s, 1);
  if (finished) {
    if (encoding == HEX)
      set_gray(c[0]);
    else
      set_gray(d[0]);
  }
  return finished;
}

void color::get_rgb(unsigned int *r, unsigned int *g, unsigned int *b)
{
  assert(scheme != NONE);
  *r = MAX_COLOR_VAL
       - min(MAX_COLOR_VAL,
	     cyan * (MAX_COLOR_VAL - black) / MAX_COLOR_VAL + black);
  *g = MAX_COLOR_VAL
       - min(MAX_COLOR_VAL,
	     magenta * (MAX_COLOR_VAL - black) / MAX_COLOR_VAL + black);
  *b = MAX_COLOR_VAL
       - min(MAX_COLOR_VAL,
	     yellow * (MAX_COLOR_VAL - black) / MAX_COLOR_VAL + black);
}

void color::get_cmy(unsigned int *c, unsigned int *m, unsigned int *y)
{
  assert(scheme != NONE);
  *c = min(MAX_COLOR_VAL,
	   cyan * (MAX_COLOR_VAL - black) / MAX_COLOR_VAL + black);
  *m = min(MAX_COLOR_VAL,
	   magenta * (MAX_COLOR_VAL - black) / MAX_COLOR_VAL + black);
  *y = min(MAX_COLOR_VAL,
	   yellow * (MAX_COLOR_VAL - black) / MAX_COLOR_VAL + black);
}

void color::get_cmyk(unsigned int *c, unsigned int *m,
		     unsigned int *y, unsigned int *k)
{
  assert(scheme != NONE);
  *c = cyan;
  *m = magenta;
  *y = yellow;
  *k = black;
}

void color::get_gray(unsigned int *l)
{
  assert(scheme != NONE);
  *l = black;
}

void color::get_rgb(double *r, double *g, double *b)
{
  assert(scheme != NONE);
  unsigned int ir, ig, ib;
  get_rgb(&ir, &ig, &ib);
  *r = (double)ir / MAX_COLOR_VAL;
  *g = (double)ig / MAX_COLOR_VAL;
  *b = (double)ib / MAX_COLOR_VAL;
}

void color::get_cmy(double *c, double *m, double *y)
{
  assert(scheme != NONE);
  unsigned int ic, im, iy;
  get_cmy(&ic, &im, &iy);
  *c = (double)ic / MAX_COLOR_VAL;
  *m = (double)im / MAX_COLOR_VAL;
  *y = (double)iy / MAX_COLOR_VAL;
}

void color::get_cmyk(double *c, double *m, double *y, double *k)
{
  assert(scheme != NONE);
  *c = (double)cyan / MAX_COLOR_VAL;
  *m = (double)magenta / MAX_COLOR_VAL;
  *y = (double)yellow / MAX_COLOR_VAL;
  *k = (double)black / MAX_COLOR_VAL;
}

void color::get_gray(double *l)
{
  assert(scheme != NONE);
  *l = (double)black / MAX_COLOR_VAL;
}

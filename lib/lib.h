/* Copyright (C) 1989, 1990, 1991 Free Software Foundation, Inc.
     Written by James Clark (jjc@jclark.uucp)

This file is part of groff.

groff is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free
Software Foundation; either version 1, or (at your option) any later
version.

groff is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License along
with groff; see the file LICENSE.  If not, write to the Free Software
Foundation, 675 Mass Ave, Cambridge, MA 02139, USA. */

/* This file is included in both C and C++ compilations. */

#ifdef __cplusplus
extern "C" {
  char *strerror(int);
#ifndef __BORLANDC__
  const char *itoa(int);
  const char *iftoa(int, int);
#endif /* __BORLANDC__ */
};

char *strsave(const char *s);
int is_prime(unsigned);
#include <stdio.h>
FILE *xtmpfile();

int interpret_lf_args(const char *p);

inline int illegal_input_char(int c)
{
  return c == 000 || (c > 012 && c < 040) || (c >= 0200 && c < 0240);
}

#endif

#ifndef INT_MAX
#define INT_MAX 2147483647
#endif

/* It's not safe to rely on people getting INT_MIN right (ie signed). */

#ifdef INT_MIN
#undef INT_MIN
#endif

#ifdef CFRONT_ANSI_BUG

/* This works around a bug in cfront 2.0 used with ANSI C compilers. */

#define INT_MIN ((long)(-INT_MAX-1))

#else /* CFRONT_ANSI_BUG */

#define INT_MIN (-INT_MAX-1)

#endif /* CFRONT_ANSI_BUG */

/* Maximum number of digits in the decimal representation of an int
(not including the -). */

#define INT_DIGITS 10

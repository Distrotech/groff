// -*- C++ -*-
/* Copyright (C) 1991 Free Software Foundation, Inc.
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

class token_info {
public:
  enum token_type { OTHER, UPPER, LOWER, ACCENT, PUNCT, HYPHEN };
private:
  token_type type;
  const char *sort_key;
  const char *other_case;
public:
  token_info();
  void set(token_type, const char *sk = 0, const char *oc = 0);
  void lower_case(const char *start, const char *end, string &result) const;
  void upper_case(const char *start, const char *end, string &result) const;
  void sortify(const char *start, const char *end, string &result) const;
  int sortify_non_empty(const char *start, const char *end) const;
  int is_upper() const;
  int is_lower() const;
  int is_accent() const;
  int is_other() const;
  int is_punct() const;
  int is_hyphen() const;
};

inline int token_info::is_upper() const
{
  return type == UPPER;
}

inline int token_info::is_lower() const
{
  return type == LOWER;
}

inline int token_info::is_accent() const
{
  return type == ACCENT;
}

inline int token_info::is_other() const
{
  return type == OTHER;
}

inline int token_info::is_punct() const
{
  return type == PUNCT;
}

inline int token_info::is_hyphen() const
{
  return type == HYPHEN;
}

int get_token(const char **ptr, const char *end);
const token_info *lookup_token(const char *start, const char *end);

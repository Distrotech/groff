#! /bin/sh

# roff2* - transform roff files into other formats

# Source file position: <groff-source>/contrib/groffer/shell/roff2.sh
# Installed position: <prefix>/bin/roff2*

# Copyright (C) 2006 Free Software Foundation, Inc.
# Written by Bernd Warken

# Last update: 7 Nov 2006

# This file is part of `groffer', which is part of `groff'.

# `groff' is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.

# `groff' is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with `groff'; see the files COPYING and LICENSE in the top
# directory of the `groff' source.  If not, write to the Free Software
# Foundation, 51 Franklin St - Fifth Floor, Boston, MA 02110-1301,
# USA.

########################################################################


##############
# echo1 (<text>*)
#
# Output to stdout with final line break.
#
# Arguments : arbitrary text including `-'.
#
echo1()
{
  cat <<EOF
$@
EOF
} # echo1()


##############
# echo2 (<text>*)
#
# Output to stderr with final line break.
#
# Arguments : arbitrary text including `-'.
#
echo2()
{
  cat >&2 <<EOF
$@
EOF
} # echo2()


name="$(echo1 "$0" | sed 's|^.*//*\([^/]*\)$|\1|')";

case "$name" in
roff2[a-z]*)
  mode="$(echo1 "$name" | sed 's/^roff2//')";
  ;;
*)
  echo2 "wrong program name: $name";
  exit 1;
  ;;
esac;

for i
do
  case $i in
  -v|--v|--ve|--ver|--vers|--versi|--versio|--version)
    cat <<EOF
$name in `groffer --version`
EOF
    exit 0;
    ;;
  -h|--h|--he|--hel|--help)
    cat <<EOF
usage: $name [option]... [--] [filespec]...

where the optional "filespec"s are either the names of existing,
readable files or "-" for standard input or a search pattern for man
pages.  The optional "option"s are arbitrary options of "groffer"; the
options override the behavior of this program.
EOF
    exit 0;
    ;;
  esac;
done

groffer --to-stdout --$mode "$@";
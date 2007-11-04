#! /bin/sh
# Emulate nroff with groff.
#
# Copyright (C) 1992, 1993, 1994, 1999, 2000, 2001, 2002, 2003,
#               2004, 2005
#   Free Software Foundation, Inc.
#
# Written by James Clark, maintained by Werner Lemberg.

# This file is of `groff'.

# `groff' is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License (GPL) as published
# by the Free Software Foundation; either version 2, or (at your
# option) any later version.

# `groff' is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with `groff'; see the files COPYING and LICENSE in the top
# directory of the `groff' source.  If not, write to the Free Software
# Foundation, 51 Franklin St - Fifth Floor, Boston, MA 02110-1301,
# USA.

prog="$0"
# Default device.
# First try the "locale charmap" command, because it's most reliable.
# On systems where it doesn't exist, look at the environment variables.
case "`exec 2>/dev/null ; locale charmap`" in
  UTF-8)
    T=-Tutf8 ;;
  ISO-8859-1 | ISO-8859-15)
    T=-Tlatin1 ;;
  IBM-1047)
    T=-Tcp1047 ;;
  *)
    case "${LC_ALL-${LC_CTYPE-${LANG}}}" in
      *.UTF-8)
        T=-Tutf8 ;;
      iso_8859_1 | *.ISO-8859-1 | *.ISO8859-1 | \
      iso_8859_15 | *.ISO-8859-15 | *.ISO8859-15)
        T=-Tlatin1 ;;
      *.IBM-1047)
        T=-Tcp1047 ;;
      *)
        case "$LESSCHARSET" in
          utf-8)
            T=-Tutf8 ;;
          latin1)
            T=-Tlatin1 ;;
          cp1047)
            T=-Tcp1047 ;;
          *)
            T=-Tascii ;;
          esac ;;
     esac ;;
esac
opts=

# `for i; do' doesn't work with some versions of sh

for i
  do
  case $1 in
    -c)
      opts="$opts -P-c" ;;
    -h)
      opts="$opts -P-h" ;;
    -[eq] | -s*)
      # ignore these options
      ;;
    -[dMmrnoT])
      echo "$prog: option $1 requires an argument" >&2
      exit 1 ;;
    -[iptSUC] | -[dMmrno]*)
      opts="$opts $1" ;;
    -Tascii | -Tlatin1 | -Tutf8 | -Tcp1047)
      T=$1 ;;
    -T*)
      # ignore other devices
      ;;
    -u*)
      # Solaris 2.2 through at least Solaris 9 `man' invokes
      # `nroff -u0 ... | col -x'.  Ignore the -u0,
      # since `less' and `more' can use the emboldening info.
      # However, disable SGR, since Solaris `col' mishandles it.
      opts="$opts -P-c" ;;
    -v | --version)
      echo "GNU nroff (groff) version @VERSION@"
      exit 0 ;;
    --help)
      echo "usage: nroff [-CchipStUv] [-dCS] [-MDIR] [-mNAME] [-nNUM] [-oLIST]"
      echo "             [-rCN] [-Tname] [FILE...]"
      exit 0 ;;
    --)
      shift
      break ;;
    -)
      break ;;
    -*)
      echo "$prog: invalid option $1" >&2
      exit 1 ;;
    *)
      break ;;
  esac
  shift
done

# Set up the `GROFF_BIN_PATH' variable
# to be exported in the current `GROFF_RUNTIME' environment.

@GROFF_BIN_PATH_SETUP@
export GROFF_BIN_PATH

# This shell script is intended for use with man, so warnings are
# probably not wanted.  Also load nroff-style character definitions.

PATH="$GROFF_RUNTIME$PATH" groff -mtty-char $T $opts ${1+"$@"}

# eof

#!/bin/sh

PROGRAM_NAME=groffer
PROGRAM_VERSION="0.3 (alpha)"
LAST_UPDATE="15 Dec 2001"

# Copyright (C) 2001 Free Software Foundation, Inc.
# Written by Bernd Warken <bwarken@mayn.de>

# This file is part of groff.

# groff is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.

# groff is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
# License for more details.

# You should have received a copy of the GNU General Public License
# along with groff; see the file COPYING.  If not, write to the Free
# Software Foundation, 59 Temple Place - Suite 330, Boston, MA
# 02111-1307, USA.

########################################################################
#                           Description
########################################################################

# Display groff files on X or tty, even when zipped.

# This script tries to avoid features of special shells, so some
# elements are programmed in a more complicated way than necessary.

########################################################################
#                            Debugging
########################################################################
# Error handling and exit behavior is complicated by the fact that
# `exit' can only escape from the current shell.  This leads to trouble
# in `$()' subshells.
# 


# for debugging only
#set -x
#set -v
function diag ()
{
  echo '>>>>>' "$@" >&2;
}
function abort ()
{
  [ $# -gt 0 ] && diag "$@";
  error 2>/dev/null || exit 1;
}

########################################################################
#                              Setup
########################################################################

set -a

########################################################################
#                       Environment Variables
########################################################################

# Environment variables that are regarded as global to this file are
# written in upper case letters and can use the underline character
# inside, e.g. $GLOBAL_VARIABLE; local variables start with an
# underline and use only lower case letters and underlines, e.g.
# $_local_variable .

#   [A-Z]*           system variables,      e.g. $MANPATH
#   [A-Z][A_Z_]*     global file variables, e.g. $MAN_PATH
#   _[a-z_]*         local variables,       e.g. $_manpath
#   _[a-z_]          local loop variables,  e.g. $_i

# global variables
FILE_ARGS=""			# the non-option command line parameters
HAS_COMPRESSION=""		# `yes' if compression is available
HAS_MANW=""			# `yes' if `man -w' is available
HAS_MKTEMP=""			# `yes' if `mktemp' program is available
HAS_OPTS_GNU=""			# `yes' if GNU `getopt' is available
HAS_OPTS_POSIX=""		# `yes' if POSIX `getopts' is available
MAN_PATH=""			# search path for man-pages
OTHER_OPTIONS=""		# given non-native command line options
OPT_SOURCE=""			# source code option (`Quellcode')
OPT_DEVICE=""			# device option
OPT_DPI=""			# groff -X option
OPT_MAN=""			# interpret file params as man-pages
OPT_MANPATH=""			# manual setting of path for man-pages
OPT_TITLE=""			# title for gxditview window
OPT_XRDB=""			# X resource arguments to gxditview
TEMP_DIR=""			# directory for temporary files
TMP_CAT=""			# stores concatenation of everything
TMP_INPUT=""			# stores stdin, if any
TMP_DONE=""			# stores the names of processed args

# command line arguments
GROFFER_LONGOPTS="device: help man manpath: source title: version \
                  xrdb:";
GROFFER_SHORTOPTS="hQT:vX";
GROFF_ARG_SHORTS="d:f:F:I:L:m:M:n:o:P:r:w:W:"; # inhereted from groff
GROFF_SHORTOPTS="abcegilpstzCEGNRSUVZ";	       # inhereted from groff
ALL_SHORTOPTS=\
"${GROFFER_SHORTOPTS}${GROFF_SHORTOPTS}${GROFF_ARG_SHORTS}";
ALL_LONGOPTS="${GROFFER_LONGOPTS}";

PROCESS_ID="$$"			# for shutting down the program

ENABLE_MANPAGES=yes		# enable search for man-pages

########################################################################
#                        System Test
########################################################################

# Test the availability of the system utilities used in this script.

########################################################################
# Test of function "test".
#
[ "a" = "a" ] || exit 1;

########################################################################
# Test of function "echo".
#
if [ "$(echo -n 'te' && echo -n && echo 'st')" != "test" ]; then
  echo 'Test of "echo" command failed.' >&2;
  exit 1;
fi;

########################################################################
# Test of function "sed".
#
if [ "$(echo teeest | sed -e '\|^teeest$|s|\(e\)\+|\1|')" != "test" ];
then
  echo 'Test of "sed" command failed.' >&2;
  exit 1;
fi;

########################################################################
# Test of function "grep".
#
if [ "$( (echo no; echo test) | grep -e '^.e..$')" != "test" ]; then
  echo 'Test of "grep" command failed.' >&2;
  exit 1;
fi;

########################################################################
# Test of function "cat".
#
if [ "$(echo test | cat)" != "test" ]; then
  echo 'Test of "cat" command failed.' >&2;
  exit 1;
fi;

########################################################################
# Test for compression.
#
if [ "$(echo test | zcat -f -)" = "test" ]; then
  HAS_COMPRESSION="yes";
else
  HAS_COMPRESSION="no";
fi;

########################################################################
# Test for temporary directory and file generating utility
#

# determine temporary directory into `$TEMP_DIR'
for _i in "$GROFF_TMPDIR $TMPDIR" "$TMP" "$TEMP" "$TEMPDIR" \
          "$HOME"/tmp /tmp "$HOME" .;
do
  if [ "$_i" != "" ]; then
    if [ -d "$_i" -a -r "$_i" -a -w "$_i" ]; then
      TEMP_DIR="$_i";
      break;
    fi;
  fi;
done
unset _i
if [ "$TEMP_DIR" = "" ]; then
  echo "Couldn't find a directory for storing temorary files." >&2;
  exit 1;
fi;

# test whether function `mktemp' is available
_tmp="$(mktemp "${TEMP_DIR}/.${PROGRAM_NAME}".XXXXXX)" 2>/dev/null;
if [ "$_tmp" != "" ]; then
  HAS_MKTEMP="yes";
  rm -f "$_tmp";
else
  HAS_MKTEMP="no";
fi;
unset _tmp;

########################################################################
# Test option parsing programs.
#

# GNU getopt
if _res="$(getopt -l GNU: ab: --GNU getopt test 2>/dev/null |
           sed -e '\|^ *\(.*\) *$|s||\1|')"; then
  if [ "$_res" = "--GNU 'getopt' -- 'test'" ]; then	
    HAS_OPTS_GNU="yes";
  fi;
fi;

# POSIX getopts
OPTIND=1;
OPTARG="";
getopts "t:" _opt -test 2>/dev/null;
if [ "$?" -eq 0 -a "$_opt" = "t" -a \
     "$OPTARG" = "est" -a "$OPTIND" -eq 2 ]; then
  HAS_OPTS_POSIX="yes";
fi;

if [ "$HAS_OPTS_GNU" = "" -a "$HAS_OPTS_POSIX" = "" ]; then
  error "No argument parser program available (`getopt' or `getopts').";
fi;

unset _opt;
unset _res;
OPTIND=1;
OPTARG="";

########################################################################
# Determine search method for man-pages
#
unset HAS_MANW			# `yes' if `man -w' is available
if _files="$(man -w man 2>/dev/null)"; then
  if [ "$_files" = "" ]; then
    HAS_MANW="no";
  else
    for _i in $_files; do
      if [ -f "$_i" ]; then
        HAS_MANW="yes";
        break;
      fi;
    done;
  fi;
  if [ "$HAS_MANW" != "yes" ]; then
    HAS_MANW="no";
  fi;
fi;
if [ "$HAS_MANW" != "yes" ]; then
  if [ "$MANPATH" = "" ]; then
    _dirs="$(manpath 2>/dev/null | tr : ' ')";
    if [ "$?" != 0 -o "$_dirs" = "" ]; then
      MANPATH="$_dirs";
    fi
  fi
  if [ "$MANPATH" = "" ]; then # set some default path
    _manpath="/usr/local/share/man /usr/local/man \
              /usr/share/man /usr/man \
              /usr/X11R6/man /usr/openwin/man \
              /opt/man /opt/gnome/man /opt/kde/man";
  else
    _manpath="$(echo -n $MANPATH | tr : ' ')";
  fi;
  _dirs="";
  for _p in $_manpath; do
    if [ -d "$_p" -a -r "$_p" -a -x "$_p" ]; then
      if [ "$_dirs" = "" ]; then
        _dirs="$_p";
      else
        _dirs="$_dirs $_p";
      fi;
    fi;
  done;
  _manpath="$_dirs";
  if [ "$LANG" = "" ]; then
    MAN_PATH="$_manpath";
  else				# language-specific directories
    MAN_PATH="";
    # two-letter version of $LANG
    _lang_short="$(echo $LANG | sed -e '\|^\(..\).*$|s||\1|')";
    for _p in $_manpath; do
      _dirs="${_p}/${_lang_short}*"; # all dirs for 2-letter lang code
      if [ "$_dirs" != "" ]; then
        if [ -d "${_p}/${LANG}" ]; then
	  _dirs="$_dirs ${_p}/${LANG}";
	fi;
      fi;
      if [ "$MAN_PATH" = "" ]; then
        MAN_PATH="$_dirs $_p";
      else
        MAN_PATH="$MAN_PATH $_dirs $_p";
      fi;
    done;    
  fi;
fi;
unset _files;
unset _dirs;
unset _i;
unset _p;
unset _manpath;

########################################################################
#                           Shell Funtions
########################################################################

# Survey of functions defined here

# The elements specified within paranthesis `(<>)' give hints to what
# the arguments are meant to be; the argument names are irrelevant.
# <>?     0 or 1
# <>*     arbitrarily many incl. none
# <>      exactly 1

# append_args (<arg>*)
# base_name (path)
# catz (<file>*)
# check_dpi ()
# clean_up ()
# count_next_quoted (<arg>*)
# del_all_leading_from (<regexp> <string>)
# del_ext_from (<extension> <filename>)
# echo2 (<text>*)
# error (<err_no> <text>*)
# get_manpath ()
# get_next_quoted (<arg>*)
# get_title ()
# is_substring_of (<part> <string>)
# leave ()
# manpage_from_path (<name> <section>?)
# manpage_search_filespec (<filespec>)
# manpage_search_name (<name> <section>?)
# normalize_args (<arg>*)
# output (<text>*)
# register_done_file (<filespec>*)
# save_stdin_if_any ()
# shift_quoted (<arg>*)
# supercat (<filearg>*)
# tmp_cat ()
# tmp_create ()
# unquote (<arg>*)
# usage ()
# version ()

########################################################################
# append_args (<arg>*)
#
# Append args to `string' separated by a space, omitting empty args.
#
# Arguments : >=2
# Output    : the generated string
#
append_args()
{
  local _res;
  while [ "$1" = "" ]; do
    if [ "$#" -eq 0 ]; then
      return;
    fi;
    shift;
  done;
  _res="$1";
  shift;
  while [ "$#" -ge 1 ]; do
    if [ "$1" != "" ]; then
      _res="$_res $1";
    fi;
    shift;
  done;
  output "$_res";
}

########################################################################
# base_name (path)
#
# Delete the directory part of `path', i.e. everything up to last `/'
# at the beginning of `path'.
#
# Arguments : 1
# Output    : the corrected string
#
base_name()
{
  if [ "$#" != 1 ]; then
    error 1 "Function base_name needs 1 argument.";
  fi
  output "$1" | sed -e '\|^\(.*/\)\+|s|||';
}

########################################################################
# catz (<file>*)
#
# If compression is available decompress standard input and write it to
# standard output; otherwise copy standard input to standard output.
#
catz()
{
  if [ "$HAS_COMPRESSION" = "yes" ]; then
    if [ "$#" = 0 ]; then
      set -- -;
    fi;
    zcat -f "$@";
  else
    cat "$@";
  fi;
}

########################################################################
# check_dpi ()
#
# Sanity check for having default X resolution 100 dpi (very defensive)
#
# Output  : generated title
#
check_dpi()
{
  local _res=100;
  local _fp;
  if _fp="$(xset q | grep '/font' 2>/dev/null)"; then
    case "$_fp" in
      *100*) : ; ;;
      *75*)  _res=75; ;;	# no 100 found in X font path, but 75
    esac;
  fi;
  output "$_res";
}

########################################################################
# clean_up () :
#
# Clean exit without an error.
#
clean_up()
{
  rm -f "$TMP_CAT" "$TMP_INPUT" "$TMP_DONE";
}

########################################################################
# count_next_quoted (<arg>*)
#
# Expects single-quoted arguments, returns the first quoted argument.
#
# Arguments : single-quoted, evt. with included spaces.
# Output    : number of arguments within the single-quote.
# Return    : `1' if arguments are not single-quoted, `0' otherwise.
#
count_next_quoted()
{
  local _args;
  local _number;
  local _quoted_block="";
  if [ "$#" -eq 0 ]; then
    return 1;
  fi;
  if output $1 | grep -e "^'" >/dev/null 2>&1; then
    # starts with a single quote
    while ! (output $1 | grep -e \'\$ >/dev/null 2>&1); do
      # doesn't end with a single quote
      _quoted_block="$(append_args $_quoted_block $1)";
      shift;
      if [ "$#" = 0 ]; then
        error "count_next_quoted : no closing quote found"
	return 1;
      fi;
    done;
    # actual $1 has closing quote
    _quoted_block="$(append_args $_quoted_block $1)";
    set -- $_quoted_block;
    _number="$#";
  else
    _number=1;
  fi;
  output $_number;
}

########################################################################
# del_all_leading_from (<regexp> <string>)
#
# Delete every occurence of `regexp' at the beginning of `string'.
#
# Arguments : 2
# Output    : the corrected string
#
del_all_leading_from()
{
  if [ "$#" != 2 ]; then
    error 1 'Function "del_all_leading_from" needs 2 args.';
  fi
  output "$2" | sed -e '\|^\('"$1"'\)\+|s|||';
}

########################################################################
# del_ext_from (<extension> <filename>)
#
# Delete `extension' from the end of `filename'.
#
# Arguments : 2
# Output    : the corrected string
#
del_ext_from()
{
  if [ "$#" != 2 ]; then
    error 1 'Function "del_ext_from" needs 2 args.';
  fi
  output "$2" | sed -e "\|^ *\('\?.*\)$1\('\?\) *"'$|s||\1\2|';
}

########################################################################
# echo2 (<text>*)
#
# Output to stderr.
#
# Arguments : arbitrary text.
#
echo2()
{
  echo "$*" >&2;
}

########################################################################
# error (<err_no> <text>*)
#
# Output argurments to stderr and abort.
#
# Arguments : arbitrary text
#
error()
{
  local _errno;
  case "$#" in
    0) set -- 'unknown error'; ;;
  esac;
  echo2 "groffer error : $*";
  clean_up;
  kill "$PROCESS_ID" >/dev/null 2>&1;
  kill -9 "$PROCESS_ID" >/dev/null 2>&1;
  exit 1;
}

########################################################################
# get_manpath ()
#
# Determine search path for man-pages (only needed when no `man -w').
#
# Return  : `0' if a valid path was retrieved.
# Output  : path as space-separated list (intended for $MAN_PATH).
# Globals : system : $MANPATH $LANG
#           file   : $OPT_MANPATH $MAN_PATH
#
get_manpath()
{
  local _files;
  local _dirs;
  local _i;
  local _d;
  local _p;
  local _all;
  local _manpath;
  if [ "$OPT_MANPATH" != "" ]; then # --manpath was set
    MANPATH="$OPT_MANPATH";
  fi;
  if [ "$MANPATH" = "" ]; then	# try `manpath' program
    _dirs="$(manpath 2>/dev/null)";
    if [ "$?" = 0 -a "$_dirs" != "" ]; then
      MANPATH="$_dirs";
    fi
  fi
  if [ "$MANPATH" = "" ]; then # set some default path
    _manpath="/usr/local/share/man /usr/local/man \
              /usr/share/man /usr/man \
              /usr/X11R6/man /usr/openwin/man \
              /opt/man /opt/gnome/man /opt/kde/man";
  else
    _manpath="$(echo -n $MANPATH | tr : ' ')";
  fi;
  if [ "$_manpath" = "" ]; then
    return 1;
  fi;
  _dirs="";
  for _p in $_manpath; do	# remove non-existing directories
    if [ -d "$_p" -a -r "$_p" -a -x "$_p" ]; then
      _dirs="$(append_args $_dirs $_p)";
    fi;
  done;
  _manpath="$_dirs";
  if [ "$_manpath" = "" ]; then
    return 1;
  fi;
  if [ "$LANG" = "" ]; then
    MAN_PATH="$_manpath";
  else				# language-specific directories
    MAN_PATH="";
    # two-letter version of $LANG
    _short_code="$(echo $LANG | sed -e '\|^\(..\).*$|s||\1|')";
    for _p in $_manpath; do
      _langdir="${_p}/${LANG}";
      _all="$(ls -d "${_p}/${_short_code}"* 2>/dev/null)";
			# all dirs with this 2-letter lang code
      _langs="";
      if [ "$_all" != "" ]; then
        for _d in $_all; do
	  if [ "$_d" != "$_langdir" -a -d "$_d" ]; then
	    _langs="$(append_args "$_langs" "$_d")";
	  fi;
	done;
        if [ -d "$_langdir" ]; then
	  _langs="$(append_args "$_langdir" $_langs)";
	fi;
      fi;
      MAN_PATH="$(append_args "$_langs" $_p)";
    done;    
  fi;
  if [ "$MAN_PATH" = "" ]; then
    return 1;
  fi;
  output "$MAN_PATH";
}


########################################################################
# get_next_quoted (<arg>*)
#
# Expects single-quoted arguments, returns the first quoted argument.
#
# Arguments : single-quoted, evt. with included spaces.
# Output    : everything up to the next arg terminated by a quote;
#             the enclosing quotes are removed.
# Return    : `1' if arguments are not single-quoted, `0' otherwise.
#
get_next_quoted()
{
  local _args="$*";
  local _number="$(count_next_quoted $_args)";
  shift $_number;
  output $_args | sed -e '\|^\(.*\)'"$*"'$|s||\1|' |
                  sed -e "\|^ *'\(.*\)' *"'$|s||\1|';
}

########################################################################
# get_title ()
#
# create title for X from the $TMP_DONE file
#
# Globals : $TMP_DONE $OPT_XRDB $OPT_TITLE
# Output  : generated title
#
get_title()
{
  if [ "$OPT_TITLE" != "" ]; then
    # title was set by option --title
    output "$OPT_TITLE";
    return 0;
  fi;
  if is_substring_of "-title" "$OPT_XRDB"; then
    # $OPT_XRDB is handled anyway, so no extra output from here
    return 0;
  fi;
  # no title was supplied on the command line, take the default title
  # constisting of the processed filespecs, stored in file $TMP_DONE.
  cat "$TMP_DONE";
}

########################################################################
# is_substring_of (<part> <string>)
#
# Test whether `part' is contained in `string'.
#
# Arguments : 2 text arguments.
# Return    : `0' if arg1 is substring of arg2, `1' otherwise.
#
is_substring_of()
{
  if [ "$#" != 2 ]; then
    false;
    error "is_substring_of needs 2 arguments.";
  fi;
  if output "$2" | grep -e "$1" >/dev/null 2>&1; then
    return 0;
  else
    return 1;
  fi;
}

########################################################################
# leave ()
#
# Clean exit without an error.
#
leave()
{
  clean_up;
  exit 0;
}

########################################################################
# manpage_from_path (<name> <section>?)
#
# Get position of man-page using the $MAN_PATH variable.
#
# Globals   : $MAN_PATH must be preset as space-separated list of dirs.
#             $LANG system language preset.
# Arguments : either 2 (`name' `section') or 1 (`name').
# Output    : the file position for the man-page
# Return    : `0'
#
manpage_from_path()
{
  local _i;
  local _p;
  local _dirs;
  local _args;
  local _name="$1";
  local _section="$2";
  case "$#" in
    1) _args="$1"; ;;
    2) _args="$2 $1"; ;;
    *)
      false;
      error 1 "man_from_path : needs 1 or 2 arguments.";
      ;;
  esac;
  if [ "$HAS_MANW" = "yes" ]; then
    error manpage_from_path : "man -w" is available.
  fi;
  if [ "$MAN_PATH" = "" ]; then
    return 0;
  fi;
  for _p in $MAN_PATH; do
    set -- "$(ls -d "${_p}/man${_section}"*"/${_name}.${_section}"* \
                 2>/dev/null)";
    while [ "$#" -gt 0 ]; do
      if [ -f "$1" -a -r "$1" ]; then
        output "$1";
	return 0;
      fi;
      shift;
    done;
  done;
  return 1;
}

########################################################################
# manpage_search_filespec (<filespec>)
#
# check argument with `man -w'
#
# Arguments : exactly 1 argument of the form `name.section',
#             `man:name', or `man:name(section)'.
#             Several args indicate an embedded space character.
#             
# Output    : filename of man page, if any.
# Return    : `0' if man page was found, `1' else.
# 
manpage_search_filespec()
{
  local _file="";
  local _arg;
  local _name;
  local _section;
  if [ "$#" -ne 1 ]; then
    return 1;
  fi;
  _arg="$1";
#  _arg="$(output "$1" | sed -e "\|'\(.*\)'|s||\1|")";
  case "$_arg" in
    */*)			# contains directory part, not handled
      return 1;
      ;;
    man:?*\(?*\))		# `man:' URL with section
      _name="$(output "$_arg" |
                 sed -e '\|^man:\([^(]\+\)(\(.*\))$|s||\1|')";
      _section="$(output $_arg |
                 sed -e '\|^man:\([^(]\+\)(\(.*\))$|s||\2|')";
      if _file="$(manpage_search_name "$_name" "$_section")" &&
        [ "$_file" != "" ]; then
        output "$_file";
        return 0;
      fi;
      return 1;
      ;;
    man:?*)			# `man:' URL without section
      _name="$(output "$_arg" | sed -e '\|^man:|s|||')";
      if _file="$(manpage_search_name "$_name")"; then
        output "$_file";
        return 0;
      else
        return 1;
      fi;
      ;;
    ?*.?*)			# name.section
      _name="$(output "$_arg" |
                 sed -e '\|^\([^.]\+\)\.\([^.]\+\)$|s||\1|')";
      _section="$(output "$_arg" |
                 sed -e '\|^\([^.]\+\)\.\([^.]\+\)$|s||\2|')";
      _file="$(manpage_search_name "$_name" "$_section")";
      if [ "$?" -eq 0 -a "$_file" != "" ]; then
        output "$_file";
        return 0;
      fi;
      _file="$(manpage_search_name "$_arg")"
      if [ "$?" -eq 0 -a "$_file" != "" ]; then
        output "$_file";
        return 0;
      fi;
      return 1;
      ;;
    ?*)
      _file="$(manpage_search_name "$_arg")";
      if [ "$?" -eq 0 -a "$_file" != "" ]; then
        output "$_file";
        return 0;
      fi;
      return 1;
      ;;
  esac;
  return 1;
}

########################################################################
# manpage_search_name (<name> <section>?)
#
# Get position of man-page `name(section)', or just `name' in the
# lowest section using `man -w'.
#
# Arguments : either 2 (`name' `section') or 1 (`name').
# Output    : the file position for the man-page
#
manpage_search_name()
{
  local _i;
  local _name;
  local _section;
  case "$#" in
    1)
      _name="$1";
      _section="";
      ;;
    2)
      _name="$1";
      _section="$2";
      ;;
    *)
      error "man_search_name : needs 1 or 2 arguments.";
      ;;
  esac;
  if [ "$HAS_MANW" = "yes" ]; then
    for _i in $(man -w $_section "$_name" 2>/dev/null); do
      if [ -f "$_i" -a -r "$_i" ] &&
         (catz "$_i" | grog | grep -e '-man') >/dev/null 2>&1;
      then
        output "$_i";
        return 0;
      fi
    done;
  else
    manpage_from_path $_section "$_name";
    return 0;
  fi;
  return 1;
}

########################################################################
# normalize_args (<arg>+)
#
# Display arguments in the normalized form of GNU `getopt'.
#
# Arguments : if no arguments are given, $* is parsed instead
# Globals   : $ALL_LONGOPTS $ALL_SHORTOPTS
# Output    : arguments in normalized form
#
normalize_args()
{
  local _args;
  local _long_opts="";
  local _i;
  local _res;
  local _opt;
  if [ "$#" -eq 0 ]; then
    set -- -;
  fi;
  if [ "$HAS_OPTS_GNU" = "yes" ]; then
    _long_opts="";
    for _i in ${ALL_LONGOPTS}; do
      _long_opts="$(append_args $_long_opts -l "$_i")";
    done;
    if _res="$(getopt -l "$_long_opts" "$ALL_SHORTOPTS" "$@")"; then
      output "$_res";
      return 0;
    else
      error 'wrong option';
    fi;   
  elif [ "$HAS_OPTS_POSIX" = "yes" ]; then # POSIX getopts
    case "--[^ ]" in
      "$_args") error "long options are only available in GNU."; ;;
    esac;
    OPTIND=1;
    OPTARG="";
    _res="";
    while getopts ":$ALL_SHORTOPTS" _opt $_args; do
      if [ "$_opt" = ":" ]; then
        if [ "$OPTARG" = "-" ]; then
	  error "your system does not allow GNU long options.";
	else
	  error "unknown option.";
        fi;
      fi;
      _res="$(append_args $_res -"$_opt")";
      if [ "$OPTARG" != "" ]; then
        _res="$(append_args $_res "'$OPTARG'")";
				# option args are quoted;
        OPTARG="";
      fi;
    done;
    if [ "$_opt" == '?' ]; then	# end of options
      # non-option parameters are quoted in the output
      _param="";
      set -- $_args;
      if [ "$OPTIND" -le "$#" ]; then
        _res="$(append_args $_res "--")";
        eval _param=${"$OPTIND"};
	if [ "$_param" != "--" ]; then
          _res="$(append_args $_res "'$_param'")";
        fi;
        shift "$OPTIND";
        while [ "$#" -gt 0 ]; do
          _res="$(append_args $_res "'$1'")";
        done;
      fi;
      output $_res;
      return 0;
    else
      error 'error in option parsing';
    fi;
  fi;
}

########################################################################
# output (<text>*)
#
# Print arguments to standard output, if there are any.
# Handle `echo' programs that can have only 1 arg.
#
# Arguments : any.
# Output    : the list of the arguments without a line break.
#
output()
{
  if [ "$#" -ge 1 ]; then
    echo -n "$*";
  fi;
}

########################################################################
# register_done_file (<filespec>)
#
# Transform argument into a title element and append to $TMP_DONE file.
#
register_done_file() {
  set -- $(base_name "$*");	    # remove directory part
  set -- $(del_ext_from .gz "$*"); # remove .hz
  set -- $(del_ext_from .Z "$*");   # remove .Z
  case "$#" in
    0) return; ;;
    1) _res="$1"; ;;
    *) _res="'$*'"; ;;
  esac;
  output " $_res" >> "$TMP_DONE";
}

########################################################################
# save_stdin_if_any ()
#
# Check if stdin is needed; if so, store to temporary file.
# Globals : $FILE_ARGS
#
save_stdin_if_any()
{
  local _a
  set -- $FILE_ARGS
  for _a in "$@"; do
    if [ "$_a" = "'-'" ]; then
      cat | catz - >"$TMP_INPUT"; # using `cat' first is safer
      break;
    fi;
  done;
}

########################################################################
# shift_quoted (<arg>*)
#
# Expects single-quoted arguments, strips the first quoted argument.
#
# Arguments : single-quoted, evt. with included spaces.
# Output    : delete everything up to the next arg terminated by a
#             quote and the following space, output the rest.
# Return    : `1' if arguments are not single-quoted, `0' otherwise.
#
shift_quoted()
{
  local _args="$*";
  shift "$(count_next_quoted $_args)";
  output $*;
}

########################################################################
# supercat (<filearg>*)
#
# Output the concatenation of files, man-pages, or standard input to
# standard output.  All parts that are stored in the gzip or Z
# compression format are decompressed.  No other modifications.
# All processed arguments are added to the global variable
# $ARGS_DONE.
#
# Arguments :
#   All arguments are expected to be surrounded by single quotes.
#   - names of existing files.
#   - '-' to represent standard input (several times allowed).
#   - 'man:name.(section)' the man-page for `name' in `section'.
#   - 'man:name' the man-page for `name' in the lowest `section'.
#   - 'name.section' the man-page for `name' in `section'.
#   - 'name' the man-page for `name' in the lowest `section'.
# Globals :
#   $TMP_INPUT : (read-only)
#   $ARGS_DONE : (read-write) arguments with a corresponding file
#                are added to variable ARGS_DONE.
# Output  : the decompressed files corresponding to the arguments
# Return  : 0 always, all errors are tolerated or fatal.
#
supercat()
{
  local _file;
  local _filespec;
  local _args;
  local _mode;
  local _sequence;
  if [ "$#" -eq 0 ]; then
    error 1 "supercat needs at least 1 arg";
  fi;
  # remove enclosing quotes and space characters
   _args="$(output $* | grep -e "^ *'.\+'"'$' |
            sed -e '\|^ *\(.*\) *$|s||\1|')";
  if [ "$_args" = "" ]; then
    error 1 "supercat : arguments are not quoted.";
  fi;
  while [ "$_args" != "" ]; do
    _filespec="$(get_next_quoted $_args)";
    _args="$(shift_quoted $_args)";
    if [ "$_filespec" = "" ]; then
      continue;
    fi;
    if [ "$_filespec" = "-" ]; then
      catz "$TMP_INPUT";
      register_done_file "-";
      continue;       
    fi
    if [ "$ENABLE_MANPAGES" = "yes"  ]; then
      if [ "$OPT_MAN" = "yes" ]; then
        _sequence="Manpage File";
      else
        _sequence="File Manpage";
      fi;
    else
      _sequence="File";
    fi;
    _done="no";
    for _mode in $_sequence; do
      case "$_mode" in
        File)
          if [ -f "$_filespec" -a -r "$_filespec" ]; then
            catz "$_filespec";
	    register_done_file "$_filespec";
	    _done="yes";
	    break;
          fi;
          ;;
        Manpage)
          _manfile="$(manpage_search_filespec "$_filespec")";
          if [ "$?" -eq 0  ]; then
            catz "$_manfile";
	    register_done_file "$_manfile";
	    _done="yes";
	    break;
          fi;
          ;;
      esac;
    done;
    if [ "$_done" != "yes" ]; then
      echo2 \"$_filespec\" is neither a file nor a man-page.;
    fi;
   done;
}

########################################################################
# tmp_cat ()
#
# output the temporary cat file (the concatenation of all input)
#
tmp_cat()
{
  cat "$TMP_CAT";
}

########################################################################
# tmp_create ()
#
# create temporary file 
#
# Output  : file generated title 
#
tmp_create()
{
  local _i;
  local _tmp="";
  local _prefix="${TEMP_DIR}/.${PROGRAM_NAME}.";
  if [ "$TEMP_DIR" = "" ]; then
    error 1 "Temporary directory must be determined first.";
  fi;
  if [ "$HAS_MKTEMP" = "yes" ]; then
    # unquoted is ok, because mktemp output has no space chars
    _tmp="$(mktemp "${_prefix}.XXXXXX" 2>/dev/null)"; # automatic
    if [ "$_tmp" = "" ]; then
      HAS_MKTEMP="no";		# try manually
    else
      if [ ! -e "$_tmp" ]; then
        echo -n >"$_tmp";
      fi;
      output "$_tmp";
      return 0;
    fi;
  fi;
  if [ "$HAS_MKTEMP" != "yes" ]; then
    _tmp="";			# manual determination
    for _i in a b c d e f g h i j k l m n o p q r s t u v w x y z \
              A B C D E F G H I J K L M N O P Q R S T U V W X Y Z; do
      _tmp="${_prefix}$$${_i}";
      if [ -e "$_tmp" ]; then
        _tmp="";
        continue;
      else
        break;  
      fi;
    done;
  fi;
  if [ "$_tmp" = "" ]; then
    error 1 "Could not manually create temporary file.";
  fi
  echo -n >"$_tmp";
  output "$_tmp";
}

########################################################################
# unquote (<arg>*)
#
# Remove quotes around each argument and escape all space characters
# by a backslash `\'.
#
# Output : the same number of arguments, but each processed.
#
unquote()
{
  local _res;
  local _a;
  local _args;
  [ "$#" = 0 ] && return;
  _res="";
  for _a in "$@"; do
    _unq="$(eval output $_a | sed -e '\| |s||\\ |g')";
    if [ "$_res" = "" ]; then
      _res="$_unq";
    else
      _res="$_res $_unq";
    fi;
  done;
  output "$_res";
}

########################################################################
# usage ()
#
# print usage information to stderr
#
usage()
{
  echo2;
  version;
  cat >&2 <<EOF
Copyright (C) 2001 Free Software Foundation, Inc.
This is free software licensed under the GNU General Public License.

Usage : $PROGRAM_NAME [options] [file] [-]
                  [manpage.x] [man:manpage] [man:manpage(x)] ...

Display groff files, standard input, and/or Unix manual pages with
gxditview in X window or in a text pager.
"-" stands for including standard input.
"manpage" is the name of a man-page, "x" its section.
All parameters and standard input are decompressed on-the-fly (by zcat).

-c --stdout    tty output without a pager
-h --help      print this usage message.
-Q --source    output as roff source.
-T --device    set device for X or tty output.
-v --version   print version information.
-X --dpi=res   set resolution to "res" ("75" or "100" (default)).
--man          check file arguments first on being man-pages.
--manpath=path preset path for searching man-pages, "" means disable.
--xrdb=opt     pass "opt" as option to gxditview (several allowed).
All other options are interpreted as "groff" parameters and tranferred
unmodified to "grog".
EOF

  if [ "$HAS_OPTS_GNU" != "yes" ]; then
    cat >&2 <<EOF

Your system does not support GNU long options.  All options starting
with double-minus are not available.
EOF
  echo2;
  fi;
}

########################################################################
# version ()
#
# print version information to stderr
#
version()
{
  echo2 "$PROGRAM_NAME $PROGRAM_VERSION of $LAST_UPDATE";
}

########################################################################
#                              main
########################################################################

# The main area contains the following parts:
# - argument parsing
# - temporary files
# - display

########################################################################
# main : argument parsing
#
set -- $(normalize_args "$@");

# $* is garanteed to have a "--" argument, separating opts and params.
# Note that all arguments to options and all non-option parameters are
# enclosed in single quotes, while options are not quoted.  The quotes
# must be removed before being used, see function `unqote'. For example,
# -X -m 'man' -- 'file1' '-' 'file2'

# parse options
until [ "$1" = "--" -o "$1" = "'--'" ]; do
  # Note: arguments to options are quoted; these quotes must be handled.
  #
  _opt="$1";
  shift;
  case "$_opt" in
    -h|--help)
      usage;
      leave;
      ;;
    -Q|--source)		# output source code (`Quellcode').
      OPT_SOURCE="yes";
      ;;
    -T|--device)		# device, non-X* go to stdout, arg
      _arg="$(get_next_quoted $*)";
      set -- $(shift_quoted $*);
      case "$_arg" in
        X75)
          OPT_DEVICE="";
          OPT_DPI=75;
          ;;
        X100)
          OPT_DEVICE="";
          OPT_DPI=100;
          ;;
        *)
          OPT_DEVICE="$_arg";
          OPT_DPI="";
          ;;
      esac;
      ;;
    -v|--version)
      version;
     leave;
      ;;
    -X)				# set X resolution 75 dpi (default 100).
      OPT_DEVICE="";
      OPT_DPI=75;
      ;;
    --man)			# interpret all file params as man-pages
      OPT_MAN="yes";
      if [ "$ENABLE_MANPAGES" != "yes" ] ; then
        error "confilicting options --man and --manpath.";
      fi;
      ;;
    --manpath)			# specify search path for man-pages, arg
      OPT_MANPATH="$(get_next_quoted $*)";
      set -- $(shift_quoted $*);
      if [ "$OPT_MANPATH" = "" ]; then
        ENABLE_MANPAGES="no";
        if [ "$OPT_MAN" = "yes" ] ; then
          error "confilicting options --man and --manpath.";
        fi;
      else
        ENABLE_MANPAGES="yes";
      fi;
      HAS_MANW="";
      ;;
    --title)
      OPT_TITLE="$(get_next_quoted $*)";
      set -- $(shift_quoted $*);
      ;;
    --xrdb)			# add X resource for gxditview, arg
      _arg="$(get_next_quoted $*)";
      set -- $(shift_quoted $*);
      OPT_XRDB="$(append_args "$OPT_XRDB" "$_arg")";
      ;;
    -?)
      _opt_char="$(output $_opt | sed -e '\|-.|s|-||')";
      if is_substring_of "$_opt_char" "${GROFF_SHORTOPTS}"; then
        OTHER_OPTIONS="$(append_args "$OTHER_OPTIONS" "$_opt")";
      elif is_substring_of "$_opt_char" "${GROFF_ARG_SHORTS}"; then
        OTHER_OPTIONS="$(\
          append_args $OTHER_OPTIONS "${1}$(unquote ${2})")";
	shift;			# argument
      else
        error 1 "Unknown option : $1";
      fi;
      ;;
    *) error 1 "main : error on argument parsing : $*"; ;;
  esac;
done;
shift;				# remove `--' argument

unset _arg
unset _opt

# Remaining arguments are file names, each enclosed in single quotes.
# Function supercat expects such arguments.

if [ "$#" -eq 0 ]; then         # use "-" for standard input
  set -- "'-'";
fi;
FILE_ARGS="$*";			# all file parameters; do not change

# setup for man-pages

if [ "$ENABLE_MANPAGES" = "yes" -a "$HAS_MANW" != "yes" ]; then
  MAN_PATH="$(get_manpath)";
  if [ "$MAN_PATH" = "" ]; then
    ENABLE_MANPAGES="no";
  fi;
fi;

########################################################################
# main : temporary files
#
# save standard input
TMP_INPUT="$(tmp_create)";
save_stdin_if_any;

# built up title consisting of processed filespecs
TMP_DONE="$(tmp_create)";
output "$PROGRAM_NAME :" > $TMP_DONE;

# output parameter files (and stdin) decompressed into temporary file
TMP_CAT="$(tmp_create)";
supercat $FILE_ARGS >"$TMP_CAT"; # this does the main work
set -- $(ls -l -L "$TMP_CAT");	 # check on empty
if [ "$5" -eq 0 ]; then
  echo2 "input is empty, nothing to display.";
  leave;
fi;

########################################################################
# main : display
#
_mode="";
if [ "$OPT_SOURCE" = "yes" ]; then # output source code
  _mode="source";
elif [ "$OPT_DEVICE" != "" ]; then # non-X device, cat to stdout
  _mode="device";
elif [ "$DISPLAY" != "" ]; then	# within X window
  _mode="X";
else				# tty
  _mode="tty";
fi;

case "$_mode" in
  source)
    tmp_cat;
    ;;
  device)
    _groggy="$(tmp_cat | grog $OTHER_OPTIONS -T"${OPT_DEVICE}")";
    tmp_cat | eval $_groggy;
    ;;
  X)
    if [ "$OPT_DPI" = "" ]; then
      OPT_DPI="$(check_dpi)";	# sanity check for using 100 dpi default
    fi;
    _groggy="$(tmp_cat | grog $OTHER_OPTIONS -TX"${OPT_DPI}" -Z )";
    tmp_cat | eval $_groggy | \
      gxditview $OPT_XRDB -title "$(get_title)" -;
    ;;
  tty)
    if [ "$OPT_DPI" = "" ]; then
      error 1 "Not in X window, no X device available.";
    fi;
    _groggy="$(tmp_cat | grog $OTHER_OPTIONS -Tlatin1)";
    if [ "$PAGER" = "" ]; then
      _pager=less;
    else
      _pager=$PAGER;
    fi;
    tmp_cat | eval $_groggy | $_pager;
    ;;
esac;
clean_up;

#!/bin/sh

# groffer - display groff files

# File position: <groff-source>/contrib/groffer/groffer

# Copyright (C) 2001,2002 Free Software Foundation, Inc.
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
# along with groff; see the file COPYING.  If not, write to the
# Free Software Foundation, 59 Temple Place - Suite 330, Boston,
# MA 02111-1307, USA.

export _PROGRAM_NAME;
export _PROGRAM_VERSION;
export _LAST_UPDATE;

_PROGRAM_NAME=groffer
_PROGRAM_VERSION="0.7"
_LAST_UPDATE="31 May 2002"


########################################################################
#                          Description
########################################################################

# Display groff files and man pages on X or tty, even when compressed.


### Usage

# Input comes from either standard input or command line parameters
# that represent either names of exisiting roff files or standardized
# specifications for man pages.  All of these can be compressed in a
# format that is decompressible by `gzip'.

# Five displaying modes are available:
# 1) Display processed input with the X roff viewer `gxditview'.
# 2) Display processed input in a text terminal using a text device.
# 3) Generate output for some groff device on stdout without a viewer.
# 4) Output only the source code without any groff processing.
# 5) Generate the troff intermediate output on standard output
#    without groff postprocessing.
# By default, the program tries to display with `gxditview' (1); if
# this does not work, text display (2) is used.


### Error handling

# Error handling and exit behavior is complicated by the fact that
# `exit' can only escape from the current shell; trouble occurs in
# subshells.  This was solved by sending kill signals, see
# $_PROCESS_ID and error().
#


### TODO

# Add to existing man path the wanted system, language,
# section/extension directories.  Do not assume a fixed sequence of
# the 3 additions above.  So run all additions 3 times.


########################################################################
#                          Compatibility
########################################################################

# This script is compatible to POSIX and GNU.  It works best in a GNU
# system.  Care was taken to restrict the programming technics used
# here in order to achieve POSIX compatibility as far back as POSIX
# P1003.2 Draft 11.2 of September 1991.

# In GNU, long options and the mixing of options and file name
# parameters are available.  In non-GNU environments, long options can
# be simulated by preceding the long option and its argument by the
# option `-W', which was reserved by POSIX for such usage.  All
# groffer features are accessible, but the usage is not as comfortable
# as in GNU systems.


########################################################################
#                        General Setup
########################################################################

# set -a
# set -x
# set -v

########################################################################
#            Survey of functions defined in this document
########################################################################

# The elements specified within paranthesis `(<>)' give hints to what
# the arguments are meant to be; the argument names are irrelevant.
# <>?     0 or 1
# <>*     arbitrarily many such arguments, incl. none
# <>+     one or more such arguments
# <>      exactly 1

# A function that starts with an underscore `_' is an internal
# function for some function.  The internal functions are defined just
# after their corresponding function; they are not mentioned in the
# following.

# abort (text>*)
# base_name (path)
# catz (<file>)
# clean_up ()
# clean_up_secondary ()
# diag (text>*)
# dirname_append (<path> [<dir...>])
# dirname_chop (<path>)
# do_filearg (<filearg>)
# do_nothing ()
# echo2 (<text>*)
# echo2n (<text>*)
# error (<text>*)
# get_first_essential (<arg>*)
# is_dir (<name>)
# is_empty (<string>)
# is_equal (<string1> <string2>)
# is_file (<name>)
# is_not_empty (<string>)
# is_not_equal (<string1> <string2>)
# is_not_file (<name>)
# is_prog (<name>)
# is_yes (<string>)
# leave ()
#   main_*(), see after the functions
# man_do_filespec (<filespec>)
# man_setup ()
# man_register_file (<file> [<name> [<section>]])
# man_search_section (<name> <section>)
# manpath_add_lang(<path> <language>)
# manpath_add_system()
# manpath_from_path ()
# normalize_args (<shortopts> <longopts> <arg>*)
# path_chop (<path>)
# path_clean (<path>)
# path_contains (<path> <dir>)
# path_not_contains (<path> <dir>)
# path_split (<path>)
# register_file (<filename>)
# register_title (<filespec>)
# save_stdin ()
# string_contains (<string> <part>)
# string_del_append (<string>)
# string_del_leading (<string> <regex>)
# string_del_trailing (<string> <regex>)
# string_flatten()
# string_not_contains (<string> <part>)
# string_replace_all (<string> <regex> <replace>)
# string_sed_s (<string> <regex> [<replace> [<flag>]])
# string_split (<string> <separator>)
# tmp_cat ()
# tmp_create (<suffix>?)
# to_tmp (<filename>)
# usage ()
# version ()
# warning (<string>)
# whatis (<filename>)
# where (<program>)


########################################################################
#                       Environment Variables
########################################################################

# Environment variables that exist only for this file start with an
# underscore letter.  Global variables to this file are written in
# upper case letters, e.g. $_GLOBAL_VARIABLE; temporary variables
# start with an underline and use only lower case letters and
# underlines, e.g.  $_local_variable .

#   [A-Z]*     system variables,      e.g. $MANPATH
#   _[A-Z_]*   global file variables, e.g. $_MAN_PATH
#   _[a-z_]*   temporary variables,   e.g. $_manpath

# Due to incompatibilities of the `ash' shell, the name of loop
# variables in `for' must be single character
#   [a-z]      local loop variables,   e.g. $i


########################################################################
# External envirnoment variables

# If these variables are exported here then the `ash' shell coughs
# when calling `groff' in `main_display()'.

_export_externals='no';
if test "${_export_externals}" = 'yes'; then

  # external system environment variables that are explicitly used
  export DISPLAY;		# Presets the X display.
  export LANG;			# For language specific man pages.
  export LC_ALL;		# For language specific man pages.
  export LC_MESSAGES;		# For language specific man pages.
  export OPTARG;		# For option processing with getopts().
  export OPTIND;		# For option processing with getopts().
  export PAGER;			# Paging program for tty mode.
  export PATH;			# Path for the programs called (: list).

  # groffer native environment variables
  export GROFFER_OPT		# preset options for groffer.

  # all groff environment variables are used, see groff(1)
  export GROFF_BIN_PATH;	# Path for all groff programs.
  export GROFF_COMMAND_PREFIX;	# '' (normally) or 'g' (several troffs).
  export GROFF_FONT_PATH;	# Path to non-default groff fonts.
  export GROFF_TMAC_PATH;	# Path to non-default groff macro files.
  export GROFF_TMPDIR;		# Directory for groff temporary files.
  export GROFF_TYPESETTER;	# Preset default device.

  # all GNU man environment variables are used, see man(1).
  export MANOPT;		# Preset options for man pages.
  export MANPATH;		# Search path for man pages (: list).
  export MANSECT;		# Search man pages only in sections (:).
  export SYSTEM;		# Man pages for different OS's (, list).
  export MANROFFSEQ;		# Ignored because of grog guessing.

fi;

unset _export_externals;


########################################################################
# read-only variables (global to this file)

# characters

export _APPEND			# Append to string to cover final char
export _NEWLINE;
export _SPACE;
export _TAB;

_APPEND='Z';
_NEWLINE='
';
_SPACE=' ';
_TAB='	';

# function return values; `0' means ok; other values are error codes
export _BAD;
export _BAD2;
export _BAD3;
export _ERROR;
export _GOOD;
export _NO;
export _OK;
export _YES;

_GOOD='0';			# return ok
_BAD='1';			# return negatively, error code `1'
_BAD2='2';			# return negatively, error code `2'
_BAD3='3';			# return negatively, error code `3'
_ERROR='-1';			# syntax errors, etc.

_NO="${_BAD}";
_YES="${_GOOD}";
_OK="${_GOOD}";

export _PROCESS_ID;		# for shutting down the program
_PROCESS_ID="$$";

# Search automatically in standard sections `1' to `8', and in the
# traditional sections `9', `n', and `o'.  On many systems, there
# exist even more sections, mostly containing a set of man pages
# special to a specific program package.  These aren't searched for
# automatically, but must be specified on the command line.
export _MAN_AUTO_SEC;
_MAN_AUTO_SEC="1 2 3 4 5 6 7 8 9 n o"


############ the command line options of several programs
#
# The naming scheme for the options environment names is
# $_OPTS_<prog>_<length>[_<argspec>]
#
# <prog>:    program name GROFFER, GROFF, or CMDLINE (for all
#            command line options)
# <length>:  LONG (long options) or SHORT (single character options)
# <argspec>: ARG for options with argument, NA for no argument;
#            without _<argspec> both the ones with and without arg.
#
# Each option that takes an argument must be specified with a
# trailing : (colon).


###### native groffer options

export _OPTS_GROFFER_SHORT_NA;
export _OPTS_GROFFER_SHORT_ARG;
export _OPTS_GROFFER_LONG_NA;
export _OPTS_GROFFER_LONG_ARG;

_OPTS_GROFFER_SHORT_NA="hQvXZ";
_OPTS_GROFFER_SHORT_ARG="P:T:W:";

_OPTS_GROFFER_LONG_NA="all apropos help intermediate-output \
local-file location \
man no-location no-man source title tty version whatis where";

_OPTS_GROFFER_LONG_ARG="bg: device: display: dpi: extension: fg: \
geometry: lang: locale: manpath: mode: pager: resolution: sections: \
systems: title: to-postproc: troff-device: xrm:";

##### options inhereted from groff

export _OPTS_GROFF_SHORT_NA;
export _OPTS_GROFF_SHORT_ARG;
export _OPTS_GROFF_LONG_NA;
export _OPTS_GROFF_LONG_ARG;

_OPTS_GROFF_SHORT_NA="abcegilpstzCEGNRSUV";
_OPTS_GROFF_SHORT_ARG="d:f:F:I:L:m:M:n:o:r:w:";
_OPTS_GROFF_LONG_NA="";
_OPTS_GROFF_LONG_ARG="";

###### man options (for parsing $MANOPT only)

export _OPTS_MAN_SHORT_ARG;
export _OPTS_MAN_SHORT_NA;
export _OPTS_MAN_LONG_ARG;
export _OPTS_MAN_LONG_NA;

_OPTS_MAN_SHORT_ARG="e:L:m:M:p:P:r:S:T:";
_OPTS_MAN_SHORT_NA="acdDfhkltuVwZ";

_OPTS_MAN_LONG_ARG="extension: lang: locale: manpath: pager: \
preprocessor: prompt: sections: systems: troff-device:";

_OPTS_MAN_LONG_NA="all apropos catman debug default ditroff help \
local-file location troff update version whatis where";

###### collections of options

# groffer

export _OPTS_GROFFER_LONG;
export _OPTS_GROFFER_SHORT;
_OPTS_GROFFER_LONG="${_OPTS_GROFFER_LONG_ARG} ${_OPTS_GROFFER_LONG_NA}";
_OPTS_GROFFER_SHORT=\
"${_OPTS_GROFFER_SHORT_ARG}${_OPTS_GROFFER_SHORT_NA}";

# groff

export _OPTS_GROFF_LONG;
export _OPTS_GROFF_SHORT;
_OPTS_GROFF_LONG="${_OPTS_GROFF_LONG_ARG} ${_OPTS_GROFF_LONG_NA}";
_OPTS_GROFF_SHORT="${_OPTS_GROFF_SHORT_ARG}${_OPTS_GROFF_SHORT_NA}";

# all command line options

export _OPTS_CMDLINE_SHORT_NA;
export _OPTS_CMDLINE_SHORT_ARG;
export _OPTS_CMDLINE_SHORT;
export _OPTS_CMDLINE_LONG_NA;
export _OPTS_CMDLINE_LONG_ARG;
export _OPTS_CMDLINE_LONG;

_OPTS_CMDLINE_SHORT_NA="\
${_OPTS_GROFFER_SHORT_NA}${_OPTS_GROFF_SHORT_NA}";
_OPTS_CMDLINE_SHORT_ARG="\
${_OPTS_GROFFER_SHORT_ARG}${_OPTS_GROFF_SHORT_ARG}";
_OPTS_CMDLINE_SHORT="${_OPTS_GROFFER_SHORT}${_OPTS_GROFF_SHORT}";

_OPTS_CMDLINE_LONG_NA="${_OPTS_GROFFER_LONG_NA} \
${_OPTS_GROFF_LONG_NA} ${_OPTS_MAN_LONG_NA}";
_OPTS_CMDLINE_LONG_ARG="${_OPTS_GROFFER_LONG_ARG} \
${_OPTS_GROFF_LONG_ARG} ${_OPTS_MAN_LONG_ARG}";
_OPTS_CMDLINE_LONG="${_OPTS_GROFFER_LONG} ${_OPTS_GROFF_LONG}";


########################################################################
# read-write variables (global to this file)

export _ADDOPTS_GROFF;		# Transp. options for groff (`eval').
export _ADDOPTS_POST;		# Transp. options postproc (`eval').
export _ADDOPTS_X;		# Transp. options X postproc (`eval').
export _DISPLAY_MODE;		# From command line arguments.
export _DISPLAY_PAGER;		# Pager to be used on tty.
export _FILEARGS;		# Stores filespec parameters.
export _REGISTERED_TITLE;	# Processed file names.
_ADDOPTS_GROFF='';
_ADDOPTS_POST='';
_ADDOPTS_X='';
_DISPLAY_MODE='';
_DISPLAY_PAGER='';
_FILEARGS='';
_REGISTERED_TITLE='';

# _HAS_* from availability tests
export _HAS_COMPRESSION;	# `yes' if compression is available
export _HAS_OPTS_GNU;		# `yes' if GNU `getopt' is available
export _HAS_OPTS_POSIX;		# `yes' if POSIX `getopts' is available
_HAS_COMPRESSION='';
_HAS_OPTS_GNU='';
_HAS_OPTS_POSIX='';

# _MAN_* finally used configuration of man searching
export _MAN_ALL;		# search all man pages per filespec
export _MAN_ENABLE;		# enable search for man pages
export _MAN_EXT;		# extension for man pages
export _MAN_FORCE;		# force file parameter to be man pages
export _MAN_IS_SETUP;		# setup man variables only once
export _MAN_LANG;		# language for man pages
export _MAN_LANG_DONE;		# language dirs added to man path
export _MAN_PATH;		# search path for man pages
export _MAN_SEC;		# sections for man pages; sep. `:'
export _MAN_SEC_DONE;		# sections added to man path
export _MAN_SYS;		# system names for man pages; sep. `,'
export _MAN_SYS;		# system names added to man path
_MAN_ALL='no';
_MAN_ENABLE='yes';		# do search for man-pages
_MAN_EXT='';
_MAN_FORCE='no';		# first local file, then search man page
_MAN_IS_SETUP='no';
_MAN_LANG='';
_MAN_LANG_DONE='no';
_MAN_PATH='';
_MAN_SEC='';
_MAN_SEC_DONE='no';
_MAN_SYS='';
_MAN_SYS_DONE='no';

# _MANOPT_* as parsed from $MANOPT
export _MANOPT_ALL;		# $MANOPT --all
export _MANOPT_EXTENSION;	# $MANOPT --extension
export _MANOPT_LANG;		# $MANOPT --locale
export _MANOPT_PATH;		# $MANOPT --manpath
export _MANOPT_PAGER;		# $MANOPT --pager
export _MANOPT_SEC;		# $MANOPT --sections
export _MANOPT_SYS;		# $MANOPT --systems
_MANOPT_ALL='no';
_MANOPT_EXTENSION='';
_MANOPT_LANG='';
_MANOPT_PATH='';
_MANOPT_PAGER='';
_MANOPT_SEC='';
_MANOPT_SYS='';

# _OPT_* as parsed from groffer command line
export _OPT_ALL;		# display all suitable man pages
export _OPT_APROPOS;		# branch to `apropos' program
export _OPT_DEVICE;		# device option
export _OPT_LANG;		# set language for man pages
export _OPT_LOCATION;		# print processed file names to stderr
export _OPT_MODE;		# values: X, tty, Q, Z, ""
export _OPT_MANPATH;		# manual setting of path for man-pages
export _OPT_PAGER;		# specify paging program for tty mode
export _OPT_SECTIONS;		# sections for man page search
export _OPT_SYSTEMS;		# man pages of different OS's
export _OPT_TITLE;		# title for gxditview window
export _OPT_WHATIS;		# print the one-liner man info
export _OPT_XRDB;		# X resource arguments to gxditview
_OPT_ALL='no';
_OPT_APROPOS='no';
_OPT_DEVICE='';
_OPT_LANG='';
_OPT_LOCATION='no';
_OPT_MODE='';
_OPT_MANPATH='';
_OPT_PAGER='';
_OPT_SECTIONS='';
_OPT_SYSTEMS='';
_OPT_TITLE='';
_MANOPT_WHATIS='no';
_OPT_XRDB='';

# _TMP_* temporary files
export _TMP_DIR;		# directory for temporary files
export _TMP_CAT;		# stores concatenation of everything
export _TMP_PREFIX;		# dir and base name for temporary files
export _TMP_STDIN;		# stores stdin, if any
_TMP_DIR='';
_TMP_CAT='';
_TMP_PREFIX='';
_TMP_STDIN='';


########################################################################
#             Test of rudimentary shell functionality
########################################################################

########################################################################
# Test of `test'.
#
test "a" = "a" || exit 1;


########################################################################
# Test of `echo' and the `$()' construct.
#
echo -n '' >/dev/null || exit -1;
if test "$(echo -n 'te' && echo -n '' && echo -n 'st')" != "test"; then
  exit -1;
fi;


########################################################################
# Test of function definitions.
#
_test_func()
{
  return "${_OK}";
}

if _test_func; then
  :
else
  echo 'shell does not support function definitions.' >&2;
  exit -1;
fi;


########################################################################
# Test of builtin `local'
#
_global='outside';

test_local()
{
  _global='inside';
  local _local >/dev/null 2>&1 || return "${_BAD}";
}

if test_local; then
  :
else
  local()
  {
    return "${_OK}";
  }
fi;

if test "${_global}" != 'inside'; then
  error "Cannot assign to global variables from within functions.";
fi;

unset _global;


########################################################################
#          Functions for error handling and debugging
########################################################################

##############
# clean_up ()
#
# Clean up at exit.
#
clean_up()
{
  clean_up_secondary;
  rm -f "${_TMP_CAT}";
}


##############
# clean_up_secondary ()
#
# Clean up temporary files without $_TMP_CAT.
#
clean_up_secondary()
{
  rm -f "${_TMP_STDIN}";
}


##############
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


##############
# echo2n (<text>*)
#
# Output to stderr.
#
# Arguments : arbitrary text.
#
echo2n()
{
  echo -n "$*" >&2;
}


#############
# diag (text>*)
#
# Output a diagnostic message to stderr
#
diag()
{
  echo2 '>>>>>'"$*";
}


#############
# error (<text>*)
#
# Print an error message to standard error; exit with an error condition
#
error()
{
  local _code;
  _code=-1;
  case "$#" in
    0) true; ;;
    1) echo2 'groffer error: '"$1"; ;;
    2)
      echo2 'groffer error: '"$1";
      _code="$2";
      ;;
    *) echo2 'groffer error: wrong number of arguments in error().'; ;;
  esac;
  clean_up;
  kill "${_PROCESS_ID}" >/dev/null 2>&1;
  kill -9 "${_PROCESS_ID}" >/dev/null 2>&1;
  exit "${_code}";
}


#############
# abort (<text>*)
#
# Terminate program with error condition
#
abort()
{
  error "Program aborted.";
  exit 1;
}


########################################################################
#                        System Test
########################################################################

# Test the availability of the system utilities used in this script.


########################################################################
# Test of function `true'.
#
if true >/dev/null 2>&1; then
  true;
else
  true()
  {
    return "${_GOOD}";
  }

  false()
  {
    return "${_BAD}";
  }
fi;


########################################################################
# Test of function `sed'.
#
if test "$(echo teeest | sed -e '\|^teeest$|s|\(e\)\+|\1|')" != "test";
then
  error 'Test of "sed" command failed.';
fi;


########################################################################
# Test of function `cat'.
#
if test "$(echo test | cat)" != "test"; then
  error 'Test of "cat" command failed.';
fi;


########################################################################
# Test for compression.
#
if test "$(echo test | gzip -c -d -f -)" = "test"; then
  _HAS_COMPRESSION="yes";
else
  _HAS_COMPRESSION="no";
fi;


########################################################################
# Test for temporary directory and file generating utility.
#

# determine temporary directory into `$_TMP_DIR'
for d in "${GROFF_TMPDIR}" "${TMPDIR}" "${TMP}" "${TEMP}" \
         "${TEMPDIR}" "${HOME}"/tmp /tmp "${HOME}" .;
do
  if test "$d" != ""; then
    if test -d "$d" && test -r "$d" && test -w "$d"; then
      _TMP_DIR="$d";
      break;
    fi;
  fi;
done;
unset d;
if test "${_TMP_DIR}" = ""; then
  error "Couldn't find a directory for storing temorary files.";
fi;
_TMP_PREFIX="${_TMP_DIR}/${_PROGRAM_NAME}";


########################################################################
# Test option parsing programs.
#

# GNU getopt
unset GETOPT_COMPATIBLE;
getopt -T >/dev/null 2>&1;
if test "$?" -eq 4; then	# special test for GNU enhanced version
  _HAS_OPTS_GNU="yes";
else
  # POSIX getopts
  OPTIND=1;
  OPTARG="";
  if getopts "t:" _opt -test 2>/dev/null && \
      test "${_opt}" = "t" && \
      test "${OPTARG}" = "est" && \
      test "${OPTIND}" -eq 2; then
    _HAS_OPTS_POSIX="yes";
  else
    error "No argument parser available (`getopt' or `getopts').";
  fi;
  unset _opt;
fi;

OPTIND=1;
OPTARG="";


########################################################################
#                    Definition of Functions
########################################################################


########################################################################
# abort (<text>*)
#
# Unconditionally terminate the program with error code;
# useful for debugging.
#
# defined above


########################################################################
# base_name (<path>)
#
# Get the file name part of <path>, i.e. delete everything up to last
# `/' from the beginning of <path>.
#
# Arguments : 1
# Output    : the file name part (without slashes)
#
base_name()
{
  if test "$#" != 1; then
    error "base_name() needs 1 argument.";
    return "${_ERROR}";
  fi;
  string_sed_s "$1" '^.*/\([^/]*\)$' '\1';
}


########################################################################
# catz (<file>)
#
# If compression is available decompress standard input and write it to
# standard output; otherwise copy standard input to standard output.
#
if test "${_HAS_COMPRESSION}" = 'yes'; then
  catz()
  {
    if test "$#" -ne 1; then
      error "catz() needs exactly 1 argument.";
      return "${_ERROR}";
    fi;
    cat "$1" | gzip -c -d -f 2>/dev/null;
  }
else
  catz()
  {
    if test "$#" -ne 1; then
      error "catz() needs exactly 1 argument.";
      return "${_ERROR}";
    fi;
    cat "$1";
  }
fi;


########################################################################
# clean_up ()
#
# Do the final cleaning up before exiting; used by the trap calls.
#
# defined above


########################################################################
# clean_up_secondary ()
#
# Do the second but final cleaning up.
#
# defined above


########################################################################
# diag (<text>*)
#
# Print marked message to standard error; useful for debugging.
#
# defined above


########################################################################
# dirname_append (<dir> <name>)
#
# Append `name' to `dir' with clean handling of `/'.
#
# Arguments : 2
# Output    : the generated new directory name <dir>/<name>
#
dirname_append()
{
  local _res;
  if test "$#" -ne 2; then
    error "dir_append() needs 2 arguments.";
    return "${_ERROR}";
  fi;
  if is_empty "$1"; then
    error "dir_append(): first argument is empty.";
    return "${_ERROR}";
  fi;
  if is_empty "$2"; then
    echo -n "$1";
    return "${_OK}";
  fi;
  dirname_chop "$1"/"$2";
}


########################################################################
# dirname_chop (<name>)
#
# Remove unnecessary slashes from directory name.
#
# Argument: 1, a directory name.
# Output:   path without double, or trailing slashes.
#
dirname_chop()
{
  local _arg;
  local _res;
  local _sep;
  if test "$#" -ne 1; then
    error 'dirname_chop() needs 1 argument.';
    return "${_ERROR}";
  fi;
  _res="$(string_replace_all "$1" '//\+' '/')";
  case "${_res}" in
    ?*/) string_del_trailing "${_res}" '/'; ;;
    *) echo -n "${_res}"; ;;
  esac;
}


########################################################################
# do_filearg (<filearg>)
#
# Append the file, man-page, or standard input corresponding to the
# argument to the temporary file.  If this is compressed in the gzip
# or Z format it is decompressed.  A title element is generated.
#
# Argument either:
#   - name of an existing files.
#   - `-' to represent standard input (several times allowed).
#   - `man:name.(section)' the man-page for `name' in `section'.
#   - `man:name.section' the man-page for `name' in `section'.
#   - `man:name' the man-page for `name' in the lowest `section'.
#   - `name.section' the man-page for `name' in `section'.
#   - `name' the man-page for `name' in the lowest `section'.
# Globals :
#   $_TMP_STDIN, $_MAN_ENABLE, $_MAN_IS_SETUP, $_OPT_MAN
#
# Output  : none
# Return  : $_GOOD if found, ${_BAD} otherwise.
#
do_filearg()
{
  local _filespec;
  local i;
  if test "$#" -ne 1; then
    error "do_filearg() expects 1 argument.";
    return "${_ERROR}";
  fi;
  _filespec="$1";
  # store sequence positional parameters
  case "${_filespec}" in
    '')
       return "${_GOOD}";
       ;;
    '-')
      register_file '-';
      return "${_GOOD}";
      ;;
    */*)			# with directory part; so no man search
      set -- 'File';
      ;;
    *)
      if is_yes "${_MAN_ENABLE}"; then
        if is_yes "${_OPT_MAN}"; then
          set -- 'Manpage' 'File';
        else
          set -- 'File' 'Manpage';
        fi;
      else
        set -- 'File';
      fi;
      ;;
  esac;
  for i in "$@"; do
    case "$i" in
      File)
        if test -f "${_filespec}"; then
          if test -r "${_filespec}"; then
            register_file "${_filespec}";
	    return "${_GOOD}";
          else
	    echo2 "could not read \`${_filespec}'";
	    return "${_BAD}";
          fi;
        else
          continue;
        fi;
        ;;
      Manpage)			# parse filespec as man page
        if is_not_yes "${_MAN_IS_SETUP}"; then
          man_setup;
        fi;
        if man_do_filespec "${_filespec}"; then
	  return "${_GOOD}";
        else
          continue;
	fi;
        ;;
    esac;
  done;
  return "${_BAD}";
} # do_filearg()


########################################################################
# do_nothing ()
#
# Dummy function.
#
do_nothing()
{
  return "${_OK}";
}


########################################################################
# echo2 (<text>*)
#
# Print to standard error with final line break.
#
# defined above


########################################################################
# echo2n (<text>*)
#
# Print to standard error without final line break.
#
# defined above


########################################################################
# error (<text>*)
#
# Print error message and exit with error code.
#
# defined above


########################################################################
# get_first_essential (<arg>*)
#
# Retrieve first non-empty argument.
#
# Return  : `1' if all arguments are empty, `0' if found.
# Output  : the retrieved non-empty argument.
#
get_first_essential()
{
  local i;
  if test "$#" -eq 0; then
    return "${_OK}";
  fi;
  for i in "$@"; do
    if is_not_empty "$i"; then
      echo -n "$i";
      return "${_OK}";
    fi;
  done;
  return "${_BAD}";
}


########################################################################
# is_dir (<name>)
#
# Test whether `name' is a directory.
#
# Arguments : 1
# Return    : `0' if arg1 is a directory, `1' otherwise.
#
is_dir()
{
  if test "$#" -ne 1; then
    error "is_dir() needs 1 argument.";
    return "${_ERROR}";
  fi;
  if is_not_empty "$1" && test -d "$1" && test -r "$1"; then
    return "${_YES}";
  else
    return "${_NO}";
  fi;
}


########################################################################
# is_empty (<string>)
#
# Test whether `string' is empty.
#
# Arguments : <=1
# Return    : `0' if arg1 is empty or does not exist, `1' otherwise.
#
is_empty()
{
  if test "$#" -ne 1; then
    error "is_empty() needs 1 argument.";
    return "${_ERROR}";
  fi;
  if test -z "$1"; then
    return "${_YES}";
  else
    return "${_NO}";
  fi;
}


########################################################################
# is_equal (<string1> <string2>)
#
# Test whether `string1' is equal to <string2>.
#
# Arguments : 2
# Return    : `0' both arguments are equal strings, `1' otherwise.
#
is_equal()
{
  if test "$#" -ne 2; then
    error "is_equal() needs 2 arguments.";
    return "${_ERROR}";
  fi;
  if test "$1" = "$2"; then
    return "${_YES}";
  else
    return "${_NO}";
  fi;
}


########################################################################
# is_file (<name>)
#
# Test whether `name' is a readable file.
#
# Arguments : 1
# Return    : `0' if arg1 is a readable file, `1' otherwise.
#
is_file()
{
  if test "$#" -ne 1; then
    error "is_file() needs 1 argument.";
    return "${_ERROR}";
  fi;
  if is_not_empty "$1" && test -f "$1" && test -r "$1"; then
    return "${_YES}";
  else
    return "${_NO}";
  fi;
}


########################################################################
# is_not_dir (<name>)
#
# Test whether `name' is not a readable directory.
#
# Arguments : 1
# Return    : `0' if arg1 is a directory, `1' otherwise.
#
is_not_dir()
{
  if test "$#" -ne 1; then
    error "is_not_dir() needs 1 argument.";
    return "${_ERROR}";
  fi;
  if is_dir "$1"; then
    return "${_NO}";
  else
    return "${_YES}";
  fi;
}


########################################################################
# is_not_empty (<string>)
#
# Test whether `string' is not empty.
#
# Arguments : <=1
# Return    : `0' if arg1 exists and is not empty, `1' otherwise.
#
is_not_empty()
{
  if test "$#" -ne 1; then
    error "is_not_empty() needs 1 argument.";
    return "${_ERROR}";
  fi;
  if is_empty "$1"; then
    return "${_NO}";
  else
    return "${_YES}";
  fi;
}


########################################################################
# is_not_equal (<string1> <string2>)
#
# Test whether `string1' and <string2> differ.
#
# Arguments : 2
#
is_not_equal()
{
  if test "$#" -ne 2; then
    error "is_not_equal() needs 2 arguments.";
    return "${_ERROR}";
  fi;
  if is_equal "$1" "$2"; then
    return "${_NO}";
  else
    return "${_YES}";
  fi;
}


########################################################################
# is_not_file (<filename>)
#
# Test whether `name' is a not readable file.
#
# Arguments : 1
#
is_not_file()
{
  if test "$#" -ne 1; then
    error "is_not_file() needs 1 argument.";
    return "${_ERROR}";
  fi;
  if is_file "$1"; then
    return "${_NO}";
  else
    return "${_YES}";
  fi;
}


########################################################################
# is_not_yes (<string>)
#
# Test whether `string' is not "yes".
#
# Arguments : 1
#
is_not_yes()
{
  if test "$#" -ne 1; then
    error "is_not_yes() needs 1 argument.";
    return "${_ERROR}";
  fi;
  if is_yes "$1"; then
    return "${_NO}";
  else
    return "${_YES}";
  fi;
}


########################################################################
# is_prog (<name>)
#
# Determine whether arg is a program in $PATH
#
# Arguments : 1 (empty allowed)
#
is_prog()
{
  if test "$#" -ne 1; then
    error "is_prog() needs 1 argument.";
    return "${_ERROR}";
  fi;
  if where "$1" >/dev/null; then
    return "${_YES}";
  else
    return "${_NO}";
  fi;
}


########################################################################
# is_yes (<string>)
#
# Test whether `string' has value "yes".
#
# Arguments : <=1
# Return    : `0' if arg1 is `yes', `1' otherwise.
#
is_yes()
{
  if test "$#" -ne 1; then
    error "is_yes() needs 1 argument.";
    return "${_ERROR}";
  fi;
  if is_equal "$1" 'yes'; then
    return "${_YES}";
  else
    return "${_NO}";
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
  exit "${_OK}";
}


########################################################################
# man_do_filespec (<filespec>)
#
# Print suitable man page(s) for filespec to $_TMP_CAT.
#
# Arguments : 2
#   <filespec>: argument of the form `man:name.section', `man:name',
#               `man:name(section)', `name.section', `name'.
#
# Globals   : $_OPT_ALL
#
# Output    : none.
# Return    : `0' if man page was found, `1' else.
#
# Only called from do_fileargs(), checks on $MANPATH and
# $_MAN_ENABLE are assumed.
#
man_do_filespec()
{
  local _got_one;
  local _name;
  local _prevsec;
  local _res;
  local _section;
  local _spec;
  local _string;
  local s;
  if is_empty "${MANPATH}"; then
    return "${_BAD}";
  fi;
  case "$#" in
    1) true; ;;
    *)
      error "man_do_filespec() needs exactly 1 argument.";
      return "${_ERROR}";
      ;;
  esac;
  if is_empty "$1"; then
    return "${_BAD}";
  fi;
  _spec="$1";
  _name='';
  _section='';
  case "${_spec}" in
    man:?*\(?*\))		# man:name(section)
      _string="$(string_del_leading "${_spec}" 'man:')";
      _string="$(string_del_trailing "${_string}" ')')";
      _name="$(string_del_trailing "${_string}" '(.\+')";
      _section="$(string_del_leading "${_string}" "${_name}"'(')";
      ;;
    man:?*.?*)			# man:name.section
      _string="$(string_del_leading "${_spec}" 'man:')";
      _name="$(string_del_trailing "${_string}" '\.[^.]*')";
      _section="$(string_del_leading "${_string}" "${_name}"'\.')";
      ;;
    man:?*)			# man:name
      _name="$(string_del_leading "${_spec}" 'man:')";
      ;;
    ?*\(?*\))			# name(section)
      _string="$(string_del_trailing "${_spec}" ')')";
      _name="$(string_del_trailing "${_string}" '(.\+')";
      _section="$(string_del_leading "${_string}" "${_name}"'(')";
      ;;
    ?*.?*)			# name.section
      _name="$(string_del_trailing "${_spec}" '\.[^.]\+')";
      _section="$(string_del_leading "${_spec}" "${_name}"'\.')";
      ;;
    ?*)
      _name="${_filespec}";
      ;;
  esac;
  if is_empty "${_name}"; then
    return "${_BAD}";
  fi;
  _got_one='no';
  if is_empty "${_section}"; then
    eval set -- "${_MAN_AUTO_SEC}";
    for s in "$@"; do
      if man_search_section "${_name}" "$s"; then # found
        if is_yes "${_MAN_ALL}"; then
          _got_one='yes';
        else
          return "${_GOOD}";
        fi;
      fi;
    done;
  else
    man_search_section "${_name}" "${_section}";
    return "$?";
  fi;
  if is_yes "${_MAN_ALL}" && is_yes "${_got_one}"; then
    return "${_GOOD}";
  fi;
  return "${_BAD}";
} # man_do_filespec()


########################################################################
# man_parse_name (<filespec>)
#
# Parse the man page name part off from a filespec
#
# Arguments: 1, 2, or 3; maybe empty
# Output: none
#
man_parse_name()
{
  return;
}


########################################################################
# man_register_file (<file> <name> [<section>])
#
# Write a found man page file and register the title element.
#
# Arguments: 1, 2, or 3; maybe empty
# Output: none
#
man_register_file()
{
  case "$#" in
    2|3) do_nothing; ;;
    *)
      error "man_register_file() expects 1 argument.";
      return "${_ERROR}";
      ;;
  esac;
  if is_empty "$1"; then
    error 'man_register_file(): file name is empty';
  fi;
  to_tmp "$1";
  case "$#" in
    2)
       register_title "man:$2";
       return "${_OK}";
       ;;
    3)
       register_title "$2($3)";
       return "${_OK}";
       ;;
  esac;
}


########################################################################
# man_search_section (<name> <section>)
#
# Retrieve man pages.
#
# Arguments : 2
# Globals   : $_MAN_PATH, $_MAN_EXT
# Return    : 0 if found, 1 otherwise
#
man_search_section()
{
  local _dir;
  local _ext;
  local _got_one;
  local _name;
  local _prefix
  local _section;
  local d;
  local f;
  if is_empty "${_MAN_PATH}"; then
    return "${_BAD}";
  fi;
  if test "$#" -ne 2; then
    error "man_sec_first() needs 2 arguments.";
    return "${_ERROR}";
  fi;
  if is_empty "$1"; then
    return "${_BAD}";
  fi;
  if is_empty "$2"; then
    return "${_BAD}";
  fi;
  _name="$1";
  _section="$2";
  eval set -- "$(path_split "${_MAN_PATH}")";
  _got_one='no';
  if is_empty "${_MAN_EXT}"; then
    for d in "$@"; do
      _dir="$(dirname_append "$d" "man${_section}")";
      if is_dir "${_dir}"; then
        _prefix="$(dirname_append "${_dir}" "${_name}.${_section}")";
        for f in $(echo -n ${_prefix}*); do
          if is_file "$f"; then
            if is_yes "${_got_one}"; then
              register_file "$f";
            elif is_yes "${_MAN_ALL}"; then
              man_register_file "$f" "${_name}";
            else
              man_register_file "$f" "${_name}" "${_section}";
              return "${_GOOD}";
            fi;
            _got_one='yes';
          fi;
        done;
      fi;
    done;
  else
    _ext="${_MAN_EXT}";
    # check for directory name having trailing extension
    for d in "$@"; do
      _dir="$(dirname_append $d man${_section}${_ext})";
      if is_dir "${_dir}"; then
        _prefix="$(dirname_append "${_dir}" "${_name}.${_section}")";
        for f in ${_prefix}*; do
          if is_file "$f"; then
            if is_yes "${_got_one}"; then
              register_file "$f";
            elif is_yes "${_MAN_ALL}"; then
              man_register_file "$f" "${_name}";
            else
              man_register_file "$f" "${_name}" "${_section}";
              return "${_GOOD}";
            fi;
            _got_one='yes';
          fi;
        done;
      fi;
    done;
    # check for files with extension in directories without extension
    for d in "$@"; do
      _dir="$(dirname_append "$d" "man${_section}")";
      if is_dir "${_dir}"; then
        _prefix="$(dirname_append "${_dir}" \
                                  "${_name}.${_section}${_ext}")";
        for f in ${_prefix}*; do
          if is_file "$f"; then
            if is_yes "${_got_one}"; then
              register_file "$f";
            elif is_yes "${_MAN_ALL}"; then
              man_register_file "$f" "${_name}";
            else
              man_register_file "$f" "${_name}" "${_section}";
              return "${_GOOD}";
            fi;
            _got_one='yes';
          fi;
        done;
      fi;
    done;
  fi;
  if is_yes "${_MAN_ALL}" && is_yes "${_got_one}"; then
    return "${_GOOD}";
  fi;
  return "${_BAD}";
} # man_search_section()


########################################################################
# man_setup ()
#
# Setup the variables $_MAN_* needed for man page searching.
#
# Globals:
#   in:     $_OPT_*, $_MANOPT_*, $LANG, $LC_MESSAGES, $LC_ALL,
#           $MANPATH, $MANROFFSEQ, $MANSEC, $PAGER, $SYSTEM, $MANOPT.
#   out:    $_MAN_PATH, $_MAN_LANG, $_MAN_SYS, $_MAN_LANG, $_MAN_LANG2,
#           $_MAN_SEC, $_MAN_ALL
#   in/out: $_MAN_ENABLE
#
# The precedence for the variables related to `man' is that of GNU
# `man', i.e.
#
# $LANG; overridden by
# $LC_MESSAGES; overridden by
# $LC_ALL; this has the same precedence as
# $MANPATH, $MANROFFSEQ, $MANSEC, $PAGER, $SYSTEM; overridden by
# $MANOPT; overridden by
# the groffer command line options.
#
man_setup()
{
  local _lang;

  if is_yes "${_MAN_IS_SETUP}"; then
    return "${_GOOD}";
  fi;
  _MAN_IS_SETUP='yes';

  if is_not_yes "${_MAN_ENABLE}"; then
    return "${_BAD}";
  fi;

  # determine basic path for man pages
  _MAN_PATH="$(get_first_essential \
               "${_OPT_MANPATH}" "${_MANOPT_PATH}" "${MANPATH}")";
  if is_empty "${_MAN_PATH}"; then
    if is_prog 'manpath'; then
      _MAN_PATH="$(manpath 2>/dev/null)"; # not on all systems available
    fi;
  fi;
  if is_empty "${_MAN_PATH}"; then
    manpath_set_from_path;
  else
    _MAN_PATH="$(path_clean "${_MAN_PATH}")";
  fi;
  if is_empty "${_MAN_PATH}"; then
    _MAN_ENABLE="no";
    return;
  fi;

  _MAN_ALL="$(get_first_essential "${_OPT_ALL}" "${_MANOPT_ALL}")";
  if is_empty "${_MAN_ALL}"; then
    _MAN_ALL='no';
  fi;

  _MAN_SYS="$(get_first_essential \
              "${_OPT_SYSTEMS}" "${_MANOPT_SYS}" "${SYSTEM}")";
  _lang="$(get_first_essential \
           "${_OPT_LANG}" "${LC_ALL}" "${LC_MESSAGES}" "${LANG}")";
  case "${_lang}" in
    C|POSIX)
      _MAN_LANG="";
      _MAN_LANG2="";
      ;;
    ?)
      _MAN_LANG="${_lang}";
      _MAN_LANG2="";
      ;;
    *)
      _MAN_LANG="${_lang}";
      _MAN_LANG2="$(string_get_leading "${_lang}" '..')";
      ;;
  esac;
  # from now on, use only $_LANG, forget about $_OPT_LANG, $LC_*.

  manpath_add_lang_sys;

  _MAN_SEC="$(get_first_essential \
              "${_OPT_SECT}" "${_MANOPT_SEC}" "${MANSEC}")";
  if is_empty "${_MAN_PATH}"; then
    _MAN_ENABLE="no";
    return;
  fi;

  _MAN_EXT="$(get_first_essential \
              "${_OPT_EXTENSION}" "${_MANOPT_EXTENSION}")";
} # man_setup()


########################################################################
# manpath_add_lang_sys ()
#
# Add language and operating system specific directories to man path.
#
# Arguments : 0
# Output    : none
# Globals:
#   in:     $_MAN_SYS: has the form `os1,os2,...', a comma separated
#             list of names of operating systems.
#           $_MAN_LANG and $_MAN_LANG2: each a single name
#   in/out: $_MAN_PATH: has the form `dir1:dir2:...', a colon
#             separated list of directories.
#
manpath_add_lang_sys()
{
  local p;
  local _mp;
  if test "$#" -ne 0; then
    error "manpath_add_system() does not have arguments.";
    return "${_ERROR}";
  fi;
  if is_empty "${_MAN_PATH}"; then
    return "${_GOOD}";
  fi;
  # twice test both sys and lang
  eval set -- "$(path_split "${_MAN_PATH}")";
  _mp='';
  for p in "$@"; do		# loop on man path directories
    _mp="$(_manpath_add_lang_sys_single "${_mp}" "$p")";
  done;
  eval set -- "$(path_split "${_mp}")";
  for p in "$@"; do		# loop on man path directories
    _mp="$(_manpath_add_lang_sys_single "${_mp}" "$p")";
  done;
  _MAN_PATH="$(path_chop "${_mp}")";
}


_manpath_add_lang_sys_single()
{
  # To the directory in $1 append existing sys/lang subdirectories
  # Function is necessary to split the OS list.
  #
  # globals: in: $_MAN_SYS, $_MAN_LANG, $_MAN_LANG2
  # argument: 2: `man_path' and `dir'
  # output: colon-separated path of the retrieved subdirectories
  #
  local d;
#  if test "$#" -ne 2; then
#    error "manpath_add_system_single() needs 2 arguments.";
#    return "${_ERROR}";
#  fi;
  _res="$1";
  _parent="$2";
  eval set -- "$(string_split "${_MAN_SYS}" ',')";
  for d in "$@" "${_MAN_LANG}" "${_MAN_LANG2}"; do
    _dir="$(dirname_append "${_parent}" "$d")";
    if path_not_contains "${_res}" "${_dir}" && is_dir "${_dir}"; then
      _res="${_res}:${_dir}";
    fi;
  done;
  if path_not_contains "${_res}" "${_parent}"; then
    _res="${_res}:${_parent}";
  fi;
  path_chop "${_res}";
}

# end manpath_add_lang_sys ()


########################################################################
# manpath_set_from_path ()
#
# Determine basic search path for man pages from $PATH.
#
# Return:    `0' if a valid man path was retrieved.
# Output:    none
# Globals:
#   in:  $PATH
#   out: $_MAN_PATH
#
manpath_set_from_path()
{
  local _base;
  local _mandir;
  local _manpath;
  local d;
  local e;
  _manpath='';

  # get a basic man path from $PATH
  if is_not_empty "${PATH}"; then
    eval set -- "$(path_split "${PATH}")";
    for d in "$@"; do
      _base="$(string_del_trailing "$d" '/\+bin/*')";
      for e in /share/man /man; do
        _mandir="${_base}$e";
        if test -d "${_mandir}" && test -r "${_mandir}"; then
        _manpath="${_manpath}:${_mandir}";
        fi;
      done;
    done;
  fi;

  # append some default directories
  for d in /usr/local/share/man /usr/local/man \
            /usr/share/man /usr/man \
            /usr/X11R6/man /usr/openwin/man \
            /opt/share/man /opt/man \
            /opt/gnome/man /opt/kde/man; do
    if path_not_contains "${_manpath}" "$d" && is_dir "$d"; then
      _manpath="${_manpath}:$d";
    fi;
  done;

  _MAN_PATH="${_manpath}";
} # manpath_set_from_path()


########################################################################
# normalize_args (<shortopts> <longopts> <arg>+)
#
# Display arguments in the normalized form of GNU `getopt'.
#
# Arguments : if no arguments are given, `-' is assumed
# Globals   : in: $_OPTS_LONG, $_OPTS_SHORT
# Output    : arguments in normalized form; these must be processed by
#               eval set -- "$(normalize_args ...)"
#
if is_yes "${_HAS_OPTS_GNU}"; then

  normalize_args()
  {
    local _long_opts;
    local _short_opts;
    local _res;
    local i;
    if test "$#" -lt 2; then
      error "normalize_args() needs at least 2 arguments";
      return "${_ERROR}";
    fi;
    _short_opts="$1";
    _long_opts="";
    if is_not_empty "$2"; then
      for i in $2; do
        _long_opts="${_long_opts} -l '$i'";
      done;
    fi;
    shift 2;
    if test "$#" -eq 0; then
      set -- '-';
    fi;
    if _res="$(eval getopt "${_long_opts}" -o \"${_short_opts}\" \
                           -- '"$@"')"; then
      echo -n "${_res}";
      return "${_GOOD}";
    else
      error 'normalize_args(): wrong option';
      return "${_ERROR}";
    fi;
  }

elif is_yes "${_HAS_OPTS_POSIX}"; then # POSIX getopts

  normalize_args()
  {
    local _opt;
    local _param;
    local _res;
    local _short_opts;
    if test "$#" -lt 2; then
      error "normalize_args() needs at least 2 arguments";
      return "${_ERROR}";
    fi;
    _short_opts="$1";
    # ignore long options in $2
    shift 2;
    if test "$#" -eq 0; then
      set -- '-';
    fi;
    OPTIND=1;
    OPTARG="";
    OPTERR=0;			# set silent mode for getopts
    _res="";
    # synopsis: getopts <optstring> <variable_for_optchar> <arg>*
    while getopts "${_short_opts}" _opt "$@"; do
      # getopts() does not fail when a wrong option is encountered.
      case "${_opt}" in
        \?)			# wrong option found
          if is_equal "${OPTARG}" '-'; then
	    error \
              "your system does not support long options; use \`-W'.";
	  else
            error "unknown option \`-${OPTARG}'.";
          fi;
          return "${_ERROR}";
          ;;
        :)			# argument not found (in silent mode)
          error "no argument found for option \`-${OPTARG}'.";
          return "${_ERROR}";
          ;;
      esac;
      _res="${_res} -${_opt}";
      if is_not_empty "${OPTARG}"; then
        _res="${_res} '${OPTARG}'";
        OPTARG="";
      fi;
    done;
    if is_equal "${_opt}" '?'; then    # end of options
      # non-option parameters are quoted in the output
      _res="${_res} --";
      if test "${OPTIND}" -le "$#"; then
        # first non-option parameter
        eval _param='"$'${OPTIND}'"';
	if test "${_param}" != "--"; then
          # save before shifting
          _res="${_res} '${_param}'";
        fi;
        shift "${OPTIND}";
        while test "$#" -gt 0; do
          _res="${_res} '$1'";
          shift;
        done;
      fi;
      echo -n "${_res}"
      return "${_OK}";
    else
      error 'error in option parsing';
      return "${_ERROR}";
    fi;
  }

else
  error 'no option processor available.';
  return "${_ERROR}";
fi;

# end normalize_args()


########################################################################
# path_chop (<path>)
#
# Remove unnecessary colons from path.
#
# Argument: 1, a colon separated path.
# Output:   path without leading, double, or trailing colons.
#
path_chop()
{
  local _res;
  if test "$#" -ne 1; then
    error 'path_chop() needs 1 argument.';
    return "${_ERROR}";
  fi;

#  _res="$1";
#  _res="$(string_flatten "${_res}" ':')";
#  _res="$(string_del_leading "${_res}" ':')";
#  _res="$(string_del_trailing "${_res}" ':')";
#  echo -n "${_res}";

  echo -n "$1" | sed -e '\|::\+|s||:|g' |
                 sed -e '\|^:*|s|||' |
                 sed -e '\|:*$|s|||';
}


########################################################################
# path_clean (<path>)
#
# Remove non-existing directories from a colon-separated list.
#
# Argument: 1, a colon separated path.
# Output:   colon-separated list of existing directories.
#
path_clean()
{
  local _arg;
  local _dir;
  local _res;
  local i;
  if test "$#" -ne 1; then
    error 'path_clean() needs 1 argument.';
    return "${_ERROR}";
  fi;
  _arg="$1";
  eval set -- "$(path_split "${_arg}")";
  _res="";
  for i in "$@"; do
    if is_not_empty "$i" \
       && path_not_contains "${_res}" "$i" \
       && is_dir "$i";
    then
      case "$i" in
        ?*/) _res="${_res}$(dirname_chop "$i")"; ;;
        *)  _res="${_res}:$i";
      esac;
    fi;
  done;
  path_chop "${_res}";
}


########################################################################
# path_contains (<path> <dir>)
#-
# Test whether `dir' is contained in `path', a list separated by `:'.
#
# Arguments : 2 arguments.
# Return    : `0' if arg2 is substring of arg1, `1' otherwise.
#
path_contains()
{
  if test "$#" -ne 2; then
    error "path_contains() needs 2 arguments.";
    return "${_ERROR}";
  fi;
  case ":$1:" in
    *":$2:"*) return "${_YES}"; ;;
    *)        return "${_NO}"; ;;
  esac;
}


########################################################################
# path_not_contains (<path> <dir>)
#-
# Test whether `dir' is not contained in colon separated `path'.
#
# Arguments : 2 arguments.
#
path_not_contains()
{
  if test "$#" -ne 2; then
    error "path_not_contains() needs 2 arguments.";
    return "${_ERROR}";
  fi;
  if path_contains "$1" "$2"; then
    return "${_NO}";
  else
    return "${_YES}";
  fi;
}


########################################################################
# path_split (<path>)
#
# In `path' escape white space and replace each colon by a space.
#
# Arguments: 1: a colon-separated path
# Output:    the resulting string
#
path_split()
{
  if test "$#" -ne 1; then
    error "path_split() needs 1 argument.";
    return "${_ERROR}";
  fi;
  string_split "$1" ':';
}


########################################################################
# register_file (<filename>)
#
# Write a found file and register the title element.
#
# Arguments: 1: a file name
# Output: none
#
register_file()
{
  if test "$#" -ne 1; then
    error 'register_file() needs 1 argument';
    return "${_ERROR}";
  fi;
  if is_empty "$1"; then
    error 'register_file(): file name is empty';
    return "${_ERROR}";
  fi;
  if is_equal "$1" '-'; then
    to_tmp "${_TMP_STDIN}";
    register_title '-';
  else
    to_tmp "$1";
    register_title "$(base_name "$1")";
  fi;
}


########################################################################
# register_title (<filespec>)
#
# Create title element from <filespec> and append to $_REGISTERED_TITLE
#
# Globals: $_REGISTERED_TITLE (rw)
#
register_title()
{
  local _title;
  if test "$#" -ne 1; then
    error "register_title() needs exactly 1 argument.";
    return "${_ERROR}";
  fi;
  if is_empty "$1"; then
    return "${_OK}";
  fi;
  _title="$(base_name "$1")";	# remove directory part
  _title="$(string_del_trailing "${_title}" '\.gz')"; # remove .gz
  _title="$(string_del_trailing "${_title}" '\.Z')";  # remove .Z
  if is_empty "${_title}"; then
    return "${_OK}";
  fi;
  _REGISTERED_TITLE="${_REGISTERED_TITLE} ${_title}";
}


########################################################################
# save_stdin ()
#
# Store standard input to temporary file.
#
save_stdin()
{
  cat | catz - >"${_TMP_STDIN}"; # using `cat' first is safer
}


########################################################################
# string_contains (<string> <part>)
#
# Test whether `part' is contained in `string'.
#
# Arguments : 2 text arguments.
# Return    : `0' if arg2 is substring of arg1, `1' otherwise.
#
string_contains()
{
  if test "$#" != 2; then
    error 'string_contains() needs 2 arguments.';
    return "${_ERROR}";
  fi;
  case "$1" in
    *"$2"*) return "${_YES}"; ;;
    *)      return "${_NO}"; ;;
  esac;
}


########################################################################
# string_del_append (<string>)
#
# Delete $_APPEND from the end of <string>, if any.
#
# As this is needed within string_sed_s() this function must use `sed'.
#
# Arguments: <string>: arbitrary sequence of characters.
# Globals: in: $_APPEND
# Output: the shortened string.
# Return: $_GOOD if successful, $_BAD if no replace took place.
#
string_del_append()
{
  if test "$#" -ne 1; then
    error "string_del_append() needs 1 argument.";
    return "${_ERROR}";
  fi;
  case "$1" in
    *"$_APPEND")
      echo -n "$1" | sed -e 's/'"$_APPEND"'$//'
      return "${_GOOD}";
      ;;
    *) return "${_BAD}"; ;;
  esac;
}


########################################################################
# string_del_leading (<string> <regex>)
#
# Delete the beginning <regex> of <string>, if any.
#
# Arguments: 2
#   <string>: arbitrary sequence of characters.
#   <regex>: is a BRE like in `sed';
#   Do not worry about the address delimiter, the program escapes them.
# Output: the replaced string.
#
string_del_leading()
{
  local _del;
  local _result;
  local _string;
  if test "$#" -ne 2; then
    error "string_del_leading() needs 2 arguments.";
    return "${_ERROR}";
  fi;
  _string="$1";
  _del="$2";
  if is_empty "${_string}"; then
    if is_empty "${_del}"; then
      return "${_GOOD}";
    else
      return "${_BAD}";
    fi;
  fi;
  if is_empty "${_del}"; then
    echo -n "${_string}";
    return "${_GOOD}";
  fi;
  _result="$(string_sed_s "${_string}" '^'"${_del}" '')";
  echo -n "${_result}";
  if is_equal "${_result}" "${_string}"; then
    return "${_BAD}";
  else
    return "${_GOOD}";
  fi;
}


########################################################################
# string_del_trailing (<string> <regex>)
#
# Delete the final <regex> of <string>, if any.
#
# Arguments: 2
#   <string>: arbitrary sequence of characters.
#   <regex>: is a BRE like in `sed';
#   Do not worry about the address delimiter, the program escapes them.
# Output: the replaced string.
#
string_del_trailing()
{
  local _del;
  local _result;
  local _string;
  if test "$#" -ne 2; then
    error "string_del_trailing() needs 2 arguments.";
    return "${_ERROR}";
  fi;
  _string="$1";
  _del="$2";
  if is_empty "${_string}"; then
    if is_empty "${_del}"; then
      return "${_GOOD}";
    else
      return "${_BAD}";
    fi;
  fi;
  if is_empty "${_del}"; then
    echo -n "${_string}";
    return "${_GOOD}";
  fi;
  _result="$(string_sed_s "${_string}" "${_del}"'$' '')";
  echo -n "${_result}";
  if is_equal "${_result}" "${_string}"; then
    return "${_BAD}";
  else
    return "${_GOOD}";
  fi;
}


########################################################################
# string_flatten (<string> <char>)
#
# Reduce multiple occurences of character <char> in <string> to one.
#
# Arguments: 2
#   <string>: arbitrary sequence of characters.
#   <char>: a character, or escaped character for sed.
#   Do not worry about the address delimiter, the program escapes them.
# Output: the retrieved string.
#
string_flatten()
{
  if test "$#" -ne 2; then
    error "string_flatten() needs 2 arguments.";
    return "${_ERROR}";
  fi;
  _string="$1";
  _char="$2";
  string_replace_all "${_string}" "${_char}${_char}\+" "${_char}";
}


########################################################################
# string_get_leading (<string> <regex>)
#
# Get the beginning <regex> of <string>, if any.
#
# Arguments: 2
#   <string>: arbitrary sequence of characters.
#   <regex>: is a BRE like in `sed';
#   Do not worry about the address delimiter, the program escapes them.
# Output: the retrieved string.
#
string_get_leading()
{
  local _del;
  local _result;
  local _string;
  if test "$#" -ne 2; then
    error "string_get_leading() needs 2 arguments.";
    return "${_ERROR}";
  fi;
  _string="$1";
  _get="$2";
  if is_empty "${_string}"; then
    if is_empty "${_get}"; then
      return "${_GOOD}";
    else
      return "${_BAD}";
    fi;
  fi;
  if is_empty "${_get}"; then
    echo -n "${_string}";
    return "${_GOOD}";
  fi;
  _result="$(string_sed_s "${_string}" '^\('"${_get}"'\).*$' '\1')";
  echo -n "${_result}";
  if is_equal "${_result}" "${_string}"; then
    return "${_BAD}";
  else
    return "${_GOOD}";
  fi;
}


########################################################################
# string_not_contains (<string> <part>)
#
# Test whether `part' is not substring of `string'.
#
# Arguments : 2 text arguments.
# Return    : `0' if arg2 is substring of arg1, `1' otherwise.
#
string_not_contains()
{
  if test "$#" != 2; then
    error 'string_not_contains() needs 2 arguments.';
    return "${_ERROR}";
  fi;
  if string_contains "$1" "$2"; then
    return "${_NO}";
  else
    return "${_YES}";
  fi;
}


########################################################################
# string_replace_all (<string> <regex> <replace>)
#
# Replace <regex> by <replace> in <string>. Interface to `sed s'.
#
# Arguments: 3
#   <regex>: is a BRE like in `sed';
#   <replace>: like the last element in `sed s', honors \1, etc.
#   <string>: no special characters, no restrictions.
#   Do not worry about the address delimiter, the program escapes them.
# Output: the replaced string.
# Return: `1', if no replace; `0' otherwise.
#
string_replace_all()
{
  if test "$#" -ne 3; then
    error "string_replace_all() needs exactly 3 arguments.";
    return "${_ERROR}";
  fi;
  string_sed_s "$@" 'g';
}


########################################################################
# string_sed_s (<string> <regex> [<replace> [<flag>]])
#
# Feed command `sed s' independently of delimiter.
#
# Equivalent to:
# echo -n <string> | sed -e '/<regex>/s//<replace>/<flag>';
#
# Arguments: do not worry about the deliniter character `/'.
#            2: <replace>='', <flag>=''
#            3: <flag>=''
#            4: with sed flag, e.g. `g' for global
# Output: the resulting string.
#
string_sed_s()
{
  local _flag;
  local _regex;
  local _replace;
  local _string;
  case "$#" in
    2)
      _replace='';
      _flag='';
      ;;
    3)
      _replace="$(_string_sed_s_esc_slash "$3")";
      _flag='';
      ;;
    4)
      _replace="$(_string_sed_s_esc_slash "$3")";
      _flag="$4";
      ;;
    *)
      error "string_sed_s() needs 2, 3, or 4 arguments.";
      return "${_ERROR}";
      ;;
  esac;
  _string="$1";
  _regex="$(_string_sed_s_esc_slash "$2")";
  if is_empty "${_string}"; then
    return "${_OK}";
  fi;
  if is_empty "${_string}"; then
    error "string_sed_s(): empty regular expression";
    return "${_ERROR}";
  fi;
  echo -n "${_string}" | \
    eval sed -e \'/"${_regex}"/s//"${_replace}"/"${_flag}"\';
} # string_sed_s()


_string_sed_s_esc_slash()
{
  # Replace each slash `/' by `\/', but not within `[]'.
  # Global: $_APPEND
  local _beginning;
  local _bracketed;
  local _end;
  local _rest;
  local _result;
  local _str;
#  if test "$#" -ne 1; then
#    error '_string_sed_s_esc_slash() requires 1 argument.';
#    return "${_ERROR}";
#  fi;
  if is_empty "$1"; then
    return "${_GOOD}";
  fi;
  if string_not_contains "$1" '/'; then
    echo -n "$1";
    return "${_GOOD}";
  fi;
  _rest="$1""${_APPEND}";
  _result='';
  while true; do
    if string_not_contains "${_rest}" '/'; then
      string_del_append "${_result}${_rest}";
      return "${_GOOD}";
    fi;
    if string_not_contains "${_rest}" '['; then
      string_del_append \
        "${_result}$(_string_sed_s_esc_slash_unbracketed "${_rest}")";
      return "${_GOOD}";
    fi;
    # split at first bracket.
    _beginning="$(echo -n "${_rest}" | sed -e '/^\([^[]*\).*$/s//\1/')";
    _rest="$(echo -n "${_rest}" | sed -e '/^[^[]*/s///')";
    if is_not_empty "${_beginning}"; then
      _str="$(_string_sed_s_esc_slash_unbracketed "${_beginning}")";
      _result="${_result}${_str}";
    fi;
    if string_not_contains "${_rest}" '/'; then
      string_del_append "${_result}${_rest}";
      return "${_GOOD}";
    fi;
    case "${_rest}" in
      \[\]*\]*)			# `[]...]' construct
        _bracketed="$(echo -n "${_rest}" | \
                      sed -e '/^\(\[\][^]]*\]\).*$/s//\1/')";
        _rest="$(echo -n "${_rest}" | \
                      sed -e '/^\(\[\][^]]*\]\)\(.*\)$/s//\2/')";
        ;;
      \[^\]*\]*)		# `[^]...]' construct
        _bracketed="$(echo -n "${_rest}" | \
                      sed -e '/^\(\[^\][^]]*\]\).*$/s//\1/')";
        _rest="$(echo -n "${_rest}" | \
                      sed -e '/^\(\[^\][^]]*\]\)\(.*\)$/s//\2/')";
        ;;
      \[*\]*)			# `[...]' construct
        _bracketed="$(echo -n "${_rest}" | \
                      sed -e '/^\(\[[^]]*\]\).*$/s//\1/')";
        _rest="$(echo -n "${_rest}" | \
                      sed -e '/^\(\[[^]]*\]\)\(.*\)$/s//\2/')";
        ;;
      *)
        error \
          '_string_sed_s_esc_slash(): $_rest must start with a bracket';
        return "${_ERROR}";
        ;;
    esac;
    _result="$(string_del_trailing "${_result}${_bracketed}" \
                                   "$_APPEND")";
  done;
  return "${_BAD}";
} # _string_sed_s_esc_slash_line()


_string_sed_s_esc_slash_unbracketed()
{
  # Do the escaping of slashes in strings that do not contain a bracket.
  #
  # Argument: 1, may not contain a `[' nor line breaks.
  # Output:   precede each slash in the argument by a backslash.
  # Return:   1, if argument has a `['; 0 otherwise.
  #
#   if test "$#" -ne 1; then
#    error \
#      '_string_sed_s_esc_slash_unbracketed() needs 1 argument).';
#    return "${_ERROR}";
#  fi;
#  if string_contains "$1" '['; then
#    error "_string_sed_s_esc_slash(): no bracket allowed in argument.";
#    return "${_ERROR}";
#  fi;
  case "$1" in
    */*)
      echo -n "$1" | sed -e '\|/|s|/|\\/|g';
      return "${_OK}";
      ;;
    *)
      echo -n "$1";
      return "${_OK}";
      ;;
  esac;
} # _string_sed_s_esc_slash_unbracketed()


########################################################################
# string_split (<string> <separator>)
#
# In <string> escape white space and replace each <separator> by space.
#
# Arguments: 2: a <string> that is to be split into parts divided by
#               <separator>
# Output:    the resulting string
#
string_split()
{
  if test "$#" -ne 2; then
    error "string_split() needs 2 arguments.";
    return "${_ERROR}";
  fi;
  string_replace_all \
    "$(string_replace_all \
       "$1" \
       '\(['"${_SPACE}${_TAB}"']\)' \
       '\\\1')" \
    "$2" \
    ' ';
}


########################################################################
# tmp_cat ()
#
# output the temporary cat file (the concatenation of all input)
#
tmp_cat()
{
  cat "${_TMP_CAT}";
}


########################################################################
# tmp_create (<suffix>?)
#
# create temporary file
#
# It's safe to use the shell process ID together with a suffix to
# have multiple temporary files.
#
# Output : name of created file
#

tmp_create()
{
  local _tmp;
  _tmp="${_TMP_PREFIX}${_PROCESS_ID}$1";
  echo -n >"${_tmp}";
  echo -n "${_tmp}";
}


########################################################################
# to_tmp (<filename>)
#
# print file (decompressed) to the temporary cat file
#
to_tmp()
{
  if test "$#" -ne 1; then
    error "to_tmp() expects 1 file argument."
    return "${_ERROR}";
  fi;
  if is_file "$1"; then
    if is_yes "${_OPT_LOCATION}"; then
      echo2 "$1";
    fi;
    if is_yes "${_OPT_WHATIS}"; then
      what_is "$1" >>"${_TMP_CAT}";
    else
      catz "$1" >>"${_TMP_CAT}";
    fi;
  else
    error "to_tmp(): could not read file \`$1'.";
    return "${_ERROR}";
  fi;
}


########################################################################
# usage ()
#
# print usage information to stderr
#
usage()
{
  local _header;
  local _gap;
  _header="Usage: ${_PROGRAM_NAME}";
  _gap="$(string_replace_all "${_header}" '\.' ' ')";
  echo2;
  version;
  cat >&2 <<EOF
Copyright (C) 2001 Free Software Foundation, Inc.
This is free software licensed under the GNU General Public License.

EOF

  echo2 "${_header} [options] [file] [-] [[man:]manpage.x]";
  echo2 "${_gap} [[man:]manpage(x)] [[man:]manpage]...";

  cat >&2 <<EOF

Display roff files, standard input, and/or Unix manual pages with
in a X window viewer or in a text pager.
"-" stands for including standard input.
"manpage" is the name of a man page, "x" its section.
All input is decompressed on-the-fly (by gzip).

-h --help        print this usage message.
-Q --source      output as roff source.
-T --device=name set device for X or tty output.
-v --version     print version information.
--dpi=res        set resolution to "res" ("75" or "100" (default)).
--extension=ext  restrict man pages to section suffix.
--local-file     same as --no-man.
--locale=lang    preset the language for man pages.
--man            check file parameters first whether they are man pages.
--manpath=path   preset path for searching man-pages.
--no-man         disable man-page facility.
--pager=program  preset the paging program for tty mode.
--system=os1,... search man pages for different operating systems.
--title='text'   set the title of the viewer window in X.
--tty            force paging on text terminal even when in X.
--xrdb=opt       pass "opt" as option to gxditview (several allowed).

All other short options are interpreted as "groff" parameters and
transferred unmodified.
EOF

  if is_yes "${_HAS_OPTS_GNU}"; then
    cat >&2 <<EOF

Your system does not support GNU long options.  You can use the POSIX
feature -W to simulate them.
-Wlongopt      simulate long options, euivalent to  "--longopt".
-Wlongopt=arg  simulate long options, euivalent to  "--longopt=arg".
-Wnon_option   internally sent to groff without modifications.
Unknown arguments to the -W command are transferred to groff.
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
  echo2 "${_PROGRAM_NAME} ${_PROGRAM_VERSION} of ${_LAST_UPDATE}";
}


########################################################################
# warning (<string>)
#
# Print warning to stderr
#
warning()
{
  echo2 "warning: $*";
}


########################################################################
# what_is (<filename>)
what_is()
{
  local _res;
  local _dot;
  if test "$#" -ne 1; then
    error "what_is() expects 1 file argument."
    return "${_ERROR}";
  fi;
  if is_not_file "$1"; then
    error "what_is(): argument is not a readable file."
    return "${_ERROR}";
  fi;
  _dot='^\.[ 	]*';
  echo '.br';
  echo "$1: ";
    echo '.br';
  echo -n '  ';
  _res="$(catz "$1" | sed -e '/'"${_dot}"'TH /p
d')";
  if is_not_empty "${_res}"; then	# traditional man style
    catz "$1" | sed -e '1,/'"${_dot}"'SH/d' \
              | sed -e '1,/'"${_dot}"'SH/p
d' \
              | sed -e '/'"${_dot}"'SH/d';
    return "${_GOOD}";
  fi;
  _res="$(catz "$1" | grep "${_dot}"'Dd ')";
  if is_not_empty "${_res}"; then	# BSD doc style
    catz "$1" |  sed -e  '/'"${_dot}"'Nd /p
d' \
              | sed -e '2q' \
              | sed -e '/'"${_dot}"'Nd *\(.*\)$/s//\1/';
    return "${_GOOD}";
  fi;
  echo 'is not a man page.';
  return "${_BAD}";
}


########################################################################
# where (<program>)
#
# Print path of a program if in $PATH
#
# Arguments : 1 (empty allowed)
# Return    : `0' if arg1 is a program in $PATH, `1' otherwise.
#
where()
{
  local _file;
  local _arg;
  local p;
  if test "$#" -ne 1; then
    error "where() needs 1 argument.";
    return "${_ERROR}";
  fi;
  _arg="$1";
  if is_empty "${_arg}"; then
    return "${_BAD}";
  fi;
  case "${_arg}" in
    /*)
      if test -f "${_arg}" && test -x "${_arg}"; then
        return "${_GOOD}";
      else
        return "${_BAD}";
      fi;
      ;;
  esac;
  eval set -- "$(path_split "${PATH}")";
  for p in "$@"; do
    case "$p" in
      */) _file=$p${_arg}; ;;
      *)  _file=$p/${_arg}; ;;
    esac;
    if test -f "${_file}" && test -x "${_file}"; then
      echo -n "${_file}";
      return "${_GOOD}";
    fi;
  done;
  return "${_BAD}";
}


########################################################################
#                              main
########################################################################

# The main area contains the following parts:
# - main_init(): initialize temporary files and set exit trap
# - main_parse_args(): argument parsing
# - determine display mode
# - setup display mode
# - parse $MANOPT
# - process filespecs
# - do the displaying

# These parts are implemented as functions, being defined below in the
# sequence they are called in the main() function.


#######################################################################
# main_init ()
#
# set exit trap and create temporary files
#
# Globals: $_TMP_CAT, $_TMP_STDIN
#
main_init()
{
  # call clean_up() on any signal
  trap clean_up  2>/dev/null || true;

  _TMP_CAT="$(tmp_create)";
  _TMP_STDIN="$(tmp_create i)";
}

########################################################################
# main_parse_args (<command_line_args>*)
#
# Parse arguments; process options and filespec parameters
#
# Arguments: pass the command line arguments unaltered.
# Globals:
#   in:  $_OPTS_*
#   out: $_OPT_*, $_ADDOPTS, $_FILEARGS
#
main_parse_args()
{
  local _arg;
  local _code;
  local _dpi;
  local _longopt;
  local _mode;
  local _opt;
  local _optchar;
  local _optarg;
  local _opts;
  local _stdin_done;
  local _string;
  local _stripped;
  local _warg;

  eval set -- "${GROFFER_OPT}" '"$@"';
  eval set -- "$(normalize_args \
                "${_OPTS_CMDLINE_SHORT}" "${_OPTS_CMDLINE_LONG}" "$@")";


# By the call of `eval', unnecessary quoting was removed.  So the
# positional shell parameters ($1, $2, ...) are now guaranteed to
# represent an option or an argument to the previous option, if any;
# then a `--' argument for separating options and
# parameters; followed by the filespec parameters if any.

# Note, the existence of arguments to options has already been checked.
# So a check for `$#' or `--' should not be done for arguments.

  until test "$#" -le 0 || is_equal "$1" '--'; do
    _opt="$1";			# $_opt is fed into the option handler
    shift;


# The special option `-W warg' can introduce a long groffer option
# (when `warg' starts with `--') or it is passed to groff (otherwise).
#  It is worked on as follows.
#
# 1) If `warg' does not start with `--', `-W warg' is to be passed to
#    groff as the groff no-warning option, so
#    - store `-W warg' to `$_ADDOPTS';
#    - get to the next option by a `continue'.
#
# Otherwise, `warg' starts with `--'; so check whether `warg' can
# represent a long option by the following steps:
#
# 2) If `warg' is exactly a long groffer option without an argument then
#    - store `warg' to `$_opt' (with the leading `--');
#    - go to the option handler.
# 3) If `warg' is exactly a long option that needs an argument then
#    the argument for this option is the argument of the next `-W'
#    command, which must follow immadiately; so
#    - store `warg' to `$_opt';
#    - if the next positional parameter is not `-W', then error;
#    - just skip the next `-W'; the wanted option argument is now `$1';
#    - go to the option handler.
# 4) If `arg' contains a `=' (equal sign) and the part before the
#    first `=' is a long option that needs an argument, then
#    - store this option to `$_opt';
#    - put the argument back as `$1' before the remaining positional
#      parameters;
#    - go to the option handler.
#    Otherwise, error.
# 5) Otherwise, error.

    if is_equal "${_opt}" '-W'; then
      _warg="$1";
      shift;
      case "${_warg}" in
        --*)			# test on long option (steps 2-5)
          _stripped="$(string_del_leading "${_warg}" '--')";
          if string_contains " ${_OPTS_CMDLINE_LONG_NA} " \
                             " ${_stripped} ";
          then			# long option without argument (step 2)
            _opt="--${_stripped}";
          elif string_contains \
               " ${_OPTS_CMDLINE_LONG_ARG} " " ${_stripped}: ";
          then			# separate argument expected (step 3)
            _opt="--${_stripped}";
            if "$#" -eq 0; then
              error "no argument found for \`${_opt}'";
              return "${_ERROR}";
            fi
            if is_equal "$1" '-W'; then
              shift;		# long option argument is now $1
            else
              error "no argument found for \`${_opt}'";
              return "${_ERROR}";
            fi
          else			# test on `=' (step 4)
            case "${_stripped}" in
              ?*=*)		# has embedded `='
                # split off option before first `='
                _longopt="$(string_del_trailing "${_stripped}" '=.*')";
                if is_substring_of \
                   " ${_OPTS_CMDLINE_LONG_ARG} " " ${_longopt}: ";
                then		# `opt=arg' verified (step 4)
                  # split off argument after first `='
                  _optarg="$(string_del_leading \
                             "${_stripped}" "${_longopt}=")";
                  _opt="--${_longopt}";
                  set -- "${_optarg}" "$@";
                else
                  error "wrong option \`-W ${_warg}'";
                  return "${_ERROR}";
                fi;
                ;;
              *)
                error "wrong option \`-W ${_warg}'";
                return "${_ERROR}";
                ;;
            esac;
          fi;
          ;;
        *)			# argument is a warning
          _ADDOPTS_GROFF="${_ADDOPTS_GROFF} -W '${_warg}'";
          if test "$#" -le 0 || is_equal "$1" '--' ]; then
            break;
          else
            _opt="$1";
            shift;
          fi;
          ;;
      esac;
    else				# not `-W'
      do_nothing;
    fi;
    # now $_opt contains the option; $1 is its argument if needed.

    # handle options
    case "${_opt}" in
      -h|--help)
        usage;
        leave;
        ;;
      -P|--to-postproc)		# option for postprocessor, arg;
         _arg="$1";
        shift;
        _ADDOPTS_POST="${_ADDOPTS_POST} -P '${_arg}'";
        ;;
      -Q|--source)		# output source code (`Quellcode').
        _OPT_MODE="source";
        ;;
      -T|--device|--troff-device)
				# device; arg
        _arg="$1";
        shift;
        _OPT_DEVICE="${_arg}";
        ;;
      -v|--version)
        version;
        leave;
        ;;
      -X)
        _OPT_MODE="X";
        ;;
      -Z|--ditroff|--intermediate-output)
				# groff intermediate output
        _OPT_MODE="intermediate-output";
        ;;
      -?)
        _optchar="$(string_del_leading "${_opt}" '-')";
        if string_contains "${_OPTS_GROFF_SHORT_NA}" "${_optchar}"; then
          _ADDOPTS_GROFF="${_ADDOPTS_GROFF} '${_opt}'";
        elif string_contains "${_OPTS_GROFF_SHORT_ARG}" "${_optchar}";
        then
          _arg="$1";
          shift;
          _ADDOPTS_GROFF="${_ADDOPTS_GROFF} '${_opt}' '${_arg}'";
        else
          error "Unknown option : \`$1'";
          return "${_ERROR}";
        fi;
        ;;
      --all)
          _OPT_ALL="yes";
          ;;
      --apropos)
          _OPT_APROPOS="yes";
          ;;
      --bg)			# background color for gxditview, arg;
        _arg="$1";
        shift;
        _ADDOPTS_X="${_ADDOPTS_X} -P -bg -P '${_arg}'";
        ;;
      --display)		# set X display, arg
          DISPLAY="$1";
          shift;
          ;;
      --dpi)			# set resolution for X devices, arg
        _arg="$1";
        shift;
        case "${_arg}" in
          75|75dpi)
            _dpi=75;
            ;;
          100|100dpi)
            _dpi=100;
            ;;
          *)
            error "only resoutions of 75 or 100 dpi are supported";
            return "${_ERROR}";
            ;;
        esac;
        _string="-P -resolution -P '${_dpi}'";
        _ADDOPTS_X="${_ADDOPTS_X} ${_string}";
        ;;
      --extension)		# the extension for man pages, arg
        _OPT_EXTENSION="$1";
        shift;
        ;;
      --fg)			# foreground color for gxditview, arg;
        _arg="$1";
        shift;
        _ADDOPTS_X="${_ADDOPTS_X} -P -fg -P '${_arg}'";
        ;;
      --geometry)		# geometry for gxditview window, arg;
        _arg="$1";
        shift;
        _ADDOPTS_X="${_ADDOPTS_X} -P -geometry -P '${_arg}'";
        ;;
      --lang|--locale)		# set language for man pages, arg
        # argument is xx[_territory[.codeset[@modifier]]] (ISO 639,...)
        _OPT_LANG="$1";
        shift;
        ;;
      --local-file)		# force local files; same as `--no-man'
        _MAN_FORCE="no";
        _MAN_ENABLE="no";
        ;;
      --location|where)		# print file locations to stderr
        _OPT_LOCATION='yes';
        ;;
      --man)			# force all file params to be man pages
        _MAN_ENABLE="yes";
        _MAN_FORCE="yes";
        ;;
      --manpath)		# specify search path for man pages, arg
        # arg is colon-separated list of directories
        _OPT_MANPATH="$1";
        shift;
        ;;
      --mode)			# display mode
        _arg="$1";
        shift;
        case "${_arg}" in
          auto|default|"")	# default
	    _mode="";
            ;;
          X|tty)		# processed output
            _mode="${_arg}";
            ;;
          Q|source)		# display source code
            _mode="source";
            ;;
          Z|intermediate-output) # generate only intermediate output
            _mode="intermediate-output";
            ;;
	  *)
            error "unknown mode ${_arg}";
            return "${_ERROR}";
            ;;
        esac;
        _OPT_MODE="${_mode}";
        ;;
      --no-location)		# disable former call to `--location'
        _OPT_LOCATION='yes';
        ;;
      --no-man)			# disable search for man pages
        # the same as --local-file
        _MAN_FORCE="no";
        _MAN_ENABLE="no";
        ;;
      --pager)			# set paging program for tty mode, arg
        _OPT_PAGER="$1";
        shift;
        ;;
      --PX)			# pass option to gxditview, arg;
        _arg="$1";
        shift;
        _ADDOPTS_X="${_ADDOPTS_X} -P '${_arg}'";
        ;;
      --sections)		# specify sections for man pages, arg
        # arg is colon-separated list of section names
        _OPT_SECTIONS="$1";
        shift;
        ;;
      --systems)		# man pages for different OS's, arg
        # argument is a comma-separated list
        _OPT_SYSTEMS="$1";
        shift;
        ;;
      --title)			# title for X, arg; OBSOLETE by -P
        _arg="$1";
        _ADDOPTS_X="${_ADDOPTS_X} -P -title -P '${_arg}'";
        shift;
        ;;
      --tty)
        _OPT_MODE="tty";
        ;;
      --whatis)
        _OPT_WHATIS='yes';
        ;;
      --xrm)			# pass X resource string, arg;
        _arg="$1";
        shift;
        _ADDOPTS_X="${_ADDOPTS_X} -P -xrm -P '${_arg}'";
        ;;
      *)
        error "error on argument parsing : \`$*'";
        return "${_ERROR}";
        ;;
    esac;
  done;
  shift;			# remove `--' argument

  # Remaining arguments are file names (filespecs).
  # Save them to $_FILEARGS
  if test "$#" -eq 0; then         # use "-" for standard input
    _FILEARGS="'-'";
    save_stdin;
  else
    if is_yes "${_OPT_APROPOS}"; then
      apropos "$@";
      _code="$?";
      clean_up;
      exit "${_code}";
    fi;

    _FILEARGS="";
    _stdin_done="no";
    for i in "$@"; do
      if is_equal "$1" '-' && is_not_yes "${_stdin_done}"; then
        save_stdin;
        _stdin_done="yes";
      fi;
      _FILEARGS="${_FILEARGS} '$1'";
      shift;
    done;
  fi;
  # $_FILEARGS must be retrieved with `eval set -- $_FILEARGS'
}


########################################################################
# main_set_mode ()
#
# Determine the display mode.
#
# Globals:
#   in:  $DISPLAY, $_OPT_MODE, $_OPT_DEVICE
#   out: $_DISPLAY_MODE
#
main_set_mode()
{
  case "${_OPT_MODE}" in
    source|intermediate-output)
      _DISPLAY_MODE="${_OPT_MODE}";
      ;;
    X)
      if is_empty "${DISPLAY}"; then
        error "you must be in X Window for this mode.";
        return "${_ERROR}";
      fi;
      _DISPLAY_MODE="X";
      ;;
    tty)
      case "${_OPT_DEVICE}" in
        "")
          _DISPLAY_MODE="tty";
          ;;
        X*)
          error "cannot display X device in a text terminal."
          return "${_ERROR}";
          ;;
        *)
          _DISPLAY_MODE="device";
          ;;
      esac;
      ;;
    "")
      case "${_OPT_DEVICE}" in
        "")
          if is_empty "${DISPLAY}"; then
            _DISPLAY_MODE="tty";
          else
            _DISPLAY_MODE="X";
          fi;
          ;;
        X*)
          if is_empty "${DISPLAY}"; then
            error "cannot display X device in a text terminal."
            return "${_ERROR}";
          else
            _DISPLAY_MODE="X";
          fi;
          ;;
        *)
          _DISPLAY_MODE="device";
          ;;
      esac;
      ;;
  esac;
}

########################################################################
# main_parse_MANOPT ()
#
# Parse $MANOPT.
#
# Globals:
#   in: $MANOPT, $_OPTS_MAN_*
#   out: $_MANOPT_*
#   in/out: $_MAN_ENABLE
#
main_parse_MANOPT()
{
  local _arg;
  local _opt;
  if is_not_yes "${_MAN_ENABLE}"; then
    return "${_GOOD}";
  fi;
  eval set -- "$(normalize_args "${_OPTS_MAN_SHORT}" \
                 "${_OPTS_MAN_LONG}" "${MANOPT}")";
  until test "$#" -le 0 || is_equal "$1" '--'; do
    _opt="$1";
    shift;
    case "${_opt}" in
      -a|--all)
        _MANOPT_ALL="yes";
        ;;
      -D|--default)
        # undo all man configuration so far (env vars and options)
        : TODO;
        ;;
      -e|--extension)
        _arg="$1";
        shift;
        _MANOPT_EXTENSION="${_arg}";
        ;;
      -l|--local-file)
        _MAN_ENABLE="no";
        break;
        ;;
      -L|--locale)
        _arg="$1";
        shift;
        _MANOPT_LANG="${_arg}";
        ;;
      -m|--systems)
        _arg="$1";
        shift;
        _MANOPT_SYS="${_arg}";
        ;;
      -M|--manpath)
        _arg="$1";
         shift;
        _MANOPT_PATH="${_arg}";
        ;;
      -P|--pager)
        _arg="$1";
        shift;
        _MANOPT_PAGER="${_arg}";
        ;;
      -S|--sections)
        _arg="$1";
        shift;
        _MANOPT_SEC="${_arg}";
        ;;
      -w|--where|--location)
        _OPT_LOCATION='yes';
        ;;
      # ignore all other options
    esac
  done
}


#######################################################################
# main_do_fileargs ()
#
# Process filespec arguments in $_FILEARGS.
#
# Globals:
#   in: $_FILEARGS (process with `eval set -- "$_FILEARGS"')
#
main_do_fileargs()
{
  local _filespec;
  local _name;
  local _ok;
  local _sec;
  eval set -- "${_FILEARGS}";
  unset _FILEARGS;
  # temporary storage of all input to $_TMP_CAT
  while test "$#" -gt 0; do
    # test for `s name' arguments, with `s' a 1-char standard section
    while true; do			# `break' means not such an s
      if test "$#" -le 0; then
        break;
      fi;
      _filespec="$1";
      shift;
      case "${_filespec}" in
        '') continue; ;;
        '-')
          register_file '-';
          continue;
          ;;
        ?) 
          if test "$#" -le 0; then
            break;
          fi;
          _sec="${_filespec}";
          if string_not_contains "${_MAN_AUTO_SEC}" "${_sec}"; then
            break;
          fi;
          _name="$1";
          case "${_name}" in
            */*) break; ;;
            man:*) break; ;;
            *\(*\)) break; ;;
            *."${_sec}") break; ;;
          esac;
          if do_filearg "man:${_name}(${_sec})"; then
            continue;
          else
            break;
          fi;
          ;;
        *) break; ;;
      esac;
    done;			# end of `s name' test
    do_filearg "${_filespec}";
    if test "$?" != "${_GOOD}"; then
      warning "\`${_filespec}' is neither a file nor a man-page.";
    fi;
    if test "$#" -eq 0; then
      return "$_OK";
    fi;
  done;
}

########################################################################
# main_display ()
#
# Do the actual display of the whole thing.
#
# Globals:
#   in: $_DISPLAY_MODE, $_OPT_DEVICE,
#       $_ADDOPTS_GROFF, $_ADDOPTS_POST, $_ADDOPTS_X,
#       $_REGISTERED_TITLE, $_TMP_PREFIX, $_TMP_CAT,
#       $_OPT_PAGER $PAGER $_MANOPT_PAGER
#
main_display()
{
  local _addopts;
  local _options;
  local _groggy;
  local _title;
  local _old_tmp;
  local _pager;
  export _addopts;
  export _groggy;
  local p;
  case "${_DISPLAY_MODE}" in
    source)
      tmp_cat;
      clean_up;
      ;;
    intermediate-output)
      _options="-Z";
      if is_not_empty "${_OPT_DEVICE}"; then
        _options="${_options} -T'${_OPT_DEVICE}'";
      fi;

      _groggy="$(eval grog "${_options}" "${_ADDOPTS_GROFF}" \
                           "${_TMP_CAT}" )";
      _groggy="$(tmp_cat | eval grog "${_options}")";
      tmp_cat | eval "${_groggy}" "${_ADDOPTS_GROFF}";
      clean_up;
      ;;
    device)
      _groggy="$(tmp_cat | grog -T"${_OPT_DEVICE}")";
      tmp_cat | eval "${_groggy}" "${_ADDOPTS_GROFF}";
      clean_up;
      ;;
    X)
      _addopts="${_ADDOPTS_GROFF} ${_ADDOPTS_POST} ${_ADDOPTS_X}";
      if is_not_empty "${_REGISTERED_TITLE}"; then
        _title="${_REGISTERED_TITLE}";
        _addopts="-P -title -P '${_title}' ${_addopts}";
      fi;
      if is_not_empty "${_OPT_DEVICE}"; then
        _addopts="-T '${_OPT_DEVICE}' ${_addopts}";
      fi;
      clean_up_secondary;
      _groggy="$(tmp_cat | grog -X)";
      trap "" EXIT 2>/dev/null || true;
      # start a new shell program to get another process ID.
      sh -c '
        set -e;
        _PROCESS_ID="$$";
        _old_tmp="${_TMP_CAT}";
        _TMP_CAT="${_TMP_PREFIX}${_PROCESS_ID}";
        rm -f "${_TMP_CAT}";
        mv "${_old_tmp}" "${_TMP_CAT}";
        cat "${_TMP_CAT}" | \
        (
          clean_up()
          {
            rm -f "${_TMP_CAT}";
          }
          trap clean_up EXIT 2>/dev/null || true;
          eval "${_groggy}" "${_addopts}";
        ) &'
      ;;
    tty)
      _addopts="${_ADDOPTS_GROFF} ${_ADDOPTS_POST}";
      _groggy="$(tmp_cat | grog -Tlatin1)";
      _pager="";
# TODO ?
      for p in "${_OPT_PAGER}" "${PAGER}" "less" "${_MANOPT_PAGER}"; do
        if is_prog "$p"; then
          _pager="$p";
          break;
        fi;
      done;
      tmp_cat | eval "${_groggy}" "${_addopts}" | \
                eval "${_pager}";
      clean_up;
      ;;
    *)
      clean_up;
      ;;
  esac;
}


########################################################################
# main (<command_line_args>*)
#
# The main function for groffer.
#
# Arguments:
#
main()
{
  # Do not change the sequence of the following functions!
  main_init;
  main_parse_args "$@";
  main_set_mode;
  main_parse_MANOPT;
  main_do_fileargs;
  main_display;
}

main "$@";

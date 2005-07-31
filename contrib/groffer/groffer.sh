#! /bin/sh

# groffer - display groff files

# Source file position: <groff-source>/contrib/groffer/groffer.sh

# Copyright (C) 2001,2002,2003,2004,2005
# Free Software Foundation, Inc.
# Written by Bernd Warken

# This file is part of groff version @VERSION@ (eventually 1.19.2).

# groff is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.

# groff is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
# License for more details.

# You should have received a copy of the GNU General Public License
# along with groff; see the files COPYING and LICENSE in the top
# directory of the groff source.  If not, write to the Free Software
# Foundation, 51 Franklin St - Fifth Floor, Boston, MA 02110-1301, USA.

_PROGRAM_NAME='groffer';
_PROGRAM_VERSION='0.9.20';
_LAST_UPDATE='30 July 2005';


########################################################################
# Determine the shell under which to run this script from the command
# line arguments or $GROFF_OPT; if none is specified, just go on with
# the starting shell.

if test _"${_GROFFER_RUN}"_ = __;
then
  # only reached during the first run of the script

  export _GROFFER_RUN;		# counter for the runs of groffer
  _GROFFER_RUN='first';

  export _PROGRAM_NAME;
  export _PROGRAM_VERSION;
  export _LAST_UPDATE;

  export GROFFER_OPT;		# option environment for groffer
  export _GROFFER_SH;		# file name of this shell script
  export _OUTPUT_FILE_NAME;	# output generated, see main_set_res..()

  export _CONF_FILES;		# configuration files
  _CONF_FILES="/etc/groff/groffer.conf ${HOME}/.groff/groffer.conf";

  case "$0" in
  *${_PROGRAM_NAME}*)
    _GROFFER_SH="$0";
    # was: _GROFFER_SH="@BINDIR@/${_PROGRAM_NAME}";
    ;;
  *)
    echo "The ${_PROGRAM_NAME} script should be started directly." >&2
    exit 1;
    ;;
  esac;

  export _NULL_DEV;
  if test -c /dev/null;
  then
    _NULL_DEV="/dev/null";
  else
    _NULL_DEV="NUL";
  fi;


  # test of `unset'
  export _UNSET;
  export _foo;
  _foo=bar;
  _res="$(unset _foo 2>&1)";
  if unset _foo >${_NULL_DEV} 2>&1 && \
     test _"${_res}"_ = __ && test _"${_foo}"_ = __
  then
    _UNSET='unset';
    eval "${_UNSET}" _res;
  else
    _UNSET=':';
  fi;


  ###########################
  # _get_opt_shell ("$@")
  #
  # Determine whether `--shell' was specified in $GROFF_OPT or in $*;
  # if so, echo its argument.
  #
  # Output: the shell name if it was specified
  #
  _get_opt_shell()
  {
    case " ${GROFFER_OPT} $*" in
      *\ --shell\ *|*\ --shell=*)
        (
          eval set x "${GROFFER_OPT}" '"$@"';
          shift;
          _sh='';
          while test $# != 0
          do
            case "$1" in
              --shell)
                if test "$#" -ge 2;
                then
                  _sh="$2";
                  shift;
                fi;
                ;;
              --shell=?*)
                # delete up to first `=' character
                _sh="$(echo x"$1" | sed -e '
s/^x//
s/^[^=]*=//
')";
                ;;
            esac;
            shift;
          done;
          cat <<EOF
${_sh}
EOF
        )
        ;;
    esac;
  }


  ###########################
  # _test_on_shell (<name>)
  #
  # Test whether <name> is a shell program of Bourne type (POSIX sh).
  #
  _test_on_shell()
  {
    if test "$#" -le 0 || test _"$1"_ = __;
    then
      return 1;
    fi;
    # do not quote $1 to allow arguments
    test _"$(eval $1 -c "'"'s=ok; echo $s'"'" 2>${_NULL_DEV})"_ = _ok_;
  }


  ###########################
  # do the shell determination from command line and $GROFFER_OPT
  _shell="$(_get_opt_shell "$@")";
  if test _"${_shell}"_ = __;
  then
    # none found, so look at the `--shell' lines in configuration files
    export f;
    # for f in $_CONF_FILES
    for f in $(eval set x ${_CONF_FILES}; shift; echo "$@")
    do
      if test -f "$f";
      then
        _all="$(cat "$f" | sed -n -e 's/^--shell[= ] *\([^ ]*\)$/\1/p')"
        # for s in $_all
        for s in $(eval set x ${_all}; shift; echo "$@")
        do
          _shell="$s";
        done;
      fi;
    done;
    eval ${_UNSET} f;
    eval ${_UNSET} s;
    eval ${_UNSET} _all;
  fi;

  export _GROFFER2_SH;            # file name of the script that follows up
  _GROFFER2_SH='@libdir@/groff/groffer/groffer2.sh';

  # restart the script with the last found $_shell, if it is a shell
  if _test_on_shell "${_shell}";
  then
    _GROFFER_RUN='second';
    # do not quote $_shell to allow arguments
    eval exec ${_shell} "'${_GROFFER2_SH}'" '"$@"';
    exit;
  fi;

  _GROFFER_RUN='second';
  eval ${_UNSET} _shell;
  eval exec "'${_GROFFER2_SH}'" '"$@"';

fi; # end of first run

if test _"${_GROFFER_RUN}"_ != _second_;
then
  echo "$_GROFFER_RUN should be 'second' here." >&2
  exit 1
fi;

eval ${_UNSET} _GROFFER_RUN

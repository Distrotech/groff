#!/bin/sh
#
# pic2graph -- compile PIC image descriptions to bitmap images
#
# by Eric S. Raymond <esr@thyrsus.com>, July 2001
#
#
# Copyright (C) 2001 Free Software Foundation, Inc.
#
# This file is part of groff.
#
# groff is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 2, or (at your option) any later
# version.
#
# groff is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with groff; see the file COPYING.  If not, write to the Free Software
# Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.


# In Unixland, the magic is in knowing what to string together...
#
# Take a pic/eqn diagram on stdin, emit cropped bitmap on stdout.
# The pic markup should *not* be wrapped in .PS/.PE, this script will do that.
# A -U option on the command line enables gpic/groff "unsafe" mode.
# All other options are passed to pnmtopng (or whichever back end is selected 
# by the format option).  The default format in PNG.
#
# Requires groff, ghostscript, and the pnm tools.  All are open source.
# Use, modify, and redistribute freely.  Send me fixes and enhancements.
#
# Here are the assumptions behind the option processing:
#
# 1. Only the -U option of gpic(1) is relevant.  -C doesn't matter because
# we're generating our own .PS/.PE, -[ntcz] are irrelevant because we're
# generating Postscript.
#
# 2. Ditto for groff(1), though it's a longer and more tedious demonstration.
#
# 3. No options of pnmcrop are relevant.  We can assume the generated image
# is going to be black-on-white because that's what pic generates.  Even
# if pic were somehow coerced into generating a non-white background,
# pnmcrop's algorithm (look at the top corners) will find the right
# thing because gs(1) is generating a full page.
#
# 4. Many options of pnmtopng(1) or other pnm converters are potentially 
# relevant, (especially -interlace, -transparent, -background, -text, and 
# -compression.
#
# Thus, we pass -U to gpic and groff, and everything else to pnmtopng.
#
# We don't have complete option coverage on eqn because this is primarily
# intended as a pic translator; we can live with eqn defaults. 
#
# $Id$
#
groffpic_opts=""
gs_opts=""
pnmtopng_opts=""
format="png"
resolution=""
eqndelim='$$'

while [ "$1" ]
do
    case $1 in
    -unsafe)
	groffpic_opts="-U"; pngtopnm_opts="$pngtopnm_opts -U";;
    -format)
	format=$2; shift;;
    -eqn)
	eqndelim=$2; shift;;
    -resolution)
	gs_opts="-r$2"; shift;;
    -v | --version)
	echo "GNU pic2graph (groff) version @VERSION@"
	exit 0;;
    --help)
	echo "usage: pic2graph [ option ...] < in > out"
	exit 0;;
    *)
	pnmtopmg_opts="$pnmtopmg_opts $1" ;;
    esac
    shift;
done

if [ "$eqndelim" ]
then
    eqndelim="delim $eqndelim"
fi

# Here goes:
# 1. Wrap the input in dummy .PS/PE macros
# 2. Process through eqn and pic to emit troff markup
# 3. Process through groff to emit Postscript
# 4. Process through ghostscript to emit a ppm bitmap
# 5. Crop the ppm bitmap
# 6. Turn the ppm into PNG
(echo ".EQ"; echo $eqndelim; echo ".EN"; echo ".PS"; cat; echo ".PE") \
	| groff -e -p $groffpic_opts -Tps \
 	| gs -q $gs_opts -sDEVICE='ppmraw' -sOutputFile='-' -dNOPAUSE -dBATCH - \
	| pnmcrop \
	| pnmto${format} $pnmtopng_opts

# End

#!/bin/sh
#
# grap2graph -- compile graph description descriptions to bitmap images
#
# by Eric S. Raymond <esr@thyrsus.com>, May 2003
#
# In Unixland, the magic is in knowing what to string together...
#
# Take grap description on stdin, emit cropped bitmap on stdout.
# The pic markup should *not* be wrapped in .G1/.G2, this script will do that.
# A -U option on the command line enables gpic/groff "unsafe" mode.
# A -format FOO option changes the image output format to any format
# supported by convert(1).  All other options are passed to convert(1).
# The default format is PNG.
#

# Requires the groff suite and the ImageMagick tools.  Both are open source.
# This code is released to the public domain.
#
# Here are the assumptions behind the option processing:
#
# 1. None of the options of grap(1) are relevant.
#
# 2. Only the -U option of groff(1) is relevant.
#
# 3. Many options of convert(1) are potentially relevant, (especially 
# -density, -interlace, -transparency, -border, and -comment).
#
# Thus, we pass -U to groff(1), and everything else to convert(1).
#
# $Id$
#
groff_opts=""
convert_opts=""
format="png"

while [ "$1" ]
do
    case $1 in
    -unsafe)
	groff_opts="-U";;
    -format)
	format=$2
	shift;;
    -v | --version)
	echo "GNU grap2graph (groff) version @VERSION@"
	exit 0;;
    --help)
	echo "usage: grap2graph [ option ...] < in > out"
	exit 0;;
    *)
	convert_opts="$convert_opts $1";;
    esac
    shift
done

# Here goes:
# 1. Add .G1/.G2.
# 2. Process through grap(1) to emit pic markup.
# 3. Process through groff(1) with pic preprocessing to emit Postscript.
# 4. Use convert(1) to crop the Postscript and turn it into a bitmap.
tmp=/usr/tmp/grap2graph-$$
trap "rm ${tmp}.*" 0 2 15 
(echo ".G1"; cat; echo ".G2") | grap | groff -p $groff_opts -Tps | \
	convert -crop 0x0 $convert_opts - ${tmp}.${format} \
	&& cat ${tmp}.${format}

# End

#!/bin/sed -f
# Strip a PostScript prologue of unnecessary comments and white space.
/^%[%!]/b
s/^[ 	][ 	]*//
s/[ 	][ 	]*$//
s/%.*//
/^$/d
s/[ 	]*\([][}{/]\)[ 	]*/\1/g

#!/bin/sh -xv
# Usage:
# genfonts.sh <input .proto file> <RES> <CPI> <FONT name>
if test -z "$1" || test -z "$2" || test -z "$3" || test -z "$4"; then
    echo "genfonts.sh: missing parameter"; exit 255;
fi

INPUT=$1
RES=$2
CPI=$3
FONT=$4
charwidth=`expr $RES / $CPI` ;
sed -e "s|^name [A-Z]*$|name $FONT|" \
    -e \
    "s/^\\([^	]*\\)	[0-9][0-9]*	/\\1	$charwidth	/" \
    -e "s/^spacewidth [0-9][0-9]*$/spacewidth $charwidth/" \
    -e "s|^internalname .*$|internalname $FONT|" \
    -e "/^internalname/s/CR/4/" \
    -e "/^internalname/s/BI/3/" \
    -e "/^internalname/s/B/2/" \
    -e "/^internalname/s/I/1/" \
    -e "/^internalname .*[^ 0-9]/d" \
    $INPUT

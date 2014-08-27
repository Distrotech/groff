#!/bin/sh
# Usage: gendesc.sh <input .proto> <RES> <CPI> <LPI> <list of fonts>
if test -z "$1" || test -z "$2" || test -z "$3" || test -z "$4" || \
    test -z "$5"; then
    echo "genfonts.sh: missing parameter"; exit 255;
fi
INPUT=$1
RES=$2
CPI=$3
LPI=$4
shift 4
NBFONTS=`echo $#`
FONTS=`echo $*`
sed -e "s/^res .*$/res $RES/" \
    -e "s/^hor .*$/hor `expr $RES / $CPI`/" \
    -e "s/^vert .*$/vert `expr $RES / $LPI`/" \
    -e "s/^fonts .*$/fonts $NBFONTS $FONTS/" \
    $INPUT

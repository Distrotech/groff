#! /bin/sh
#
#	A very simple function test for gdiffmk.sh.
#
# Copyright (C) 2004, 2005, 2009 Free Software Foundation, Inc.
# Written by Mike Bianchi <MBianchi@Foveal.com <mailto:MBianchi@Foveal.com>>

# This file is part of the gdiffmk utility, which is part of groff.

# groff is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# groff is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
# License for more details.

# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
# This file is part of GNU gdiffmk.

# abs_top_srcdir and abs_top_builddir are set by AM_TESTS_ENVIRONMENT
# (defined in Makefile.am) when running make check

srcdir=${abs_top_srcdir}/contrib/gdiffmk/tests

command=${abs_top_builddir}/gdiffmk

#	Test the number of arguments and the first argument.
case $#-$1 in
1-clean )
	rm -fv result* tmp_file*
	exit 0
	;;
1-run )
	;;
* )
	echo >&2 "$0 [ clean | run ]
Run a few simple tests on \`${command}'."'

clean	Remove the result? and tmp_file? files.
run	Run the tests.
'
	exit 255
	;;
esac

function TestResult {
	if cmp -s $1 $2
	then
		echo $2 PASSED
	else
		echo ''
		echo $2 TEST FAILED
		diff $1 $2
		echo ''
	fi
}

tmpfile=/tmp/$$
trap 'rm -f ${tmpfile}' 0 1 2 3 15

#	Run tests.

#	3 file arguments
ResultFile=result.1
${command}  ${srcdir}/file1  ${srcdir}/file2 ${ResultFile} 2>${tmpfile}
cat ${tmpfile} >>${ResultFile}
TestResult ${srcdir}/baseline ${ResultFile}

#	OUTPUT to stdout by default
ResultFile=result.2
${command}  ${srcdir}/file1  ${srcdir}/file2  >${ResultFile} 2>&1
TestResult ${srcdir}/baseline ${ResultFile}

#	OUTPUT to stdout via  -  argument
ResultFile=result.3
${command}  ${srcdir}/file1  ${srcdir}/file2 - >${ResultFile} 2>&1
TestResult ${srcdir}/baseline ${ResultFile}

#	FILE1 from standard input via  -  argument
ResultFile=result.4
${command}  - ${srcdir}/file2 <${srcdir}/file1  >${ResultFile} 2>&1
TestResult ${srcdir}/baseline ${ResultFile}

#	FILE2 from standard input via  -  argument
ResultFile=result.5
${command}  ${srcdir}/file1 - <${srcdir}/file2  >${ResultFile} 2>&1
TestResult ${srcdir}/baseline ${ResultFile}

#	Different values for addmark, changemark, deletemark
ResultFile=result.6
${command}  -aA -cC -dD  ${srcdir}/file1 ${srcdir}/file2  >${ResultFile} 2>&1
TestResult ${srcdir}/baseline.6 ${ResultFile}

#	Test for accidental file overwrite.
ResultFile=result.7
cp ${srcdir}/file2 tmp_file.7
${command}  -aA -dD -cC  ${srcdir}/file1 tmp_file.7  tmp_file.7	\
							>${ResultFile} 2>&1
TestResult ${srcdir}/baseline.7 ${ResultFile}

#	Test -D option
ResultFile=result.8
${command}  -D  ${srcdir}/file1 ${srcdir}/file2 >${ResultFile} 2>&1
TestResult ${srcdir}/baseline.8 ${ResultFile}

#	Test -D  and  -M  options
ResultFile=result.9
${command}  -D  -M '<<<<' '>>>>'				\
			${srcdir}/file1 ${srcdir}/file2 >${ResultFile} 2>&1
TestResult ${srcdir}/baseline.9 ${ResultFile}

#	Test -D  and  -B  options
ResultFile=result.10
${command}  -D  -B  ${srcdir}/file1 ${srcdir}/file2 >${ResultFile} 2>&1
TestResult ${srcdir}/baseline.10 ${ResultFile}

#	EOF

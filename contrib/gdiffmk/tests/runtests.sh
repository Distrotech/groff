#!/bin/sh
#	A very simple function test for gdiffmk.sh.

command=../gdiffmk.sh

#	Test the number of arguments and the first argument.
case $#-$1 in
1-clean )
	rm -fv test_result? tmp_file?
	exit 0
	;;
1-run )
	;;
* )
	echo >&2 "$0 [ clean | run ]
Run a few simple tests on \`${command}'."'

clean	Remove the test_result? and tmp_file? files.
run	Run the tests.
'
	exit 255
	;;
esac

function TestResult {
	if diff $1 $2
	then
		echo $2 PASSED
	else
		echo $2 TEST FAILED '\a'
	fi
}

tmpfile=/tmp/$$
trap 'rm -f ${tmpfile}' 0 1 2 3 15

#	3 file arguments
ResultFile=test_result1
sh ${command}  file1  file2 ${ResultFile} 2>${tmpfile}
cat ${tmpfile} >>${ResultFile}
TestResult test_baseline ${ResultFile}

#	OUTPUT to stdout by default
ResultFile=test_result2
sh ${command}  file1  file2  >${ResultFile} 2>&1
TestResult test_baseline ${ResultFile}

#	OUTPUT to stdout via  -  argument
ResultFile=test_result3
sh ${command}  file1  file2 - >${ResultFile} 2>&1
TestResult test_baseline ${ResultFile}

#	FILE1 from standard input via  -  argument
ResultFile=test_result4
sh ${command}  - file2 <file1  >${ResultFile} 2>&1
TestResult test_baseline ${ResultFile}

#	FILE2 from standard input via  -  argument
ResultFile=test_result5
sh ${command}  file1 - <file2  >${ResultFile} 2>&1
TestResult test_baseline ${ResultFile}

#	Different values for addmark, changemark, deletemark
ResultFile=test_result6
sh ${command}  -aA -cC -dD  file1 file2  >${ResultFile} 2>&1
TestResult test_baseline6 ${ResultFile}

#	Test for accidental file overwrite.
ResultFile=test_result7
cp file2 tmp_file7
sh ${command}  -aA -dD -cC  file1 tmp_file7  tmp_file7  >${ResultFile} 2>&1
TestResult test_baseline7 ${ResultFile}

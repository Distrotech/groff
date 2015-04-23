#!/bin/sh

# Execute runtests.sh in the builddir 

set -e

mkdir -p ${abs_top_builddir}/contrib/gdiffmk/tests
cd ${abs_top_builddir}/contrib/gdiffmk/tests
${abs_top_srcdir}/contrib/gdiffmk/tests/runtests.sh run

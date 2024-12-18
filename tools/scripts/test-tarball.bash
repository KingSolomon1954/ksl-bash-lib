#!/usr/bin/env bash
#
# -----------------------------------------------------------
#
# Performs a minimal checkout of the tar ball.
#
# -----------------------------------------------------------

# $1 = build directory   _build
# $2 = tar-file          _build/release/ksl-bash-lib-0.0.3.tgz

b=$(basename $2)         # ksl-bash-lib-0.0.3.tgz
release="${b%%".tgz"}"   # strip .tgz

testdir=$1/test-tarball
rm -rf   $testdir
mkdir -p $testdir
tar -xzf $2 --directory=$testdir

releaseDir=$testdir/$release

[ ! -d $releaseDir ]                 && exit 1
[ ! -d $releaseDir/docs ]            && exit 1
[ ! -f $releaseDir/docs/index.html ] && exit 1
(( $(ls $releaseDir/*.bash | wc -l) < 7 )) && exit 1

export KSL_BASH_LIB=$releaseDir

source $KSL_BASH_LIB/libStrings.bash

declare -i ret
ksl::startsWith "happy go-lucky" "happy"
ret=$?
(( $ret != 0 )) && exit 1
exit 0

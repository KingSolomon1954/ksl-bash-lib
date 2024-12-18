#!/usr/bin/env bash
#
# -----------------------------------------------------------
#
# Performs a minimal checkout of the tar ball.
#
# -----------------------------------------------------------

# $1 = build directory   _build
# $2 = tar-file          _build/release/ksl-bash-lib-0.0.3.tgz

b=$(basename $2)        # ksl-bash-lib-0.0.3.tgz
release="${b%%".tgz"}"  # strip .tgz

rm -rf   $1/test-tarball
mkdir -p $1/test-tarball
tar -xzf $2 --directory=$1/test-tarball
cd    $1/test-tarball
[ ! -d $release ]                 && exit 1
[ ! -d $release/docs ]            && exit 1
[ ! -f $release/docs/index.html ] && exit 1
(( $(ls $release/*.bash | wc -l) < 7 )) && exit 1

export KSL_BASH_LIB=$release

source $KSL_BASH_LIB/libStrings.bash

declare -i ret
ksl::startsWith "happy go-lucky" "happy"
ret=$?
(( $ret != 0 )) && exit 1
exit 0

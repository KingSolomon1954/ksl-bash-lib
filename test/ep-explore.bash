#!/usr/bin/env bash

source "${KSL_BASH_LIB}"/libError.bash

# -----------------------------------------------------------

processFiles()
{
    # SAVE_IFS="${IFS}"; IFS=":"
    for f in "$@"; do
    # for f in ${filesToProcess}; do
        processOneFile "${f}"
    done
    # IFS="${SAVE_IFS}"
}

# -----------------------------------------------------------

processOneFile()
{
    echo "processOneFile(): \"$1\""
    if ! libAbc::fileExists "$1"; then
        echo "Unable to read configuration: "
#       ksl::epPrepend "Unable to read configuration: "
        [[ ${#ep1[@]} -gt 0 ]] && echo "ep1 created and usable"
        return 1
    fi
}

# -----------------------------------------------------------

libAbc::fileExists()
{
    [ -f "$1" ] && return
    ksl::epSet --description "No such file: \"$1\"" \
               --fileName \"libAbc.bash\" \
               --funcName libAbc::openFile.bash
    [[ ${#ep1[@]} -gt 0 ]] && echo "ep1 created and usable"
    return 1
}

# -----------------------------------------------------------

# filesToProcess="/tmp/epTest1.$$:/tmp/epTest2.$$:/tmp/brian dani mike"

touch "$@"
processFiles "$@" /tmp/badfile.txt

rm -f "$@"

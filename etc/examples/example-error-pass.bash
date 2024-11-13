#!/usr/bin/env bash

source "${KSL_BASH_LIB}"/libError.bash

# -----------------------------------------------------------

initApp()
{
    if ! processConfigFiles "$@"; then
        ksl::epPrepend "Failed to initialize. "
        ksl::epSetSeverity "Critical"
        return 1
    fi
}

# -----------------------------------------------------------

processConfigFiles()
{
    for f in "$@"; do
        ! processOneConfigFile "${f}" && return 1
    done
}

# -----------------------------------------------------------

processOneConfigFile()
{
    echo "Processing: \"${1}\""
    if ! parseYamlFile "$1"; then
        ksl::epSetErrorType "ConfigurationError"
        return 1
    fi
}

# -----------------------------------------------------------

parseYamlFile()
{
    # echo "entered parseYamlFile(): \"$1\""
    if ! fileExists "$1"; then
        ksl::epPrepend "Error parsing yaml file. "
        return 1
    fi
}

# -----------------------------------------------------------

fileExists()
{
    [ -f "$1" ] && return
    ksl::epSet --description "No such file: \"$1\"." \
               --errorName NotFoundError \
               --fileName $BASH_SOURCE \
               --funcName $FUNCNAME \
               --lineNum $LINENO
    return 1
}

# -----------------------------------------------------------

filesToProcess=/tmp/epTest1.$$
filesToProcess+=:/tmp/epTest2.$$
filesToProcess+=":/tmp/black mountain peak"

IFS=":"
for f in $filesToProcess; do
    touch "$f"
done
    
# echo $filesToProcess

if ! initApp $filesToProcess /tmp/badfile.yml; then
    ksl::epPrint
fi

rm $filesToProcess

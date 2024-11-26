#!/usr/bin/env bash

source "${KSL_BASH_LIB}"/libStdOut.bash

# -----------------------------------------------------------

test_traceTest()
{
    echo
    ksl::stdOut "This is a message using ksl::stdOut"
    ksl::stdErr "This is a message using ksl::stdErr"
    ksl::stdTrace "This is a message using ksl::stdTrace"
    ksl::stdDebug "This is a message using ksl::stdDebug"
    ksl::stdInfo  "This is a message using ksl::stdInfo"
    ksl::stdWarn  "This is a message using ksl::stdWarn"
    ksl::stdError "This is a message using ksl::stdError"
    ksl::stdFatal "This is a message using ksl::stdFatal"
}

# -----------------------------------------------------------

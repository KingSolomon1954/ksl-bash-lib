#!/usr/bin/env bash

source "${KSL_BASH_LIB}"/libStdOut.bash

# -----------------------------------------------------------

test_stdOutTest()
{
    echo
    echo -e -n "\t"; ksl::stdOut   "This is a message using ksl::stdOut"
    echo -e -n "\t"; ksl::stdErr   "This is a message using ksl::stdErr"
    echo -e -n "\t"; ksl::stdTrace "This is a message using ksl::stdTrace"
    echo -e -n "\t"; ksl::stdDebug "This is a message using ksl::stdDebug"
    echo -e -n "\t"; ksl::stdInfo  "This is a message using ksl::stdInfo"
    echo -e -n "\t"; ksl::stdWarn  "This is a message using ksl::stdWarn"
    echo -e -n "\t"; ksl::stdError "This is a message using ksl::stdError"
    echo -e -n "\t"; ksl::stdFatal "This is a message using ksl::stdFatal"
}

# -----------------------------------------------------------

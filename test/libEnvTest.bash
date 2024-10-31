#!/usr/bin/env bash

source "${KSL_BASH_LIB}"/libEnv.bash

# -----------------------------------------------------------

test_envContains()
{
    # test insufficient args - no args
    assert_fails "ksl::envContains"

    # test insufficient args - 1 arg
    assert_fails "ksl::envContains '/usr/dinosaur'"

    # test two empty args
    assert_fails "ksl::envContains '' ''"

    # test one empty arg first
    assert_fails "ksl::envContains '' '/usr/dinosaur'"

    # test one empty arg second
    assert_fails "ksl::envContains '/usr/dinosaur' ''"

    # test unset var
    assert_fails "ksl::envContains 'SOME_UNSETVAR' '/usr/dinosaur'"

    # test null/empty var
    # shellcheck disable=SC2034
    SOME_EMPTY_VAR=
    assert_fails "ksl::envContains 'SOME_EMPTY_VAR' '/usr/dinosaur'"

    # match only entry
    PATH_VAR="/usr/bird"
    assert "ksl::envContains 'PATH_VAR' '/usr/bird'"

    # match element at front
    PATH_VAR="/usr/bird:/front_schmutz:/end_schmutz"
    assert "ksl::envContains 'PATH_VAR' '/usr/bird'"

    # match element in middle
    PATH_VAR="/front_schmutz:/usr/bird:/end_schmutz"
    assert "ksl::envContains 'PATH_VAR' '/usr/bird'"

    # match element at end
    PATH_VAR="/front_schmutz:/end_schmutz/:/usr/bird"
    assert "ksl::envContains 'PATH_VAR' '/usr/bird'"

    # match element to env var having leading ":" 
    PATH_VAR=":/usr/bird"
    assert "ksl::envContains 'PATH_VAR' '/usr/bird'"

    # match element to env var having trailing ":" 
    PATH_VAR="/usr/bird:"
    assert "ksl::envContains 'PATH_VAR' '/usr/bird'"

    # match using bad element having leading ":"
    PATH_VAR="/usr/bird"
    assert "ksl::envContains 'PATH_VAR' ':/usr/bird'"

    # match using bad element having trailing ":"
    PATH_VAR="/usr/bird"
    assert "ksl::envContains 'PATH_VAR' '/usr/bird:'"

    # match using bad element having leading and trailing ":"
    PATH_VAR="/usr/bird"
    assert "ksl::envContains 'PATH_VAR' ':/usr/bird:'"

    # match using bad element having mulitples leading and trailing ":"
    PATH_VAR="/usr/bird"
    assert "ksl::envContains 'PATH_VAR' '::/usr/bird::'"
    
    # no match using bad element having embedded ":", not allowed
    PATH_VAR="/usr:/home"
    assert_fails "ksl::envContains 'PATH_VAR' '/usr:/home'"
    
    # match with spaces in front
    PATH_VAR="/front schmutz:/end schmutz/:/usr/bird"
    assert "ksl::envContains 'PATH_VAR' '/front schmutz'"

    # match with spaces in middle
    PATH_VAR="/front schmutz:/end schmutz:/usr/bird"
    assert "ksl::envContains 'PATH_VAR' '/end schmutz'"

    # no match - spaces with partial substring
    PATH_VAR="/front schmutz:/end/schmutz/:/usr/bird"
    assert_fails "ksl::envContains 'PATH_VAR' 'schmutz'"

    # match with escaped space
    # shellcheck disable=SC2034
    PATH_VAR="/front schmutz:/end schmutz/:/usr/bird"
    assert "ksl::envContains 'PATH_VAR' '/front\ schmutz'"
}

# -----------------------------------------------------------

test_envAppend()
{
    # test insufficient args - no args
    assert_fails "ksl::envAppend"

    # test insufficient args - 1 arg
    assert_fails "ksl::envAppend '/usr/dinosaur'"

    # test two empty args
    assert_fails "ksl::envAppend '' ''"

    # test empty args
    assert_fails "ksl::envAppend '/usr/dinosaur' ''"

    # test empty args
    assert_fails "ksl::envAppend '' '/usr/dinosaur'"

    # appending to an unset var
    unset SOME_UNSETVAR
    ksl::envAppend SOME_UNSETVAR /usr/dinosaur
    assert_equals "/usr/dinosaur" "${SOME_UNSETVAR}"
    unset SOME_UNSETVAR

    # appending to a null/empty var
    SOME_PATHVAR=
    ksl::envAppend SOME_PATHVAR /usr/dinosaur
    assert_equals "/usr/dinosaur" "${SOME_PATHVAR}"

    # appending to existing var already with content
    SOME_PATHVAR="/usr/dinosaur"
    ksl::envAppend SOME_PATHVAR /usr/phylum
    assert_equals "/usr/dinosaur:/usr/phylum" "${SOME_PATHVAR}"

    # appending to existing var already with content
    SOME_PATHVAR="/usr/dinosaur"
    ksl::envAppend SOME_PATHVAR /usr/phylum
    assert_equals "/usr/dinosaur:/usr/phylum" "${SOME_PATHVAR}"

    # appending to existing var with trailing colon
    SOME_PATHVAR="/usr/dinosaur:"
    ksl::envAppend SOME_PATHVAR /usr/phylum
    assert_equals "/usr/dinosaur:/usr/phylum" "${SOME_PATHVAR}"

    # appending disallowed duplicate front content
    SOME_PATHVAR="/usr/dinosaur:/usr/phylum"
    ksl::envAppend SOME_PATHVAR /usr/dinosaur
    assert_equals "/usr/dinosaur:/usr/phylum" "${SOME_PATHVAR}"

    # appending disallowed duplicate end content
    SOME_PATHVAR="/usr/dinosaur:/usr/phylum"
    ksl::envAppend SOME_PATHVAR /usr/phylum
    assert_equals "/usr/dinosaur:/usr/phylum" "${SOME_PATHVAR}"

    # appending allowing duplicates
    SOME_PATHVAR="/usr/bin:/usr/local"
    ksl::envAppend -a SOME_PATHVAR /usr/local
    assert_equals "/usr/bin:/usr/local:/usr/local" "${SOME_PATHVAR}"

    # appending to existing var with extra ":" in content
    SOME_PATHVAR="/usr/dinosaur:/usr/phylum"
    ksl::envAppend SOME_PATHVAR ":/usr/games:"
    assert_equals "/usr/dinosaur:/usr/phylum:/usr/games" "${SOME_PATHVAR}"

    # appending with file check existance
    SOME_PATHVAR="/usr/dinosaur:/usr/phylum"
    touch /tmp/envtest.bash
    ksl::envAppend SOME_PATHVAR -f /tmp/envtest.bash
    assert_equals "/usr/dinosaur:/usr/phylum:/tmp/envtest.bash" "${SOME_PATHVAR}"
    rm /tmp/envtest.bash

    # appending with file check existence, but file doesn't exist
    SOME_PATHVAR="/usr/dinosaur:/usr/phylum"
    rm -f /tmp/envtest.bash # ensure not there
    ksl::envAppend -f SOME_PATHVAR /tmp/envtest.bash
    assert_equals "/usr/dinosaur:/usr/phylum" "${SOME_PATHVAR}"
}

# -----------------------------------------------------------

test_envPrepend()
{
    # test insufficient args - no args
    assert_fails "ksl::envPrepend"

    # test insufficient args - 1 arg
    assert_fails "ksl::envPrepend '/usr/dinosaur'"

    # test two empty args
    assert_fails "ksl::envPrepend '' ''"

    # test empty args
    assert_fails "ksl::envPrepend '/usr/dinosaur' ''"

    # test empty args
    assert_fails "ksl::envPrepend '' '/usr/dinosaur'"

    # prepending to an unset var
    unset SOME_UNSETVAR
    ksl::envPrepend SOME_UNSETVAR /usr/dinosaur
    assert_equals "/usr/dinosaur" "${SOME_UNSETVAR}"
    unset SOME_UNSETVAR

    # prepending to a null/empty var
    SOME_PATHVAR=
    ksl::envPrepend SOME_PATHVAR /usr/dinosaur
    assert_equals "/usr/dinosaur" "${SOME_PATHVAR}"

    # prepending to existing var already with content
    SOME_PATHVAR="/usr/dinosaur"
    ksl::envPrepend SOME_PATHVAR /usr/phylum
    assert_equals "/usr/phylum:/usr/dinosaur" "${SOME_PATHVAR}"

    # prepending to existing var with trailing colon
    SOME_PATHVAR="/usr/dinosaur:"
    ksl::envPrepend SOME_PATHVAR /usr/phylum
    assert_equals "/usr/phylum:/usr/dinosaur" "${SOME_PATHVAR}"

    # appending disallowed duplicate front content
    SOME_PATHVAR="/usr/dinosaur:/usr/phylum"
    ksl::envPrepend  SOME_PATHVAR /usr/dinosaur
    assert_equals "/usr/dinosaur:/usr/phylum" "${SOME_PATHVAR}"

    # appending disallowed duplicate end content
    SOME_PATHVAR="/usr/dinosaur:/usr/phylum"
    ksl::envPrepend SOME_PATHVAR /usr/phylum
    assert_equals "/usr/dinosaur:/usr/phylum" "${SOME_PATHVAR}"

    # prepending allowing duplicates
    SOME_PATHVAR="/usr/bin:/usr/local"
    ksl::envPrepend -a SOME_PATHVAR /usr/local
    assert_equals "/usr/local:/usr/bin:/usr/local" "${SOME_PATHVAR}"

    # prepending to existing var with extra ":" in content
    SOME_PATHVAR="/usr/dinosaur:/usr/phylum"
    ksl::envPrepend SOME_PATHVAR ":/usr/games:"
    assert_equals "/usr/games:/usr/dinosaur:/usr/phylum" "${SOME_PATHVAR}"

    # appending with file check existance
    SOME_PATHVAR="/usr/dinosaur:/usr/phylum"
    touch /tmp/envtest.bash
    ksl::envPrepend SOME_PATHVAR -f /tmp/envtest.bash
    assert_equals "/tmp/envtest.bash:/usr/dinosaur:/usr/phylum" "${SOME_PATHVAR}"
    rm /tmp/envtest.bash

    # prepending with file check existence, but file doesn't exist
    SOME_PATHVAR="/usr/dinosaur:/usr/phylum"
    rm -f /tmp/envtest.bash # ensure not there
    ksl::envPrepend SOME_PATHVAR -f /tmp/envtest.bash
    assert_equals "/usr/dinosaur:/usr/phylum" "${SOME_PATHVAR}"
}

# -----------------------------------------------------------

test_envDelete()
{
    # test insufficient args - no args
    assert_fails "ksl::envDelete"

    # test insufficient args - 1 arg
    assert_fails "ksl::envDelete '/usr/dinosaur'"

    # test two empty args
    assert_fails "ksl::envDelete '' ''"

    # test empty args
    assert_fails "ksl::envDelete '/usr/dinosaur' ''"

    # test empty args
    assert_fails "ksl::envDelete '' '/usr/dinosaur'"

    # deleting from an unset var
    unset SOME_UNSETVAR
    ksl::envDelete SOME_UNSETVAR /usr/dinosaur
    assert_equals "" "${SOME_UNSETVAR}"
    unset SOME_UNSETVAR

    # deleting from an null/empty var
    SOME_PATHVAR=
    ksl::envDelete SOME_PATHVAR /usr/dinosaur
    assert_equals "" "${SOME_PATHVAR}"

    # deleting from existing var no matching content
    SOME_PATHVAR="/usr/dinosaur"
    ksl::envDelete SOME_PATHVAR /usr/gabage
    assert_equals "/usr/dinosaur" "${SOME_PATHVAR}"

    # deleting from existing var matching content
    SOME_PATHVAR="/usr/dinosaur"
    ksl::envDelete SOME_PATHVAR /usr/dinosaur
    assert_equals "" "${SOME_PATHVAR}"

    # deleting from existing var with trailing colon
    SOME_PATHVAR="/usr/dinosaur:"
    ksl::envDelete SOME_PATHVAR /usr/dinosaur
    assert_equals "" "${SOME_PATHVAR}"

    # deleting from var at front
    SOME_PATHVAR="/usr/dinosaur:/usr/phylum:/usr/games"
    ksl::envDelete SOME_PATHVAR /usr/dinosaur
    assert_equals "/usr/phylum:/usr/games" "${SOME_PATHVAR}"

    # deleting from var in middle
    SOME_PATHVAR="/usr/dinosaur:/usr/phylum:/usr/games"
    ksl::envDelete SOME_PATHVAR /usr/phylum
    assert_equals "/usr/dinosaur:/usr/games" "${SOME_PATHVAR}"

    # deleting from var at end
    SOME_PATHVAR="/usr/dinosaur:/usr/phylum:/usr/games"
    ksl::envDelete  SOME_PATHVAR /usr/games
    assert_equals "/usr/dinosaur:/usr/phylum" "${SOME_PATHVAR}"

    # deleting from var with extra ":" in content
    SOME_PATHVAR="/usr/dinosaur:/usr/phylum:/usr/games"
    ksl::envDelete SOME_PATHVAR ":/usr/phylum:"
    assert_equals "/usr/dinosaur:/usr/games" "${SOME_PATHVAR}"
}

# -----------------------------------------------------------

test_ksl::envDeleteFirst()
{
    # test insufficient args - no args
    assert_fails "ksl::envDeleteFirst"

    # test empty args
    assert_fails "ksl::envDeleteFirst ''"

    # test deleting from an unset var
    unset SOME_UNSETVAR
    ksl::envDeleteFirst SOME_UNSETVAR
    assert_equals "" "${SOME_UNSETVAR}"
    unset SOME_UNSETVAR

    # test deleting from null/empty var
    SOME_PATHVAR=
    ksl::envDeleteFirst SOME_PATHVAR
    assert_equals "" "${SOME_PATHVAR}"

    # deleting first fragment leaving empty string
    SOME_PATHVAR="/usr/dinosaur"
    ksl::envDeleteFirst SOME_PATHVAR
    assert_equals "" "${SOME_PATHVAR}"

    # deleting first fragment with multiple entries
    SOME_PATHVAR="/usr/dinosaur:/usr/phylum:/usr/games"
    ksl::envDeleteFirst SOME_PATHVAR
    assert_equals "/usr/phylum:/usr/games" "${SOME_PATHVAR}"

    # deleting first fragment with spaces
    SOME_PATHVAR="/usr folder:/bin/dinosaur"
    ksl::envDeleteFirst SOME_PATHVAR
    assert_equals "/bin/dinosaur" "${SOME_PATHVAR}"
}

# -----------------------------------------------------------

test_ksl::envDeleteLast()
{
    # test insufficient args - no args
    assert_fails "ksl::envDeleteLast"

    # test empty args
    assert_fails "ksl::envDeleteFirst ''"

    # test deleting from an unset var
    unset SOME_UNSETVAR
    ksl::envDeleteLast SOME_UNSETVAR
    assert_equals "" "${SOME_UNSETVAR}"
    unset SOME_UNSETVAR

    # test deleting from null/empty var
    SOME_PATHVAR=
    ksl::envDeleteLast SOME_PATHVAR
    assert_equals "" "${SOME_PATHVAR}"

    # deleting last fragment leaving empty string
    SOME_PATHVAR="/usr/dinosaur"
    ksl::envDeleteLast SOME_PATHVAR
    assert_equals "" "${SOME_PATHVAR}"

    # deleting Last fragment with multiple entries
    SOME_PATHVAR="/usr/dinosaur:/usr/phylum:/usr/games"
    ksl::envDeleteLast SOME_PATHVAR
    assert_equals "/usr/dinosaur:/usr/phylum" "${SOME_PATHVAR}"
}

# -----------------------------------------------------------

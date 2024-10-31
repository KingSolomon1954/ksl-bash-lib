#!/usr/bin/env bash

source ${KSL_BASH_LIB}/libFiles.bash

# -----------------------------------------------------------

test_baseName()
{
    assert_equals "music"   "$(ksl::baseName 'music')"
    assert_equals "music"   "$(ksl::baseName 'music/')"
    assert_equals "music"   "$(ksl::baseName '/music/')"
    assert_equals "beatles" "$(ksl::baseName 'music/beatles/')"
}

# -----------------------------------------------------------

test_dirName()
{
    assert_equals "."       "$(ksl::dirName 'music')"
    assert_equals "."       "$(ksl::dirName 'music/')"
    assert_equals "music"   "$(ksl::dirName 'music/beatles')"
    assert_equals "music"   "$(ksl::dirName 'music/beatles/')"
    assert_equals "/music"  "$(ksl::dirName '/music/beatles/')"
    assert_equals "./music" "$(ksl::dirName './music/beatles/')"
    
#    assert_fail "envp.append"
}

# -----------------------------------------------------------

test_scriptDir()
{
    local tmp=$(ksl::scriptName)
    assert_not_equals "0" "${#tmp}"  # Best we can do
}

# -----------------------------------------------------------

test_scriptName()
{
    assert_equals "bash_unit" "$(ksl::scriptName)"
}

# -----------------------------------------------------------

test_suffix()
{
    # echo
    # echo "1 barrier$(ksl::suffix 'music')barrier"
    # echo "2 barrier$(ksl::suffix 'music.')barrier"
    # echo "3 barrier$(ksl::suffix '.music')barrier"
    # echo "4 barrier$(ksl::suffix '.music.')barrier"
    # echo "5 barrier$(ksl::suffix '../music.')barrier"
    # echo "6 barrier$(ksl::suffix '.')barrier"
    # echo "7 barrier$(ksl::suffix '')barrier"
    # echo "8 barrier$(ksl::suffix './')barrier"
    # echo "9 barrier$(ksl::suffix './//')barrier"
    # echo "10 barrier$(ksl::suffix './.')barrier"
    # echo "11 barrier$(ksl::suffix './music/album.flac')barrier"
    # echo "12 barrier$(ksl::suffix '/music.flac')barrier"
    # echo "13 barrier$(ksl::suffix 'music.country/../beatles')barrier"

    assert_equals ""        "$(ksl::suffix 'music')"
    assert_equals "."       "$(ksl::suffix 'music.')"
    assert_equals ".music"  "$(ksl::suffix '.music')"
    assert_equals "."       "$(ksl::suffix '.music.')"
    assert_equals ""        "$(ksl::suffix './music')"
    assert_equals "."       "$(ksl::suffix '../music.')"
    assert_equals ".music"  "$(ksl::suffix './.music')"
    assert_equals "."       "$(ksl::suffix '.')"
    assert_equals ""        "$(ksl::suffix '')"
    assert_equals ""        "$(ksl::suffix './')"
    assert_equals ""        "$(ksl::suffix './//')"
    assert_equals "."       "$(ksl::suffix './.')"
    assert_equals ".flac"   "$(ksl::suffix './music/album.flac')"
    assert_equals ".flac"   "$(ksl::suffix '/music.flac')"
    assert_equals ""        "$(ksl::suffix 'music.country/../beatles')"
}

# -----------------------------------------------------------

    

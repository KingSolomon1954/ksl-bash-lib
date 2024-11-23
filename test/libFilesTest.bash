#!/usr/bin/env bash

source "${KSL_BASH_LIB}"/libFiles.bash

# -----------------------------------------------------------

test_baseName()
{
    assert_fails "ksl::baseName 2>/dev/null"
    assert_equals ""        "$(ksl::baseName '')"
    assert_equals ""        "$(ksl::baseName '////')"
    assert_equals " "       "$(ksl::baseName ' ')"
    assert_equals "music"   "$(ksl::baseName 'music')"
    assert_equals "music"   "$(ksl::baseName 'music/')"
    assert_equals "music"   "$(ksl::baseName '/music/')"
    assert_equals "beatles" "$(ksl::baseName 'music/beatles/')"
    assert_equals "beatles" "$(ksl::baseName 'music/beatles////')"
    assert_equals "beatles" "$(ksl::baseName '///music////beatles////')"

}

# -----------------------------------------------------------

test_dirName()
{
    assert_fails "ksl::dirName 2>/dev/null"
    assert_equals "."              "$(ksl::dirName '')"
    assert_equals "."              "$(ksl::dirName 'music')"
    assert_equals "."              "$(ksl::dirName 'music/')"
    assert_equals "."              "$(ksl::dirName 'music///')"
    assert_equals "/"              "$(ksl::dirName '/')"
    assert_equals "/"              "$(ksl::dirName '////')"
    assert_equals "/"              "$(ksl::dirName '/music')"
    assert_equals "/"              "$(ksl::dirName '/music///')"
    assert_equals "music"          "$(ksl::dirName 'music/beatles')"
    assert_equals "music"          "$(ksl::dirName 'music/beatles/')"
    assert_equals "/music"         "$(ksl::dirName '/music/beatles/')"
    assert_equals "./music"        "$(ksl::dirName './music/beatles/')"
    assert_equals "/music/beatles" "$(ksl::dirName '/music/beatles/yellow-submarine.flak')"
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

test_notSuffix()
{
    assert_equals "music"        "$(ksl::notSuffix 'music')"    
    assert_equals "music"        "$(ksl::notSuffix '/home/media/music')"    
    assert_equals "music"        "$(ksl::notSuffix '/.home/media/music')"    
    assert_equals ""             "$(ksl::notSuffix '.flak')"
    assert_equals ".music"       "$(ksl::notSuffix '.music.flak')"
    assert_equals "music"        "$(ksl::notSuffix 'music.flak')"
    assert_equals ".music"       "$(ksl::notSuffix '.music.flak')"
    assert_equals "music"        "$(ksl::notSuffix '/home/media/music.flak')"
    assert_equals "music"        "$(ksl::notSuffix '/home/.media/music.flak')"
    assert_equals ".music"       "$(ksl::notSuffix '/home/.media/.music.flak')"
    assert_equals "music"        "$(ksl::notSuffix 'music.flak/')"
    assert_equals "music"        "$(ksl::notSuffix 'music.flak///')"
    assert_equals "music"        "$(ksl::notSuffix '///home/media///music.flak///')"
}

# -----------------------------------------------------------
    

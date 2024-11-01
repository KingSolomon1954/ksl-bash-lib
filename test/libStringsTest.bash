#!/usr/bin/env bash

source "${KSL_BASH_LIB}"/libStrings.bash

# -----------------------------------------------------------

test_strlen()
{
    assert_equals "8" "$(ksl::strlen dinosaur)"      # normal string
    assert_equals "9" "$(ksl::strlen 'dino saur')"   # normal string
    assert_equals "0" "$(ksl::strlen )"              # test no args
    assert_equals "0" "$(ksl::strlen '')"            # test zero length string

    local DINO="dinosaur"
    assert_equals "8" "$(ksl::strlenR DINO)"         # normal string
    DINO="dino saur"
    assert_equals "9" "$(ksl::strlenR DINO)"         # normal string
    assert_equals "0" "$(ksl::strlenR )"             # test no args
    assert_equals "0" "$(ksl::strlenR EMPTY)"        # test empty named string
    assert_equals "0" "$(ksl::strlenR "")"           # test zero length string
}

test_isEmpty()
{
    assert "ksl::isEmpty ''"
    assert_fails "ksl::isEmpty 'dinosaur' "
    assert "ksl::isEmpty "

    local DINO="dinosaur"
    assert "ksl::isEmptyR '' "
    assert_fails "ksl::isEmptyR 'DINO' "
    assert "ksl::isEmptyR "
    DINO=""
    assert "ksl::isEmptyR 'DINO' "
    DINO=
    assert "ksl::isEmptyR 'DINO' "
}

test_startsWith()
{
    assert "ksl::startsWith 'rolling thunder' 'rolling'"
    assert_fails "ksl::startsWith 'rolling thunder' 'thunder'"
    assert_fails "ksl::startsWith 'rolling thunder' ''"
    assert_fails "ksl::startsWith '' 'thunder'"
    assert_fails "ksl::startsWith '' ''"
    assert_fails "ksl::startsWith"
}

test_endsWith()
{
    assert "ksl::endsWith 'rolling thunder' 'thunder'"
    assert_fails "ksl::endsWith 'rolling thunder' 'rolling'"
    assert_fails "ksl::endsWith 'rolling thunder' ''"
    assert_fails "ksl::endsWith '' 'thunder'"
    assert_fails "ksl::endsWith '' ''"
    assert_fails "ksl::endsWith"
}

test_toLower()
{
    assert_equals "rolling thunder" "$(ksl::toLower 'ROLLING Thunder')"
    assert_equals "rolling thunder" "$(ksl::toLower 'rolling thunder')"
    assert_equals "" "$(ksl::toLower '')"
}

test_toUpper()
{
    assert_equals "ROLLING THUNDER" "$(ksl::toUpper 'rolling thunder')"
    assert_equals "ROLLING THUNDER" "$(ksl::toUpper 'ROLLING THUNDER')"
    assert_equals "" "$(ksl::toUpper '')"
}

test_capitalize()
{
    assert_equals "Rolling Thunder" "$(ksl::capitalize 'rolling Thunder')"
    assert_equals "Rolling thunder" "$(ksl::capitalize 'Rolling thunder')"
    assert_equals "" "$(ksl::capitalize '')"
}

test_trimLeft()
{
    assert_equals " Rolling Thunder" "$(ksl::trimLeft 'aabbcc Rolling Thunder' 'aabbcc')"
    assert_equals "Rolling Thunder"  "$(ksl::trimLeft '      Rolling Thunder')"
    assert_equals "Rolling Thunder"  "$(ksl::trimLeft 'Rolling Thunder' 'no-match')"
}

test_trimRight()
{
    assert_equals "Rolling Thunder " "$(ksl::trimRight 'Rolling Thunder aabbcc' 'aabbcc')"
    assert_equals "Rolling Thunder"  "$(ksl::trimRight 'Rolling Thunder      ')"
    assert_equals "Rolling thunder"  "$(ksl::trimRight 'Rolling thunder' 'no-match')"
}

test_trimWhitespace()
{
    assert_equals "Rolling Thunder" "$(ksl::trimWhitespace '         Rolling Thunder         ')"
    assert_equals "Rolling Thunder" "$(ksl::trimWhitespace '         Rolling Thunder')"
    assert_equals "Rolling Thunder" "$(ksl::trimWhitespace 'Rolling Thunder          ')"
    assert_equals "Rolling Thunder" "$(ksl::trimWhitespace 'Rolling Thunder')"
}

test_contains()
{
    assert "ksl::contains '0123456789' '123' "
    assert "ksl::contains '0123456789' '5' "
    assert "ksl::contains '55555' '5' "
    assert_fails "ksl::contains '0123456789' '000' "
    assert_fails "ksl::contains '0123456789' 'a' "
    assert_fails "ksl::contains '0123456789' 'a' "
    assert_fails "ksl::contains '0123456789' '' "
    assert_fails "ksl::contains '' 'abc' "
    assert_fails "ksl::contains '' '' "
}

test_isAlphNum()
{
    assert "ksl::isAlphNum '12345' "
    assert "ksl::isAlphNum 'abcde' "
    assert "ksl::isAlphNum '1a2b3c4d5e' "
    assert_fails "ksl::isAlphNum "
    assert_fails "ksl::isAlphNum '#%@' "
    assert_fails "ksl::isAlphNum 'I am Spartacus' "
}

test_isAlpha()
{
    assert "ksl::isAlpha 'abcde' "
    assert_fails "ksl::isAlpha "
    assert_fails "ksl::isAlpha '12345'"
    assert_fails "ksl::isAlpha 'a2b3c4d5e'"
    assert_fails "ksl::isAlpha '#%@'"
    assert_fails "ksl::isAlpha 'I am Spartacus'"
}

test_isAscii()
{
    # assert "isAscii '\20'"
    assert_fails "ksl::isAscii 'abcde'"
    assert_fails "ksl::isAscii '12345'"
    assert_fails "ksl::isAscii"
    assert_fails "ksl::isAscii '#%@'"
    assert_fails "ksl::isAscii 'I am Spartacus'"
}

test_isBlank()
{
    local x="           "
    assert "ksl::isBlank '$x'"
    assert_fails "ksl::isBlank 'abcde'"
    assert_fails "ksl::isBlank '12345'"
    assert_fails "ksl::isBlank"
    assert_fails "ksl::isBlank '#%@'"
    assert_fails "ksl::isBlank 'I am Spartacus'"
}

test_isCntrl()
{
    local x=$'\e\a\t\r\n'
    assert "ksl::isCntrl '$x'"
    assert_fails "ksl::isCntrl 'abcde'"
    assert_fails "ksl::isCntrl '12345'"
    assert_fails "ksl::isCntrl"
    assert_fails "ksl::isCntrl '#%@'"
    assert_fails "ksl::isCntrl 'I am Spartacus'"
}

test_isDigit()
{
    assert "ksl::isDigit '12345'"
    assert "ksl::isDigit '0'"
    assert_fails "ksl::isDigit"
    assert_fails "ksl::isDigit '-12345'"
    assert_fails "ksl::isDigit '+12345'"
    assert_fails "ksl::isDigit '#%@'"
    assert_fails "ksl::isDigit 'I am Spartacus'"
}

test_isGraph()
{
    assert "ksl::isGraph '12345'"
    assert "ksl::isGraph '0'"
    assert "ksl::isGraph '-12345'"
    assert "ksl::isGraph '+12345'"
    assert "ksl::isGraph '#%@'"
    assert_fails "ksl::isGraph"
    assert_fails "ksl::isGraph '\t   '"
    assert_fails "ksl::isGraph 'I am Spartacus'"
}

test_isInteger()
{
    # valid integers
    assert "ksl::isInteger '12345'"
    assert "ksl::isInteger '+12345'"
    assert "ksl::isInteger '-12345'"
    assert "ksl::isInteger '0'"

    # bad integers
    assert_fails "ksl::isInteger "
    assert_fails "ksl::isInteger '+'"
    assert_fails "ksl::isInteger '-'"
    assert_fails "ksl::isInteger '.'"
    assert_fails "ksl::isInteger 'dinosaur'"
    assert_fails "ksl::isInteger '+d'"
    assert_fails "ksl::isInteger '123a45'"
    assert_fails "ksl::isInteger '123-45'"
    assert_fails "ksl::isInteger '123+45'"
    assert_fails "ksl::isInteger '123.45'"
    assert_fails "ksl::isInteger '#%@'"
    assert_fails "ksl::isInteger 'I am Spartacus'"
}

test_isNumber()
{
    # valid numerics
    assert "ksl::isNumber '1'"
    assert "ksl::isNumber '12345'"
    assert "ksl::isNumber '+12345'"
    assert "ksl::isNumber '-12345'"
    assert "ksl::isNumber '0'"
    assert "ksl::isNumber '0.0'"
    assert "ksl::isNumber '+0.0'"
    assert "ksl::isNumber '+.0'"
    assert "ksl::isNumber '-.0'"
    assert "ksl::isNumber '+42.250'"
#   assert "ksl::isNumber '+42.250E4'"
#   assert "ksl::isNumber '+42.250+E4'"
#   assert "ksl::isNumber '-2.250-E4'"
#   assert "ksl::isNumber '250E4'"
#   assert "ksl::isNumber '250e4'"

    # bad numerics
    assert_fails "ksl::isNumber "
    assert_fails "ksl::isNumber '+'"
    assert_fails "ksl::isNumber '-'"
    assert_fails "ksl::isNumber '.'"
    assert_fails "ksl::isNumber 'dinosaur'"
    assert_fails "ksl::isNumber '+d'"
#   assert_fails "ksl::isNumber '123a45'"
#   assert_fails "ksl::isNumber '123-45'"
#   assert_fails "ksl::isNumber '123+45'"
#   assert_fails "ksl::isNumber '123.45'"
    assert_fails "ksl::isNumber '#%@' "
    assert_fails "ksl::isNumber 'I am Spartacus' "
}

test_isLower()
{
    assert "ksl::isLower 'iamspartacus'"
    assert_fails "ksl::isLower 'i am spartacus'"
    assert_fails "ksl::isLower 'I am Spartacus'"
    assert_fails "ksl::isLower '12345'"
    assert_fails "ksl::isLower '0'"
    assert_fails "ksl::isLower '#%@'"
    assert_fails "ksl::isLower"
}

test_isPrint()
{
    assert "ksl::isPrint '12345'"
    assert "ksl::isPrint '0'"
    assert "ksl::isPrint '-12345'"
    assert "ksl::isPrint '+12345'"
    assert "ksl::isPrint '#%@'"
    assert "ksl::isPrint 'I am Spartacus'"
    assert_fails "ksl::isPrint"
    local x=$'\e\a\t\r\n'
    assert_fails 'isPrint "$x"'
}

test_isPunct()
{
    assert "ksl::isPunct '!,.;:'"
    assert_fails "ksl::isPunct '12345'"
    assert_fails "ksl::isPunct '0'"
    assert_fails "ksl::isPunct '-12345'"
    assert_fails "ksl::isPunct '+12345'"
    assert_fails "ksl::isPunct"
    assert_fails "ksl::isPunct '\t   '"
    assert_fails "ksl::isPunct 'I am Spartacus'"
}

test_isSpace()
{
    local x=$'\r\t\n   '
    assert 'ksl::isSpace "$x"'
    assert_fails "ksl::isSpace '12345'"
    assert_fails "ksl::isSpace '0'"
    assert_fails "ksl::isSpace '-12345'"
    assert_fails "ksl::isSpace '+12345'"
    assert_fails "ksl::isSpace"
    assert_fails "ksl::isSpace 'I am Spartacus'"
}

test_isUpper()
{
    assert "ksl::isUpper 'IAMSPARTACUS'"
    assert_fails "ksl::isUpper 'I AM SPARTACUS'"
    assert_fails "ksl::isUpper 'I am Spartacus'"
    assert_fails "ksl::isUpper '12345'"
    assert_fails "ksl::isUpper '0'"
    assert_fails "ksl::isUpper '#%@'"
    assert_fails "ksl::isUpper"
}

# Commented out until isWord is debugged.
#
# test_isWord()
# {
#     assert "isWord 'hello'"
#     assert "isWord 'a1_b2345'"
#     assert "isWord 'R2_D2' "
#     assert "isWord '0' "
#     assert_fails "isWord 'I AM SPARTACUS' "
#     assert_fails "isWord 'I am Spartacus' "
#     assert_fails "isWord '#%@' "
#     assert_fails "isWord "
#     assert_fails "isWord 'I-am-Spartacus' "
# }

test_isXdigit()
{
    assert "ksl::isXdigit '0123456789abcdefABCDEF'"
    assert "ksl::isXdigit '0' "
    assert_fails "ksl::isXdigit 'I AM SPARTACUS'"
    assert_fails "ksl::isXdigit 'I am Spartacus'"
    assert_fails "ksl::isXdigit '#%@'"
    assert_fails "ksl::isXdigit"
}

# -----------------------------------------------------------

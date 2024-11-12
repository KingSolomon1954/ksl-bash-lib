# -----------------------------------------------------------
#
# @name libStrings
# @brief Functions to process shell strings.
#
# @description
# Functions to process and manipulate shell strings.
#
# Contains the following:
#
#     * ksl::strlen()
#     * ksl::strlenR()
#     * ksl::isEmpty()
#     * ksl::isEmptyR()
#     * ksl::startsWith()
#     * ksl::endsWith()
#     * ksl::trimRight()
#     * ksl::trimLeft()
#     * ksl::trimWhitespace()
#     * ksl::contains()
#     * ksl::toLower()
#     * ksl::toUpper()
#     * ksl::capitalize()
#     * ksl::isAlphNum()
#     * ksl::isAlpha()
#     * ksl::# isAscii()
#     * ksl::isBlank()
#     * ksl::isCntrl()
#     * ksl::isDigit()
#     * ksl::isGraph()
#     * ksl::isLower()
#     * ksl::isInteger()
#     * ksl::isPrint()
#     * ksl::isPunct()
#     * ksl::isSpace()
#     * ksl::isUpper()
#     * ksl::# isWord()
#     * ksl::isXdigit()
#
# -----------------------------------------------------------

# Avoid double inclusion
[[ -v libStringImported ]] && [[ "$1" != "-f" ]] && return
libStringImported=true

# -----------------------------------------------------------
#
# Returns the number of characters in string.
# Pass string by value. See also strLenR() next.
#
# Example:
#     x=$(strlen "dinosaur")
#
ksl::strlen ()
{
    echo ${#1}
}

# -----------------------------------------------------------
#
# Returns the number of characters held by the named variable.
# Pass string by reference.
#
# Example:
#     ANIMAL=dinosaur
#     x=$(strlenR ANIMAL)
#     results in x = 8
#
ksl::strlenR ()
{
    [[ -z "${1:-}" ]] && echo 0 && return
    local -nr s=$1
    echo ${#s}
}

# -----------------------------------------------------------
#
# Returns true if string is empty, otherwise false
# Pass string by value. See also isEmptyR() below.
#
# Example:
#     if isEmpty s1; then
#
ksl::isEmpty ()
{
    [[ -z "${1}" ]]
}

# -----------------------------------------------------------
#
# Returns true if string is empty, otherwise false
# Pass string by reference. See also isEmpty() above.
#
# Example:
#     if isEmpty HOME; then
#
#
ksl::isEmptyR ()
{
    [[ -z "${1:-}" ]] && return     # empty or no arg
    local -nr s=$1
    [[ ${#s} == 0 ]]
}

# -----------------------------------------------------------
#
# Return true if $1 string starts with $2 string
# digits.
#
ksl::startsWith()
{
    [[ -z "${2}" ]] && return 1
    [[ $1 =~ ^"$2" ]]
}

# -----------------------------------------------------------
#
# Return true if $1 string ends with $2 string
# digits.
#
ksl::endsWith()
{
    [[ -z "${2}" ]] && return 1
    [[ $1 =~ "$2"$ ]]
}

# -----------------------------------------------------------
#
# Return copy of $1 with the matching string in $2 removed
# from the front of $1. If $2 is not given then defaults to
# removing whitespace. $2 argument is a prefix.
#
ksl::trimLeft()
{
    local s=${1}
    if (( $# < 2 )); then
      echo "${s#"${s%%[![:space:]]*}"}"
    else
      echo "${s##"$2"}"
    fi
}

# -----------------------------------------------------------
#
# Return copy of $1 with the matching string in $2 removed
# from the end of $1. If $2 is not given then defaults to
# removing whitespace. $2 argument is a prefix.
#
ksl::trimRight()
{
    local s=${1}
    if (( $# < 2 )); then
        echo "${s%"${s##*[![:space:]]}"}"
    else
      echo "${s%%"$2"}"
    fi
}

# -----------------------------------------------------------
#
# Return copy of $1 with the matching string in $2 removed
# from the end of $1. If $2 is not given then defaults to
# removing whitespace. $2 argument is a prefix.
#
ksl::trimWhitespace()
{
    local s
    s=$(ksl::trimRight "${1}")
    ksl::trimLeft "${s}"
}

# -----------------------------------------------------------
#
# Returns true if $1 string contains the string in $2.
#
ksl::contains()
{
    [[ -z "$2" ]] && return 1
    [[ "$1" == *$2* ]]
}

# -----------------------------------------------------------
#
# Return copy of $1 string converted to lower case.
#
ksl::toLower()
{
    echo "${1,,}"
}

# -----------------------------------------------------------
#
# Return copy of $1 string converted to upper case
#
ksl::toUpper()
{
    echo "${1^^}"
}

# -----------------------------------------------------------
#
# Return copy of $1 string with first character capitalized and
# the rest left alone.
#
ksl::capitalize()
{
    echo "${1^}"
}

# -----------------------------------------------------------
#
# Return true if all characters in the string are alphanumeric as
# defined by POSIX standard.
#
ksl::isAlphNum()
{
    local pat='^[[:alnum:]]+$'
    [[ ${1} =~ ${pat} ]]
}

# -----------------------------------------------------------
    #
# Return true if all characters in the string are alpha as defined by
# POSIX standard.
#
ksl::isAlpha()
{
    local pat='^[[:alpha:]]+$'
    [[ ${1} =~ ${pat} ]]
}

# -----------------------------------------------------------
#
# Return true if all characters in the string are ASCII chars as defined
# by POSIX standard.
#
# ASCII is not currently working. Need to investigate.
#
ksl::isAscii()
{
    local pat='^[[:ascii:]]+$'
    [[ ${1} =~ ${pat} ]]
}

# -----------------------------------------------------------
#
# Return true if all characters in the string are blank as
# defined by POSIX standard.
#
ksl::isBlank()
{
    local pat='^[[:blank:]]+$'
    [[ ${1} =~ ${pat} ]]
}

# -----------------------------------------------------------
#
# Return true if all characters in the string are control characters as
# defined by POSIX standard.
#
ksl::isCntrl()
{
    local pat='^[[:cntrl:]]+$'
    [[ ${1} =~ ${pat} ]]
}

# -----------------------------------------------------------
#
# Return true if all characters in the string are digits as defined by
# POSIX standard. Note that "+" "-" "." are not digits.
#
ksl::isDigit()
{
    local pat='^[[:digit:]]+$'
    [[ ${1} =~ ${pat} ]]
}

# -----------------------------------------------------------
#
# Return true if all characters in the string are in the graph class
# (displayable on a screen) as defined by POSIX standard.
#
ksl::isGraph()
{
    local pat='^[[:graph:]]+$'
    [[ ${1} =~ ${pat} ]]
}

# -----------------------------------------------------------
#
# Return true if all characters in the string are lowercase as
# defined by POSIX standard.
#
ksl::isLower()
{
    local pat='^[[:lower:]]+$'
    [[ ${1} =~ ${pat} ]]
}

# -----------------------------------------------------------
#
# Return true if the string forms a valid integer meaning all digits
# with an optional preceding +/-. Does not check for length.
#
ksl::isInteger()
{
    local pat='^[+-]?[[:digit:]]+$'
    [[ ${1} =~ ${pat} ]]
}

# -----------------------------------------------------------
#
# Return true if the string forms a valid number
#
ksl::isNumber()
{
    ksl::isInteger "$1" || ksl::isFloat "$1"
}

# -----------------------------------------------------------
#
# Return true if the string forms a valid number
#
ksl::isFloat()
{
    [[ ${1:-} =~ ^[+-]?[0-9]*\.?[0-9]+$ ]]
}

# -----------------------------------------------------------
#
# Return true if all characters in the string are printable as
# defined by POSIX standard.
#
ksl::isPrint()
{
    local pat='^[[:print:]]+$'
    [[ ${1} =~ ${pat} ]]
}

# -----------------------------------------------------------
#
# Return true if all characters in the string are punctuations as
# defined by POSIX standard.
#
ksl::isPunct()
{
    local pat='^[[:punct:]]+$'
    [[ ${1} =~ ${pat} ]]
}

# -----------------------------------------------------------
#
# Return true if all characters in the string are spaces as
# defined by POSIX standard.
#
ksl::isSpace()
{
    local pat='^[[:space:]]+$'
    [[ ${1} =~ ${pat} ]]
}

# -----------------------------------------------------------
#
# Return true if all characters in the string are uppercase as
# defined by POSIX standard.
#
ksl::isUpper()
{
    local pat='^[[:upper:]]+$'
    [[ ${1} =~ ${pat} ]]
}

# -----------------------------------------------------------
#
# Return true if all characters in the string are considered a
# word - containing only letters, digits, and the character _.
#
# isWord is not currently working. Need to investigate.
#
ksl::isWord()
{
    local pat='^[[:word:]]+$'
    [[ ${1} =~ ${pat} ]]
}

# -----------------------------------------------------------
#
# Return true if all characters in the string are valid hexadecimal
# digits.
#
ksl::isXdigit()
{
    local pat='^[[:xdigit:]]+$'
    [[ ${1} =~ ${pat} ]]
}

# -----------------------------------------------------------

#  -- Method: str.find (sub[, start[, end]])

#  -- Method: str.find (sub[, start[, end]])
#
#      Return the lowest index in the string where substring `sub' is
#      found within the slice ‘s[start:end]’.  Optional arguments `start'
#      and `end' are interpreted as in slice notation.  Return ‘-1’ if
#      `sub' is not found.
#
#  -- Method: str.rfind (sub[, start[, end]])
#
#      Return the highest index in the string where substring `sub' is
#      found, such that `sub' is contained within ‘s[start:end]’.
#      Optional arguments `start' and `end' are interpreted as in slice
#      notation.  Return ‘-1’ on failure.
#
#
#  -- Method: str.replace (old, new[, count])
#
#      Return a copy of the string with all occurrences of substring `old'
#      replaced by `new'.  If the optional argument `count' is given, only
#      the first `count' occurrences are replaced.
#
# :docstring strtrunc:
# # Usage: strtrunc $n $s1 {$s2} {$...}
# #
# # Used by many functions like strncmp to truncate arguments for comparison.
# # Echoes the first n characters of each string s1 s2 ... on stdout.
# #:end docstring:
#
# ###;;;autoload
# function strtrunc ()
# {
#     n=$1 ; shift
#     for z; do
#         echo "${z:0:$n}"
#     done
# }
#
#
#  -- Method: str.partition (sep)
#
#      Split the string at the first occurrence of `sep', and return a
#      3-tuple containing the part before the separator, the separator
#      itself, and the part after the separator.  If the separator is not
#      found, return a 3-tuple containing the string itself, followed by
#      two empty strings.
#
#  -- Method: str.split (sep=None, maxsplit=-1)
#
#      Return a list of the words in the string, using `sep' as the
#      delimiter string.  If `maxsplit' is given, at most `maxsplit'
#      splits are done (thus, the list will have at most ‘maxsplit+1’
#      elements).  If `maxsplit' is not specified or ‘-1’, then there is
#      no limit on the number of splits (all possible splits are made).
#
# #:docstring strstr:
# # Usage: strstr s1 s2
# #
# # Strstr echoes a substring starting at the first occurrence of string s2 in
# # string s1, or nothing if s2 does not occur in the string.  If s2 points to
# # a string of zero length, strstr echoes s1.
# #:end docstring:
#
# ###;;;autoload
# function strstr ()
# {
#     # if s2 points to a string of zero length, strstr echoes s1
#     [ ${#2} -eq 0 ] && { echo "$1" ; return 0; }
#
#     # strstr echoes nothing if s2 does not occur in s1
#     case "$1" in
#     *$2*) ;;
#     *) return 1;;
#     esac
#
#     # use the pattern matching code to strip off the match and everything
#     # following it
#     first=${1/$2*/}
#
#     # then strip off the first unmatched portion of the string
#     echo "${1##$first}"
# }
#
#  -- Method: str.zfill (width)
#
#      Return a copy of the string left filled with ASCII ‘'0'’ digits to
#      make a string of length `width'.  A leading sign prefix
#      (‘'+'’/‘'-'’) is handled by inserting the padding `after' the sign
#      character rather than before.  The original string is returned if
#      `width' is less than or equal to ‘len(s)’.
#
#      For example:
#
#           >>> "42".zfill(5)
#           '00042'
#           >>> "-42".zfill(5)
#           '-0042'
#
#

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
# @description Returns the number of characters in string.
#
# Passes string by value. See also strlenR() next.
#
# @arg $1 ... the string of interest
#
# @exitcode 0 in all cases
#
# @example
#     x=$(ksl::strlen "dinosaur")
#
# @stdout the string length <p><p>![](../images/pub/divider-line.png)
#
ksl::strlen ()
{
    echo ${#1}
}

# -----------------------------------------------------------
#
# @description Returns the number of characters held in string variable.
#
# Passes string by reference. See also strlen() previous.
#
# @arg $1 ... the variable name holding a string
#
# @exitcode 0 in all cases
#
# @example
#     ANIMAL=dinosaur
#     x=$(ksl::strlenR ANIMAL)
#
# @stdout the string length <p><p>![](../images/pub/divider-line.png)
#
ksl::strlenR ()
{
    [[ -z "${1:-}" ]] && echo 0 && return
    local -nr s=$1
    echo ${#s}
}

# -----------------------------------------------------------
#
# @description Returns true if string is empty, otherwise false.
#
# Passes string by value. See also isEmptyR() next.
#
# @arg $1 ... the string of interest
#
# @exitcode 0 if string is empty (true)
# @exitcode 1 if string is non-empty (false) <p><p>![](../images/pub/divider-line.png)
#
# @example
#     ANIMAL=dinosaur
#     if ksl::isEmpty $ANIMAL; then echo "yes"; fi
#
ksl::isEmpty ()
{
    [[ -z "${1}" ]]
}

# -----------------------------------------------------------
#
# @description Returns true if string variable holds a non-zero string.
#
# Passes string by reference. See also isEmpty() previous.
#
# @arg $1 ... the variable name holding a string
#
# @exitcode 0 if string variable is empty (true)
# @exitcode 1 if string variable is non-empty (false) <p><p>![](../images/pub/divider-line.png)
#
# @example
#     ANIMAL=dinosaur
#     if ksl::isEmptyR ANIMAL; then echo "yes"; fi
#
ksl::isEmptyR ()
{
    [[ -z "${1:-}" ]] && return     # empty or no arg
    local -nr s=$1
    [[ ${#s} == 0 ]]
}

# -----------------------------------------------------------
#
# @description Returns true if $1 string starts with $2 string.
#
# @arg $1 ... the major string to test
# @arg $2 ... the minor string to look for
#
# @exitcode 0 the major string starts with the minor string (true)
# @exitcode 1 the major string does not start with the minor string (false) <p><p>![](../images/pub/divider-line.png)
#
# @example
#     ANIMAL="old dinosaur"
#     if ksl::startsWith $ANIMAL "old"; then echo "yes"; fi
#
ksl::startsWith()
{
    [[ -z "${2}" ]] && return 1
    [[ $1 =~ ^"$2" ]]
}

# -----------------------------------------------------------
#
# @description Returns true if $1 string ends with $2 string.
#
# @arg $1 ... the major string to test
# @arg $2 ... the minor string to look for
#
# @exitcode 0 the major string ends with the minor string (true)
# @exitcode 1 the major string does not end with the minor string (false) <p><p>![](../images/pub/divider-line.png)
#
# @example
#     ANIMAL="old dinosaur"
#     if ksl::endsWith $ANIMAL "dinosaur"; then echo "yes"; fi
#
ksl::endsWith()
{
    [[ -z "${2}" ]] && return 1
    [[ $1 =~ "$2"$ ]]
}

# -----------------------------------------------------------
#
# @description Returns true if $1 string contains the string in $2.
#
# @arg $1 ... the major string to test
# @arg $2 ... the minor string to look for
#
# @exitcode 0 the major string contains the minor string (true)
# @exitcode 1 the major string does not contain the minor string (false) <p><p>![](../images/pub/divider-line.png)
#
# @example
#     ANIMAL="old dinosaur"
#     if ksl::contains $ANIMAL "dinosaur"; then echo "yes"; fi
#
ksl::contains()
{
    [[ -z "$2" ]] && return 1
    [[ "$1" == *$2* ]]
}

# -----------------------------------------------------------
#
# @description Returns a copy of $1 with the matching string in $2
# removed from the front of $1.
#
# If $2 is not given then defaults to removing whitespace. $2 argument
# is a prefix.
#
# @arg $1 ... the major string to operate on
# @arg $2 ... the minor string to look for
#
# @exitcode 0 in all cases
#
# @example
#     ANIMAL="old dinosaur"
#     echo ksl::trimLeft $ANIMAL "old "
#     outputs: "dinosaur"
#
# @stdout the resulting string <p><p>![](../images/pub/divider-line.png)
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
# @description Returns a copy of $1 with the matching string in $2
# removed from the end of $1.
#
# If $2 is not given then defaults to removing whitespace. $2 argument
# is a prefix.
#
# @arg $1 ... the major string to operate on
# @arg $2 ... the minor string to look for
#
# @exitcode 0 in all cases
#
# @example
#     ANIMAL="old dinosaur"
#     echo ksl::trimRight $ANIMAL "dinosaur"
#     outputs: "old "
#
# @stdout the resulting string <p><p>![](../images/pub/divider-line.png)
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
# @description Returns a copy of $1 with the whitspace
# removed from both the start and end of $1.
#
# @arg $1 ... the string to operate on
#
# @exitcode 0 in all cases
#
# @example
#     ANIMAL="  old dinosaur\t"
#     echo ksl::trimWhitespace $ANIMAL
#     outputs: "old dinosaur"
#
# @stdout the resulting string <p><p>![](../images/pub/divider-line.png)
#
ksl::trimWhitespace()
{
    local s
    s=$(ksl::trimRight "${1}")
    ksl::trimLeft "${s}"
}

# -----------------------------------------------------------
#
# @description Returns a copy of $1 string converted to lower case.
#
# @arg $1 ... the string to operate on
#
# @exitcode 0 in all cases
#
# @example
#     ANIMAL="Old Dinosaur"
#     echo ksl::toLower $ANIMAL
#     outputs: "old dinosaur"
#
# @stdout the resulting string <p><p>![](../images/pub/divider-line.png)
#
ksl::toLower()
{
    echo "${1,,}"
}

# -----------------------------------------------------------
#
# @description Returns a copy of $1 string converted to upper case.
#
# @arg $1 ... the string to operate on
#
# @exitcode 0 in all cases
#
# @example
#     ANIMAL="Old Dinosaur"
#     echo ksl::toUpper $ANIMAL
#     outputs: "OLD DINOSAUR"
#
# @stdout the resulting string <p><p>![](../images/pub/divider-line.png)
#
ksl::toUpper()
{
    echo "${1^^}"
}

# -----------------------------------------------------------
#
# @description Returns a copy of $1 string with first character
# capitalized and the rest left alone.
#
# @arg $1 ... the string to operate on
#
# @exitcode 0 in all cases
#
# @example
#     ANIMAL="old dinosaur"
#     echo ksl::capitalize $ANIMAL
#     outputs: "Old dinosaur"
#
# @stdout the resulting string <p><p>![](../images/pub/divider-line.png)
#
ksl::capitalize()
{
    echo "${1^}"
}

# -----------------------------------------------------------
#
# @description Returns true if all characters in $1 are
# alphanumeric as defined by the POSIX standard.
#
# @arg $1 ... the string to operate on
#
# @exitcode 0 the string contains only alpha numeric characters (true)
# @exitcode 1 the string contains more than just alpha numeric characters (false) <p><p>![](../images/pub/divider-line.png)
#
# @example
#     ANIMAL="dinosaur"
#     if ksl::isAlphaNum $ANIMAL; then echo "yes"; fi
#
ksl::isAlphNum()
{
    local pat='^[[:alnum:]]+$'
    [[ ${1} =~ ${pat} ]]
}

# -----------------------------------------------------------
#
# @description Returns true if all characters in $1 are
# alpha as defined by the POSIX standard.
#
# @arg $1 ... the string to operate on
#
# @exitcode 0 the string contains only alpha characters (true)
# @exitcode 1 the string contains more than just alpha characters (false) <p><p>![](../images/pub/divider-line.png)
#
# @example
#     ANIMAL="dinosaur"
#     if ksl::isAlpha $ANIMAL; then echo "yes"; fi
#
ksl::isAlpha()
{
    local pat='^[[:alpha:]]+$'
    [[ ${1} =~ ${pat} ]]
}

# -----------------------------------------------------------
#
# @description Returns true if all characters in $1 are
# ASCII characters as defined by the POSIX standard.
#
# ASCII is not currently working. Need to investigate.
#
# @arg $1 ... the string to operate on
#
# @exitcode 0 the string contains only ASCII characters (true)
# @exitcode 1 the string contains more than just ASCII characters (false) <p><p>![](../images/pub/divider-line.png)
#
# @example
#     ANIMAL="dinosaur"
#     if ksl::isAscii $ANIMAL; then echo "yes"; fi
#
ksl::isAscii()
{
    local pat='^[[:ascii:]]+$'
    [[ ${1} =~ ${pat} ]]
}

# -----------------------------------------------------------
#
# @description Returns true if all characters in $1 are blank as
# defined by the POSIX standard.
#
# @arg $1 ... the string to operate on
#
# @exitcode 0 the string contains only blank characters (true)
# @exitcode 1 the string contains more than just blank characters (false) <p><p>![](../images/pub/divider-line.png)
#
# @example
#     ANIMAL="dinosaur"
#     if ksl::isBlank $ANIMAL; then echo "yes"; fi
#
ksl::isBlank()
{
    local pat='^[[:blank:]]+$'
    [[ ${1} =~ ${pat} ]]
}

# -----------------------------------------------------------
#
# @description Returns true if all characters in $1 are control
# characters as defined by the POSIX standard.
#
# @arg $1 ... the string to operate on
#
# @exitcode 0 the string contains only control characters (true)
# @exitcode 1 the string contains more than just control characters (false) <p><p>![](../images/pub/divider-line.png)
#
# @example
#     ANIMAL="dinosaur"
#     if ksl::isCntrl $ANIMAL; then echo "yes"; fi
#
ksl::isCntrl()
{
    local pat='^[[:cntrl:]]+$'
    [[ ${1} =~ ${pat} ]]
}

# -----------------------------------------------------------
#
# @description Returns true if $1 contains only characters that
# are printable as defined by POSIX standard.
#
# @arg $1 ... the string to operate on
#
# @exitcode 0 the string contains only printable characters (true)
# @exitcode 1 the string contains more than just printable characters (false) <p><p>![](../images/pub/divider-line.png)
#
# @example
#     ANIMAL="dinosaur"
#     if ksl::isPrint $ANIMAL; then echo "yes"; fi
#
ksl::isPrint()
{
    local pat='^[[:print:]]+$'
    [[ ${1} =~ ${pat} ]]
}

# -----------------------------------------------------------
#
# @description Returns true if all characters in $1 are in the graph
# class (displayable on a screen) as defined by the POSIX standard.
#
# @arg $1 ... the string to operate on
#
# @exitcode 0 the string contains only digit characters (true)
# @exitcode 1 the string contains more than just digit characters (false) <p><p>![](../images/pub/divider-line.png)
#
# @example
#     ANIMAL="dinosaur"
#     if ksl::isGraph $ANIMAL; then echo "yes"; fi
#
ksl::isGraph()
{
    local pat='^[[:graph:]]+$'
    [[ ${1} =~ ${pat} ]]
}

# -----------------------------------------------------------
#
# @description Returns true if all characters in $1 are
# lower case as defined by the POSIX standard.
#
# @arg $1 ... the string to operate on
#
# @exitcode 0 the string contains only lowercase characters (true)
# @exitcode 1 the string contains more than just lowercase characters (false) <p><p>![](../images/pub/divider-line.png)
#
# @example
#     ANIMAL="dinosaur"
#     if ksl::isLower $ANIMAL; then echo "yes"; fi
#
ksl::isLower()
{
    local pat='^[[:lower:]]+$'
    [[ ${1} =~ ${pat} ]]
}

# -----------------------------------------------------------
#
# @description Returns true if all characters in $1 are
# upper case as defined by the POSIX standard.
#
# @arg $1 ... the string to operate on
#
# @exitcode 0 the string contains only upper case characters (true)
# @exitcode 1 the string contains more than just upper case characters (false) <p><p>![](../images/pub/divider-line.png)
#
# @example
#     ANIMAL="dinosaur"
#     if ksl::isUpper $ANIMAL; then echo "yes"; fi
#
ksl::isUpper()
{
    local pat='^[[:upper:]]+$'
    [[ ${1} =~ ${pat} ]]
}

# -----------------------------------------------------------
#
# @description Returns true if $1 contains only characters that
# are punctuations as defined by the POSIX standard.
#
# @arg $1 ... the string to operate on
#
# @exitcode 0 the string contains only punctuation characters (true)
# @exitcode 1 the string contains more than just punctuation characters (false) <p><p>![](../images/pub/divider-line.png)
#
# @example
#     ANIMAL="dinosaur"
#     if ksl::isPunct $ANIMAL; then echo "yes"; fi
#
ksl::isPunct()
{
    local pat='^[[:punct:]]+$'
    [[ ${1} =~ ${pat} ]]
}

# -----------------------------------------------------------
#
# @description Returns true if $1 contains only characters that
# are spaces as defined by the POSIX standard.
#
# @arg $1 ... the string to operate on
#
# @exitcode 0 the string contains only space characters (true)
# @exitcode 1 the string contains more than just space characters (false) <p><p>![](../images/pub/divider-line.png)
#
# @example
#     ANIMAL="dinosaur"
#     if ksl::isSpace $ANIMAL; then echo "yes"; fi
#
ksl::isSpace()
{
    local pat='^[[:space:]]+$'
    [[ ${1} =~ ${pat} ]]
}

# -----------------------------------------------------------
#
# @description Returns true if all characters in $1 are considered a
# word - containing only letters, digits, and the character _.
#
# isWord is not currently working. Need to investigate.
#
# @arg $1 ... the string to operate on
#
# @exitcode 0 the string contains a valid word (true)
# @exitcode 1 the string contains more than a word (false) <p><p>![](../images/pub/divider-line.png)
#
# @example
#     ANIMAL="dinosaur"
#     if ksl::isWord $ANIMAL; then echo "yes"; fi
#
ksl::isWord()
{
    local pat='^[[:word:]]+$'
    [[ ${1} =~ ${pat} ]]
}

# -----------------------------------------------------------
#
# @description Returns true if all characters in $1 are digits
# as defined by the POSIX standard.
#
# Note that "+" "-" "." are not digits.
#
# @arg $1 ... the string to operate on
#
# @exitcode 0 the string contains only digit characters (true)
# @exitcode 1 the string contains more than just digit characters (false) <p><p>![](../images/pub/divider-line.png)
#
# @example
#     ANIMAL="dinosaur"
#     if ksl::isDigit $ANIMAL; then echo "yes"; fi
#
ksl::isDigit()
{
    local pat='^[[:digit:]]+$'
    [[ ${1} =~ ${pat} ]]
}

# -----------------------------------------------------------
#
# @description Returns true if $1 forms a valid integer meaning
# all digits with an optional preceding +/-.
#
# Does not check for length.
#
# @arg $1 ... the string to operate on
#
# @exitcode 0 the string contains a valid integer (true)
# @exitcode 1 the string contains more than just an integer (false) <p><p>![](../images/pub/divider-line.png)
#
# @example
#     ANIMAL="dinosaur"
#     if ksl::isInteger $ANIMAL; then echo "yes"; fi
#
ksl::isInteger()
{
    local pat='^[+-]?[[:digit:]]+$'
    [[ ${1} =~ ${pat} ]]
}

# -----------------------------------------------------------
#
# @description Returns true if $1 forms a valid number.
#
# @arg $1 ... the string to operate on
#
# @exitcode 0 the string contains a valid number (true)
# @exitcode 1 the string contains more than just a number (false) <p><p>![](../images/pub/divider-line.png)
#
# @example
#     ANIMAL="dinosaur"
#     if ksl::isNumber $ANIMAL; then echo "yes"; fi
#
ksl::isNumber()
{
    ksl::isInteger "$1" || ksl::isFloat "$1"
}

# -----------------------------------------------------------
#
# @description Returns true if $1 forms a valid floating point number.
#
# @arg $1 ... the string to operate on
#
# @exitcode 0 the string contains a valid floating point number (true)
# @exitcode 1 the string contains more than just a floating point number (false) <p><p>![](../images/pub/divider-line.png)
#
# @example
#     ANIMAL="dinosaur"
#     if ksl::isFloat $ANIMAL; then echo "yes"; fi
#
ksl::isFloat()
{
    [[ ${1:-} =~ ^[+-]?[0-9]*\.?[0-9]+$ ]]
}

# -----------------------------------------------------------
#
# @description Returns true if all characters in $1 are
# valid hexadecimal digits.
#
# @arg $1 ... the string to operate on
#
# @exitcode 0 the string contains only hexadecimal characters (true)
# @exitcode 1 the string contains more than just hexadecimal characters (false) <p><p>![](../images/pub/divider-line.png)
#
# @example
#     ANIMAL="dinosaur"
#     if ksl::isXdigit $ANIMAL; then echo "yes"; fi
#
ksl::isXdigit()
{
    local pat='^[[:xdigit:]]+$'
    [[ ${1} =~ ${pat} ]]
}

# -----------------------------------------------------------

#!/usr/bin/env bash

source "${KSL_BASH_LIB}"/libArrays.bash

# -----------------------------------------------------------

test_arrayExists()
{
    local -i ret

    # Missing args
    ksl::arrayExists
    ret=$?; assert '[[ $ret -eq 1 ]]'

    # Bad array, doesn't exist
    unset dogs
    ksl::arrayExists dogs
    ret=$?; assert '[[ $ret -eq 1 ]]'

    # Good array - associative
    local -A dogs
    ksl::arrayExists dogs
    ret=$?; assert '[[ $ret -eq 0 ]]'

    # Good array - indexed
    local -a birds
    ksl::arrayExists birds
    ret=$?; assert '[[ $ret -eq 0 ]]'
}

test_arraySize()
{
    local -i ret
    local val

    # Missing args
    val=$(ksl::arraySize)
    ret=$?; assert '[[ $ret -eq 1 ]]'

    # Bad array, doesn't exist
    unset dogs
    val=$(ksl::arraySize dogs)
    ret=$?; assert '[[ $ret -eq 1 ]]'

    # Good array, no elements
    local -A dogs
    val=$(ksl::arraySize dogs)
    ret=$?; assert '[[ $ret -eq 0 ]]'
    assert_equals "0" "$val"

    # Good array, several elements
    dogs[SPOT]=
    dogs[ROVER]=
    dogs[FIDO]=
    val=$(ksl::arraySize dogs)
    ret=$?; assert '[[ $ret -eq 0 ]]'
    assert_equals "3" "$val"
}

# -----------------------------------------------------------

test_arrayHasKey()
{
    local -i ret

    # Missing args
    ksl::arrayHasKey
    ret=$?; assert '[[ $ret -eq 1 ]]'

    # Missing args
    ksl::arrayHasKey oneArg
    ret=$?; assert '[[ $ret -eq 1 ]]'

    # Bad array, doesn't exist
    unset dogs
    ksl::arrayHasKey dogs SPOT
    ret=$?; assert '[[ $ret -eq 1 ]]'

    # Good array - associative, but missing key
    local -A dogs
    ksl::arrayHasKey dogs SPOT
    ret=$?; assert '[[ $ret -eq 1 ]]'

    # Good array - associative, has key
    dogs[SPOT]=
    ksl::arrayHasKey dogs SPOT
    ret=$?; assert '[[ $ret -eq 0 ]]'

    # Good array - index, but missing key
    local -a birds
    ksl::arrayHasKey birds 1
    ret=$?; assert '[[ $ret -eq 1 ]]'

    # Good array - index, has key
    birds[1]=
    ksl::arrayHasKey birds 1
    ret=$?; assert '[[ $ret -eq 0 ]]'
}

# -----------------------------------------------------------

test_arrayGetValue()
{
    local -i ret
    local val

    # Bad array, doesn't exist
    ksl::arrayGetValue dogs ROVER 2>/dev/null
    ret=$?; assert '[[ $ret -eq 1 ]]'

    local -A dogs
    dogs[SPOT]="spot"

    # Good array, bad key
    ksl::arrayGetValue dogs ROVER 2>/dev/null
    ret=$?; assert '[[ $ret -eq 1 ]]'

    # Good array, good key, good entry
    val=$(ksl::arrayGetValue dogs SPOT)
    ret=$?; assert '[[ $ret -eq 0 ]]'
    assert_equals "$val" "spot"

    # Key and value with embedded spaces
    dogs["GREAT_DANE"]="I am a great dane"
    val=$(ksl::arrayGetValue dogs "GREAT_DANE")
    ret=$?; assert '[[ $ret -eq 0 ]]'
    assert_equals "$val" "I am a great dane"

    # Good array index, bad key
    local -a birds
    ksl::arrayGetValue birds 1 2>/dev/null
    ret=$?; assert '[[ $ret -eq 1 ]]'

    # Good array, good key, good entry
    birds[1]="bluejay"
    val=$(ksl::arrayGetValue birds 1)
    ret=$?; assert '[[ $ret -eq 0 ]]'
    assert_equals "$val" "bluejay"
}

# -----------------------------------------------------------

test_arraySetValue()
{
    local -i ret

    # Missing args
    ksl::arraySetValue 2>/dev/null
    ret=$?; assert '[[ $ret -eq 1 ]]'

    # Missing args
    ksl::arraySetValue oneArg twoArg 2>/dev/null
    ret=$?; assert '[[ $ret -eq 1 ]]'

    # Bad array, doesn't exist
    unset dogs
    ksl::arraySetValue dogs SPOT "I am spotty" 2>/dev/null
    ret=$?; assert '[[ $ret -eq 1 ]]'

    # Good array, unknown key, so should set it
    local -A dogs

    ksl::arraySetValue dogs SPOT "I am spotty"
    ret=$?; assert '[[ $ret -eq 0 ]]'
    assert_equals "I am spotty" "${dogs[SPOT]}"

    # Set Key and value with embedded spaces
    ksl::arraySetValue dogs "GREAT DANE" "I am great"
    ret=$?; assert '[[ $ret -eq 0 ]]'
    assert_equals "I am great" "${dogs[GREAT DANE]}"

    # Good array index, unknown key, so should set it
    local -a birds

    ksl::arraySetValue birds 1 "I am a bluejay"
    ret=$?; assert '[[ $ret -eq 0 ]]'
    assert_equals "I am a bluejay" "${birds[1]}"
}

# -----------------------------------------------------------

test_arrayAppendValue()
{
    local -i ret

    # Missing all args
    ksl::arrayAppend 2>/dev/null
    ret=$?; assert '[[ $ret -eq 1 ]]'

    # Missing 1 arg
    ksl::arrayAppend dogs 2>/dev/null
    ret=$?; assert '[[ $ret -eq 1 ]]'

    # Bad array, doesn't exist
    ksl::arrayAppend dogs ROVER "I rove around" 2>/dev/null
    ret=$?; assert '[[ $ret -eq 1 ]]'

    local -A dogs
    dogs[SPOT]="spot"

    # Good array, bad key
    ksl::arrayAppend dogs ROVER "I rove around" 2>/dev/null
    ret=$?; assert '[[ $ret -eq 1 ]]'

    # Good array, good key, append success
    dogs[ROVER]="Roving: "
    ksl::arrayAppend dogs ROVER "I rove around"
    ret=$?; assert '[[ $ret -eq 0 ]]'
    assert_equals "Roving: I rove around" "${dogs[ROVER]}"

    # Good key and value with embedded spaces
    dogs["GREAT DANE"]="I am a great dane"
    ksl::arrayAppend dogs "GREAT DANE" " the greatest"
    ret=$?; assert '[[ $ret -eq 0 ]]'
    assert_equals "I am a great dane the greatest" "${dogs[GREAT DANE]}"
}

# -----------------------------------------------------------

test_arrayPrependValue()
{
    local -i ret

    # Missing all args
    ksl::arrayPrepend
    ret=$?; assert '[[ $ret -eq 1 ]]'

    # Missing 1 arg
    ksl::arrayPrepend dogs
    ret=$?; assert '[[ $ret -eq 1 ]]'

    # Bad array, doesn't exist
    ksl::arrayPrepend dogs ROVER "I rove around" 2>/dev/null
    ret=$?; assert '[[ $ret -eq 1 ]]'

    local -A dogs
    dogs[SPOT]="spot"

    # Good array, bad key
    ksl::arrayPrepend dogs ROVER "I rove around" 2>/dev/null
    ret=$?; assert '[[ $ret -eq 1 ]]'

    # Good array, good key, prepend success
    dogs[ROVER]="Roving: "
    ksl::arrayPrepend dogs ROVER "I rove around "
    ret=$?; assert '[[ $ret -eq 0 ]]'
    assert_equals "I rove around Roving: " "${dogs[ROVER]}"

    # Good key and value with embedded spaces
    dogs["GREAT DANE"]="I am a great dane"
    ksl::arrayPrepend dogs "GREAT DANE" " the greatest"
    ret=$?; assert '[[ $ret -eq 0 ]]'
    assert_equals " the greatestI am a great dane" "${dogs[GREAT DANE]}"
}

# -----------------------------------------------------------

# $1 = value from array
# $2 = index | key
# $3 = array name
# [args...]
#
visitAll()
{
    # echo "visitAll value: $1, key: $2, array: $3 \$4:$4 \$5:$5"
    (( numVisits++ ))
}

# $1 = value from array
# $2 = index | key
# $3 = array name
# [args...]
#
findValue()
{
    # echo "findValue(): $1, key: $2, array: $3, looking for: $4"
    if [[ "$1" == "$4" ]]; then
        # echo Found it at key/index: "$2"
        return 10
    fi
}

test_arrayVisit()
{
    local -i ret
    local val

    # Missing all args
    ksl::arrayVisit
    ret=$?; assert '[[ $ret -eq 1 ]]'

    # Missing 1 arg
    ksl::arrayVisit dogs
    ret=$?; assert '[[ $ret -eq 1 ]]'

    # Bad array, doesn't exist
    ksl::arrayVisit dogs ROVER "I rove around" 2> /dev/null
    ret=$?; assert '[[ $ret -eq 1 ]]'

    declare -A dogs
    dogs["big shepard"]="I am sheppy"
    dogs["irish setter"]="I am irish"
    dogs["great dane"]="I am danish"

    local -i ret
    declare -i numVisits=0
    ksl::arrayVisit dogs visitAll "happy and smiling" sad
    ret=$?; assert '[[ $ret -eq 0 ]]'
    assert '[[ numVisits -eq 3 ]]'

    ksl::arrayVisit dogs findValue "I am irish"
    ret=$?; assert '[[ $ret -eq 10 ]]'

    ksl::arrayVisit dogs findValue "I am xxirish"
    ret=$?; assert '[[ $ret -eq 0 ]]'
}

# -----------------------------------------------------------

#!/usr/bin/env bash

source "${KSL_BASH_LIB}"/libArrays.bash

# -----------------------------------------------------------

test_arrayExists ()
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

# -----------------------------------------------------------

test_arrayHasKey ()
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

test_arrayGetValue ()
{
    local -i ret
    local val

    # Bad array, doesn't exist
    val=$(ksl::arrayGetValue dogs ROVER)
    ret=$?; assert '[[ $ret -eq 1 ]]'
    assert_equals "$val" "arrayGetValue() no such array: \"dogs\""
    
    local -A dogs
    dogs[SPOT]="spot"

    # Good array, bad key
    val=$(ksl::arrayGetValue dogs ROVER)
    ret=$?; assert '[[ $ret -eq 1 ]]'
    assert_equals "$val" "arrayGetValue() no such key: \"ROVER\""
    
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
    val=$(ksl::arrayGetValue birds 1)
    ret=$?; assert '[[ $ret -eq 1 ]]'
    assert_equals "$val" "arrayGetValue() no such key: \"1\""
    
    # Good array, good key, good entry
    birds[1]="bluejay"
    val=$(ksl::arrayGetValue birds 1)
    ret=$?; assert '[[ $ret -eq 0 ]]'
    assert_equals "$val" "bluejay"
}

# -----------------------------------------------------------

test_arraySetValue ()
{
    local -i ret
    local val

    # Missing args
    val=$(ksl::arraySetValue)
    ret=$?; assert '[[ $ret -eq 1 ]]'
    assert_equals "$val" "arraySetValue() missing args"

    # Missing args
    val=$(ksl::arraySetValue oneArg twoArg)
    ret=$?; assert '[[ $ret -eq 1 ]]'
    assert_equals "$val" "arraySetValue() missing args"
    
    # Bad array, doesn't exist
    unset dogs
    val=$(ksl::arraySetValue dogs SPOT "I am spotty")
    ret=$?; assert '[[ $ret -eq 1 ]]'
    assert_equals "$val" "arraySetValue() no such array: \"dogs\""

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

test_arrayAppendValue ()
{
    local -i ret
    local val

    # Missing all args
    val=$(ksl::arrayAppend)
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    # Missing 1 arg
    val=$(ksl::arrayAppend dogs)
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    # Bad array, doesn't exist
    val=$(ksl::arrayAppend dogs ROVER "I rove around")
    ret=$?; assert '[[ $ret -eq 1 ]]'
    assert_equals "$val" "arrayAppend() no such array: \"dogs\""
    
    local -A dogs
    dogs[SPOT]="spot"

    # Good array, bad key
    val=$(ksl::arrayAppend dogs ROVER "I rove around")
    ret=$?; assert '[[ $ret -eq 1 ]]'
    assert_equals "$val" "arrayAppend() no such key: \"ROVER\""
    
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

test_arrayPrependValue ()
{
    local -i ret
    local val

    # Missing all args
    val=$(ksl::arrayPrepend)
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    # Missing 1 arg
    val=$(ksl::arrayPrepend dogs)
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    # Bad array, doesn't exist
    val=$(ksl::arrayPrepend dogs ROVER "I rove around")
    ret=$?; assert '[[ $ret -eq 1 ]]'
    assert_equals "$val" "arrayPrepend() no such array: \"dogs\""
    
    local -A dogs
    dogs[SPOT]="spot"

    # Good array, bad key
    val=$(ksl::arrayPrepend dogs ROVER "I rove around")
    ret=$?; assert '[[ $ret -eq 1 ]]'
    assert_equals "$val" "arrayPrepend() no such key: \"ROVER\""
    
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

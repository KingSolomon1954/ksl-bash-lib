#!/usr/bin/env bash

source "${KSL_BASH_LIB}"/libError.bash

# -----------------------------------------------------------
#
# Note:
#
# Stay away from running commands inside bash_unit assert()'s. Got
# opposite results if same assert is run just two lines later. 
# Therefore don't do this:
# 
#     assert 'ksl::epCreate ep1"'
#
# Additionally, in the above case with epCreate, ep1 seems to be
# shadowed. Some kind of scoping thing with bash_unit. Not sure.
#
# There are two alternatives. First form uses assert in a 
# multi-conditional idiom like so:
#
#     ksl::epCreate ep1 && assert "false"   # expected negative condition
#     ! ksl::epCreate ep1 && assert "false" # expected positive condition
#
# Just be careful as the test subject must always be negated from
# the expected response. Kind of a head scratcher. Note that only
# the '&& assert "false"' form is workable, otherwise the truth
# table is not properly covered.
#
# Second alternative is more verbose but reads better and less error
# prone since the test condition is always positve. Just need to flip
# the -eq test between 0 and 1 for positive and negative conditions,
# similar to the first alternative. This also has the advantage of being
# able to test for specific return values instead of just success/fail.
#
#     local -i ret
#     ksl::epCreate ep1
#     ret=$?; assert '[[ $ret -eq 0 ]]'
#
# -----------------------------------------------------------

test_epCreate()
{
    # create

    local -i ret
    # create ep1, expect success
    ksl::epCreate ep1
    ret=$?; assert '[[ $ret -eq 0 ]]'
    assert '[[ ${#ep1[@]} -gt 0 ]]'

    # create same again - error this time
    ksl::epCreate ep1
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    # create missing args
    ksl::epCreate
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    unset ep1
}

# -----------------------------------------------------------

test_epDestroy()
{
    local -i ret
    
    # destroy but missing args
    ksl::epDestroy
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    # destroy but doesn't exist, error
    unset ep1
    ksl::epDestroy ep1
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    # destroy, good params, expect success
    ksl::epCreate ep1
    ksl::epDestroy ep1
    ret=$?; assert '[[ $ret -eq 0 ]]'

    ksl::epExists ep1
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    unset ep1
}

# -----------------------------------------------------------

test_epExists()
{
    local -i ret
    
    # missing arg
    ksl::epExists
    ret=$?; assert '[[ $ret -eq 1 ]]'

    # good args but no exist
    unset ep1
    ksl::epExists ep1
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    # good args, yes exists
    ksl::epCreate ep1
    ret=$?; assert '[[ $ret -eq 0 ]]'
    ksl::epExists ep1
    ret=$?; assert '[[ $ret -eq 0 ]]'

    unset ep1
}

# -----------------------------------------------------------

test_epClear()
{
    local -i ret
    unset ep1

    # clear on unset EPS, will use ep1, expect fail
    ksl::epClear
    ret=$?; assert '[[ $ret -eq 1 ]]'
    
    # clear on freshly created EPS, expect success
    ksl::epCreate ep1
    ksl::epClear
    ret=$?; assert '[[ $ret -eq 0 ]]'

    # set a value into description
    ksl::epSetDescription "illegal value"
    assert '[[ "${ep1[DESC]}" == "illegal value" ]]'

    # now clear, expect null description
    ksl::epClear
    ret=$?; assert '[[ $ret -eq 0 ]]'
    assert '[[ "${ep1[DESC]}" == "" ]]'

    unset ep1
}

# -----------------------------------------------------------

test_epSet()
{
    local -i ret
    
    # no args, should create ep1
    unset ep1
    ksl::epSet
    ret=$?; assert '[[ $ret -eq 0 ]]'

    # explicity specifiy ep1,
    unset ep1
    ksl::epSet ep1
    ret=$?; assert '[[ $ret -eq 0 ]]'
    ksl::epExists ep1
    ret=$?; assert '[[ $ret -eq 0 ]]'
    
    # two epSets in row
    unset ep1
    ksl::epSet ep1
    ksl::epSet ep1
    ksl::epExists ep1
    ret=$?; assert '[[ $ret -eq 0 ]]'
    
    # explicity specify other than ep1
    unset ep1
    ksl::epSet ep2
    ksl::epExists ep2
    ret=$?; assert '[[ $ret -eq 0 ]]'
    
    unset ep2

    # assign description
    unset ep1
    ksl::epSet -d "ETH2 network is down"
    ksl::epExists ep1
    ret=$?; assert '[[ $ret -eq 0 ]]'
    assert "[[ ${#ep1[@]} -gt 0 ]]"
    assert '[[ "${ep1[DESC]}" == "ETH2 network is down" ]]'
    
    # assign file name
    ksl::epSet -fi "libStrings.bash"
    ksl::epExists ep1
    ret=$?; assert '[[ $ret -eq 0 ]]'
    assert "[[ ${#ep1[@]} -gt 0 ]]"
    assert '[[ "${ep1[FILE]}" == "libStrings.bash" ]]'

    # assign func name
    ksl::epSet -fu "ksl::uppercase()"
    ksl::epExists ep1
    ret=$?; assert '[[ $ret -eq 0 ]]'
    assert "[[ ${#ep1[@]} -gt 0 ]]"
    assert '[[ "${ep1[FUNC]}" == "ksl::uppercase()" ]]'

    # assign three at once, clobbering old values
    ksl::epSet -d "Broken initialization" -fi "/etc/init" -fu "ksl::lowercase()"
    assert '[[ "${ep1[DESC]}" == "Broken initialization" ]]'
    assert '[[ "${ep1[FILE]}" == "/etc/init" ]]'
    assert '[[ "${ep1[FUNC]}" == "ksl::lowercase()" ]]'

    # operator a different EPS, ensure both ep1 and ep2 are intact
    # reuse ep1 from previous
    # create a new ep2 with different values
    ksl::epSet ep2 -d "communications timeout" -fi "/usr/lib" -fu "socket()"
    assert '[[ "${ep1[DESC]}" == "Broken initialization" ]]'
    assert '[[ "${ep1[FILE]}" == "/etc/init" ]]'
    assert '[[ "${ep1[FUNC]}" == "ksl::lowercase()" ]]'
    assert '[[ "${ep2[DESC]}" == "communications timeout" ]]'
    assert '[[ "${ep2[FILE]}" == "/usr/lib" ]]'
    assert '[[ "${ep2[FUNC]}" == "socket()" ]]'

    ksl::epDestroy ep1
    ksl::epDestroy ep2
}

# -----------------------------------------------------------

test_epSetDescription()
{
    local -i ret
    
    # create ep1
    ksl::epCreate ep1
    
    # put value in description using default ep1
    ksl::epSetDescription "I/O error"
    assert '[[ "${ep1[DESC]}" == "I/O error" ]]'

    # this time supply ep1 and clobber previous value
    ksl::epSetDescription ep1 "Configuration bad value"
    assert '[[ "${ep1[DESC]}" == "Configuration bad value" ]]'

    # put value for non-existent EPS
    ksl::epSetDescription ep2 "Configuration bad value"
    ret=$?; assert '[[ $ret -eq 1 ]]'

    # put value into different existing EPS
    ksl::epCreate ep2
    ksl::epSetDescription ep2 "missing parameter"
    assert '[[ "${ep2[DESC]}" == "missing parameter" ]]'
    assert '[[ "${ep1[DESC]}" == "Configuration bad value" ]]'
    
    unset ep1
    unset ep2
}

# -----------------------------------------------------------

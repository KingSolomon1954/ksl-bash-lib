#!/usr/bin/env bash

source "${KSL_BASH_LIB}"/libError.bash

# -----------------------------------------------------------

test_epCreate()
{
    # create
    # Don't do this "assert "ksl::epCreate ep1"" because
    # ep1 seems to be shadowed. Though OK after exists.
    ksl::epCreate ep1 && assert "true"

    assert "[[ ${#ep1[@]} -gt 0 ]]"

    # create same again - error
    assert_fails "ksl::epCreate ep1"
    
    # create missing args
    assert_fails "ksl::epCreate"
    
    unset ep1
}

# -----------------------------------------------------------

test_epDestroy()
{
    unset ep1
    # destroy but doesn't exist
    ksl::epDestroy ep1 && assert "false"
    
    # destroy
    ksl::epCreate ep1 && assert "true"
    ksl::epDestroy ep1 && assert "true"

    assert_fails "ksl::epExists ep1"
    unset ep1
}

# -----------------------------------------------------------

test_epExists()
{
    # No exist
    unset ep1
    assert_fails "ksl::epExists ep1"
    
    # Yes exist
    ksl::epCreate ep1 && assert "true"
    assert "ksl::epExists ep1"
    unset ep1
}

# -----------------------------------------------------------


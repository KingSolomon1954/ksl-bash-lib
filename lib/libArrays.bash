# -------------------------------------------------------
#
# @name libArrays
# @brief Functions to support array processing
#
# @description
# Functions to help with arrays.
#
# Contains the following:
#
#     * ksl::arrayExists()
#     * ksl::arraySize()
#     * ksl::arrayHasKey()
#     * ksl::arrayGetValue()
#     * ksl::arraySetValue()
#     * ksl::arrayAppendValue()
#     * ksl::arrayPrependValue()
#     * ksl::arrayVisit()
#
# -----------------------------------------------------------

# Avoid double inclusion, but optionally allow a forcing option
# mainly for developers. For example: "source libStdOut -f"
#
[[ -v libArraysImported ]] && [[ "$1" != "-f" ]] && return
libArraysImported=true

# -----------------------------------------------------------
#
# $1 = name of array 
#
ksl::arrayExists()
{
    [[ $# -eq 0 ]] && return 1
    local -n ref=$1
    [[ ${ref@a} =~ A|a ]]
}

# -----------------------------------------------------------
#
# $1 = name of array
#
ksl::arraySize()
{
    [[ $# -eq 0 ]] && return 1
    # shellcheck disable=SC2086
    ! ksl::arrayExists $1 && return 1
    local -n ref=$1
    echo ${#ref[@]}
}

# -----------------------------------------------------------
#
# $1 = name of array
# $2 = name of key in array
# 
# example: ksl::arrayHasKey acronyms CRC
#
ksl::arrayHasKey()
{
    [[ $# -ne 2 ]] && return 1
    # shellcheck disable=SC2086
    ! ksl::arrayExists $1 && return 1
    local -n ref=$1
    [[ ${ref["$2"]+_} == _ ]]
}

# -----------------------------------------------------------
#
# $1 = name of array
# $2 = name of key in array
# $3 = value to set
#
# example: ksl::arraySetValue acronyms CRC "Cyclic Redundancy Check"
#
ksl::arraySetValue()
{
    [[ $# -ne 3 ]]        && echo "arraySetValue() missing args" >&2          && return 1
    # shellcheck disable=SC2086
    ! ksl::arrayExists $1 && echo "arraySetValue() no such array: \"$1\"" >&2 && return 1

    eval "$1[$2]=\$3"
}

# -----------------------------------------------------------
#
# $1 = name of array
# $2 = name of key in array
# 
# example: val=$(ksl::arrayGetValue acronyms CRC)
#
ksl::arrayGetValue()
{
    # shellcheck disable=SC2086
    ! ksl::arrayExists $1 && echo "arrayGetValue() no such array: \"$1\"" >&2    && return 1
    # shellcheck disable=SC2086
    ! ksl::arrayHasKey $1 "$2" && echo "arrayGetValue() no such key: \"$2\"" >&2 && return 1
    local -n ref=$1
    echo "${ref[$2]}"
}

# -----------------------------------------------------------
#
# $1 = name of array
# $2 = name of key in array
# $3 = value to append
#
# example: ksl::arrayAppend errpass DESC " on channel 12"
#
ksl::arrayAppend()
{
    [[ $# -lt 2 ]] && return 1
    # shellcheck disable=SC2086
    ! ksl::arrayExists $1 && echo "arrayAppend() no such array: \"$1\"" >&2   && return 1
    # shellcheck disable=SC2086
    ! ksl::arrayHasKey $1 "$2" && echo "arrayAppend() no such key: \"$2\"" >&2 && return 1

    eval "$1[$2]=\${$1[$2]}\$3"
}

# -----------------------------------------------------------
#
# $1 = name of array
# $2 = name of key in array
# $3 = value to prepend
#
# example: ksl::arrayPrepend errpass DESC "Fatal error: "
#
ksl::arrayPrepend()
{
    [[ $# -lt 2 ]] && return 1
    # shellcheck disable=SC2086
    ! ksl::arrayExists $1      && echo "arrayPrepend() no such array: \"$1\"" >&2 && return 1
    # shellcheck disable=SC2086
    ! ksl::arrayHasKey $1 "$2" && echo "arrayPrepend() no such key: \"$2\""   >&2 && return 1

    eval "$1[$2]=\$3\${$1[$2]}"
}

# -----------------------------------------------------------
#
# Visits each element in an array and invokes your function on it.
#
# $1 = name of array (required)
# $2 = function to call on each element (required)
# [args...] additional arguments (optional) to pass into your function
#
# Your function is called with three args, plus your additional args if any:
#     <value>, <key|index>, <array name> and [args...]
#     If your function returns 10 or 11, then visit() will
#     stop visiting remaining elements. Typically use 10 to exit
#     early with success, and 11 to exit early with an error.
#     But you can apply any meaning to these two values as they
#     both exit early for whatever reason.
#
# Returns (0) success if all elements have been visited
#         (10) success if your function stopped visiting with a 10
#         (11) error if your function stopped visiting with an 11
#
# Example:
#    ksl::arrayVisit dogs findValue "Roving rover"
#    ret=$?
#    [[ $ret -eq 0 ]]  && echo "Not found"
#    [[ $ret -eq 10 ]] && echo "Found it"
#    [[ $ret -eq 11 ]] && echo "Error from findValue()"
#
#    findValue()
#    {
#        # $1 = element value 
#        # $2 = element key|index
#        # $3 = array name
#        # $4 = "Roving rover"
#        [[ "$1" == "$4" ]] && return 10
#    }
#
ksl::arrayVisit()
{
    local arrayName=$1
    local func=$2;
    local -n ref=$1;
    shift 2
    local -i ret
    
    for k in "${!ref[@]}"; do
        # shellcheck disable=SC2086
        $func "${ref["$k"]}" "$k" $arrayName "$@"
        ret=$?
        [[ $ret -eq 10 ]] || [[ $ret -eq 11 ]] && return $ret
    done
    return 0
}

# -----------------------------------------------------------

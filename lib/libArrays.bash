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
# @description Returns true if the array exists.
#
# @arg $1 array the name of the array 
#
# @exitcode 1 not an array or missing args
# @exitcode 0 it is an array that exists
#
# @example
#     if ksl::arrayExists myArray; then echo "have it"; fi
#
# @stdout no output <p><p>![](../images/pub/divider-line.png)
#
ksl::arrayExists()
{
    [[ $# -eq 0 ]] && return 1
    local -n ref=$1
    [[ ${ref@a} =~ A|a ]]
}

# -----------------------------------------------------------
#
# @description Returns the size of the array.
#
# This is the number of elements it contains.
#
# @arg $1 array the name of the array 
#
# @exitcode 1 not an array or missing args
# @exitcode 0 success
#
# @example
#     echo "There are $(ksl::arraySize myArray) elements"
#
# @stdout the size of the array <p><p>![](../images/pub/divider-line.png)
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
# @description Returns true if the array has an element with the given key
#
# @arg $1 array the name of the array 
# @arg $2 string the name of the key
#
# @exitcode 1 not an array or missing args
# @exitcode 0 success
#
# @example
#     if ksl::arrayHasKey acronyms CRC; then echo "have it"; fi
#
# @stdout no output <p><p>![](../images/pub/divider-line.png)
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
# @description Set a value in an array.
#
# The element is created if it does not exist. If the element already
# exists, then its previous value is overwritten. 
#
# @arg $1 array the name of the array 
# @arg $2 string the name of the key
# @arg $3 string the value to set for this element
#
# @exitcode 1 not an array or missing args
# @exitcode 0 success
#
# @example
#     ksl::arraySetValue acronyms CRC "Cyclic Redundancy Check"
#
# @stdout no output
# @stderr arraySetValue() no such array: <p><p>![](../images/pub/divider-line.png)
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
# @description Get a value in an array.
#
# @arg $1 array the name of the array 
# @arg $2 string the name of the key
#
# @exitcode 1 not an array, no such key, or missing args
# @exitcode 0 success
#
# @example
#     val=$(ksl::arrayGetValue acronyms CRC)
#
# @stdout the value
# @stderr arraySetValue() no such key: <p><p>![](../images/pub/divider-line.png)
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
# @description Append to a value in an array.
#
# The element must already exist, otherwise it's an error.
#
# @arg $1 array the name of the array 
# @arg $2 string the name of the key
# @arg $3 string the value to append for this element
#
# @exitcode 1 not an array, no such key, or missing args
# @exitcode 0 success
#
# @example
#     ksl::arrayAppend errpass DESC " on channel 12"
#
# @stdout no output
# @stderr arrayAppend() no such key: <p><p>![](../images/pub/divider-line.png)
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
# @description Prepend to a value in an array.
#
# The element must already exist, otherwise it's an error.
#
# @arg $1 array the name of the array 
# @arg $2 string the name of the key
# @arg $3 string the value to prepend for this element
#
# @exitcode 1 not an array, no such key, or missing args
# @exitcode 0 success
#
# @example
#     ksl::arrayPrepend errpass DESC "Fatal error: "
#
# @stdout no output
# @stderr arrayPrepend() no such key: <p><p>![](../images/pub/divider-line.png)
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
# @description Visits each element in an array and invokes your function on it.
#
# Your function is called with three args, plus any additional args you provide:
#
#     \<value\>, \<key|index\>, \<array name\> and [args...]
#
# If your function returns 10 or 11, then visit() will
# stop visiting remaining elements. Typically use 10 to exit
# early with success, and 11 to exit early with an error.
# But you can apply any meaning to these two values as they
# both exit early for whatever reason.
#
# Returns
#
# * 0 success if all elements have been visited
# * 1 fail missing or bad args
# * 10 success if your function stopped visiting with a 10
# * 11 error if your function stopped visiting with an 11
#
# @arg $1 array the name of array (required)
# @arg $2 function the function to call on each element (required)
# @arg $3 [args...] additional arguments (optional) to pass into your function
#
# @exitcode 0 success - all elements visited
# @exitcode 1 fail - not an array or missing args
# @exitcode 10 success if your function stopped visiting with a 10
# @exitcode 11 error if your function stopped visiting with an 11
#
# @example
#    ksl::arrayVisit dogs findValue "Roving rover"
#    ret=$?
#    [[ $ret -eq 0 ]]  && echo "Not found"
#    [[ $ret -eq 10 ]] && echo "Found it"
#    [[ $ret -eq 11 ]] && echo "Error from findValue()"
#    #
#    # Your function
#    findValue()
#    {
#        # $1 = element value 
#        # $2 = element key|index
#        # $3 = array name
#        # $4 = "Roving rover"
#        [[ "$1" == "$4" ]] && return 10
#    }
#
# @stdout no output
# @stderr arrayVisit() no such array: <p><p>![](../images/pub/divider-line.png)
#
ksl::arrayVisit()
{
    [[ $# -lt 2 ]] && return 1
    ! ksl::arrayExists $1 && echo "arrayVisit() no such array: \"$1\"" >&2 && return 1
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

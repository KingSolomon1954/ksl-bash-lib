# -------------------------------------------------------
#
# Functions to help with arrays.
#
# Contains the following:
#
#     ksl::arrayExists()
#     ksl::arraySize()
#     ksl::arrayHasKey()
#     ksl::arrayGetValue()
#     ksl::arraySetValue()
#     ksl::arrayAppendValue()
#     ksl::arrayPrependValue()
#
# -----------------------------------------------------------

# Avoid double inclusion, but optionally allow a forcing option
# mainly for developers. For example: "source libStdOut -f"
#
[[ -v libArraysImported ]] && [[ "$1" != "-f" ]] && return
libArraysImported=true

# -----------------------------------------------------------

ksl::arrayExists ()
{
    [[ $# -eq 0 ]] && return 1
    local -n ref=$1
    [[ ${ref@a} =~ A|a ]]
}

# -----------------------------------------------------------
#
# $1 = array name
#
ksl::arraySize ()
{
    [[ $# -eq 0 ]] && return 1
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
ksl::arrayHasKey ()
{
    [[ $# -ne 2 ]] && return 1
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
ksl::arraySetValue ()
{
    [[ $# -ne 3 ]]        && echo "arraySetValue() missing args"          && return 1
    ! ksl::arrayExists $1 && echo "arraySetValue() no such array: \"$1\"" && return 1

    eval "$1[$2]=\$3"
}

# -----------------------------------------------------------
#
# $1 = name of array
# $2 = name of key in array
# 
# example: val=$(ksl::arrayGetValue acronyms CRC)
#
ksl::arrayGetValue ()
{
    ! ksl::arrayExists $1 && echo "arrayGetValue() no such array: \"$1\"" && return 1
    ! ksl::arrayHasKey $1 "$2" && echo "arrayGetValue() no such key: \"$2\""   && return 1
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
ksl::arrayAppend ()
{
    [[ $# -lt 2 ]] && return 1
    ! ksl::arrayExists $1 && echo "arrayAppend() no such array: \"$1\"" && return 1
    ! ksl::arrayHasKey $1 "$2" && echo "arrayAppend() no such key: \"$2\""   && return 1

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
ksl::arrayPrepend ()
{
    [[ $# -lt 2 ]] && return 1
    ! ksl::arrayExists $1      && echo "arrayPrepend() no such array: \"$1\"" && return 1
    ! ksl::arrayHasKey $1 "$2" && echo "arrayPrepend() no such key: \"$2\""   && return 1

    eval "$1[$2]=\$3\${$1[$2]}"
}

# -----------------------------------------------------------



array.contains() {
  local element

  @return # is it required? TODO: test

  ## TODO: probably should return a [boolean] type, not normal return

  for element in "${this[@]}"
  do
    [[ "$element" == "$1" ]] && return 0
  done
  return 1
}


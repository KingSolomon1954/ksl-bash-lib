# -------------------------------------------------------
#
# Functions to help with arrays.
#
# Contains the following:
#
#     ksl::arrayHasKey()
#     ksl::arrayGetField()
#     ksl::arraySetField()
#
# -----------------------------------------------------------

# Avoid double inclusion, but optionally allow a forcing option
# mainly for developers. For example: "source libStdOut -f"
#
[[ -v libArraysImported ]] && [[ "$1" != "-f" ]] && return
libArraysImported=true

ksl::arrayExists ()
{
    [[ $# -eq 0 ]] && return 1
    local -n ref=$1
    [[ ${ref@a} =~ A|a ]]
}

# -----------------------------------------------------------
#
# $1 = name of array
# $2 = name of key in array
# 
# example: ksl::arrayHasKey acronyms CRC
#
xxksl::arrayHasKey ()
{
    eval "[[ \${$1[$2]+_} == _ ]]"
}

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
# 
# example: ksl::arrayGetValue acronyms CRC
#
xxksl::arrayGetValue ()
{
    eval "echo \${$1[$2]}"
}

ksl::arrayGetValue ()
{
    ! ksl::arrayExists $1 && echo "arrayGetValue() no such array: \"$1\"" && return 1
    ! ksl::arrayHasKey $1 "$2" && echo "arrayGetValue() no such key: \"$2\""   && return 1
    local -n ref=$1
    echo "${ref[$2]}"
}

# -----------------------------------------------------------

ksl::arrayAppend ()
{
    [[ $# -lt 2 ]] && return 1
    ! ksl::arrayExists $1 && echo "arrayAppend() no such array: \"$1\"" && return 1
    ! ksl::arrayHasKey $1 "$2" && echo "arrayAppend() no such key: \"$2\""   && return 1

    eval "$1[$2]=\${$1[$2]}\$3"
#   eval "$1[$2]=\${$1[$2]}\$3"  works
}

# -----------------------------------------------------------

ksl::arrayPrepend ()
{
    [[ $# -lt 2 ]] && return 1
    ! ksl::arrayExists $1      && echo "arrayPrepend() no such array: \"$1\"" && return 1
    ! ksl::arrayHasKey $1 "$2" && echo "arrayPrepend() no such key: \"$2\""   && return 1

    eval "$1[$2]=\$3\${$1[$2]}"
}

# -----------------------------------------------------------

ksl::arraySetValue ()
{
    [[ $# -ne 3 ]]        && echo "arraySetValue() missing args"          && return 1
    ! ksl::arrayExists $1 && echo "arraySetValue() no such array: \"$1\"" && return 1

    eval "$1[$2]=\$3"
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


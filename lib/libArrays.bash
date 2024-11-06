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

# -----------------------------------------------------------

ksl::arrayHasKey ()
{
    eval "[[ \${$1[$2]+_} == _ ]]"
}

# -----------------------------------------------------------

ksl::arrayGetField ()
{
    eval "echo \${$1[$2]}"
}

# -----------------------------------------------------------

ksl::arraySetField ()
{
    eval "$1[$2]=\$3"
}

# -----------------------------------------------------------


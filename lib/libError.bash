# -----------------------------------------------------------
#
# Functions to support error passing
#
# Contains the following:
#
#
# -----------------------------------------------------------

# Avoid double inclusion, but optionally allow a forcing option
# mainly for developers. For example: "source libStdOut -f"
#
[ -v libErrorImported ] && [ "$1" != "-f" ] && return
libErrorImported=true

# -------------------------------------------------------
#
# Output text to standard out.
#
# epCreate errPass
ksl::epCreate()
{
    [ -z "$1" ] && return 1
    ksl::epExists "$1" && return 1
    local -A -g "$1"
    local -n name="$1"
    name[DESC]=
    name[FUNC]=
    name[FILE]=
}

# -------------------------------------------------------

ksl::epDestroy()
{
    ! ksl::epExists "$1" && return 1
    unset "$1"
}

# -------------------------------------------------------

ksl::epExists()
{
    local -n name="$1"
    [[ ${#name[@]} -gt 0 ]]
}

# -------------------------------------------------------

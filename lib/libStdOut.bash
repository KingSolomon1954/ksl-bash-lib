# -----------------------------------------------------------
#
# Functions to help print messages.
#
# Contains the following:
#
#    ksl::stdOut()
#    ksl::stdErr()
#    ksl::stdTrace()
#    ksl::stdDebug()
#    ksl::stdInfo()
#    ksl::stdWarn()
#    ksl::stdError()
#    ksl::stdFatal()
#
# -----------------------------------------------------------

# Avoid double inclusion, but optionally allow a forcing option
# mainly for developers. For example: "source libStdOut -f"
#
[ -v libStdOutImported ] && [ "$1" != "-f" ] && return
libStdOutImported=true

source "${KSL_BASH_LIB}"/libColors.bash

# -------------------------------------------------------
#
# Output text to standard out.
#
ksl::stdOut()
{
    echo -e "$*"
}

# -------------------------------------------------------
#
# Output text to standard error.
#
ksl::stdErr()
{
    echo -e "$*" 1>&2
}

# -------------------------------------------------------
#
# Output message to standard out prefaced by TRACE.
#
ksl::stdTrace()
{
    local s="${DIM}${FG_MAGENTA}[TRACE] $*${CLEAR}"
    ksl::stdOut "$s"
}

# -------------------------------------------------------
#
# Output message to standard out prefaced by DEBUG.
#
ksl::stdDebug()
{
    local s="${FG_MAGENTA}[DEBUG] $*${CLEAR}"
    ksl::stdOut "$s"
}

# -------------------------------------------------------
#
# Output message to standard out prefaced by INFO.
#
ksl::stdInfo()
{
    local s="[INFO] $*"
    ksl::stdOut "$s"
}

# -------------------------------------------------------
#
# Output message to standard out prefaced by WARN
#
ksl::stdWarn()
{
    local s="${FG_YELLOW}[WARN] $*${CLEAR}"
    ksl::stdOut "$s"
}

# -------------------------------------------------------
#
# Output message to standard error prefaced by ERROR
#
ksl::stdError()
{
    local s="${FG_RED}[ERROR] $*${CLEAR}"
    ksl::stdErr "$s"
}

# -------------------------------------------------------
#
# Output message to standard error prefaced by FATAL
#
ksl::stdFatal()
{
    local s="${BOLD}${FG_RED}[FATAL] $*${CLEAR}"
    ksl::stdErr "$s"
}

# -------------------------------------------------------

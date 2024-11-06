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
[[ -v libStdOutImported ]] && [[ "$1" != "-f" ]] && return
libStdOutImported=true

source "${KSL_BASH_LIB}"/libColors.bash

# Defaults
COLOR_TRACE=${FG_MAGENTA}
COLOR_DEBUG=${FG_MAGENTA}
COLOR_INFO=${FG_GREEN}
COLOR_WARN=${FG_YELLOW}
COLOR_ERROR=${FG_RED}
COLOR_FATAL=${BOLD}${FG_RED}

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
    local before="" after=""
    if ${KSL_USE_COLOR}; then
        before="${COLOR_TRACE}"
        after="${CLEAR}"
    fi
    
    ksl::stdOut "${before}[TRACE]${after} $*"
}

# -------------------------------------------------------
#
# Output message to standard out prefaced by DEBUG.
#
ksl::stdDebug()
{
    local before="" after=""
    if ${KSL_USE_COLOR}; then
        before="${COLOR_DEBUG}"
        after="${CLEAR}"
    fi
    ksl::stdOut "${before}[DEBUG]${after} $*"
}

# -------------------------------------------------------
#
# Output message to standard out prefaced by INFO.
#
ksl::stdInfo()
{
    local before="" after=""
    if ${KSL_USE_COLOR}; then
        before="${COLOR_INFO}"
        after="${CLEAR}"
    fi
    ksl::stdOut "${before}[INFO]${after} $*"
}

# -------------------------------------------------------
#
# Output message to standard out prefaced by WARN
#
ksl::stdWarn()
{
    local before="" after=""
    if ${KSL_USE_COLOR}; then
        before="${COLOR_WARN}"
        after="${CLEAR}"
    fi
    ksl::stdOut "${before}[WARN]${after} $*"
}

# -------------------------------------------------------
#
# Output message to standard error prefaced by ERROR
#
ksl::stdError()
{
    local before="" after=""
    if ${KSL_USE_COLOR}; then
        before="${COLOR_ERROR}"
        after="${CLEAR}"
    fi
    ksl::stdErr "${before}[ERROR]${after} $*"
}

# -------------------------------------------------------
#
# Output message to standard error prefaced by FATAL
#
ksl::stdFatal()
{
    local before="" after=""
    if ${KSL_USE_COLOR}; then
        before="${COLOR_FATAL}"
        after="${CLEAR}"
    fi
    ksl::stdErr "${before}[FATAL]${after} $*"
}

# -------------------------------------------------------

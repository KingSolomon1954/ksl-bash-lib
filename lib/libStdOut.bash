# -----------------------------------------------------------
#
# @name libStdOut
# @brief Functions to help print messages.
#
# @description
# Functions to help print consistent messages.
#
# Contains the following:
#
#     * ksl::stdOut()
#     * ksl::stdErr()
#     * ksl::stdTrace() - prepends [TRACE] to the message
#     * ksl::stdDebug() - prepends [DEBUG] to the message
#     * ksl::stdInfo()  - prepends [INFO] to the message
#     * ksl::stdWarn()  - prepends [WARN] to the message
#     * ksl::stdError() - prepends [ERROR] to the message
#     * ksl::stdFatal() - prepends [FATAL] to the message
#
# ![](../images/pub/stdout-example.png)
#
# **Colors**
#
# Colors can be changed and applied to the introducer string as well as
# the text of the message itself. So for example, `[TRACE]` would be
# displayed in the `COLOR_TRACE_INTRO` color and the text of the trace
# message would be displayed in the `COLOR_TRACE_TEXT` color. If
# `KSL_USE_COLOR` is true, then the following colors are applied to
# introducers and text.
#
# * `COLOR_TRACE_INTRO=${FG_MAGENTA}`
# * `COLOR_DEBUG_INTRO=${FG_MAGENTA}`
# * `COLOR_INFO_INTRO=${FG_GREEN}`
# * `COLOR_WARN_INTRO=${FG_YELLOW}`
# * `COLOR_ERROR_INTRO=${FG_RED}`
# * `COLOR_FATAL_INTRO=${BOLD}${FG_RED}`
#
# * `COLOR_TRACE_TEXT=`  # default is terminal color
# * `COLOR_DEBUG_TEXT=`  # default is terminal color
# * `COLOR_INFO_TEXT=`   # default is terminal color
# * `COLOR_WARN_TEXT=`   # default is terminal color
# * `COLOR_ERROR_TEXT=${FG_RED}`
# * `COLOR_FATAL_TEXT=${FG_RED}`
#
# An application can modify these colors as desired. See
# [libColors](libColors.html) for color setup.
#
# -----------------------------------------------------------

# Avoid double inclusion, but optionally allow a forcing option
# mainly for developers. For example: "source libStdOut -f"
#
[[ -v libStdOutImported ]] && [[ "$1" != "-f" ]] && return
libStdOutImported=true

source "${KSL_BASH_LIB}"/libColors.bash

# Defaults
COLOR_TRACE_INTRO=${FG_MAGENTA}
COLOR_DEBUG_INTRO=${FG_MAGENTA}
COLOR_INFO_INTRO=${FG_GREEN}
COLOR_WARN_INTRO=${FG_YELLOW}
COLOR_ERROR_INTRO=${FG_RED}
COLOR_FATAL_INTRO=${BOLD}${FG_RED}

# Default use terminal color for text, except for error/fatal.
COLOR_TRACE_TEXT=
COLOR_DEBUG_TEXT=
COLOR_INFO_TEXT=
COLOR_WARN_TEXT=
COLOR_ERROR_TEXT=${FG_RED}
COLOR_FATAL_TEXT=${FG_RED}

# -------------------------------------------------------
#
# @description Output text to standard out.
#
# Does not embelish text with any introducer or color.
#
# @arg $1 ... all args are printed to stdout
#
# @exitcode 0 in all cases
#
# @example
#     ksl::stdOut "${scriptName} v${scriptVersion}"
#
# @stdout all the args  <p><p>![](../images/pub/divider-line.png)
#
ksl::stdOut()
{
    echo -e "$*"
}

# -------------------------------------------------------
#
# @description Output text to standard error.
#
# Does not embelish text with any introducer or color.
#
# @arg $1 ... all args are printed to stdout
#
# @exitcode 0 in all cases
#
# @example
#     ksl::stdErr "${scriptName} v${scriptVersion}"
#
# @stderr all the args  <p><p>![](../images/pub/divider-line.png)
#
ksl::stdErr()
{
    echo -e "$*" 1>&2
}

# -------------------------------------------------------
#
# @description Output message to standard out prefaced by `[TRACE]`.
#
# If [ksl::useColor](libColor.html#kslusecolor) is true then
# colors are applied.
#
# @set COLOR_TRACE_INTRO string the color to use for the introducer
# @set COLOR_TRACE_TEXT string the color to use for the text following the introducer
#
# @arg $1 ... all args are printed to stdout
#
# @exitcode 0 in all cases
#
# @example
#     ksl::stdTrace "Entered: showConfig()"
#     outputs: [TRACE] Entered: showConfig()
#
# @stdout [TRACE] followed by all the args  <p><p>![](../images/pub/divider-line.png)
#
ksl::stdTrace()
{
    local beforeIntro="" beforeText="" after=""
    if ksl::useColor; then
        beforeIntro="${COLOR_TRACE_INTRO}"
        beforeText="${COLOR_TRACE_TEXT}"
        after="${CLEAR}"
    fi

    ksl::stdOut "${beforeIntro}[TRACE]${after} ${beforeText}$*${after}"
}

# -------------------------------------------------------
#
# @description Output message to standard out prefaced by `[DEBUG]`.
#
# If [ksl::useColor](libColor.html#kslusecolor) is true then
# colors are applied.
#
# @set COLOR_DEBUG_INTRO string the color to use for the introducer
# @set COLOR_DEBUG_TEXT string the color to use for the text following the introducer
#
# @arg $1 ... all args are printed to stdout
#
# @exitcode 0 in all cases
#
# @example
#     ksl::stdDebug "Entered: showConfig()"
#     outputs: [DEBUG] Entered: showConfig()
#
# @stdout [DEBUG] followed by all the args  <p><p>![](../images/pub/divider-line.png)
#
ksl::stdDebug()
{
    local beforeIntro="" beforeText="" after=""
    if ksl::useColor; then
        beforeIntro="${COLOR_DEBUG_INTRO}"
        beforeText="${COLOR_DEBUG_TEXT}"
        after="${CLEAR}"
    fi
    ksl::stdOut "${beforeIntro}[DEBUG]${after} ${beforeText}$*${after}"
}

# -------------------------------------------------------
#
# @description Output message to standard out prefaced by `[INFO]`.
#
# If [ksl::useColor](libColor.html#kslusecolor) is true then
# colors are applied.
#
# @set COLOR_INFO_INTRO string the color to use for the introducer
# @set COLOR_INFO_TEXT string the color to use for the text following the introducer
#
# @arg $1 ... all args are printed to stdout
#
# @exitcode 0 in all cases
#
# @example
#     ksl::stdInfo "Entered: showConfig()"
#     outputs: [INFO] Entered: showConfig()
#
# @stdout [INFO] followed by all the args  <p><p>![](../images/pub/divider-line.png)
#
ksl::stdInfo()
{
    local beforeIntro="" beforeText="" after=""
    if ksl::useColor; then
        beforeIntro="${COLOR_INFO_INTRO}"
        beforeText="${COLOR_INFO_TEXT}"
        after="${CLEAR}"
    fi
    ksl::stdOut "${beforeIntro}[INFO]${after} ${beforeText}$*${after}"
}

# -------------------------------------------------------
#
# @description Output message to standard out prefaced by `[WARN]`.
#
# If [ksl::useColor](libColor.html#kslusecolor) is true then
# colors are applied.
#
# @set COLOR_WARN_INTRO string the color to use for the introducer
# @set COLOR_WARN_TEXT string the color to use for the text following the introducer
#
# @arg $1 ... all args are printed to stdout
#
# @exitcode 0 in all cases
#
# @example
#     ksl::stdWarn "Entered: showConfig()"
#     outputs: [WARN] Entered: showConfig()
#
# @stdout [WARN] followed by all the args  <p><p>![](../images/pub/divider-line.png)
#
ksl::stdWarn()
{
    local beforeIntro="" beforeText="" after=""
    if ksl::useColor; then
        beforeIntro="${COLOR_WARN_INTRO}"
        beforeText="${COLOR_WARN_TEXT}"
        after="${CLEAR}"
    fi
    ksl::stdOut "${beforeIntro}[WARN]${after} ${beforeText}$*${after}"
}

# -------------------------------------------------------
#
# @description Output message to standard error prefaced by `[ERROR]`.
#
# If [ksl::useColor](libColor.html#kslusecolor) is true then
# colors are applied.
#
# @set COLOR_ERROR_INTRO string the color to use for the introducer
# @set COLOR_ERROR_TEXT string the color to use for the text following the introducer
#
# @arg $1 ... all args are printed to stderr
#
# @exitcode 0 in all cases
#
# @example
#     ksl::stdError "Entered: showConfig()"
#     outputs: [ERROR] Entered: showConfig()
#
# @stderr [ERROR] followed by all the args  <p><p>![](../images/pub/divider-line.png)
#
ksl::stdError()
{
    local beforeIntro="" beforeText="" after=""
    if ksl::useColor; then
        beforeIntro="${COLOR_ERROR_INTRO}"
        beforeText="${COLOR_ERROR_TEXT}"
        after="${CLEAR}"
    fi
    ksl::stdErr "${beforeIntro}[ERROR]${after} ${beforeText}$*${after}"
}

# -------------------------------------------------------
#
# @description Output message to standard error prefaced by `[FATAL]`.
#
# If [ksl::useColor](libColor.html#kslusecolor) is true then
# colors are applied.
#
# @set COLOR_FATAL_INTRO string the color to use for the introducer
# @set COLOR_FATAL_TEXT string the color to use for the text following the introducer
#
# @arg $1 ... all args are printed to stderr
#
# @exitcode 0 in all cases
#
# @example
#     ksl::stdFatal "Entered: showConfig()"
#     outputs: [FATAL] Entered: showConfig()
#
# @stderr [FATAL] followed by all the args <p><p>![](../images/pub/divider-line.png)
#
ksl::stdFatal()
{
    local beforeIntro="" beforeText="" after=""
    if ksl::useColor; then
        beforeIntro="${COLOR_FATAL_INTRO}"
        beforeText="${COLOR_FATAL_TEXT}"
        after="${CLEAR}"
    fi
    ksl::stdErr "${beforeIntro}[FATAL]${after} ${beforeText}$*${after}"
}

# -------------------------------------------------------

# -----------------------------------------------------------
#
# @name libColors
# @brief Functions to help with color.
#
# @description
#
# Functions to help with color.
#
# Contains the following:
#
#     * ksl::isColorCapable()
#     * ksl::enableColor()
#     * ksl::disableColor()
#     * ksl::useColor()
#
# Sourcing `libColors.bash` implicitly calls `ksl::enableColor()` and if
# the terminal is capable of color, `KSL_USE_COLOR` is set to true. So
# an application does not need to do anything additional. If desired,
# applications can call `ksl::useColor()` if they need to test for
# color.
#
# Also provides the following shell variables that
# help with colors.
#
# * ESC
# * FG
# * BG
#
# * FG_BLACK
# * FG_RED
# * FG_GREEN
# * FG_YELLOW
# * FG_BLUE
# * FG_MAGENTA
# * FG_CYAN
# * FG_WHITE
# * FG_ORANGE
#
# * BG_BLACK
# * BG_RED
# * BG_GREEN
# * BG_YELLOW
# * BG_BLUE
# * BG_MAGENTA
# * BG_CYAN
# * BG_WHITE
# * BG_ORANGE
#
# * CLEAR
# * BOLD
# * DIM
# * UNDERLINE
# * BLINK
# * REVERSE
# * HIDDEN
#
# -----------------------------------------------------------

# Avoid double inclusion, but optionally allow a forcing option
# mainly for developers. For example: "source libStdOut -f"
#
[[ -v libColorImported ]] && [[ "$1" != "-f" ]] && return
libColorImported=true

export KSL_USE_COLOR=false

export ESC="\033"
export FG="${ESC}[38;5;0;"
export BG="${ESC}[48;5;0;"

export FG_BLACK="${FG}30m"
export FG_RED="${FG}31m"
export FG_GREEN="${FG}32m"
export FG_YELLOW="${FG}33m"
export FG_BLUE="${FG}34m"
export FG_MAGENTA="${FG}35m"
export FG_CYAN="${FG}36m"
export FG_WHITE="${FG}37m"
export FG_ORANGE="${FG}91m"

export BG_BLACK="${BG}40m"
export BG_RED="${BG}41m"
export BG_GREEN="${BG}42m"
export BG_YELLOW="${BG}43m"
export BG_BLUE="${BG}44m"
export BG_MAGENTA="${BG}45m"
export BG_CYAN="${BG}46m"
export BG_WHITE="${BG}47m"
export BG_ORANGE="${BG}101m"

export CLEAR="${ESC}[0m"
export BOLD="${ESC}[1m"
export DIM="${ESC}[2m"
export UNDERLINE="${ESC}[4m"
export BLINK="${ESC}[5m"
export REVERSE="${ESC}[7m"
export HIDDEN="${ESC}[8m"

# -----------------------------------------------------------
#
# @description Determines if the terminal is capable of color.
#
# @noargs
#
# @exitcode 0 terminal is capable of color
# @exitcode 1 terminal is not capable of color <p><p>![](../images/pub/divider-line.png)
#
# @example
#     if ksl::isColorCapable; then echo yes; fi
#
ksl::isColorCapable()
{
    # -t fd True if file descriptor fd is open and refers to a terminal.
    if [[ ! -t 1 ]]; then
        return 1     # not color capable
    fi
    
    if ! tput colors 2>/dev/null; then
        return 1     # not color capable
    fi

    [[ $(tput colors) -ge 8 ]] && return 0
    return 1    # not color capable
    
#    local val=$(tput colors)
#    [[ -t 1 && $val -ge 8 ]]
}

# -----------------------------------------------------------
#
# @description Enables color if terminal is capable.
#
# This is called implicitly once, when the `libColors.bash` is sourced.
#
# @set KSL_USE_COLOR boolean set to true or false
#
# @noargs
#
# @exitcode 0 if terminal is color capable and KSL_USE_COLOR is set to true
# @exitcode 1 terminal is not color capable and KSL_USE_COLOR remains unchanged <p><p>![](../images/pub/divider-line.png)
#
# @example
#     ksl::enableColor
#
ksl::enableColor()
{
    ksl::isColorCapable && KSL_USE_COLOR=true
}

# -----------------------------------------------------------
#
# @description Disables color.
#
# @set KSL_USE_COLOR boolean sets it to false
#
# @noargs
#
# @exitcode 0 in all cases <p><p>![](../images/pub/divider-line.png)
#
# @example
#     ksl::disableColor
#
ksl::disableColor()
{
    KSL_USE_COLOR=false
}

# -----------------------------------------------------------
#
# @description Returns true if color is enabled.
#
# @set KSL_USE_COLOR boolean returns value of this variable
#
# @noargs
#
# @exitcode 0 if KSL_USE_COLOR is true
# @exitcode 1 if KSL_USE_COLOR is false <p><p>![](../images/pub/divider-line.png)
#
# @example
#     if ksl::useColor; then echo yes; fi
#
ksl::useColor()
{
    ${KSL_USE_COLOR}
}

# -----------------------------------------------------------

# GitHub pipeline sensitive to enableColor() returning false
[[ ksl::enableColor || : ]]

# -----------------------------------------------------------

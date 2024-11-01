# -----------------------------------------------------------
#
# Functions to help with color.
#
# Contains the following:
#
#     ksl::isColorCapable()
#     ksl::enableColor()
#     ksl::disableColor()
#
# -----------------------------------------------------------

# Avoid double inclusion, but optionally allow a forcing option
# mainly for developers. For example: "source libStdOut -f"
#
[ -v libColorImported ] && [ "$1" != "-f" ] && return
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
# See if terminal supports colors.
#
ksl::isColorCapable()
{
    [[ -t 1 && "$(tput colors)" -ge 8 ]]
}

# -----------------------------------------------------------

ksl::enableColor()
{
    ksl::isColorCapable && KSL_USE_COLOR=true
}

# -----------------------------------------------------------

ksl::disableColor()
{
    KSL_USE_COLOR=false
}

# -----------------------------------------------------------

# Enable color if terminal is capable
ksl::enableColor

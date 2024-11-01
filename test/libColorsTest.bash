#!/usr/bin/env bash

source "${KSL_BASH_LIB}"/libColors.bash

# -----------------------------------------------------------

test_isColorCapable()
{
    ksl::isColorCapable
    assert "[[ $? -eq 0 || $? -gt 0 ]]"
}

# -----------------------------------------------------------

test_enableColor()
{
    if ksl::enableColor; then
        assert "[ -n "${KSL_USE_COLOR}" ]"
        assert "[[ "${KSL_USE_COLOR}" == "true" || "${KSL_USE_COLOR}" == "false" ]]"
    fi
}
# -----------------------------------------------------------

printIt()
{
    echo -e "\t${1}${2}${CLEAR}"
}

# -----------------------------------------------------------

test_fgColors()
{
    echo
    printIt "${FG_BLACK}"   "This message is in foreground black"
    printIt "${FG_RED}"     "This message is in foreground red"
    printIt "${FG_GREEN}"   "This message is in foreground green"
    printIt "${FG_YELLOW}"  "This message is in foreground yellow"
    printIt "${FG_BLUE}"    "This message is in foreground blue"
    printIt "${FG_MAGENTA}" "This message is in foreground magenta"
    printIt "${FG_CYAN}"    "This message is in foreground cyan"
    printIt "${FG_WHITE}"   "This message is in foreground white"
    printIt "${FG_ORANGE}"  "This message is in foreground orange"
}

test_bgColors()
{
    echo
    printIt "${BG_BLACK}"   "This message is in background black"
    printIt "${BG_RED}"     "This message is in background red"
    printIt "${BG_GREEN}"   "This message is in background green"
    printIt "${BG_YELLOW}"  "This message is in background yellow"
    printIt "${BG_BLUE}"    "This message is in background blue"
    printIt "${BG_MAGENTA}" "This message is in background magenta"
    printIt "${BG_CYAN}"    "This message is in background cyan"
    printIt "${BG_WHITE}"   "This message is in background white"
    printIt "${BG_ORANGE}"  "This message is in background orange"
}

# -----------------------------------------------------------

test_boldColors()
{
    echo
    printIt "${BOLD}${FG_BLACK}"   "This message is in bold black"
    printIt "${BOLD}${FG_RED}"     "This message is in bold red"
    printIt "${BOLD}${FG_GREEN}"   "This message is in bold green"
    printIt "${BOLD}${FG_YELLOW}"  "This message is in bold yellow"
    printIt "${BOLD}${FG_BLUE}"    "This message is in bold blue"
    printIt "${BOLD}${FG_MAGENTA}" "This message is in bold magenta"
    printIt "${BOLD}${FG_CYAN}"    "This message is in bold cyan"
    printIt "${BOLD}${FG_WHITE}"   "This message is in bold white"
    printIt "${BOLD}${FG_ORANGE}"  "This message is in bold orange"
}

# -----------------------------------------------------------

test_dimColors()
{
    echo
    printIt "${DIM}${FG_BLACK}"   "This message is in dim black"
    printIt "${DIM}${FG_RED}"     "This message is in dim red"
    printIt "${DIM}${FG_GREEN}"   "This message is in dim green"
    printIt "${DIM}${FG_YELLOW}"  "This message is in dim yellow"
    printIt "${DIM}${FG_BLUE}"    "This message is in dim blue"
    printIt "${DIM}${FG_MAGENTA}" "This message is in dim magenta"
    printIt "${DIM}${FG_CYAN}"    "This message is in dim cyan"
    printIt "${DIM}${FG_WHITE}"   "This message is in dim white"
    printIt "${DIM}${FG_ORANGE}"  "This message is in dim orange"
}

# -----------------------------------------------------------

test_underlineColors()
{
    echo
    printIt "${UNDERLINE}${FG_BLACK}"   "This message is in underline black"
    printIt "${UNDERLINE}${FG_RED}"     "This message is in underline red"
    printIt "${UNDERLINE}${FG_GREEN}"   "This message is in underline green"
    printIt "${UNDERLINE}${FG_YELLOW}"  "This message is in underline yellow"
    printIt "${UNDERLINE}${FG_BLUE}"    "This message is in underline blue"
    printIt "${UNDERLINE}${FG_MAGENTA}" "This message is in underline magenta"
    printIt "${UNDERLINE}${FG_CYAN}"    "This message is in underline cyan"
    printIt "${UNDERLINE}${FG_WHITE}"   "This message is in underline white"
    printIt "${UNDERLINE}${FG_ORANGE}"   "This message is in underline orange"
}

# -----------------------------------------------------------

test_reverseColors()
{
    echo
    printIt "${REVERSE}${FG_BLACK}"   "This message is in reverse black"
    printIt "${REVERSE}${FG_RED}"     "This message is in reverse red"
    printIt "${REVERSE}${FG_GREEN}"   "This message is in reverse green"
    printIt "${REVERSE}${FG_YELLOW}"  "This message is in reverse yellow"
    printIt "${REVERSE}${FG_BLUE}"    "This message is in reverse blue"
    printIt "${REVERSE}${FG_MAGENTA}" "This message is in reverse magenta"
    printIt "${REVERSE}${FG_CYAN}"    "This message is in reverse cyan"
    printIt "${REVERSE}${FG_WHITE}"   "This message is in reverse white"
    printIt "${REVERSE}${FG_ORANGE}"  "This message is in reverse orange"
}

# -----------------------------------------------------------

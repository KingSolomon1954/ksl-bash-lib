# -----------------------------------------------------------
#
# Submake to import color variables
#
# -----------------------------------------------------------

ifndef _INCLUDE_COLORS_MAK
_INCLUDE_COLORS_MAK := 1

ESC=\\033
FG=$(ESC)[38;5;0;
BG=$(ESC)[48;5;0;

FG_BLACK=$(FG)30m
FG_RED=$(FG)31m
FG_GREEN=$(FG)32m
FG_YELLOW=$(FG)33m
FG_BLUE=$(FG)34m
FG_MAGENTA=$(FG)35m
FG_CYAN=$(FG)36m
FG_WHITE=$(FG)37m
FG_ORANGE=$(FG)91m

BG_BLACK=$(BG)40m
BG_RED=$(BG)41m
BG_GREEN=$(BG)42m
BG_YELLOW=$(BG)43m
BG_BLUE=$(BG)44m
BG_MAGENTA=$(BG)45m
BG_CYAN=$(BG)46m
BG_WHITE=$(BG)47m
BG_ORANGE=$(BG)101m

CLEAR=$(ESC)[0m
BOLD=$(ESC)[1m
DIM=$(ESC)[2m
UNDERLINE=$(ESC)[4m
BLINK=$(ESC)[5m
REVERSE=$(ESC)[7m
HIDDEN=$(ESC)[8m

endif

# -----------------------------------------------------------------
#
# This submake supplies the common help target.
#
# Prints out section from Makefile between two sentinels.
#
# -----------------------------------------------------------------
#
ifndef _INCLUDE_HELP_MAK
_INCLUDE_HELP_MAK := 1

help:
	@sed -n "/^# *Start Section/,/^# *End Section/p" Makefile | \
	sed -e "/^# Start Section/d" -e "/^# End Section/d" | \
	colrm 1 2
	@yellow="\033[33m"; green="\033[32m"; clear="\033[0m"; \
	echo "$${green}-------------- $${yellow}Targets$${green} --------------${clear}"
	@echo
	@echo $(HELP_TXT) | \
	sed '/^[[:space:]]*$$/d' | \
	sed 's/^[[:space:]]*//g' | \
	sort | \
	awk 'BEGIN { FS="," ; longest=0 } \
	    { \
	        count++; \
	        left[count] = $$1; \
	        right[count] = $$2; \
	        sub(/^[ \n\r\t]+/, "", right[count]) ; \
	        if (length(left[count]) > longest) { \
	            longest = length(left[count]) \
	        } \
	    } \
	    END { \
	        yellow = "\033[33m"; green = "\033[32m"; clear = "\033[0m"; \
	        for (i = 1; i <= count; i++) \
	        { \
	            printf "%s%-*s %s- %s%s\n", \
	                yellow, longest, left[i], \
	                green, right[i], clear \
	        } \
	    } \
	'
.PHONY: help

HELP_TXT += "\n\
help, Displays help information and targets\n\
"
endif

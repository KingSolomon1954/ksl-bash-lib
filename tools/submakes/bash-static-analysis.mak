# -----------------------------------------------------------------
#
# Submake rules to run C++ static analysis tool
#
# -----------------------------------------------------------------

ifndef _INCLUDE_BASH_STA_MAK
_INCLUDE_BASH_STA_MAK := 1

ifndef D_BLD
    $(error Parent makefile must define 'D_BLD')
endif
ifndef D_MAK
    $(error Parent makefile must define 'D_MAK')
endif
ifndef D_TOOLS
    $(error Parent makefile must define 'D_TOOLS)
endif

include $(D_MAK)/container-tech.mak
include $(D_MAK)/container-names-shellcheck.mak
include $(D_MAK)/colors.mak

# ------------ Setup Section ------------

# Using STA as the mnemonic for static analysis

_D_STA_OUT     := $(D_BLD)/static-analysis
_F_STA_RESULTS := $(D_BLD)/static-analysis/results.txt
_F_STA_BADGE   := $(D_BLD)/static-analysis/badge.yml

# ------------ Repo Analysis Section ------------

static-analysis: static-analysis-report

static-analysis-report: $(_F_STA_BADGE)

# Running shellcheck command inside an if statement because, if there
# are shellcheck findings, the shellcheck tool exits with an error which
# in turn causes make to report an error and exit the build right then
# and there. Using "-" in front of the call tells make to ignore the
# error and that works, but make still reports the error to the
# screen. The developer then think there was problem running the
# tool. The tool ran successfully and did its job. The fact that there
# are shellcheck findings is not a a runtime error. The if statement is
# used to silently consumes the return code.

_FRAG_STA_RESULTS = $(BOLD)Find results ($${value} findings) in:$(CLEAR)$(FG_YELLOW) \"$@\" $(CLEAR)

$(_F_STA_RESULTS): _create-sta_dirs
	# Running shellcheck analysis against repo
	@if $(CNTR_TECH) run --rm -t \
	    --volume $(PWD):/mnt \
	    $(CNTR_SHELLCHECK_TOOLS_PATH) \
	    -P lib $(wildcard lib/*.bash) > $@; then :; fi
	@value=$$(grep -c "line " $@); \
	echo "$(_FRAG_STA_RESULTS)"

$(_F_STA_BADGE): $(_F_STA_RESULTS)
	@value=$$(grep -c "line " $<); \
	echo "badge:" > $@; \
	echo "  findings: $${value}" >> $@

static-analysis-clean:
	rm -rf $(_D_STA_OUT)

_create-sta_dirs:
	@mkdir -p $(_D_STA_OUT)

.PHONY: static-analysis static-analysis-clean \
        static-analysis-report _create-sta_dirs

# ------------ Individual File Analysis Section ------------

%.sta : %.bash
	# Running shellcheck analysis against "$^"
	# Results are output to screen
	@if $(CNTR_TECH) run -t --rm \
	    --volume $(PWD):/mnt \
	    $(CNTR_SHELLCHECK_TOOLS_PATH) \
	    -P lib -x $^; then \
	    echo "$(BOLD)Results:$(CLEAR)$(FG_YELLOW) 0 findings$(CLEAR)"; \
	fi

# ------------ Help Section ------------

static-analysis-help: $(_STA_HELP_FILE)
	@$(_STA_HELP_FILE) $(D_MAK)

.PHONY: static-analysis-help

HELP_TXT += "\n\
<filepath>.sta,        Runs Bash static analysis on given file\n\
static-analysis,       Runs Bash static analysis against repo\n\
static-analysis-clean, Deletes Bash static analysis artifacts\n\
static-analysis-help,  Displays help for Bash static analysis\n\
"

endif

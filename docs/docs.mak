# -------------------------------------------------------
#
# Submake to build auto-documentation targets
#
# -------------------------------------------------------

ifndef _INCLUDE_DOCS_MAK
_INCLUDE_DOCS_MAK := 1

ifndef D_BLD
    $(error Parent makefile must define 'D_BLD')
endif

docs:
	@echo "Not implemented yet"

docs-clean:
	@echo "Not implemented yet"

.PHONY: docs

# ------------ Help Section ------------

HELP_TXT += "\n\
docs,       Builds all the docs\n\
docs-clean, Deletes generated docs\n\
"
endif

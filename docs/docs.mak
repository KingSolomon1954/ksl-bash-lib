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
ifndef D_MAK
    $(error Parent makefile must define 'D_MAK')
endif

D_DOCS_BLD   := $(D_BLD)/docs/src
D_DOCS_SITE  := $(D_BLD)/docs/site

docs: docs-prep-out docs-shdoc docs-sphinx 

docs-sphinx: docs-shdoc-cmd docs-sphinx-cmd

docs-shdoc: docs-sphinx 

docs-clean:
	rm -rf $(D_DOCS_BLD) $(D_DOCS_SITE)

# Always remove and then recreate docs tree
# so to catch deleted files between runs.
#
docs-prep-out:
	rm -rf   $(D_DOCS_BLD) $(D_DOCS_SITE)
	mkdir -p $(D_DOCS_BLD)
	cp -r $(D_DOCS)/src/* $(D_DOCS_BLD)

.PHONY: docs          docs-clean \
        docs-sphinx   docs-shdoc \
        docs-prep-out

include $(D_MAK)/docs-sphinx.mak
include $(D_MAK)/docs-shdoc.mak

# ------------ Help Section ------------

HELP_TXT += "\n\
docs,        Builds all the docs\n\
docs-sphinx, Generates only Sphinx docs\n\
docs-shdoc,  Generates only bash API docs\n\
docs-clean,  Deletes generated docs\n\
"
endif

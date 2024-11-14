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
ifndef D_DOCS
    $(error Parent makefile must define 'D_DOCS')
endif

D_BLD_DOCS := $(D_BLD)/docs/src
D_BLD_SITE := $(D_BLD)/docs/site
D_PUB_SITE := $(D_DOCS)/site

docs: docs-prep-out docs-sphinx

docs-sphinx: docs-shdoc docs-sphinx-cmd docs-examples

docs-shdoc: docs-shdoc-cmd

docs-examples: docs-examples-cmd

docs-clean:
	rm -rf $(D_BLD_DOCS) $(D_BLD_SITE)

# Always remove and then recreate docs tree
# so to catch deleted files between runs.
#
docs-prep-out:
	rm -rf   $(D_BLD_DOCS) $(D_BLD_SITE)
	mkdir -p $(D_BLD_DOCS)
	cp -r $(D_DOCS)/src/* $(D_BLD_DOCS)

.PHONY: docs          docs-clean \
        docs-sphinx   docs-shdoc \
        docs-prep-out

include $(D_MAK)/docs-sphinx.mak
include $(D_MAK)/docs-shdoc.mak
include $(D_MAK)/docs-publish.mak

# ------------ Help Section ------------

HELP_TXT += "\n\
docs,        Builds all the docs\n\
docs-sphinx, Generates only Sphinx docs\n\
docs-shdoc,  Generates only bash API docs\n\
docs-clean,  Deletes generated docs\n\
"
endif

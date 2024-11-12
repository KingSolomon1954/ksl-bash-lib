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
ifndef D_TOOLS
    $(error Parent makefile must define 'D_TOOLS')
endif

include $(D_MAK)/container-tech.mak
include $(D_MAK)/container-names-pandoc.mak

_D_DOCS_OUT := $(D_BLD)/docs
SHDOC       := $(D_TOOLS)/shdoc/shdoc

docs: docs-src

docs-src: $(addsuffix .rst,$(basename $(wildcard lib/*.bash)))

%.rst : %.md
	# Converting it to $@
	$(CNTR_TECH) run -t --rm \
	    --volume $(PWD):/work \
	    $(CNTR_PANDOC_TOOLS_PATH) \
	    -s /work/$(_D_DOCS_OUT)/$^ \
	    -t rst -o /work/$(_D_DOCS_OUT)/lib/$(@F)

# $(CNTR_TECH) run --rm --volume=$(pwd):/work pandoc/core
# -s /work/_build/docs/libArrays.md
# -t rst -o /work/_build/docs/libArrays.rst

%.md : %.bash $(_D_DOCS_OUT)/lib
	# Creating $@
	$(SHDOC) < $(<) > _build/docs/lib/$(@F)

$(_D_DOCS_OUT)/lib:
	mkdir -p $@

docs-clean:
	rm -rf $(_D_DOCS_OUT)

.PHONY: docs

# ------------ Help Section ------------

HELP_TXT += "\n\
docs,       Builds all the docs\n\
docs-src,   Builds API docs from bash sources\n\
docs-clean, Deletes generated docs\n\
"
endif

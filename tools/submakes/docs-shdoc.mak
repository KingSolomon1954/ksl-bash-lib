# -------------------------------------------------------
#
# Submake to build shdoc docs
#
# -------------------------------------------------------

ifndef _INCLUDE_SHDOC_MAK
_INCLUDE_SHDOC_MAK := 1

ifndef D_MAK
    $(error Parent makefile must define 'D_MAK')
endif
ifndef D_TOOLS
    $(error Parent makefile must define 'D_TOOLS')
endif
ifndef D_BLD_DOCS
    $(error Parent makefile must define 'D_BLD_DOCS')
endif

_SHDOC := $(D_TOOLS)/shdoc/shdoc

include $(D_MAK)/container-tech.mak
include $(D_MAK)/container-names-pandoc.mak

docs-shdoc-cmd: $(addsuffix .rst,$(basename $(wildcard lib/*.bash)))

%.rst : %.md
	# Converting it to $@
	$(CNTR_TECH) run -t --rm \
	    --volume $(PWD):/work \
	    $(CNTR_PANDOC_TOOLS_PATH) \
	    -s /work/$(D_BLD_DOCS)/shdoc/$(^F) \
	    -t rst -o /work/$(D_BLD_DOCS)/shdoc/$(@F)

%.md : %.bash $(D_BLD_DOCS)/shdoc
	# Creating $(D_BLD_DOCS)/shdoc/$(@F)
	$(_SHDOC) < $(<) > $(D_BLD_DOCS)/shdoc/$(@F)

$(D_DOCS_BLD)/shdoc:
	mkdir -p $@

.PHONY: docs-shdoc-cmd

endif

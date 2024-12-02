# -------------------------------------------------------
#
# Submake to build Sphinx docs
#
# -------------------------------------------------------

ifndef _INCLUDE_DOCS_SPHINX_MAK
_INCLUDE_DOCS_SPHINX_MAK := 1

ifndef D_MAK
    $(error Parent makefile must define 'D_MAK')
endif
ifndef D_EXA
    $(error Parent makefile must define 'D_EXA')
endif
ifndef D_BLD_DOCS
    $(error Parent makefile must define 'D_BLD_DOCS')
endif
ifndef D_BLD_SITE
    $(error Parent makefile must define 'D_BLD_SITE')
endif

include $(D_MAK)/container-tech.mak
include $(D_MAK)/container-names-sphinx.mak

docs-sphinx-cmd:
	# Generating Sphinx docs
	$(CNTR_TECH) run --rm \
	    --user=$(CNTR_USER) \
	    --volume=$$(pwd):/work -it \
	    $(CNTR_SPHINX_TOOLS_PATH) sphinx-build -b html -a \
	    -D release=$(VERSION_TRIPLET) \
	    -D version=$(VERSION_TRIPLET) \
	    --jobs auto \
	    /work/$(D_BLD_DOCS) /work/$(D_BLD_SITE)

#	    --fail-on-warning \

.PHONY: docs-sphinx-cmd

docs-examples-cmd:
	cp $(D_EXA)/example-error-pass.bash $(D_BLD_SITE)/shdoc/

endif

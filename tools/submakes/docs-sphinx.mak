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
ifndef D_DOCS_BLD
    $(error Parent makefile must define 'D_DOCS_BLD')
endif
ifndef D_DOCS_SITE
    $(error Parent makefile must define 'D_DOCS_SITE')
endif

include $(D_MAK)/container-tech.mak
include $(D_MAK)/container-names-sphinx.mak

_DOCS_SRC := $(D_DOCS)/src

docs-sphinx-cmd:
	# Generating Sphinx docs
	$(CNTR_TECH) run --rm \
	    --user=$(CNTR_USER) \
	    --volume=$$(pwd):/work -it \
	    $(CNTR_SPHINX_TOOLS_PATH) sphinx-build -b html -a \
	    -D release=$(VERSION_TRIPLET) \
	    -D version=$(VERSION_TRIPLET) \
	    --jobs auto \
	    /work/$(D_DOCS_BLD) /work/$(D_DOCS_SITE)

#	    --fail-on-warning \


.PHONY: docs-sphinx-cmd

docs-examples-cmd:
	cp etc/examples/example-error-pass.bash $(D_DOCS_SITE)/shdoc/

endif

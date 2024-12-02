# -----------------------------------------------------------------
#
# This submake provides standard variables for pandoc
#
# -----------------------------------------------------------------
#
ifndef _INCLUDE_CONTAINER_PANDOC_NAMES_MAK
_INCLUDE_CONTAINER_PANDOC_NAMES_MAK := 1

CNTR_PANDOC_TOOLS_REPO  ?= docker.io
CNTR_PANDOC_TOOLS_IMAGE ?= pandoc/core
CNTR_PANDOC_TOOLS_VER   ?= latest
CNTR_PANDOC_TOOLS_PATH  ?= $(CNTR_PANDOC_TOOLS_REPO)/$(CNTR_PANDOC_TOOLS_IMAGE):$(CNTR_PANDOC_TOOLS_VER)
CNTR_PANDOC_TOOLS_NAME  ?= pandoc

endif

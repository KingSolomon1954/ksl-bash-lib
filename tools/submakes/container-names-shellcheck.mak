# -----------------------------------------------------------------
#
# This submake provides standard variables for shellcheck
#
# -----------------------------------------------------------------
#
ifndef _INCLUDE_CONTAINER_SHELLCHECK_NAMES_MAK
_INCLUDE_CONTAINER_SHELLCHECK_NAMES_MAK := 1

CNTR_SHELLCHECK_TOOLS_REPO  ?= docker.io
CNTR_SHELLCHECK_TOOLS_IMAGE ?= koalaman/shellcheck
CNTR_SHELLCHECK_TOOLS_VER   ?= stable
CNTR_SHELLCHECK_TOOLS_PATH  ?= $(CNTR_SHELLCHECK_TOOLS_REPO)/$(CNTR_SHELLCHECK_TOOLS_IMAGE):$(CNTR_SHELLCHECK_TOOLS_VER)
CNTR_SHELLCHECK_TOOLS_NAME  ?= shellcheck

endif

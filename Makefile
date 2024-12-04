# -------------------------------------------------------
#
# File: Makefile
#
# Copyright (c) 2024 KingSolomon1954
#
# SPDX-License-Identifier: MIT
#
# -------------------------------------------------------
#
# Start Section
# KSL Bash Library
# End Section
#
# -------------------------------------------------------

TOP     := .
D_LIB   := $(TOP)/lib
D_DOCS  := $(TOP)/docs
D_TOOLS := $(TOP)/tools
D_TEST  := $(TOP)/test
D_ETC   := $(TOP)/etc
D_BLD   := $(TOP)/_build
D_MAK   := $(D_TOOLS)/submakes
D_SCP   := $(D_TOOLS)/scripts
D_CNTRS := $(D_TOOLS)/containers
D_EXA   := $(D_ETC)/examples

all: all-relay

include $(D_TEST)/unit-test.mak
include $(D_DOCS)/docs.mak
include $(D_MAK)/version-vars.mak
include $(D_MAK)/bash-static-analysis.mak
include $(D_MAK)/release-tarball.mak
include $(D_MAK)/help.mak

all-relay: unit-tests

.PHONY: all all-relay

# ------------ Help Section ------------

HELP_TXT += "\n\
all,   Build the repo\n\
"

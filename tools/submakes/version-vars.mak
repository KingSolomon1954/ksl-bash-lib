# -----------------------------------------------------------------
#
# Submake to setup version variables
#
# -----------------------------------------------------------------
#
# version file is expected in the root folder and named 
# "version". Contains a single line of text in following form:
# major.minor.patch

ifndef _INCLUDE_VERSION_VARS_MAK
_INCLUDE_VERSION_VARS_MAK := 1

VERSION_TRIPLET := $(shell cat version)
_VERSION_TRIPLET := $(subst ., ,$(VERSION_TRIPLET))
VERSION_MAJOR := $(word 1,$(_VERSION_TRIPLET))
VERSION_MINOR := $(word 2,$(_VERSION_TRIPLET))
VERSION_PATCH := $(word 3,$(_VERSION_TRIPLET))

endif

# -----------------------------------------------------------------
#
# This submake supplies the common CNTR_TECH variable
#
# Determines which container tool is available.
# Prefers Podman over Docker.
#
# Defines CNTR_TECH
#
# -----------------------------------------------------------------
#
ifndef _INCLUDE_CONTAINER_TECH_MAK
_INCLUDE_CONTAINER_TECH_MAK := 1

# The container technology (podman or docker)
CNTR_TECH := $(shell if which podman 1>&2 > /dev/null; then echo podman; else echo docker; fi)

# The effective user and group id of the host.
# If running a container as a non-root user, this user and group id
# may be used to preserve file permissions instead of creating files
# owned by root. This is an issue for WSL environments, but not OSX.
HOST_USER_GROUP_ID := $$(id -u):$$(id -g)

# Podman is rootless, meaning inside the user appears as root, but
# actually maps to the current user of the host system.
CNTR_USER := $(HOST_USER_GROUP_ID)
ifeq (podman,$(CNTR_TECH))
    CNTR_USER := root
endif

endif

# -----------------------------------------------------------------
#
# Submake to create a release tarball
# 
# -----------------------------------------------------------------

ifndef _INCLUDE_RELEASE_TARBALL_MAK
_INCLUDE_RELEASE_TARBALL_MAK := 1

ifndef D_BLD
    $(error Parent makefile must define 'D_BLD')
endif
ifndef D_LIB
    $(error Parent makefile must define 'D_LIB')
endif
ifndef D_DOCS
    $(error Parent makefile must define 'D_DOCS')
endif


# TAG_NAME=${LIB_NAME_FULL}-${{ github.ref_name }}
#	echo "TAR_FILE=${TAR_FILE}"       >> ${GITHUB_OUTPUT}
#	echo "LIB_VERSION=${LIB_VERSION}" >> ${GITHUB_OUTPUT}
#	echo "TAG_NAME=${TAG_NAME}"       >> ${GITHUB_OUTPUT}

# Create the release tarball in _build folder.
# Create 3 associated artifacts (files) to support
# handoff to GitHub release.
#
release-tarball:
	LIB_VERSION=v$$(cat version);\
	LIB_NAME="ksl-bash-lib-$${LIB_VERSION}" ;\
	D_REL=$(D_BLD)/release; \
	D_REL_FILES=$(D_BLD)/release/version/$${LIB_NAME}; \
	TAR_FILE=$${D_REL}/$${LIB_NAME}.tgz; \
	mkdir -p $${D_REL_FILES} $${D_REL_FILES}/docs; \
	cp -p $(D_LIB)/* $${D_REL_FILES}/; \
	cp -p -r $(D_DOCS)/site/* $${D_REL_FILES}/docs/; \
	tar -czf $${TAR_FILE} --directory=$${D_REL_FILES}/.. .; \
	echo "$${TAR_FILE}"    > $${D_REL}/tarfile-name; \
	echo "$${LIB_VERSION}" > $${D_REL}/lib-version; \
	echo "$${LIB_NAME}"    > $${D_REL}/lib-name

.PHONY: release-tarball

HELP_TXT += "\n\
release-tarball, Creates a release tarball\n\
"

endif

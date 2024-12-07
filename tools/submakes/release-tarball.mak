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

release-major: BUMP := major
release-major: release

release-minor: BUMP := minor
release-minor: release

release-patch: BUMP := patch
release-patch: release

# release: bump-version update-changelog docs docs-publish create-tarball test-tarball
# release: bump-version update-changelog docs docs-site create-tarball test-tarball
release: bump-version update-changelog create-tarball test-tarball

bump-version:
	@git checkout version   # Always start fresh, allow back-to-back runs
	@echo "Bumping \"$(BUMP)\" version"
	@echo "Old version: $$(cat version)"
	@$(D_SCP)/bump-version.bash $(BUMP) version
	@echo "New version: $$(cat version)"

update-changelog:
	@echo "Updating changelog"
	@touch etc/changelog.txt

_D_REL:=$(D_BLD)/release

# add version file, and changelog file to tarball
create-tarball:
	LIB_VERSION=$$(cat version);\
	LIB_NAME="ksl-bash-lib-$${LIB_VERSION}" ;\
	TAR_FILE=$(_D_REL)/$${LIB_NAME}.tgz; \
	TAR_TOP=$(_D_REL)/staging/$${LIB_NAME}; \
	mkdir -p $${TAR_TOP} $${TAR_TOP}/docs; \
	cp -p $(D_LIB)/* $${TAR_TOP}/; \
	cp -p -r $(D_DOCS)/site/* $${TAR_TOP}/docs/; \
	tar -czf $${TAR_FILE} --directory=$${TAR_TOP}/.. .

test-tarball:
	@echo "testing tarball"

# TAG_NAME=${LIB_NAME_FULL}-${{ github.ref_name }}
#	echo "TAR_FILE=${TAR_FILE}"       >> ${GITHUB_OUTPUT}
#	echo "LIB_VERSION=${LIB_VERSION}" >> ${GITHUB_OUTPUT}
#	echo "TAG_NAME=${TAG_NAME}"       >> ${GITHUB_OUTPUT}

# Create the release tarball in _build folder.
# Create 3 associated artifacts (files) to support
# handoff to GitHub release.
#
release-tarball-old:
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

release-clean:
	rm -rf $(_D_REL)

HELP_TXT += "\n\
create-tarball, Creates a release tarball\n\
release-clean,   Deletes release artifacts\n\
"

endif

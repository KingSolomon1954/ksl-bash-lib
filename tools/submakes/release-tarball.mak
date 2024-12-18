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

# Runs all the release targets similar to the Release workflow, but here
# nothing is actually checked-in or tagged. This allows for developing,
# debugging and confirming release targets and artifacts.

release: bump-version \
	 update-changelog \
	 docs \
	 docs-publish \
	 create-tarball \
	 test-tarball

bump-version:
	@git checkout version   # Always start fresh, allow back-to-back runs
	@echo "Bumping \"$(BUMP)\" version"
	@echo "Old version: $$(cat version)"
	@$(D_SCP)/bump-version.bash $(BUMP) version
	@echo "New version: $$(cat version)"

update-changelog:
	@echo "Updating changelog"
	@$(D_SCP)/update-changelog.bash > etc/changelog.md

_D_REL:=$(D_BLD)/release

create-tarball:
	LIB_VERSION=$$(cat version);\
	LIB_NAME="ksl-bash-lib-$${LIB_VERSION}" ;\
	TAR_FILE=$(_D_REL)/$${LIB_NAME}.tgz; \
	TAR_TOP=$(_D_REL)/staging/$${LIB_NAME}; \
	mkdir -p $${TAR_TOP} $${TAR_TOP}/docs; \
	cp -p $(D_LIB)/* $${TAR_TOP}/; \
	cp -p version $${TAR_TOP}/; \
	cp -p etc/changelog.md $${TAR_TOP}/; \
	cp -p -r $(D_DOCS)/site/* $${TAR_TOP}/docs/; \
	tar -czf $${TAR_FILE} --directory=$${TAR_TOP}/.. .; \
	# Create some handoff variables to simplify pipeline runs; \
	echo "$$LIB_VERSION" > $(_D_REL)/lib-version; \
	echo "$$LIB_NAME"    > $(_D_REL)/lib-name; \
	echo "$$TAR_FILE"    > $(_D_REL)/tarfile-name

test-tarball:
	@echo "Testing tarball"
	@$(D_SCP)/test-tarball.bash $(D_BLD) $$(cat $(_D_REL)/tarfile-name)

release-clean:
	rm -rf $(_D_REL)

.PHONY: create-tarball bump-version \
        update-changelog test-tarball \
        release-major release-minor \
        release-patch release-clean

# ------------ Help Section ------------

HELP_TXT += "\n\
create-tarball,   Creates a release tarball\n\
update-changelog, Updates changelog\n\
bump-version,     Update version file\n\
release-major,    Runs makefile targets for a major release\n\
release-minor,    Runs makefile targets for a minor release\n\
release-patch,    Runs makefile targets for a patch release\n\
release-clean,    Deletes release $(_D_REL) artifacts\n\
"

endif

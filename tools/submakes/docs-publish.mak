# -----------------------------------------------------------------
#
# Submake to prepare folder for publishing to GitHub Pages
# 
# -----------------------------------------------------------------

ifndef _INCLUDE_DOCS_PUBLISH_MAK
_INCLUDE_DOCS_PUBLISH_MAK := 1

ifndef D_BLD_SITE
    $(error Parent makefile must define 'D_BLD_SITE')
endif
ifndef D_PUB_SITE
    $(error Parent makefile must define 'D_PUB_SITE')
endif

# Always git remove first and then recreate the docs tree so to catch
# deleted files between commits.
#
# Also have to prevent GitHub actions from exiting with an error when
# issuing git commit and there are no published files that have changed.
# This is an expected use case.  See below the "or" "||" conditional 
# fragment with a null shell statement '|| ":"'
#
docs-publish:
	rm -rf $(D_PUB_SITE)/*
	mkdir -p $(D_PUB_SITE)
	cp -p -r $(D_BLD_SITE)/* $(D_PUB_SITE)/
	touch $(D_PUB_SITE)/.nojekyll

#	if git log docs/site/index.html > /dev/null 2>&1; then \
#	    git rm -q -r $(D_PUB_SITE)/*; \
#	fi
#	mkdir -p $(D_PUB_SITE)
#	cp -p -r $(D_BLD_SITE)/* $(D_PUB_SITE)/
#	touch $(D_PUB_SITE)/.nojekyll
#	git add -A $(D_PUB_SITE)
#	git commit -m "Publish documentation" || ":"
#	@echo "Reminder: issue \"git push\" when ready."

.PHONY: docs-publish

HELP_TXT += "\n\
docs-publish, Update $(D_PUB_SITE) with $(D_BLD_SITE) and checkin to Git\n\
"

endif

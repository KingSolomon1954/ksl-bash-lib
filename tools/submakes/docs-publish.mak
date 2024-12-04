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

# Always git remove and then recreate docs tree
# so to catch deleted files between commits.
#
docs-publish:
	if git log docs/site/index.html > /dev/null 2>&1; then \
	    git rm -q -r $(D_PUB_SITE)/*; \
	fi
	mkdir -p $(D_PUB_SITE)
	cp -p -r $(D_BLD_SITE)/* $(D_PUB_SITE)/
	touch $(D_PUB_SITE)/.nojekyll
	git add -A $(D_PUB_SITE)
	git commit -m "Publish documentation" || ":"
	# -git commit -m "Publish documentation"
	@echo "Reminder: issue \"git push\" when ready."

.PHONY: docs-publish

HELP_TXT += "\n\
docs-publish, Update $(D_PUB_SITE) with $(D_BLD_SITE) and checkin to Git\n\
"

endif

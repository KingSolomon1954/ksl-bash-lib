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

# Copy _build/docs/site/* --> docs/site/*
# Always remove existing files first and then recreate
# the docs tree so to catch deleted files between commits.
#
docs-publish:
	rm -rf $(D_PUB_SITE)/*
	mkdir -p $(D_PUB_SITE)
	cp -p -r $(D_BLD_SITE)/* $(D_PUB_SITE)/
	touch $(D_PUB_SITE)/.nojekyll

.PHONY: docs-publish

# ------------ Help Section ------------

HELP_TXT += "\n\
docs-publish, Update $(D_PUB_SITE) with $(D_BLD_SITE)\n\
"

endif

# ----------------------------------------------------------------
#
# conf.py for Sphinx docs
#
# ----------------------------------------------------------------
#
import os
import datetime

# For a full list of Sphinx options see:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- General -----------------------------------------------------

project = 'ksl-bash-lib'
author  = 'KingSolomon1954@github.com'
copyright = f'{datetime.datetime.now().year}, KingSolomon1954@github.com'

# -- File Setup --------------------------------------------------

root_doc = 'index'

# Add any Sphinx extension module names here, as strings. They can be
# extensions coming with Sphinx (named 'sphinx.ext.*') or your custom
# ones.
extensions = ["sphinx.ext.extlinks", "sphinx.ext.autosectionlabel"]

# Only parse files with `.rst` extension.
# Ensures that `.inc` files are not parsed, so they can be used with
# `.. include::` without creating duplicate labels.
source_suffix = ['.rst']

# Explicitly specify RST file locations
# Use `**` wildcard to include all subfolders recursively
include_patterns = ['index.rst',
                    'shdoc**',
                    'licenses**']

# exclude_patterns = ['misc/abc.rst']

suppress_warnings = ['autosectionlabel.*']

# -- Options for HTML output -------------------------------------

# The theme to use for HTML and HTML Help pages.  See the documentation for
# a list of builtin themes.
#
html_theme = 'sphinx_rtd_theme'

# Paths in this file are relative the location of conf.py itself. If conf.py is
# in the _build folder then paths are relative from there. If conf.py is in
# docs-src folder then relative to there.

# Add any paths that contain templates here, relative to this directory.
templates_path = [ "templates", "shared/templates"]

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
#
html_static_path = ["static"]

html_logo = "images/pub/blue-fire-icon-60x90.png"

# ----------------------------------------------------------------
#
# Global substitutions
rst_prolog = """
.. include:: /include/rst-prolog.rst
"""
rst_epilog = """
.. include:: /include/rst-epilog.rst
"""

# ----------------------------------------------------------------

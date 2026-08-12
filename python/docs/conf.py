# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

import os
import sys

# Add the project source directory to sys.path so autodoc can import it.
# Adjust this path if your package lives somewhere else.
sys.path.insert(0, os.path.abspath(".."))

# -- Project information -----------------------------------------------------

project = "mole"
copyright = "2026"
author = ""

# -- General configuration --------------------------------------------------

extensions = [
    "sphinx.ext.autodoc",
    "sphinx.ext.napoleon",
    "sphinx.ext.viewcode",
]

templates_path = ["_templates"]
exclude_patterns = ["_build", "Thumbs.db", ".DS_Store"]

# -- Options for HTML output ------------------------------------------------

html_theme = "alabaster"
html_static_path = ["_static"]

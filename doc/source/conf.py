import os
import sys

# -- Path setup --------------------------------------------------------------

# Add any paths that contain extensions or modules here, relative to this directory.
sys.path.insert(0, os.path.abspath('../../src'))

# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = 'MOLE Documentation'
copyright = '2024, CSRC/P'
author = 'CSRC/P'
release = '1.0.0'

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = [
    'sphinx.ext.autodoc',
    'sphinx.ext.viewcode',
    'sphinx.ext.napoleon',  # For Google and NumPy style docstrings
    'sphinx.ext.todo',
    'sphinx.ext.mathjax',
    'sphinx.ext.intersphinx',
    'breathe'  # For C++ API integration if using Doxygen
]

templates_path = ['_templates']
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']


# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = 'sphinx_rtd_theme'
html_static_path = ['_static']

# -- Options for todo extension ----------------------------------------------

todo_include_todos = True

# -- Intersphinx configuration -----------------------------------------------

intersphinx_mapping = {
    'python': ('https://docs.python.org/3', None),
    'numpy': ('https://numpy.org/doc/stable/', None),
}

# -- Breathe configuration ---------------------------------------------------

breathe_projects = {"MoleProject": "../../doc/api_docs/cpp/xml"}
breathe_default_project = "MoleProject"

# -- Paths for API and additional docs ---------------------------------------

# Paths to Doxygen-generated API documentation for C++
doxygen_output_dir = os.path.abspath('../../doc/api_docs/cpp')
html_extra_path = [doxygen_output_dir]

# Paths to Sphinx-generated API documentation for MATLAB (if needed)
matlab_docs_path = os.path.abspath('../../doc/api_docs/matlab')
html_extra_path.append(matlab_docs_path)

# -- Source files for index and structure ------------------------------------

# Master document
master_doc = 'index'

# Include README and other overview files
rst_prolog = """
.. include:: ../../README.md
.. include:: ../../CONTRIBUTING.md
"""

# -- Options for MathJax -----------------------------------------------------

mathjax3_config = {
    'tex': {
        'macros': {
            'RR': '\\mathbb{R}',
        }
    }
}


# import os
# import sys

# sys.path.insert(0, os.path.abspath('.'))

project = 'mole'
copyright = '2024, CSRC'
author = 'CSRC'
release = '1.0.0'

extensions = [
    'breathe',
    'sphinx.ext.autodoc',
    'sphinx.ext.napoleon',
    'sphinx.ext.todo',
    'sphinx.ext.viewcode',
    'sphinx.ext.doctest',
    'sphinx.ext.intersphinx',
    'sphinx.ext.coverage',
    'sphinx.ext.mathjax',
    'sphinx.ext.ifconfig',
    'sphinx.ext.githubpages',
    'sphinx_rtd_theme',
    'myst_parser',
]

# Configure myst-parser
myst_enable_extensions = [
    "colon_fence",
    "deflist",
]

# Add support for Markdown files
source_suffix = {
    '.rst': 'restructuredtext',
    '.md': 'markdown',
}

templates_path = ['_templates']
exclude_patterns = []

# -- Options for HTML output -------------------------------------------------

html_theme = 'sphinx_rtd_theme'

html_theme_options = {
    "style_external_links": True,
    "logo_only": True,
    "navigation_depth": 4,
}

html_static_path = []

html_logo = "../../../logo.png"

# Breathe configuration
breathe_projects = {
    "MoleCpp": "../../api_docs/cpp/xml" 
    # "MoleMatlab": "../../api_docs/matlab",  
}
breathe_default_project = "MoleCpp"

html_output_dir = '../sphinx/build'
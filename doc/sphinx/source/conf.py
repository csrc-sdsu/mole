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
    'sphinx_book_theme',
]

templates_path = ['_templates']
exclude_patterns = []

# -- Options for HTML output -------------------------------------------------

html_theme = 'sphinx_book_theme'

html_theme_options = {
    "repository_url": "https://github.com/csrc-sdsu/mole",
    "use_repository_button": True,
    "use_issues_button": True,
    "use_edit_page_button": True,
    "path_to_docs": "doc/sphinx/source",
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
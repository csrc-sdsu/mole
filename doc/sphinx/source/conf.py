import os
import sys
from pathlib import Path

# Define root directory using pathlib
ROOT_DIR = Path(__file__).resolve().parents[3]

# Update Python path - simplified version
sys.path.insert(0, str(ROOT_DIR))

# Project information
project = 'mole'
copyright = '2024, CSRC'
author = 'CSRC'
release = '1.0.0'

# Extensions configuration
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
    "dollarmath",
    "fieldlist",
    "html_admonition",
    "html_image",
    "replacements",
    "smartquotes",
    "substitution",
    "tasklist"
]

# Source configuration
source_suffix = {
    '.rst': 'restructuredtext',
    '.md': 'markdown',
}

templates_path = ['_templates']
exclude_patterns = []

# HTML output configuration
html_theme = 'sphinx_rtd_theme'
html_theme_options = {
    "style_external_links": True,
    "logo_only": True,
    "navigation_depth": 4,
}
html_static_path = []
html_logo = str(ROOT_DIR / "logo.png")

# Breathe configuration
breathe_projects = {
    "MoleCpp": str(ROOT_DIR / "doc/api_docs/cpp/xml")
}
breathe_default_project = "MoleCpp"

# Warning suppression
suppress_warnings = [
    'myst.domains',
    'epub.unknown_project_files'
]

# LaTeX configuration
latex_engine = 'lualatex'

latex_elements = {
    'papersize': 'letterpaper',
    'pointsize': '11pt',
    'fontpkg': r'''
        \usepackage[math-style=ISO,bold-style=ISO]{unicode-math}
        \setmainfont{TeX Gyre Pagella}
        \setmathfont{TeX Gyre Pagella Math}
        \setsansfont{DejaVu Sans}
        \setmonofont{DejaVu Sans Mono}
    ''',
    'preamble': r'''
        \usepackage{amscd}
        \usepackage{cancel}
        \usepackage{fancyhdr}
        
        % Header and margin adjustments
        \setlength{\headheight}{14.0pt}
        \addtolength{\topmargin}{-2.0pt}
        
        % Fix overfull hbox warnings
        \setlength{\emergencystretch}{3em}
        \providecommand{\tightlist}{\setlength{\itemsep}{0pt}\setlength{\parskip}{0pt}}
        
        % Improved figure placement
        \usepackage{float}
        \let\origfigure\figure
        \let\endorigfigure\endfigure
        \renewenvironment{figure}[1][2] {
            \expandafter\origfigure\expandafter[H]
        } {
            \endorigfigure
        }
        
        % Math commands
        \newcommand\bm[1]{\symbf{#1}}
        \def\diff{\operatorname{d}\!}
        \def\tcolon{\!:\!}
        \def\trace{\operatorname{trace}}
        
        % Remove page numbers from references
        \renewcommand{\sphinxcrossref}[1]{\texttt{#1}}
    ''',
    'figure_align': 'H',
    'extrapackages': r'\usepackage{float}',
    'hyperref': r'''
        \usepackage[hidelinks]{hyperref}
    ''',
}

latex_documents = [
    ('index', 'MOLE.tex', 'MOLE Documentation',
     'MOLE Development Team', 'manual'),
]

# Additional LaTeX settings
latex_show_pagerefs = False
latex_show_urls = 'footnote'
latex_logo = str(ROOT_DIR / "logo.png")
latex_domain_indices = True

# Image settings
numfig = True
numfig_format = {
    'figure': 'Figure %s',
    'table': 'Table %s',
    'code-block': 'Listing %s',
    'section': 'Section %s'
}

# Fix image handling
latex_additional_files = []



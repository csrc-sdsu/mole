import os
import sys
from pathlib import Path
import shutil
import subprocess

# Define root directory using pathlib
ROOT_DIR = Path(__file__).resolve().parents[3]

# Update Python path - simplified version
sys.path.insert(0, str(ROOT_DIR))

# Add the _ext directory to the Python path
sys.path.insert(0, os.path.abspath('_ext'))

# Project information
project = 'MOLE'
copyright = '2023, CSRC SDSU'
author = 'CSRC SDSU'
release = '1.0.0'

# Extensions configuration
extensions = [
    'sphinx.ext.autodoc',
    'sphinx.ext.mathjax',
    'sphinx.ext.viewcode',
    'sphinx.ext.napoleon',
    'sphinx.ext.intersphinx',
    'sphinx_rtd_theme',
    'breathe',
    'myst_parser',
    'copy_assets',  # Our custom extension to copy assets
    'sphinxcontrib.mermaid',  # Add Mermaid support
]

# Disable epub builder
epub_show_urls = 'no'
epub_use_index = False

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

# Additional myst-parser settings
myst_heading_anchors = 3
myst_url_schemes = ("http", "https", "mailto", "ftp", "file")
myst_all_links_external = False
myst_ref_domains = None

# Source configuration
source_suffix = {
    '.rst': 'restructuredtext',
    '.md': 'markdown',
}

# Follow symlinks
html_extra_path = [str(ROOT_DIR / 'doc' / 'doxygen')]
html_use_symlinks = True
follow_links = True

templates_path = ['_templates']
exclude_patterns = []

# HTML output configuration
html_theme = 'sphinx_rtd_theme'
html_theme_options = {
    "style_external_links": True,
    "logo_only": True,
    "navigation_depth": 3,
    "includehidden": True,
    "titles_only": False,
    "collapse_navigation": False
}
html_static_path = ['_static']
html_logo = str(ROOT_DIR / "logo.png")

# Add custom CSS
html_css_files = [
    'css/custom.css',
]

# Breathe configuration
breathe_projects = {
    "MoleCpp": str(ROOT_DIR / "doc/doxygen/cpp/xml")
}
breathe_default_project = "MoleCpp"
breathe_domain_by_extension = {
    ".h": "cpp",
    ".hpp": "cpp",
    ".cpp": "cpp",
    ".c": "c",
}
breathe_default_members = ('members', 'undoc-members')

# Run Doxygen if needed during build
if not os.path.exists(str(ROOT_DIR / "doc/doxygen/cpp/xml/index.xml")):
    print("Doxygen XML not found. Running Doxygen...")
    subprocess.call(["doxygen", "Doxyfile"], cwd=str(ROOT_DIR))

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

# Fix for assets directory warning
html_static_path = ['_static']
# Add a custom path for assets
assets_path = os.path.abspath(os.path.join(os.path.dirname(__file__), '../../../../doc/assets'))
if os.path.exists(assets_path):
    # If the assets directory exists at the project level, use it
    html_static_path.append(assets_path)
else:
    # Otherwise, create a symlink or copy the assets
    local_assets = os.path.join(os.path.dirname(__file__), '_static/assets')
    os.makedirs(local_assets, exist_ok=True)



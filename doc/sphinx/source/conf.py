################################################################################
# MOLE Documentation Sphinx Configuration
################################################################################

#------------------------------------------------------------------------------
# Basic imports
#------------------------------------------------------------------------------
import os
import sys
from pathlib import Path
import shutil
import subprocess
import importlib.util
import pkg_resources

#------------------------------------------------------------------------------
# Path configuration
#------------------------------------------------------------------------------
# Define root directory using pathlib
ROOT_DIR = Path(__file__).resolve().parents[3]

# Update Python path to include project root
sys.path.insert(0, str(ROOT_DIR))

# Add the _ext directory to the Python path for custom extensions
sys.path.insert(0, os.path.abspath('_ext'))

#------------------------------------------------------------------------------
# Project information
#------------------------------------------------------------------------------
project = 'MOLE'
copyright = '2023, CSRC SDSU'
author = 'CSRC SDSU'
release = '1.0.0'

#------------------------------------------------------------------------------
# Extensions configuration
#------------------------------------------------------------------------------
# Core and required extensions
extensions = [
    # Sphinx core extensions
    'sphinx.ext.autodoc',     # Generate documentation from docstrings
    'sphinx.ext.mathjax',     # Math rendering
    'sphinx.ext.viewcode',    # Link to source code
    'sphinx.ext.napoleon',    # Support for NumPy and Google style docstrings
    'sphinx.ext.intersphinx', # Link to other project's documentation
    
    # Theme
    'sphinx_rtd_theme',       # Read the Docs theme
    
    # External documentation extensions
    'breathe',                # Doxygen integration
    'myst_parser',            # Markdown support
    
    # Diagram support
    'sphinxcontrib.mermaid',  # Mermaid diagram support
]

#------------------------------------------------------------------------------
# MyST Parser configuration (Markdown support)
#------------------------------------------------------------------------------
# Enable specific MyST extensions
myst_enable_extensions = [
    "colon_fence",     # Alternative code fence syntax 
    "deflist",         # Definition lists
    "dollarmath",      # Math in $...$ syntax
    "fieldlist",       # Field lists
    "html_admonition", # HTML admonition directives
    "html_image",      # HTML image directives
    "replacements",    # Text replacements
    "smartquotes",     # Smart quotes
    "substitution",    # Substitution references
    "tasklist"         # Task lists
]

# Additional MyST settings
myst_heading_anchors = 3                     # Generate anchors for headings
myst_url_schemes = ("http", "https", "mailto", "ftp", "file")
myst_all_links_external = False
myst_ref_domains = None                      # Disable automatic reference domain

#------------------------------------------------------------------------------
# Breathe configuration (Doxygen integration)
#------------------------------------------------------------------------------
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

#------------------------------------------------------------------------------
# Mermaid diagram configuration
#------------------------------------------------------------------------------
# Check if mermaid-cli is available
has_mmdc = shutil.which('mmdc') is not None
has_npx = shutil.which('npx') is not None

if has_mmdc:
    mermaid_cmd = 'mmdc'
    mermaid_output_format = 'svg'
elif has_npx:
    mermaid_cmd = 'npx mmdc'
    mermaid_output_format = 'svg'
else:
    # If Mermaid CLI is not available, disable the extension
    extensions.remove('sphinxcontrib.mermaid')
    print("\n" + "="*80)
    print("WARNING: Mermaid CLI not found. Mermaid diagrams will not be rendered.")
    print("To install Mermaid CLI, run: npm install -g @mermaid-js/mermaid-cli")
    print("="*80 + "\n")

#------------------------------------------------------------------------------
# Source configuration
#------------------------------------------------------------------------------
# File types to process
source_suffix = {
    '.rst': 'restructuredtext',
    '.md': 'markdown',
}

# Directories and files to exclude
templates_path = ['_templates']
exclude_patterns = []

# Link handling
follow_links = True

#------------------------------------------------------------------------------
# HTML output configuration
#------------------------------------------------------------------------------
# Theme settings
html_theme = 'sphinx_rtd_theme'
html_theme_options = {
    "style_external_links": True,
    "logo_only": True,
    "navigation_depth": 3,
    "includehidden": True,
    "titles_only": False,
    "collapse_navigation": False
}

# Path settings
html_static_path = ['_static']
html_extra_path = [str(ROOT_DIR / 'doc' / 'doxygen')]
html_use_symlinks = True

# Appearance
html_logo = str(ROOT_DIR / "logo.png")
html_css_files = [
    'css/custom.css',
]

#------------------------------------------------------------------------------
# Warning suppression
#------------------------------------------------------------------------------
suppress_warnings = [
    'myst.domains',
    'myst.anchor',
    'myst.header',
    'epub.unknown_project_files',
    'image.nonlocal_uri',
    'app.add_source_parser',
    'autosectionlabel.*',
    'ref.python',
    'ref.cpp',
    'ref.c',
    'toc.excluded'
]

def setup(app):
    """Setup function for Sphinx extension."""
    app.connect('build-finished', on_build_finished)
    
def on_build_finished(app, exc):
    """Handle build finished event."""
    # This function is now minimal, we removed all custom LaTeX handling
    pass

#------------------------------------------------------------------------------
# Optional debugging section - uncomment when needed
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# LaTeX and PDF output configuration
#------------------------------------------------------------------------------
# Use pdflatex for standard PDF generation
latex_engine = 'pdflatex'

# Minimal LaTeX configuration options
latex_elements = {
    # Paper size
    'papersize': 'letterpaper',
    
    # Document class (report provides chapters)
    'pointsize': '11pt',
    
    # Simplified preamble
    'preamble': r'''
\usepackage{booktabs}  % Better tables
\usepackage{xcolor}    % Colors

% Fix the headheight warning from fancyhdr
\setlength{\headheight}{14pt}

% Define missing commands from sphinxVerbatim
\newcommand{\capstart}{}

% Debug log for LaTeX variables
\typeout{DEBUG: headheight=\the\headheight}
\typeout{DEBUG: topmargin=\the\topmargin}

% Fix for Unicode character handling
\DeclareUnicodeCharacter{FE0F}{}

% Turn off SVG handling since we removed SVG images
\usepackage{silence}
\WarningFilter{latex}{Unknown graphics extension}
''',
    
    # No empty pages
    'classoptions': ',oneside',
    
    # Hyperref setup
    'hyperref': r'''
\usepackage{hyperref}
\hypersetup{
    colorlinks=true,
    linkcolor=blue,
    filecolor=blue,
    urlcolor=blue,
}
''',
}

# Main LaTeX/PDF document configuration
latex_documents = [
    (
        'index',           # Source start file
        'MOLE-docs.tex',   # Target filename
        'MOLE Documentation',      # Title
        'CSRC SDSU',       # Author
        'manual',          # Document class
        False              # toctree_only
    ),
]

# If false, no module index is generated
latex_domain_indices = True

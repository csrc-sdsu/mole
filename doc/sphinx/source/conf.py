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
master_doc = 'index'
root_doc = 'index'

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

# Configure HTML image handling
html_copy_source = True
html_show_sourcelink = True

# Image and static file configuration
# NOTE: Important guidelines for adding images to documentation:
# 1. Place SVG/image files in a 'figures' directory next to the markdown files
# 2. In markdown files, use the following format for images with centered captions:
#    <div style="text-align: center">
#    ![Alt text](figures/image.svg)
#    *Caption text*
#    </div>
# 3. This format ensures compatibility with both Sphinx and standard Markdown viewers (e.g., GitHub)
# 4. Add any new image directories to html_extra_path below to ensure they're copied to build

html_static_path = ['_static']
html_extra_path = [
    str(ROOT_DIR / 'README.md'),
    str(ROOT_DIR / 'doc/doxygen'),
    str(ROOT_DIR / 'doc/assets'),
    str(ROOT_DIR / 'doc/sphinx/README.md'),
    str(ROOT_DIR / 'doc/sphinx/source/api/examples/md/figures')  # Figures for markdown docs
]

# Configure image handling
html_static_images = ['*.svg', '*.png', '*.jpg', '*.gif']

# Additional MyST settings
myst_heading_anchors = 3                     # Generate anchors for headings
myst_url_schemes = ("http", "https", "mailto", "ftp", "file", "doc")
myst_all_links_external = True
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

print("\nDEBUG: Mermaid Configuration:")
print(f"mmdc available: {has_mmdc}")
print(f"npx available: {has_npx}")

if has_mmdc:
    mermaid_cmd = 'mmdc'
    mermaid_output_format = 'svg'
    print(f"Using direct mmdc command: {mermaid_cmd}")
elif has_npx:
    mermaid_cmd = 'npx mmdc'
    mermaid_output_format = 'svg'
    print(f"Using npx command: {mermaid_cmd}")
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
html_extra_path = [
    str(ROOT_DIR / 'README.md'),
    str(ROOT_DIR / 'doc' / 'doxygen'), 
    str(ROOT_DIR / 'doc' / 'assets'),
    str(ROOT_DIR / 'doc' / 'sphinx' / 'README.md')
    ]
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
    'toc.excluded',
    'image.svg_to_png'
]

def setup(app):
    """Setup function for Sphinx extension."""
    app.add_js_file('mathconf.js')
    
    # Add capability to replace problematic math environments
    app.connect('source-read', fix_math_environments)

def fix_math_environments(app, docname, source):
    """Fix problematic math environments in markdown source."""
    src = source[0]
    
    # Replace \tag{} inside \begin{split}...\end{split} environments
    import re
    src = re.sub(r'(\\begin{split}.*?)\\tag{(.*?)}(.*?\\end{split})', r'\1\3', src)
    
    # Ensure split environments are in align, not equation*
    src = re.sub(r'\\begin{equation\*}\s*\\begin{split}', r'\\begin{align}', src)
    src = re.sub(r'\\end{split}\s*\\end{equation\*}', r'\\end{align}', src)
    
    source[0] = src

#------------------------------------------------------------------------------
# LaTeX and PDF output configuration
#------------------------------------------------------------------------------
# Use pdflatex for standard PDF generation
latex_engine = 'pdflatex'

# Configure LaTeX elements
latex_elements = {
    'preamble': r'''
    \usepackage{graphicx}
    \DeclareGraphicsExtensions{.pdf,.png,.jpg}
    
    % Set up graphics paths
    \graphicspath{
      {_images/}
      {figures/}
      {./}
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

# Fix math rendering in MyST markdown
myst_update_mathjax = True
myst_dmath_allow_labels = True
myst_dmath_double_inline = False

# For LaTeX output
latex_use_xindy = False  # Disable xindy for better compatibility
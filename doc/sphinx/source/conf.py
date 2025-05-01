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
import glob

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
    'sphinx.ext.graphviz',    # GraphViz diagram support
    'sphinx.ext.viewcode',    # Link to source code
    'sphinx.ext.napoleon',    # Support for NumPy and Google style docstrings
    'sphinx.ext.intersphinx', # Link to other project's documentation
    
    # Theme and theme extensions
    'sphinx_book_theme',      # Book theme
    'sphinx_design',          # UI components
    
    # External documentation extensions
    'breathe',                # Doxygen integration
    'myst_parser',            # Markdown support
    
    # MATLAB documentation
    'sphinxcontrib.matlab',   # MATLAB domain support
    
    # Custom extensions
    'matlab_doc_filter',      # Filter license info from MATLAB docstrings
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

# Make sure amsmath extension is enabled for math environments
myst_enable_extensions += ["amsmath", "colon_fence"]

# Configure HTML image handling
html_copy_source = True
html_show_sourcelink = True

# Image and static file configuration
html_static_path = ['_static']
html_extra_path = [
    str(ROOT_DIR / 'doc/doxygen'),
    str(ROOT_DIR / 'doc/sphinx/README.md'),
]

# Additional MyST settings
myst_heading_anchors = 3                     # Generate anchors for headings
myst_url_schemes = ("http", "https", "mailto", "ftp", "file", "doc")
myst_all_links_external = True
myst_ref_domains = None

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
# GraphViz configuration
#------------------------------------------------------------------------------
graphviz_output_format = 'svg'
graphviz_dot_args = [
    '-Tsvg',
    '-Gfontname=Arial',
    '-Nfontname=Arial',
    '-Efontname=Arial'
]

#------------------------------------------------------------------------------
# MATLAB domain configuration
#------------------------------------------------------------------------------
# Path to MATLAB source directory for cross-reference functionality
matlab_src_dir = os.path.abspath(os.path.join(ROOT_DIR, 'src', 'matlab'))

# Enhanced debug logging
# print("\nDEBUG: Enhanced MATLAB Configuration:")
# print(f"Current working directory: {os.getcwd()}")
# print(f"ROOT_DIR value: {ROOT_DIR}")
# print(f"MATLAB source directory: {matlab_src_dir}")
# print(f"Directory exists: {os.path.exists(matlab_src_dir)}")
try:
    if os.path.exists(os.path.dirname(matlab_src_dir)):
        # print(f"Parent directory contents: {os.listdir(os.path.dirname(matlab_src_dir))}")
        pass # Placeholder if you remove the print statement
    else:
        # print(f"Parent directory {os.path.dirname(matlab_src_dir)} does not exist")
        pass # Placeholder
except Exception as e:
    # print(f"Error listing parent directory: {e}")
    pass # Placeholder

# Version compatibility check
# print("\nDEBUG: Version Information:")
# print(f"Python version: {sys.version}")
# print(f"Sphinx version: {pkg_resources.get_distribution('sphinx').version}")
try:
    # print(f"sphinxcontrib-matlab version: {pkg_resources.get_distribution('sphinxcontrib-matlab').version}")
    pass # Placeholder
except Exception as e:
    # print(f"Error getting sphinxcontrib-matlab version: {e}")
    pass # Placeholder

# Add MATLAB directory to Python path if it exists
if os.path.exists(matlab_src_dir):
    sys.path.insert(0, matlab_src_dir)
    # print(f"\nAdded existing MATLAB directory to Python path: {matlab_src_dir}")

# For matlabdomain, we need to treat MATLAB files as modules
primary_domain = 'mat'  # Make MATLAB the primary domain for .m files

# MATLAB documentation style settings
matlab_keep_package_prefix = False
matlab_short_links = True
matlab_auto_link = "basic"  # Auto-link known MATLAB code elements
matlab_show_property_default_value = False
matlab_show_property_specs = False

# MATLAB documentation filtering options
matlab_filter_options = {
    'remove_license': True,
    'm2html_style': True,
}

# Add MATLAB to intersphinx mapping if needed
intersphinx_mapping = {
    'python': ('https://docs.python.org/3', None),
    'numpy': ('https://numpy.org/doc/stable', None),
    'matplotlib': ('https://matplotlib.org/stable', None),
}

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
exclude_patterns = [
    'README.md',  # Only exclude the root README
    'api/examples-m/tex/list.md',
    'api/examples/index.md',
]

# Link handling
follow_links = True

#------------------------------------------------------------------------------
# HTML output configuration
#------------------------------------------------------------------------------
# Theme settings
html_theme = 'sphinx_book_theme'
html_theme_options = {
    # Repository configuration
    "repository_url": "https://github.com/csrc-sdsu/mole",
    "repository_branch": "main",
    "use_repository_button": True,
    
    # Navigation options
    "show_toc_level": 2,
    "use_download_button": True,
    "use_fullscreen_button": True,
    
    # Message banner
    "announcement": "This documentation is using the sphinx-book-theme.",
}

# Appearance
html_logo = str(ROOT_DIR / "logo.png")
html_title = "MOLE Documentation" 
html_favicon = str(ROOT_DIR / "logo.png")
html_css_files = ['css/custom.css']
html_js_files = ['js/theme-custom.js']

# Control sidebar contents - using defaults
# html_sidebars = {
#     "**": ["sbt-sidebar-nav.html"]
# }

# Custom template adjustments 
templates_path = ['_templates']
html_context = {
    'display_github': True,
    'github_user': 'csrc-sdsu',
    'github_repo': 'mole',
    'github_version': 'main',
    'display_version': True,
    'conf_py_path': '/doc/sphinx/source/',
}

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
    'autosectionlabel.*'
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

#------------------------------------------------------------------------------
# File copying configuration
#------------------------------------------------------------------------------
def mkdir_p(path):
    try:
        os.makedirs(path)
    except FileExistsError:
        pass

# Clean up and copy example documentation from source tree
example_dest = str(ROOT_DIR / "doc/sphinx/source/examples")
try:
    if os.path.exists(example_dest):
        shutil.rmtree(example_dest)
except FileNotFoundError:
    pass

# Debug info
print("\nDEBUG: Exclude Patterns:")
for pattern in exclude_patterns:
    print(f"  - {pattern}")

# Copy all markdown files from examples directory
for filename in glob.glob(str(ROOT_DIR / "examples/**/*.md"), recursive=True):
    rel_path = os.path.relpath(filename, str(ROOT_DIR / "examples"))
    destdir = os.path.join(example_dest, os.path.dirname(rel_path))
    dest_file = os.path.join(destdir, os.path.basename(rel_path))
    
    # Only exclude if the relative path exactly matches an exclude pattern
    skip_file = rel_path in exclude_patterns
    
    if not skip_file:
        mkdir_p(destdir)
        shutil.copy2(filename, destdir)
        print(f"DEBUG: Copied markdown file: {filename} to {destdir}")

# Copy all image files from examples directory
for ext in ['*.jpg', '*.jpeg', '*.png', '*.svg']:
    for filename in glob.glob(str(ROOT_DIR / "examples/**/" / ext), recursive=True):
        rel_path = os.path.relpath(filename, str(ROOT_DIR / "examples"))
        destdir = os.path.join(example_dest, os.path.dirname(rel_path))
        mkdir_p(destdir)
        shutil.copy2(filename, destdir)
        print(f"DEBUG: Copied image file: {filename} to {destdir}")

# Debug info to help troubleshoot file copying
print("\nDEBUG: Directory Structure Before File Operations:")
if os.path.exists(example_dest):
    for root, dirs, files in os.walk(example_dest):
        rel_root = os.path.relpath(root, example_dest)
        if rel_root == ".":
            print(f"Directory: {example_dest}")
        else:
            print(f"Directory: {os.path.join(example_dest, rel_root)}")
        for file in files:
            print(f"  File: {file}")

# Ensure README files that are referenced in toctree exist
readme_files = [
    os.path.join(example_dest, "README.md"),
    os.path.join(example_dest, "cpp/README.md"),
    os.path.join(example_dest, "matlab/compact_operators/README.md")
]

for readme_file in readme_files:
    dir_path = os.path.dirname(readme_file)
    if not os.path.exists(dir_path):
        mkdir_p(dir_path)
    
    # If the README doesn't exist, create a basic one with a title
    if not os.path.exists(readme_file):
        basename = os.path.basename(os.path.dirname(readme_file))
        if basename == "examples":
            title = "MOLE Examples Overview"
            content = "This directory contains examples demonstrating the usage of MOLE."
        elif basename == "cpp":
            title = "C++ Examples"
            content = "This folder contains C++ examples for MOLE."
        elif basename == "compact_operators":
            title = "MATLAB Compact Operators"
            content = "This folder contains MATLAB examples for compact operators."
        
        with open(readme_file, 'w') as f:
            f.write(f"# {title}\n\n{content}\n")

# Debug info after file operations
print("\nDEBUG: Directory Structure After File Operations:")
if os.path.exists(example_dest):
    for root, dirs, files in os.walk(example_dest):
        rel_root = os.path.relpath(root, example_dest)
        if rel_root == ".":
            print(f"Directory: {example_dest}")
        else:
            print(f"Directory: {os.path.join(example_dest, rel_root)}")
        for file in files:
            print(f"  File: {file}")

# Check if specific README files exist
print("\nDEBUG: Checking for specific README files:")
for readme_file in readme_files:
    if os.path.exists(readme_file):
        print(f"  - {readme_file}: FOUND")
    else:
        print(f"  - {readme_file}: NOT FOUND")
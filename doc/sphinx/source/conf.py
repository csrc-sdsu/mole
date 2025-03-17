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
    'sphinxcontrib.mermaid',
]

# Mermaid configuration
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
    'myst.anchor',
    'myst.header',
    'epub.unknown_project_files'
]

# LaTeX configuration
latex_engine = 'lualatex'

latex_elements = {
    # Basic document settings
    'papersize': 'letterpaper',
    'pointsize': '11pt',
    'babel': r'\usepackage[english]{babel}',  # Better language support
    'inputenc': '',  # Not needed with LuaLaTeX
    'fontenc': '',   # Not needed with LuaLaTeX
    
    # Font configuration - using standard LaTeX fonts
    'fontpkg': r'''
        \usepackage{fontspec}
        \setmainfont{Latin Modern Roman}
        \setsansfont{Latin Modern Sans}
        \setmonofont{Latin Modern Mono}
        \usepackage[math-style=ISO]{unicode-math}
        \setmathfont{Latin Modern Math}
    ''',
    
    'passoptionstopackages': r'''
        \PassOptionsToPackage{svgnames}{xcolor}
    ''',
    
    'preamble': r'''
        % Core packages
        \usepackage{amscd}
        \usepackage{cancel}
        \usepackage{fancyhdr}
        \usepackage{float}
        \usepackage{microtype}  % Better typography
        \usepackage[chapter]{algorithm}
        \usepackage{algpseudocode}
        
        % Header and margin adjustments
        \setlength{\headheight}{14.0pt}
        \addtolength{\topmargin}{-2.0pt}
        \setlength{\parskip}{0.5em}  % Better paragraph spacing
        
        % Fix overfull hbox warnings
        \setlength{\emergencystretch}{3em}
        \providecommand{\tightlist}{\setlength{\itemsep}{0pt}\setlength{\parskip}{0pt}}
        
        % Math commands and environments
        \newcommand\bm[1]{\symbf{#1}}
        \def\diff{\operatorname{d}\!}
        \def\tcolon{\!:\!}
        \def\trace{\operatorname{trace}}
        
        % Cross-referencing improvements
        \renewcommand{\sphinxcrossref}[1]{\texttt{#1}}
        
        % Better code listings
        \definecolor{codecolor}{RGB}{240,240,240}
        \definecolor{codetext}{RGB}{36,36,36}
        \fancypagestyle{normal}{
            \fancyhf{}
            \fancyfoot[R]{\thepage}
            \fancyhead[L]{\leftmark}
            \fancyhead[R]{MOLE Documentation}
            \renewcommand{\headrulewidth}{0.4pt}
            \renewcommand{\footrulewidth}{0.4pt}
            }
            
        % Table spacing improvements
        \renewcommand{\tabcolsep}{0.5em}
    
    ''',
    
    # Figure settings
    'figure_align': 'H',
    'extrapackages': r'\usepackage{float}',
    
    # Hyperref settings (should be loaded last)
    'hyperref': r'''
        \usepackage[hidelinks,
                   colorlinks=true,
                   linkcolor=NavyBlue,
                   urlcolor=NavyBlue,
                   citecolor=NavyBlue]{hyperref}
    '''
}

# LaTeX document configuration
latex_documents = [
    ('index', 'MOLE.tex', 'MOLE Documentation',
     'MOLE Development Team', 'manual'),
]

# Additional LaTeX settings
latex_show_pagerefs = True  # Changed to True for better cross-referencing
latex_show_urls = 'footnote'
latex_logo = str(ROOT_DIR / "logo.png")
latex_domain_indices = True

# Image and numbering settings
numfig = True
numfig_format = {
    'figure': 'Figure %s',
    'table': 'Table %s',
    'code-block': 'Listing %s',
    'section': 'Section %s'
}
numfig_secnum_depth = 2

# Additional files needed for the build
latex_additional_files = []

# Fix for assets directory warning
html_static_path = ['_static']

# Removed assets directory check code completely
# No longer needed as we're not copying assets

myst_heading_anchors = 3  # Limit heading anchor depth
myst_ref_domains = []     # Disable automatic reference domain 
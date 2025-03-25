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
    'toc.excluded'
]

def convert_svg_to_pdf(app):
    """Convert SVG files to PDF before LaTeX build."""
    if app.builder.name != 'latex':
        return
    
    build_dir = Path(app.outdir)
    images_dir = build_dir / '_images'
    images_dir.mkdir(exist_ok=True)
    
    # Check for available conversion tools
    rsvg_available = shutil.which('rsvg-convert') is not None
    cairosvg_available = False
    try:
        import cairosvg
        cairosvg_available = True
    except ImportError:
        pass
    
    print(f"\nSVG Conversion Tools Available:")
    print(f"- Inkscape: {shutil.which('inkscape') is not None}")
    print(f"- rsvg-convert: {rsvg_available}")
    print(f"- cairosvg: {cairosvg_available}")
    
    # Find and inspect all SVG files
    svg_files = list(Path(app.srcdir).rglob('*.svg'))
    print(f"\nFound {len(svg_files)} SVG files")
    
    for svg_file in svg_files:
        pdf_file = images_dir / f"{svg_file.stem}.pdf"
        print(f"\nProcessing: {svg_file}")
        
        # Inspect SVG file
        try:
            with open(svg_file, 'r') as f:
                svg_content = f.read()
                svg_size = len(svg_content)
                print(f"- SVG size: {svg_size} bytes")
                print(f"- Has viewBox: {'viewBox' in svg_content}")
                print(f"- SVG version: {'version=' + svg_content.split('version=')[1].split('"')[1] if 'version=' in svg_content else 'unknown'}")
        except Exception as e:
            print(f"- Error inspecting SVG: {e}")
        
        # Try different conversion methods in order of preference
        conversion_success = False
        
        # 1. Try rsvg-convert (often best quality)
        if rsvg_available and not conversion_success:
            try:
                print("Attempting conversion with rsvg-convert...")
                subprocess.run([
                    'rsvg-convert',
                    '-f', 'pdf',
                    '-o', str(pdf_file),
                    '--dpi-x', '300',
                    '--dpi-y', '300',
                    str(svg_file)
                ], check=True, capture_output=True, text=True)
                if pdf_file.exists() and pdf_file.stat().st_size > 100:
                    conversion_success = True
                    print(f"✓ rsvg-convert successful: {pdf_file.stat().st_size} bytes")
            except Exception as e:
                print(f"✗ rsvg-convert failed: {e}")
        
        # 2. Try cairosvg
        if cairosvg_available and not conversion_success:
            try:
                print("Attempting conversion with cairosvg...")
                import cairosvg
                cairosvg.svg2pdf(url=str(svg_file), write_to=str(pdf_file), dpi=300)
                if pdf_file.exists() and pdf_file.stat().st_size > 100:
                    conversion_success = True
                    print(f"✓ cairosvg successful: {pdf_file.stat().st_size} bytes")
            except Exception as e:
                print(f"✗ cairosvg failed: {e}")
        
        # 3. Try Inkscape with PDF Cairo
        if not conversion_success:
            try:
                print("Attempting conversion with Inkscape Cairo...")
                subprocess.run([
                    'inkscape',
                    '--export-filename=' + str(pdf_file),
                    '--export-type=pdf',
                    '--export-pdf-version=1.5',
                    '--export-area-page',
                    '--export-text-to-path',
                    '--export-pdf-cairo',
                    str(svg_file)
                ], check=True, capture_output=True, text=True)
                if pdf_file.exists() and pdf_file.stat().st_size > 100:
                    conversion_success = True
                    print(f"✓ Inkscape Cairo successful: {pdf_file.stat().st_size} bytes")
            except Exception as e:
                print(f"✗ Inkscape Cairo failed: {e}")
        
        # 4. Try direct Inkscape export as fallback
        if not conversion_success:
            try:
                print("Attempting conversion with direct Inkscape export...")
                subprocess.run([
                    'inkscape',
                    '--export-filename=' + str(pdf_file),
                    '--export-dpi=600',
                    str(svg_file)
                ], check=True, capture_output=True, text=True)
                if pdf_file.exists() and pdf_file.stat().st_size > 100:
                    conversion_success = True
                    print(f"✓ Direct Inkscape successful: {pdf_file.stat().st_size} bytes")
            except Exception as e:
                print(f"✗ Direct Inkscape failed: {e}")
        
        if not conversion_success:
            print("⚠ All conversion methods failed!")

def setup(app):
    """Setup function for Sphinx extension."""
    app.add_js_file('mathconf.js')
    
    # Add capability to replace problematic math environments
    app.connect('source-read', fix_math_environments)
    app.connect('builder-inited', on_builder_inited)
    app.connect('build-finished', on_build_finished)

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

def on_builder_inited(app):
    """Log SVG-related configuration at build start."""
    if app.builder.name == 'latex':
        print("\n" + "!"*80)
        print("SVG PROCESSING DEBUG")
        print("!"*80)
        
        # Check for SVG conversion tools
        import shutil
        inkscape_available = shutil.which('inkscape') is not None
        print(f"\n1. SVG Conversion Tools:")
        print(f"   - Inkscape available: {inkscape_available}")
        
        # Log SVG files
        svg_files = list(Path(app.builder.srcdir).rglob('*.svg'))
        print(f"\n2. SVG Files Found: {len(svg_files)}")
        for svg in svg_files[:3]:
            print(f"   - {svg.relative_to(app.builder.srcdir)}")
        
        # Check LaTeX graphics configuration
        print("\n3. LaTeX Graphics Configuration:")
        graphics_packages = ['graphicx', 'svg']
        for pkg in graphics_packages:
            if pkg in latex_elements.get('preamble', ''):
                print(f"   - {pkg}: configured")
            else:
                print(f"   - {pkg}: missing")
        
        print("!"*80 + "\n")

def on_build_finished(app, exc):
    """Handle build finished event."""
    pass

#------------------------------------------------------------------------------
# Optional debugging section - uncomment when needed
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# LaTeX and PDF output configuration
#------------------------------------------------------------------------------
# Use pdflatex for standard PDF generation
latex_engine = 'pdflatex'

# Image handling configuration
image_converter = 'convert'  # Use ImageMagick's convert command
images_config = {
    'override_imagesize': True,
    'default_image_width': '100%',
    'default_image_height': 'auto',
    'backend': 'sphinx.ext.imgconverter',
    'convert_path': shutil.which('convert'),
    'inkscape_path': shutil.which('inkscape')
}

# Add imgconverter extension
if 'sphinx.ext.imgconverter' not in extensions:
    extensions.append('sphinx.ext.imgconverter')

# Configure image handling for LaTeX
latex_elements = {
    'preamble': r'''
\usepackage{booktabs}  % Better tables
\usepackage{xcolor}    % Colors
\usepackage{graphicx}  % Enhanced graphics support

% Configure graphics handling for high quality
\pdfminorversion=7  % Use PDF 1.7 for better graphics support
\pdfobjcompresslevel=0  % Disable compression for better quality
\pdfcompresslevel=0

% Define graphics path with all possible image locations
\DeclareGraphicsExtensions{.pdf,.png,.jpg}
\graphicspath{
    {_build/latex/}
    {_build/latex/_images/}
    {_images/}
    {api/examples/md/figures/}
    {figures/}
    {_static/}
}

% Allow for image filename resolution
\makeatletter
\let\origincludegraphics\includegraphics
\renewcommand{\includegraphics}[2][]{%
  \IfFileExists{#2}{\origincludegraphics[#1]{#2}}%
  {\IfFileExists{#2.pdf}{\origincludegraphics[#1]{#2.pdf}}%
   {\IfFileExists{#2.png}{\origincludegraphics[#1]{#2.png}}%
    {\origincludegraphics[#1]{#2}}}}%
}
\makeatother

% Fix the headheight warning from fancyhdr
\setlength{\headheight}{14pt}

% Define missing commands from sphinxVerbatim
\newcommand{\capstart}{}

% Debug log for LaTeX variables
\typeout{DEBUG: headheight=\the\headheight}
\typeout{DEBUG: topmargin=\the\topmargin}

% Fix for Unicode character handling
\DeclareUnicodeCharacter{FE0F}{}
''',
}

# Configure image conversion settings
latex_additional_files = []
latex_images = True

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
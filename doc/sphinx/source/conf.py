################################################################################
# MOLE User Manual Sphinx Configuration
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
from PIL import Image, ImageOps
import errno

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
with open("../../../AUTHORS") as f:
    authorlist = f.readlines()
author = ", ".join(authorlist)
release = '1.1.0'
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
    'sphinx.ext.todo',        # Support for TODO items
    'sphinx.ext.autosectionlabel', # Auto-generate section labels
    'sphinx.ext.autosummary', # Generate summaries automatically
    'sphinx.ext.coverage',    # Check documentation coverage
    
    # Theme and theme extensions
    'sphinx_book_theme',      # Book theme
    'sphinx_design',          # UI components (tabs, cards, dropdowns)
    'sphinx_copybutton',      # Copy button for code blocks
    'sphinx_togglebutton',    # Collapsible content
    
    # External documentation extensions
    'breathe',                # Doxygen integration
    'myst_parser',            # Markdown support
    
    # MATLAB documentation
    'sphinxcontrib.matlab',   # MATLAB domain support
    
    # Custom extensions
    'matlab_doc_filter',      # Filter license info from MATLAB docstrings
    'matlab_args_fix',        # Fix MATLAB function argument warnings
    'generate_sitemap',       # Generate sitemap.xml for SEO
    'github_contributors',    # Display GitHub contributors
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

# Reduce MyST verbosity
myst_suppress_warnings = ["myst.domains"]

# Make sure amsmath extension is enabled for math environments
myst_enable_extensions += ["amsmath", "colon_fence"]

# Configure HTML image handling
html_copy_source = True
html_show_sourcelink = True

# Image and static file configuration
html_static_path = ['_static']
# Note: _images directory is created automatically by Sphinx when images are referenced
# We don't need to add it to html_static_path
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
# MATLAB/Octave domain configuration
#------------------------------------------------------------------------------
# Path to MATLAB/Octave source directory for cross-reference functionality
matlab_src_dir = os.path.abspath(os.path.join(ROOT_DIR, 'src', 'matlab_octave'))

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

# Add MATLAB/Octave directory to Python path if it exists
if os.path.exists(matlab_src_dir):
    sys.path.insert(0, matlab_src_dir)
    # print(f"\nAdded existing MATLAB/Octave directory to Python path: {matlab_src_dir}")

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

# Reduce MATLAB domain verbosity
matlab_suppress_warnings = True

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
    "path_to_docs": "doc/sphinx/source",
    
    # Navigation options
    "show_toc_level": 2,
    "show_navbar_depth": 1,  # Control expansion: 1 = only top-level expanded by default
    "use_download_button": True,
    "use_fullscreen_button": True,
    "use_source_button": True,
    
    # Theme and appearance
    "pygments_light_style": "tango",
    
    # Removing unsupported theme options
    # "use_dark_theme": False,
    # "single_page": False,
}

# Logo for light/dark modes - uncomment and modify when dark logo is available
html_theme_options.update({
    "logo": {
        "image_light": "_static/logo.png",
        "image_dark": "_static/logo-dark.png",
    }
})

# Create the dark logo if it doesn't exist
logo_path = str(ROOT_DIR / "logo.png")
dark_logo_path = str(ROOT_DIR / "doc/sphinx/source/_static/logo-dark.png")
if os.path.exists(logo_path) and not os.path.exists(dark_logo_path):
    try:
        # Create the _static directory if it doesn't exist
        os.makedirs(os.path.dirname(dark_logo_path), exist_ok=True)
        
        # Copy the logo to _static
        import shutil
        shutil.copy2(logo_path, str(ROOT_DIR / "doc/sphinx/source/_static/logo.png"))
        
        # Create a dark version of the logo
        img = Image.open(logo_path)
        if img.mode == 'RGBA':
            # For PNG with transparency
            r, g, b, a = img.split()
            img_gray = ImageOps.invert(Image.merge('RGB', (r, g, b)))
            dark_img = Image.merge('RGBA', (img_gray.split() + (a,)))
        else:
            # For JPG or other formats
            dark_img = ImageOps.invert(img.convert('RGB'))
        
        dark_img.save(dark_logo_path)
        # print(f"Created dark mode logo at {dark_logo_path}")  # Commented for cleaner output
    except Exception as e:
        print(f"Error creating dark logo: {e}")
        # If there's an error, just use the normal logo
        html_theme_options.update({
            "logo": {
                "image_light": "_static/logo.png",
                "image_dark": "_static/logo.png",
            }
        })

# Appearance
html_title = "MOLE User Manual" 
html_favicon = str(ROOT_DIR / "logo.png")
html_css_files = [
    'css/custom.css',
    'css/announcement.css',
    'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css'
]
html_js_files = ['js/theme-custom.js', 'js/theme-mode-toggle.js', 'js/announcement.js']

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

# sphinx-copybutton configuration
copybutton_prompt_text = r">>> |\.\.\. |\$ |In \[\d*\]: | {2,5}\.\.\.: | {5,8}: "
copybutton_prompt_is_regexp = True
copybutton_remove_prompts = True
copybutton_line_continuation_character = "\\"
copybutton_here_doc_delimiter = "EOT"

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
    'autosummary',
    'matlab.duplicate_object'
]

# Set logging level to reduce verbosity
import logging
logging.getLogger('sphinx').setLevel(logging.WARNING)
logging.getLogger('myst_parser').setLevel(logging.WARNING)
logging.getLogger('sphinxcontrib.matlab').setLevel(logging.WARNING)

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

def copy_all_images_to_sphinx(app):
    """
    Copy all images from various source locations to Sphinx's _images directory.
    
    This ensures images referenced in any markdown file (including included files)
    are available when Sphinx processes documents, regardless of whether the build
    is run via Makefile or directly via sphinx-build (e.g., on ReadTheDocs).
    
    This function:
    1. Copies images from doc/assets/img/ to source/_images/
    2. Copies images from any figures/ directories in source/
    3. Works for any contributor adding images anywhere
    
    The path fixing functions ensure images are correctly referenced regardless
    of where they're included from.
    
    See: GitHub Issue #222
    """
    import shutil
    from pathlib import Path
    
    # Determine paths relative to conf.py location
    conf_dir = Path(app.confdir)
    repo_root = conf_dir.parent.parent.parent
    
    # Primary destination: Standard Sphinx image directory
    img_dest = conf_dir / "_images"
    img_dest.mkdir(parents=True, exist_ok=True)
    
    # Source locations to copy from
    image_sources = [
        # Main image directory (for OSE_ORGANIZATION.md and similar)
        repo_root / "doc" / "assets" / "img",
        # Any figures directories in source tree
        conf_dir / "math_functions" / "figures",
        conf_dir / "api" / "examples" / "md" / "figures",
        conf_dir / "api" / "examples-m" / "md" / "figures",
        # Examples Time-Integrators figures (if they exist)
        conf_dir / "examples" / "Time-Integrators" / "figures",
        conf_dir / "examples" / "Time-Integrators" / "_images",
    ]
    
    copied_count = 0
    # Copy images from all source locations
    for img_source in image_sources:
        if not img_source.exists():
            continue
        
        # Copy all image files
        for pattern in ["*.png", "*.jpg", "*.jpeg", "*.gif", "*.svg"]:
            for img in img_source.glob(pattern):
                dest_file = img_dest / img.name
                try:
                    shutil.copy2(img, dest_file)
                    copied_count += 1
                except shutil.SameFileError:
                    # Source and destination are the same file, skip silently
                    pass
                except (PermissionError, FileNotFoundError) as e:
                    print(f"Warning: Could not copy {img.name}: {e}")
    
    # Also copy images from figures directories relative to markdown files
    # This handles cases where included files (or including files) reference
    # figures/ subdirectories. We check ALL markdown files, not just those
    # with {include} directives, because included files themselves typically
    # don't include other files but may have figures/ directories next to them.
    for source_file in conf_dir.rglob("*.md"):
        if source_file.is_file():
            # Find figures directory relative to this file
            figures_dir = source_file.parent / "figures"
            if figures_dir.exists():
                # Copy to _images (they'll be found there)
                for pattern in ["*.png", "*.jpg", "*.jpeg", "*.gif", "*.svg"]:
                    for img in figures_dir.glob(pattern):
                        dest_file = img_dest / img.name
                        try:
                            shutil.copy2(img, dest_file)
                            copied_count += 1
                        except shutil.SameFileError:
                            # Source and destination are the same file, skip silently
                            pass
                        except (PermissionError, FileNotFoundError) as e:
                            print(f"Warning: Could not copy {img.name}: {e}")


def fix_included_image_paths_source(app, docname, source):
    """
    Fix image paths in source before MyST processes includes.
    
    When MyST includes a file, image paths in that file are resolved relative
    to the INCLUDING file, not the included file. This causes broken paths.
    
    This function rewrites image paths to use Sphinx's standard _images/ path,
    which works regardless of where the file is included from.
    
    Works for ANY markdown file, including both included files and standalone files.
    We process all documents because:
    1. Included files need their paths fixed (main use case)
    2. Standalone files with relative paths also benefit from the fix
    3. The logic is safe - it only changes relative paths and skips absolute paths/URLs
    """
    import re
    from pathlib import Path
    
    src = source[0]
    
    # Pattern to match markdown image syntax: ![alt](path)
    # Match images with various path patterns:
    # - doc/assets/img/file.png (from repo root)
    # - figures/file.png (relative to included file)
    # - path/to/file.png (any relative path)
    # - Already broken paths like intros/doc/assets/img/file.png
    
    def fix_image_path(match):
        alt_text = match.group(1)
        img_path = match.group(2)
        
        # Extract filename from path (handles paths like ../../_images/file.png)
        # Normalize the path to handle ../ and ./ correctly
        try:
            # Use Path to normalize the path and extract just the filename
            normalized_path = Path(img_path)
            img_filename = normalized_path.name
        except Exception:
            # Fallback: just extract filename from string
            img_filename = img_path.split('/')[-1].split('\\')[-1]
        
        # If path already points to _images (at any level), normalize it to absolute path
        if '/_images/' in img_path or img_path.startswith('_images/'):
            # Use absolute path from source root to avoid document-relative resolution
            fixed_path = f'![{alt_text}](/_images/{img_filename})'
            return fixed_path
        
        # If it's an absolute path or URL, keep it (but normalize _images paths)
        if img_path.startswith(('http://', 'https://', '#')):
            return match.group(0)
        if img_path.startswith('/'):
            # Already absolute, but check if it's an _images path that needs normalization
            if '/_images/' in img_path:
                fixed_path = f'![{alt_text}](/_images/{img_filename})'
                return fixed_path
            return match.group(0)
        
        # Rewrite to use Sphinx's standard _images directory with absolute path
        fixed_path = f'![{alt_text}](/_images/{img_filename})'
        return fixed_path
    
    # Match markdown image syntax: ![alt](path)
    image_pattern = r'!\[([^\]]*)\]\(([^)]+)\)'
    
    # Replace all matching image paths
    new_src = re.sub(image_pattern, fix_image_path, src)
    
    if new_src != src:
        source[0] = new_src


def fix_included_image_paths_doctree(app, doctree):
    """
    Fix image paths in doctree as a fallback.
    
    This runs after MyST processes includes and creates the doctree.
    This is a fallback in case source-level fixing didn't work.
    
    Works for ANY document with images, fixing broken paths from included files.
    """
    from docutils import nodes
    from pathlib import Path
    
    # Get docname from app environment
    docname = app.env.docname
    
    # Find all image nodes in the doctree
    fixed_count = 0
    for node in doctree.traverse(nodes.image):
        uri = node.get('uri', '')
        original_uri = uri
        
        # Skip if already correct (absolute /_images/ path)
        if uri.startswith('/_images/'):
            continue
        
        # Skip URLs
        if uri.startswith(('http://', 'https://', '#')):
            continue
        
        # Handle absolute paths that aren't _images
        if uri.startswith('/') and '/_images/' not in uri:
            continue
        
        # Check if this is a broken path that needs fixing
        # Common broken patterns from included files:
        # - intros/doc/assets/img/file.png (resolved relative to wrapper)
        # - doc/assets/img/file.png (from repo root)
        # - figures/file.png (relative to included file location)
        # - examples/Time-Integrators/_images/file.png (resolved relative path - document-relative)
        # - math_functions/_images/file.svg (resolved relative path - document-relative)
        # - _images/file.png (relative path that gets resolved relative to document)
        # - any/path/to/file.png (any relative path)
        
        # If path contains _images/ but isn't absolute, normalize it to absolute
        if '/_images/' in uri or uri.startswith('_images/'):
            # Extract filename from the path
            img_filename = Path(uri).name
            node['uri'] = f'/_images/{img_filename}'
            fixed_count += 1
            continue
        
        # Extract filename
        img_filename = Path(uri).name
        
        # Rewrite to use Sphinx's standard _images directory with absolute path
        node['uri'] = f'/_images/{img_filename}'
        fixed_count += 1

def copy_images_to_build_output(app, exception):
    """
    Copy images to build output directory after build completes.
    
    Sphinx should copy images automatically, but if paths are fixed in doctree
    after Sphinx's image collection phase, we need to manually copy them.
    This ensures images are available in the final HTML output.
    
    This works for ALL images copied to source/_images/, regardless of their
    original location, making it work for any contributor.
    """
    if exception is not None:
        return
    
    import shutil
    from pathlib import Path
    
    # Only copy for HTML builds
    if app.builder.name != 'html':
        return
    
    # Source: source/_images/
    conf_dir = Path(app.confdir)
    img_source = conf_dir / "_images"
    
    # Destination: build/html/_images/
    img_dest = Path(app.outdir) / "_images"
    
    if not img_source.exists():
        return
    
    # Copy images to build output
    img_dest.mkdir(parents=True, exist_ok=True)
    
    copied_count = 0
    for pattern in ["*.png", "*.jpg", "*.jpeg", "*.gif", "*.svg"]:
        for img in img_source.glob(pattern):
            dest_file = img_dest / img.name
            try:
                shutil.copy2(img, dest_file)
                copied_count += 1
            except shutil.SameFileError:
                # Source and destination are the same file, skip silently
                pass
            except (PermissionError, FileNotFoundError) as e:
                print(f"Warning: Could not copy {img.name} to build output: {e}")


def fix_html_image_paths(app, exception):
    """
    Post-process HTML files to convert absolute /_images/ paths to relative paths.
    
    This ensures images work with both:
    - Local file:// URLs (needs relative paths)
    - Web servers (works with both absolute and relative paths)
    
    Sphinx outputs absolute paths when we use /_images/ in the doctree, but for
    local file viewing, we need relative paths based on document depth.
    """
    if exception is not None:
        return
    
    # Only process HTML builds
    if app.builder.name != 'html':
        return
    
    import re
    from pathlib import Path
    
    html_dir = Path(app.outdir)
    
    # Process all HTML files
    for html_file in html_dir.rglob("*.html"):
        try:
            with open(html_file, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Calculate relative path depth from this HTML file to _images/
            # HTML files are in subdirectories like intros/, math_functions/, etc.
            # _images/ is at the root of build/html/
            depth = len(html_file.relative_to(html_dir).parent.parts)
            
            # Build relative path: ../ repeated depth times, then _images/
            if depth == 0:
                rel_path = "_images/"
            else:
                rel_path = "../" * depth + "_images/"
            
            # Replace absolute /_images/ paths with relative paths
            # Match: src="/_images/filename" or src='/_images/filename'
            pattern = r'src=["\']/_images/([^"\']+)["\']'
            replacement = f'src="{rel_path}\\1"'
            
            new_content = re.sub(pattern, replacement, content)
            
            # Only write if content changed
            if new_content != content:
                with open(html_file, 'w', encoding='utf-8') as f:
                    f.write(new_content)
        except Exception as e:
            # Don't fail the build if one file can't be processed
            print(f"Warning: Could not process {html_file}: {e}")


def setup(app):
    """Setup function for Sphinx extension."""
    app.add_js_file('mathconf.js')
    
    # Copy all images to Sphinx _images directory before build starts
    # Use builder-inited instead of config-inited for better timing
    # This ensures the builder is fully set up before we copy images
    # Works for any contributor adding images anywhere
    app.connect('builder-inited', copy_all_images_to_sphinx)
    
    # Fix image paths in included markdown files
    # Try to fix in source first (before MyST processes includes)
    app.connect('source-read', fix_included_image_paths_source)
    # Also fix in doctree as a fallback (after MyST processes includes)
    app.connect('doctree-read', fix_included_image_paths_doctree)
    
    # Copy images to build output after build completes
    app.connect('build-finished', copy_images_to_build_output)
    
    # Fix HTML image paths to use relative paths for local file viewing
    app.connect('build-finished', fix_html_image_paths)
    
    # Add capability to replace problematic math environments
    app.connect('source-read', fix_math_environments)
    
    # Patch graphviz extension to avoid file exists errors
    from sphinx.ext import graphviz
    original_on_build_finished = graphviz.on_build_finished
    
    def patched_on_build_finished(app, exception):
        """Patched version of graphviz on_build_finished that ignores file exists errors."""
        try:
            original_on_build_finished(app, exception)
        except FileExistsError:
            pass
    
    graphviz.on_build_finished = patched_on_build_finished

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

latexauthorslist = r" \and ".join(authorlist)
latex_documents = [
    (
        'index',            # Source start file
        'MOLE-docs.tex',    # Target filename
        'MOLE User Manual', # Title
        latexauthorslist,   # Author
        'manual',           # Document class
        False               # toctree_only
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
# try:
#     if os.path.exists(example_dest):
#         shutil.rmtree(example_dest)
# except FileNotFoundError:
#     pass

# Debug info - commented out for cleaner build output
# print("\nDEBUG: Exclude Patterns:")
# for pattern in exclude_patterns:
#     print(f"  - {pattern}")

# # Copy all markdown files from examples directory
# for filename in glob.glob(str(ROOT_DIR / "examples/**/*.md"), recursive=True):
#     rel_path = os.path.relpath(filename, str(ROOT_DIR / "examples"))
#     destdir = os.path.join(example_dest, os.path.dirname(rel_path))
#     dest_file = os.path.join(destdir, os.path.basename(rel_path))
#     
#     # Only exclude if the relative path exactly matches an exclude pattern
#     skip_file = rel_path in exclude_patterns
#     
#     if not skip_file:
#         mkdir_p(destdir)
#         shutil.copy2(filename, destdir)
#         print(f"DEBUG: Copied markdown file: {filename} to {destdir}")

# # Copy all image files from examples directory
# for ext in ['*.jpg', '*.jpeg', '*.png', '*.svg']:
#     for filename in glob.glob(str(ROOT_DIR / "examples/**/" / ext), recursive=True):
#         rel_path = os.path.relpath(filename, str(ROOT_DIR / "examples"))
#         destdir = os.path.join(example_dest, os.path.dirname(rel_path))
#         mkdir_p(destdir)
#         shutil.copy2(filename, destdir)
#         print(f"DEBUG: Copied image file: {filename} to {destdir}")

# Debug info to help troubleshoot file copying
# print("\nDEBUG: Directory Structure Before File Operations:")
# if os.path.exists(example_dest):
#     for root, dirs, files in os.walk(example_dest):
#         rel_root = os.path.relpath(root, example_dest)
#         if rel_root == ".":
#             print(f"Directory: {example_dest}")
#         else:
#             print(f"Directory: {os.path.join(example_dest, rel_root)}")
#         for file in files:
#             print(f"  File: {file}")

# # Ensure README files that are referenced in toctree exist
# readme_files = [
#     os.path.join(example_dest, "README.md"),
#     os.path.join(example_dest, "cpp/README.md"),
#     os.path.join(example_dest, "matlab/compact_operators/README.md")
# ]
# 
# for readme_file in readme_files:
#     dir_path = os.path.dirname(readme_file)
#     if not os.path.exists(dir_path):
#         mkdir_p(dir_path)
#     
#     # If the README doesn't exist, create a basic one with a title
#     if not os.path.exists(readme_file):
#         basename = os.path.basename(os.path.dirname(readme_file))
#         if basename == "examples":
#             title = "MOLE Examples Overview"
#             content = "This directory contains examples demonstrating the usage of MOLE."
#         elif basename == "cpp":
#             title = "C++ Examples"
#             content = "This folder contains C++ examples for MOLE."
#         elif basename == "compact_operators":
#             title = "MATLAB Compact Operators"
#             content = "This folder contains MATLAB examples for compact operators."
#         
#         with open(readme_file, 'w') as f:
#             f.write(f"# {title}\n\n{content}\n")

# Debug info after file operations
# print("\nDEBUG: Directory Structure After File Operations:")
# if os.path.exists(example_dest):
#     for root, dirs, files in os.walk(example_dest):
#         rel_root = os.path.relpath(root, example_dest)
#         if rel_root == ".":
#             print(f"Directory: {example_dest}")
#         else:
#             print(f"Directory: {os.path.join(example_dest, rel_root)}")
#         for file in files:
#             print(f"  File: {file}")

# Check if specific README files exist
# print("\nDEBUG: Checking for specific README files:")
# for readme_file in readme_files:
#     if os.path.exists(readme_file):
#         print(f"  - {readme_file}: FOUND")
#     else:
#         print(f"  - {readme_file}: NOT FOUND")

# SEO and metadata settings
html_baseurl = 'https://mole-pdes.readthedocs.io/'
html_extra_path = []
html_use_opensearch = ''

# Additional meta tags for all pages
html_meta = {
    'keywords': 'mimetic operators, computational science, PDE solver, numerical methods, scientific computing, MATLAB, C++',
    'description': 'MOLE: Mimetic Operators Library Enhanced - A high-order mimetic differential operators library for solving PDEs',
    'author': 'CSRC SDSU',
    'viewport': 'width=device-width, initial-scale=1',
}

# Add version information display
html_last_updated_fmt = '%b %d, %Y'
html_use_smartypants = True

# Add a sitemap
html_additional_pages = {}
html_extra_path.append('robots.txt')

# Enable Google Analytics if you have a tracking ID
# html_theme_options.update({
#     "google_analytics_id": "UA-XXXXX-X",
# })

# SEO and metadata settings
html_baseurl = 'https://mole-pdes.readthedocs.io/'
html_use_opensearch = ''

# Additional meta tags for all pages
html_meta.update({
    'og:title': 'MOLE User Manual',
    'og:site_name': 'MOLE: Mimetic Operators Library Enhanced',
    'og:url': 'https://mole-pdes.readthedocs.io/',
    'og:image': 'https://mole-pdes.readthedocs.io/_static/logo.png',
    'og:type': 'website',
    'twitter:card': 'summary_large_image',
    'twitter:title': 'MOLE User Manual',
    'twitter:description': 'MOLE: Mimetic Operators Library Enhanced - A high-order mimetic differential operators library for solving PDEs',
})

# Add Open Graph protocol markup
html_theme_options.update({
    # Other options
    # "announcement": "Latest release: v1.1.0",
    "use_edit_page_button": True,
    "extra_footer": """
        <div class="footer-extra">
            <p>MOLE is a project by CSRC SDSU.</p>
        </div>
    """,
    "home_page_in_toc": True,
    "icon_links": [
        {
            "name": "GitHub",
            "url": "https://github.com/csrc-sdsu/mole",
            "icon": "fab fa-github",
        },
        {
            "name": "MATLAB",
            "url": "https://www.mathworks.com/matlabcentral/fileexchange/124870-mole",
            "icon": "fas fa-cube",
        },
    ],
})

# Configure sphinx-copybutton
copybutton_selector = "div.highlight pre"

# Fix for static file copying issues
def copy_file_safe(src, dst):
    """Copy file without raising error if destination exists."""
    try:
        shutil.copy2(src, dst)
    except OSError as e:
        if e.errno != errno.EEXIST:
            raise

# Override default copytree function for static files
original_copytree = shutil.copytree

def copytree_ignore_existing(src, dst, *args, **kwargs):
    """Copy directory tree but ignore existing files."""
    try:
        return original_copytree(src, dst, *args, **kwargs)
    except FileExistsError:
        # If dst exists as a file or dir, just return without raising error
        return dst

# Monkey patch for Sphinx to use our custom copy function
shutil.copytree = copytree_ignore_existing
# print("\nDEBUG: Checking for specific README files:")
# for readme_file in readme_files:
#     if os.path.exists(readme_file):
#         print(f"  - {readme_file}: FOUND")
#     else:
#         print(f"  - {readme_file}: NOT FOUND")
# MOLE Documentation Guide

This is the definitive guide for building and maintaining the documentation for the MOLE.

## Documentation Structure

The MOLE documentation consists of two main components:

1. **API Documentation** (Doxygen)
   - C++ API reference
   - MATLAB/Octave API reference
   - Implementation details
   - Code documentation

2. **User Manual** (Sphinx)
   - Tutorials
   - Examples
   - Usage guides
   - Theory background

## ️Building Documentation

### Prerequisites

Before building the documentation, ensure you have:

1. **Doxygen** installed on your system (for API documentation)
   ```bash
   # Ubuntu/Debian
   sudo apt install doxygen
   
   # macOS with Homebrew
   brew install doxygen
   
   # RHEL/CentOS/Fedora
   sudo dnf install doxygen
   ```

2. **Graphviz** installed for generating diagrams
   ```bash
   # Ubuntu/Debian
   sudo apt install graphviz
   
   # macOS with Homebrew
   brew install graphviz
   
   # RHEL/CentOS/Fedora
   sudo dnf install graphviz
   ```

3. **Inkscape** installed for high-quality SVG to PDF conversion (required for PDF output)
   ```bash
   # Ubuntu/Debian
   sudo apt install inkscape
   
   # macOS with Homebrew
   brew install inkscape
   
   # RHEL/CentOS/Fedora
   sudo dnf install inkscape
   ```

5. **LaTeX** (required for PDF generation):
   ```bash
   # Ubuntu/Debian
   sudo apt install texlive-latex-base texlive-fonts-recommended texlive-latex-extra

   # RHEL/CentOS/Fedora
   sudo dnf install texlive-scheme-medium

   # macOS
   brew install --cask mactex
   ```

6. **Python dependencies**:
   First, ensure Python 3 and pip are installed:
   ```bash
   # Ubuntu/Debian
   sudo apt install python3 python3-pip python3-venv
   
   # RHEL/CentOS/Fedora
   sudo dnf install python3 python3-pip python3-virtualenv
   ```

   Then set up the Python environment:
   ```bash
   # Navigate to the documentation directory
   cd doc/sphinx

   # Create and activate a virtual environment (Required)
   python3 -m venv .venv
   source .venv/bin/activate  # On Unix/MacOS
   # or
   .venv\Scripts\activate     # On Windows

   # Install required dependencies 
   # Either use:
   make doc-deps
   # Or install directly:
   python3 -m pip install -r requirements.txt
   ```

   Some additional packages have been added to enhance documentation features:
   - `sphinx-togglebutton`: For collapsible content
   - `sphinx-fontawesome`: For FontAwesome icons
   - `sphinxcontrib-mermaid`: For Mermaid.js diagrams
   - `sphinxext-altair`: For Altair chart integration
   - `Pillow`: For image processing including dark mode logo

### Building Steps

All commands should be run from the `doc/sphinx` directory:

```bash
# Generate API Documentation
make doc-doxygen

# Build HTML documentation
make doc-html

# PDF output (requires LaTeX and Inkscape)
make doc-latexpdf

# Clean build files (Doxygen + Sphinx)
make doc-clean

# Build all documentation
make doc-all
```

The documentation will be generated in:
- HTML: `doc/sphinx/build/html/`
- PDF: `doc/sphinx/build/latex/MOLE-docs.pdf` and at the project root (`MOLE-docs.pdf`)
- API Docs: `doc/doxygen/`

### PDF Generation Process

The PDF generation process does the following:

1. Runs Sphinx to generate LaTeX files
2. Converts SVG figures to high-quality PDF using Inkscape (2400 DPI)
3. Applies special fixes to LaTeX files for proper math rendering
4. Compiles the LaTeX document into a PDF
5. Copies the final PDF to the project root directory

This process is handled by the `build.sh` script, which is called by the `doc-latexpdf` make target.

### Image Handling

Images are automatically handled when building the documentation using the Makefile targets:

The image handling process:
- Copies images from `doc/assets/img/` to `doc/sphinx/build/html/_static/img/`
- Fixes image paths in the HTML output
- For PDF output, converts SVG files to high-quality PDFs (using Inkscape)

If you're running Sphinx directly without the Makefile, you'll need to run the image copy script separately:

```bash
# Run after building documentation manually
./copy_images.sh
```

## Development Workflow

When contributing to documentation:

1. **API Documentation**
   - Add C++ documentation in source code using Doxygen syntax
   - Build with `make doc-doxygen` to verify

2. **User Manual**
   - Edit `.rst` or `.md` files in `doc/sphinx/source/`
   - Build with `make doc-html` to preview changes
   - Use `make doc-clean` to force full rebuild

## Documentation Standards

- Use clear, concise language
- Include working code examples
- Follow [Sphinx reST](https://www.sphinx-doc.org/en/master/usage/restructuredtext/basics.html) syntax
- Follow [Doxygen](https://www.doxygen.nl/manual/docblocks.html) conventions for API docs

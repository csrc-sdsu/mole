# MOLE Documentation

This guide explains how to build and maintain the documentation for the Mimetic Operators Library Enhanced (MOLE).

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

```bash
# Navigate to the documentation directory
cd doc/sphinx

# Create and activate a virtual environment (Recommended)
python -m venv .venv
source .venv/bin/activate  # On Unix/MacOS
# or
.venv\Scripts\activate     # On Windows

# Install required dependencies from requirements.txt
make doc-deps
```

### Building Steps

All commands should be run from the `doc/sphinx` directory:

```bash
# Generate API Documentation
make doc-doxygen

# Build HTML documentation
make doc-html

# PDF output (requires LaTeX)
make doc-latexpdf

# Clean build files (Doxygen + Sphinx)
make doc-clean

# Build all documentation
make doc-all
```

The documentation will be generated in:
- HTML: `doc/sphinx/build/html/`
- PDF: `doc/sphinx/build/pdf/`
- API Docs: `doc/doxygen/`

### Image Handling

Images are automatically handled when building the documentation using the Makefile targets:

The image handling process:
- Copies images from `doc/assets/img/` to `doc/sphinx/build/html/_static/img/`
- Fixes image paths in the HTML output

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

## Useful Links

- [Sphinx Documentation](https://www.sphinx-doc.org/)
- [Doxygen Manual](https://www.doxygen.nl/manual/)
- [reStructuredText Primer](https://www.sphinx-doc.org/en/master/usage/restructuredtext/basics.html)

## Contributing

Please read our [Contributing Guide](https://github.com/csrc-sdsu/mole/blob/master/CONTRIBUTING.md) before submitting documentation changes.
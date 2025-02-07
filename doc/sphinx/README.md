# MOLE Documentation

This guide explains how to build and maintain the documentation for the Mimetic Operators Library Enhanced (MOLE).

## 📚 Documentation Structure

The MOLE documentation consists of two main components:

1. **API Documentation** (Doxygen)
   - C++ API reference
   - MATLAB API reference
   - Implementation details
   - Code documentation

2. **User Manual** (Sphinx)
   - Tutorials
   - Examples
   - Usage guides
   - Theory background

## 🛠️ Building Documentation

### Prerequisites

```bash
# Create and activate a virtual environment (Recommended)
python -m venv .venv
source .venv/bin/activate  # On Unix/MacOS
# or
.venv\Scripts\activate     # On Windows

# Install dependencies
pip install -r doc/sphinx/requirements.txt
```

### Building Steps

1. **Generate API Documentation**
```bash
# From project root
make doxygen
```

2. **Build User Manual**
```bash
# HTML output
make html

# PDF output (requires LaTeX)
make latexpdf

# Clean build (Removes all Sphinx build files)
make clean
```

The documentation will be generated in:
- C++ API Docs: `doc/api_docs/cpp/`
- HTML: `doc/sphinx/build/html/`
- PDF: `doc/sphinx/build/pdf/`

## 🔄 Development Workflow

When contributing to documentation:

1. **API Documentation**
   - Add C++ documentation in source code using Doxygen syntax
   - Build with `make doxygen` to verify

2. **User Manual**
   - Edit `.rst` files in `doc/sphinx/source/`
   - Build with `make html` to preview changes
   - Use `make clean` to force full rebuild

## 📖 Documentation Standards

- Use clear, concise language
- Include working code examples
- Follow [Sphinx reST](https://www.sphinx-doc.org/en/master/usage/restructuredtext/basics.html) syntax
- Follow [Doxygen](https://www.doxygen.nl/manual/docblocks.html) conventions for API docs

## 🔗 Useful Links

- [Sphinx Documentation](https://www.sphinx-doc.org/)
- [Doxygen Manual](https://www.doxygen.nl/manual/)
- [reStructuredText Primer](https://www.sphinx-doc.org/en/master/usage/restructuredtext/basics.html)

## 🤝 Contributing

Please read our [Contributing Guide](../../CONTRIBUTING.md) before submitting documentation changes.
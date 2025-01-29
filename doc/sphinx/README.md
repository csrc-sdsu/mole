# MOLE: Documentation

This page provides a brief description of the documentation for the Mimetic Operators Library Enhanced (MOLE).

### Dependencies

The documentation system requires several Python packages. You can install them using:

```sh
virtualenv VENV                              # create a virtual environment (Recommended)
source VENV/bin/activate                     # activate the environment (Recommended)
pip install -r doc/sphinx/requirements.txt   # install dependencies
```

## Documentation Structure

The MOLE documentation consists of two main components:

1. **API Documentation**: Generated using Doxygen, providing detailed C++ API reference
2. **User Manual**: Written in Sphinx, offering tutorials, examples, and usage guides

## 1. Doxygen

Doxygen is used to generate the C++ API documentation. The configuration can be found in the `Doxyfile` in the root directory. To build the API documentation:

```sh
doxygen Doxyfile
```

This will generate documentation in the `doc/api_docs/cpp` directory.

## 2. Sphinx

Sphinx is the tool used for libCEED's User Manual. Sphinx can produce documentation in different output formats: HTML, LaTeX (for printable PDF versions), ePub, Texinfo, manual pages, and plain text. Sphinx comes with a broad set of extensions for different features, for instance the automatic inclusion of documentation from docstrings and snippets of codes, support of todo items, highlighting of code, and math rendering.

To be able to contribute to libCEED's User Manual, Sphinx needs to be [installed](http://www.sphinx-doc.org/en/master/usage/installation.html) together with its desired extensions.

The Sphinx API documentation depends on Doxygen's XML output (via the `breathe` plugin).  Build these files in the `xml/` directory via:

```sh
doxygen Doxyfile
```

If you are editing documentation, such as the reStructuredText files in `doc/sphinx/source`, you can rebuild incrementally via

```sh
sphinx-build -b html doc/sphinx/source  doc/sphinx/build 
```
which will HTML docs in the [doc/sphinx/build](./sphinx/build) directory.

```sh
sphinx-build -b latexpdf doc/sphinx/source doc/sphinx/build 
```

to build PDF using the LaTeX toolchain (which must be installed).
This requires the `rsvg-convert` utility, which is likely available from your package manager under `librsvg` or `librsvg2-bin`.

## Contributing to Documentation

When contributing to the documentation:

1. API documentation should be written as C++ comments in the source code
2. User manual content should be added to the appropriate `.rst` files in `doc/sphinx/source`
3. Examples and tutorials should include working code samples
4. Build and test the documentation locally before submitting changes

For more information about the documentation system, please refer to:
- [Doxygen Manual](https://www.doxygen.nl/manual/)
- [Sphinx Documentation](https://www.sphinx-doc.org/)
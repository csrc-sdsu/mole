# MOLE: Documentation

This page provides a brief description of the documentation for the Mimetic Operators Library Enhanced (MOLE).

## Quick Build

If you have Python and Doxygen installed, these two commands should build the documentation in `doc/api_docs/cpp`:

```sh
pip install --user -r doc/sphinx/requirements.txt  # only needed once
make doc                                          # builds documentation
```

## Documentation Structure

The MOLE documentation consists of two main components:

1. **API Documentation**: Generated using Doxygen, providing detailed C++ API reference
2. **User Manual**: Written in Sphinx, offering tutorials, examples, and usage guides

## Doxygen

Doxygen is used to generate the C++ API documentation. The configuration can be found in the `Doxyfile` in the root directory. To build the API documentation:

```sh
make doxygen
```

This will generate documentation in the `doc/api_docs/cpp` directory.

## Sphinx

Sphinx is used for the User Manual, which can produce documentation in multiple formats including HTML, PDF, and ePub. 

### Dependencies

The documentation system requires several Python packages. You can install them using:

```sh
pip install --user -r doc/sphinx/requirements.txt
```

For isolated development, you can use a virtual environment:

```sh
virtualenv VENV                              # create a virtual environment
source VENV/bin/activate                     # activate the environment
pip install -r doc/sphinx/requirements.txt   # install dependencies
make doc                                     # build documentation
```

### Building Documentation

To build specific documentation formats:

```sh
make -C doc/sphinx html      # Build HTML documentation
make -C doc/sphinx latexpdf  # Build PDF documentation (requires LaTeX)
```

For a list of all available documentation targets:

```sh
make -C doc/sphinx help
```

## Contributing to Documentation

When contributing to the documentation:

1. API documentation should be written as C++ comments in the source code
2. User manual content should be added to the appropriate `.rst` files in `doc/sphinx/source`
3. Examples and tutorials should include working code samples
4. Build and test the documentation locally before submitting changes

For more information about the documentation system, please refer to:
- [Doxygen Manual](https://www.doxygen.nl/manual/)
- [Sphinx Documentation](https://www.sphinx-doc.org/)

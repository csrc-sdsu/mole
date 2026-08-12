# pymole: Python interface for [MOLE](https://github.com/csrc-sdsu/mole)

## Description

This is an implementation written in Python for the MOLE package. The source files for the operators are located at ```src/``` and examples can be found in ```examples/```. This is a WIP implementation; currently (as of August 11, 2026), only the 1D and 2D operators are available.

## Installation

pymole is not yet available in the Python Package Index (PyPI). For now, this repository needs to be cloned locally in order to use the library in Python.

## Using pymole

In order to use the pymole library, first navigate to the location where the repository has been cloned to. Then, go to the `mole/python` sub-directory. From here, you can access the library via the command line.

### From the command line

In `mole/python`, use the following command to install the MOLE module:

```sh
python -m pip install --user ./python
```

## Running the test suite

To run the unit tests, first install the MOLE module as described above, then run the command `python -m pytest python/tests` from the directory `mole/python`). The results of the unit tests should be displayed to your console.

## Examples

The MOLE library contains examples demonstrating how to use the operators, in a broad range of partial differential equations (PDEs). More information on the mathematical content can be found in the [main MOLE documentation](https://mole-docs.readthedocs.io/en/main/examples/index.html).

Currently, the following examples are available in the MOLE Python package.

- Elliptic Problems
    - 1D Examples
        - `elliptic1D`: A script that solves the 1D Poisson's equation with Robin boundary conditions using mimetic operators.

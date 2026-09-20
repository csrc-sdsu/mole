# pymole: Python interface for [MOLE](https://github.com/csrc-sdsu/mole)

## Description

This is an implementation written in Python for the MOLE package. The source files for the operators are located at ```src/``` and examples can be found in ```examples/```. This is a WIP implementation; currently (as of August 11, 2026), only the 1D and 2D operators are available.

## Installation

pymole is not yet available in the Python Package Index (PyPI). For now, this repository needs to be cloned locally in order to use the library in Python.

## Python 3

The pymole library requires Python 3. You can check your Python version by running the command `python --version` or `python3 --version` in your terminal. If you do not have Python 3 installed, you can install it by following the instructions at [python.org](https://www.python.org/downloads/). 

If your operating system comes with Python 2 pre-installed, you may need to use `python3` instead of `python` in the commands below. In this case, you can also use the `python3` command to access your Python 3 installation.

## Using pymole

In order to use the pymole library, first navigate to the location where the repository has been cloned to. From here, you can access the library via the command line.

### Dependencies

MOLE requires the following packages to be installed:

- numpy: [installation instructions](https://numpy.org/install/)

python -m pip install --user numpy

- pytest: [installation instructions](https://docs.pytest.org/en/stable/getting-started/installation.html)

python -m pip install --user pytest

- scipy: [installation instructions](https://docs.scipy.org/doc/scipy/reference/building_scipy.html)

python -m pip install --user scipy

- matplotlib: [installation instructions](https://matplotlib.org/stable/users/installing.html)

python -m pip install --user matplotlib

### From the command line

In the repository root, `mole`, use the following command to install the Python MOLE module:

```sh
python -m pip install --user ./python
```

## Running the test suite

To run the unit tests, first install the MOLE module as described above, then run the command `python -m pytest python/tests` from the same root directory `mole`). The results of the unit tests should be displayed to your console.

## Examples

The MOLE library contains examples demonstrating how to use the operators, in a broad range of partial differential equations (PDEs). More information on the mathematical content can be found in the [main MOLE documentation](https://mole-docs.readthedocs.io/en/main/examples/index.html).

Currently, the following examples are available in the MOLE Python package.

- Elliptic Problems
    - 1D Examples
        - `elliptic1D`: A script that solves the 1D Poisson's equation with Robin boundary conditions using mimetic operators. Invoke as
        
        ```sh
         python python/examples/elliptic1D.py
        ```

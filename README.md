# MOLE: Mimetic Operators Library Enhanced

[![JOSS paper](https://joss.theoj.org/papers/10.21105/joss.06288/status.svg)](https://doi.org/10.21105/joss.06288)
[![MATLAB File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/124870-mole)
[![License](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Build Status](https://github.com/csrc-sdsu/mole/actions/workflows/ci.yml/badge.svg)](https://github.com/csrc-sdsu/mole/actions/workflows/ci.yml)
[![Documentation](https://readthedocs.org/projects/mole-docs/badge/?version=latest)](https://mole-docs.readthedocs.io/en/latest/)

## Description

MOLE is a high-quality (C++ & MATLAB/Octave) library that implements
high-order mimetic operators to solve partial differential equations.
It provides discrete analogs of the most common vector calculus operators:
Gradient, Divergence, Laplacian, Bilaplacian, and Curl. These operators (highly sparse matrices) act
on staggered grids (uniform, non-uniform, curvilinear) and satisfy local and
global conservation laws.

Mathematics is based on the work of [Corbino and Castillo](https://doi.org/10.1016/j.cam.2019.06.042).
However, the user may find helpful previous publications, such as [Castillo and Grone](https://doi.org/10.1137/S0895479801398025),
in which similar operators were derived using a matrix analysis approach.

## Installation

### Platform and Compiler Compatibility
Refer to the table below for compiler support across different operating systems when building MOLE.

| OS / Compiler | GCC 13.2.0 | AppleClang | IntelLLVM (icpx) |
|---------------|------------|------------|------------------|
| Linux         | Yes        | No         | Yes              |
| macOS         | No         | Yes        | Yes              |

### Prerequisites

To install the MOLE library, you'll need the following packages:

- CMake (Minimum version 3.10)
- OpenBLAS (Minimum version 0.3.10)
- Eigen3
- LAPACK (Mac only)
- libomp (Mac only)

For documentation build requirements, please refer to the [Documentation Guide](https://github.com/csrc-sdsu/mole/blob/main/doc/sphinx/README.md).

### Package Installation by OS

#### Ubuntu/Debian Systems

```bash
# Install all required packages
sudo apt install cmake libopenblas-dev libeigen3-dev
```

#### macOS Systems

Install [Homebrew](https://brew.sh/) if you don't have it already, then run:

```bash
# Install all required packages
brew install cmake openblas eigen libomp lapack
```

> **Troubleshooting Homebrew:** If you encounter installation errors, try these steps:
> ```bash
> # Fix permissions issues
> sudo chown -R $(whoami) /usr/local/Cellar
> # Fix shallow clone issues
> git -C /usr/local/Homebrew/Library/Taps/homebrew/homebrew-core fetch --unshallow
> # Remove Java dependencies if they cause conflicts
> brew uninstall --ignore-dependencies java
> brew update
> ```

#### RHEL/CentOS/Fedora Systems

```bash
# Install all required packages
sudo yum install cmake openblas-devel eigen3-devel lapack
```

## Building and Installing

1. Clone the repository:
   ```bash
   git clone https://github.com/csrc-sdsu/mole.git
   cd mole
   ```

2. Build the library:
   ```bash
   mkdir build && cd build
   cmake ..
   make
   ```

3. Install the library:
   - For a custom location:
     ```bash
     cmake --install . --prefix /path/to/location
     ```
   - For a system location (requires privileges):
     ```bash
     sudo cmake --install .
     ```
     Or
     ```bash
     sudo cmake --install . --prefix /path/to/privileged/location
     ```

**Note:** Armadillo and SuperLU will be automatically installed in the build directory during the build process.

## Testing

Run from the `build` directory:

### C++

A suite of four automatic tests that verify MOLE's installation and dependencies. These tests run automatically during the C++ library construction.

```bash
make run_tests
```

### MATLAB/Octave

MATLAB/Octave equivalent of the C++ test suite. We recommend running these tests before using MOLE to ensure proper setup.

```matlab
make run_matlab_octave_tests
```

## Examples

Many of the examples require 'gnuplot' to visualize the results. You can get gnuplot on macOSX with 
```bash
brew install gnuplot
```
and on Windows downlaoding and running the file from [here](https://sourceforge.net/projects/gnuplot/files/gnuplot/6.0.2/gp602-win64-mingw.exe/download)

### C++

Four self-contained, well-documented examples demonstrating typical PDE solutions. These are automatically built with `make` and serve as an excellent starting point for C++ users.

### MATLAB/Octave Examples

A collection of over 30 examples showcasing various PDE solutions, from simple linear one-dimensional problems to complex nonlinear multidimensional scenarios.

## Documentation

MOLE comes with comprehensive documentation:

- **API Reference & User Guide**: Access our online [Documentation](https://mole-docs.readthedocs.io/en/latest/)
- **Building Documentation**: To build documentation locally, follow our [Documentation Guide](https://github.com/csrc-sdsu/mole/blob/main/doc/sphinx/README.md).

> **Important Note:** Performing non-unary operations involving operands constructed over different grids may lead to unexpected results. While MOLE allows such operations without throwing errors, users must exercise caution when manipulating operators across different grids.

## Licensing

MOLE is distributed under a GNU General Public License; please refer to the _LICENSE_
file for more details.

## Community Guidelines

We welcome contributions to MOLE, including:
- Adding new functionalities
- Providing examples
- Addressing existing issues
- Reporting bugs
- Requesting new features

Please refer to our [Contribution Guidelines](https://github.com/csrc-sdsu/mole/blob/main/CONTRIBUTING.md) for more details.

## Citations

Please cite our work if you use MOLE in your research or software.
Citations are helpful for the continued development and maintenance of the library.

## Gallery

Now, some cool pictures obtained with MOLE:

![Obtained with curvilinear operators](doc/assets/img/4thOrder.png)
![Obtained with curvilinear operators](doc/assets/img/4thOrder2.png)
![Obtained with curvilinear operators](doc/assets/img/4thOrder3.png)
![Obtained with curvilinear operators](doc/assets/img/grid2.png)
![Obtained with curvilinear operators](doc/assets/img/grid.png)
![Obtained with curvilinear operators](doc/assets/img/WavyGrid.png)
![Obtained with curvilinear operators](doc/assets/img/wave2D.png)
![Obtained with curvilinear operators](doc/assets/img/burgers.png)

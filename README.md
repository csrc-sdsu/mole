# MOLE: Mimetic Operators Library Enhanced

[![JOSS paper](https://joss.theoj.org/papers/10.21105/joss.06288/status.svg)](https://doi.org/10.21105/joss.06288)
[![MATLAB File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/124870-mole)
[![License](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Build Status](https://github.com/csrc-sdsu/mole/actions/workflows/ci.yml/badge.svg)](https://github.com/csrc-sdsu/mole/actions/workflows/ci.yml)
[![Documentation](https://readthedocs.org/projects/mole-docs/badge/?version=main)](https://mole-docs.readthedocs.io/en/main/)

## Description

MOLE is a high-quality (C++, MATLAB/Octave, or Fortran) library that implements
high-order mimetic operators to solve partial differential equations.
It provides discrete analogs of the most common vector calculus operators:
Gradient, Divergence, Laplacian, Bilaplacian, and Curl. These operators (highly sparse matrices) act
on staggered grids (uniform, non-uniform, curvilinear) and satisfy local and
global conservation laws.  Fortran programs invoke mimetic operators via
defined operations: `.div. v`, `.grad. f`, and `.laplacian. f`, for exmaple.

Mathematics is based on the work of [Corbino and Castillo](https://doi.org/10.1016/j.cam.2019.06.042).
However, the user may find helpful previous publications, such as [Castillo and Grone](https://doi.org/10.1137/S0895479801398025),
in which similar operators were derived using a matrix analysis approach.

## Installation

### Platform and Compiler Compatibility
#### C++
Refer to the table below for compiler support across different operating systems when building MOLE.

| OS / Compiler | GCC 13.2.0 | AppleClang | IntelLLVM (icpx) |
|---------------|------------|------------|------------------|
| Linux         | Yes        | No         | Yes              |
| macOS         | No         | Yes        | Yes              |

#### Fortran
The Fortran implementation supports recent versions of the GCC (`gfortran`), Intel (`ifx`),
LLVM (`flang`), and NAG (`nagfor`) compilers on macOS and Ubuntu Linux.

### Prerequisites
#### C++
To install MOLE's C++ library, you'll need the following packages:

- CMake (Minimum version 3.10)
- OpenBLAS (Minimum version 0.3.10)
- Eigen3
- LAPACK (Mac only)
- libomp (Mac only)

For documentation build requirements, please refer to the [Documentation Guide](https://github.com/csrc-sdsu/mole/blob/main/doc/sphinx/README.md).

#### Fortran
To install MOLE's Fortran library, you'll need the Fortran Package Manager ([`fpm`](https://github.com/fortran-lang/fpm)),
which will automatically download and build all prerequisites.

### Package Installation by OS

#### Fortran
On macOS, Linux, or Windows with `git` and `fpm` installed,
```
git clone https://github.com/csrc-sdsu/mole
cd mole
git submodule update --init --recursive
fpm install --profile release --flag "-I./src/fortran/include"
```
which builds with the compiler specified by the `FPM_FC` environment variable
of with `gfortran` if `FPM_FC` is empty.  For `fpm` commands to use with other
supported compilers, please consult `src/fortran/README.md` _after_ running
the above `git submodule` command to ensure `src/fortran` exists.

#### C++

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

### C++
Run from the `build` directory:

A suite of four automatic tests that verify MOLE's installation and dependencies. These tests run automatically during the C++ library construction.

```bash
make run_tests
```

### MATLAB/Octave
Run from the `build` directory:

MATLAB/Octave equivalent of the C++ test suite. We recommend running these tests before using MOLE to ensure proper setup.

```matlab
make run_matlab_octave_tests

### Fortran
Run from the `src/fortran` directory:
```
fpm test
```

## Examples

Many of the examples require 'gnuplot' to visualize the results. You can get gnuplot on macOSX with 
```bash
brew install gnuplot
```
and on Windows downlaoding and running the file from [here](https://sourceforge.net/projects/gnuplot/files/gnuplot/6.0.2/gp602-win64-mingw.exe/download)

### Fortran
With your present working directory set to anywhere inside the `src/fortran` directory, run
```
fpm run --example [<base-name>]
```
where square brackets desginate an optional argument, angular brackets indicate user input,
and `<base-name>` is the string preceding the `.F90` extension in the name of any file in
the `src/fortran/example` directory.

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

## How to Cite

Please cite our work if you use MOLE in your research or software.
Citations are helpful for the continued development and maintenance of the library.

```bibtex
@article{Corbino2024, 
   doi = {10.21105/joss.06288}, 
   url = {https://doi.org/10.21105/joss.06288}, 
   year = {2024}, 
   publisher = {The Open Journal}, 
   volume = {9}, 
   number = {99}, 
   pages = {6288}, 
   author = {Corbino, Johnny and Dumett, Miguel A. and Castillo, Jose E.}, 
   title = {MOLE: Mimetic Operators Library Enhanced}, 
   journal = {Journal of Open Source Software} }
```

The archival copy of the MOLE User Manual is maintained on [Zenodo](https://zenodo.org/records/16898575). To cite the User Manual please use:

```bibtex
@misc{MOLE_user_manual,
   author       = {Barra, Valeria and
                  Boada, Angel and
                  Brzenski, Jared and
                  Castillo, Jose and
                  Chakalasiya, Prit and
                  Singh, Surinder Chhabra and
                  Corbino, Johnny Delgado and
                  Drummond, Tony and
                  Dumett, Miguel and
                  Hellmers, Joe and
                  Ilaty, Arshia and
                  Kaviani, Katayoon and
                  Nzerem, Oluchi and
                  Pagallo, Giulia and
                  Paolini, Christopher and
                  Rosano, Valentina and
                  Srinivas, Aneesh Murthy and
                  Srinivasan, Janani Priyadharshini and
                  Valera, Manuel},
   title        = {{MOLE User Manual}},
   month        = aug,
   year         = 2025,
   publisher    = {Zenodo},
   version      = {1.1.0},
   doi          = {10.5281/zenodo.16898575},
   url          = {https://doi.org/10.5281/zenodo.16898575},
}
```

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

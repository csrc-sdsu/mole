MOLE: Mimetic Operators Library Enhanced
========================================


1: Description
--------------

MOLE is a high-quality (C++ & MATLAB/Octave) library that implements 
high-order mimetic operators to solve partial differential equations. 
It provides discrete analogs of the most common vector calculus operators: 
Gradient, Divergence, Laplacian, Bilaplacian, and Curl. These operators (highly sparse matrices) act 
on staggered grids (uniform, non-uniform, curvilinear) and satisfy local and 
global conservation laws.

Mathematics is based on the work of [Corbino and Castillo, 2020](https://doi.org/10.1016/j.cam.2019.06.042). 
However, the user may find helpful previous publications, such as [Castillo and Grone, 2003](https://doi.org/10.1137/S0895479801398025),
in which similar operators were derived using a matrix analysis approach.


2: Licensing
------------

MOLE is distributed under a GNU General Public License; please refer to the _LICENSE_ 
file for more details.


3: Installation
------------

### 3.1 Packages Required

To install the MOLE library on your system, certain packages must be installed and configured beforehand. The required packages vary by operating system.

For the macOS, Homebrew needs to be installed to download the required packages. Invoke the following command in the terminal app
	
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

Remove Java dependencies

	brew uninstall --ignore-dependencies java

Update Homebrew again

	brew update

If you encounter errors during Homebrew installation, please run the following commands before the installation:


	sudo chown -R $(whoami) /usr/local/Cellar
	git -C /usr/local/Homebrew/Library/Taps/homebrew/homebrew-core fetch --unshallow

#### 3.1.1 CMake
**Minimum Version Required**: 3.10

##### For Ubuntu systems:
	sudo apt install cmake
##### For Mac Systems
	brew install cmake
##### For Yum-based systems:  
	sudo yum install cmake

#### 3.1.2 OpenBLAS
**Minimum Version Required**: OpenBLAS 0.3.10

##### For Ubuntu systems:
	sudo apt install libopenblas-dev 
##### For Mac Systems
	brew install openblas
##### For Yum-based systems:  
	sudo yum install openblas-devel

#### 3.1.3 Eigen3
**Minimum Version Required**: eigen-3

##### For Ubuntu systems
	sudo apt install libeigen3-dev
##### For Mac Systems
	brew install eigen  
##### For Yum-based systems:  
	sudo yum install eigen3-devel

#### 3.1.4 libomp

##### For Mac Systems
	brew install libomp


#### 3.1.5 LAPACK

##### For Mac Systems
	brew install lapack
 

### 3.2 MOLE Library Installation


**Clone the MOLE repository and build the library**

	git clone https://github.com/csrc-sdsu/mole.git  
	cd mole  
	mkdir build && cd build  
	cmake ..
	make  
 To install the library in a custom location (Eg. home/mole) 

 	cmake --install . --prefix /path/to/location
 
 To install the library in a previledged location (Eg. /opt/mole)

 	sudo cmake --install .
 Or

 	sudo cmake --install . --prefix /path/to/privileged/location	

To run the C++ tests manually,

	make run_tests

To run the matlab tests manually,

	make run_matlab_tests
 
 Armadillo and SuperLu will be locally installed in the build directory once the cmake .. command is passed.
 By following the steps outlined above, you will successfully install the necessary packages and the MOLE library on your system. 
 The library will be installed in the location provided.
 The tests and examples to be executed will also be built locally inside the build directory. 
	


4: Running Examples & Tests
---------------------------

Here are instructions on how to run the provided examples and tests for both the C++ and MATLAB versions of the library to help you quickly get started with MOLE.

* **tests/cpp:**
These tests, which are automatically executed upon constructing the library's C++ version, play a crucial role in verifying the correct installation of MOLE and its dependencies. There are four tests in total.

* **tests/matlab:**
We encourage MATLAB users to execute these tests before using MOLE by entering the `tests/matlab` directory and executing `run_tests.m` from MATLAB. These tests are analogous to those contained in `tests/cpp`.

* **examples/cpp:**
These will be automatically built after calling `make`. We encourage C++ users to make this their entry point to familiarize themselves with this library version. The four examples are self-contained and adequately documented, and they solve typical PDEs.

* **examples/matlab:**
Most of our examples are provided in the MATLAB scripting language. Over 30 examples range from linear one-dimensional PDEs to highly nonlinear multidimensional PDEs.


5: Documentation
----------------

For detailed documentation, including API references, tutorials, and examples, please refer to our [Documentation Guide](doc/sphinx/README.md).

**NOTE:**
Performing non-unary operations involving operands constructed over different grids may lead to unexpected results. While MOLE allows such operations without throwing errors, users must exercise caution when manipulating operators across different grids.


6: Community Guidelines
-----------------------

We welcome contributions to MOLE, whether they involve adding new functionalities, providing examples, addressing existing issues, reporting bugs, or requesting new features. Please refer to our [Contribution Guidelines](https://github.com/csrc-sdsu/mole/blob/master/CONTRIBUTING.md) for more details.


7: Citations
------------

Please cite our work if you use MOLE in your research or software. 
Citations are helpful for the continued development and maintenance of 
the library [![DOI](https://joss.theoj.org/papers/10.21105/joss.06288/status.svg)](https://doi.org/10.21105/joss.06288)

[![View mole on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/124870-mole)

Now, some cool pictures obtained with MOLE:

![Obtained with curvilinear operators](doc/assets/img/4thOrder.png)
![Obtained with curvilinear operators](doc/assets/img/4thOrder2.png)
![Obtained with curvilinear operators](doc/assets/img/4thOrder3.png)
![Obtained with curvilinear operators](doc/assets/img/grid2.png)
![Obtained with curvilinear operators](doc/assets/img/grid.png)
![Obtained with curvilinear operators](doc/assets/img/WavyGrid.png)
![Obtained with curvilinear operators](doc/assets/img/wave2D.png)
![Obtained with curvilinear operators](doc/assets/img/burgers.png)
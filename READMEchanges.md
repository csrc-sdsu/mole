# MOLE Library Installation Guide

## 3. Packages Required

To install the MOLE library on your system, certain packages must be installed and configured beforehand. The required packages vary by operating system.

For a MacOS, Homebrew needs to be installed to download the required packages. Homebrew can be downloaded from
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

### 3.1 General Packages  
- **cmake**
- **fortran**  
- **gcc** and **g++**

### 3.2 OpenBLAS
**Minimum Version Required**: OpenBLAS 0.3.10

	# For Ubuntu systems:
	sudo apt install libopenblas-dev 
	# For Mac Systems
	brew install openblas
	# For Yum-based systems:  
	sudo yum install openblas-devel

### 3.3 Eigen3
**Minimum Version Required**: eigen-3

	# For Ubuntu systems
	sudo apt install eigen3-dev
	# For Mac Systems
	brew install eigen  
	# For Yum-based systems:  
	sudo yum install eigen3-devel

### 3.4 libomp

	# For Mac Systems
	brew install libomp


### 3.5 LAPACK

	# For Mac Systems
	brew install lapack
 

## 4. MOLE Library Installation


**Clone the MOLE repository and build the library**

	git clone https://github.com/csrc-sdsu/mole.git  
	cd mole  
	mkdir build && cd build  
	cmake ..
	make  
	make install  # To install the library
 Armadillo and SuperLu will be locally installed in the build directory once the cmake .. command is passed.
 By following the steps outlined above, you will successfully install the necessary packages and the MOLE library on your system. 
	







	

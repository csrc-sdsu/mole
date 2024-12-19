# MOLE Library Installation Guide

## 3. Packages Required

To install the MOLE library on your system, certain packages must be installed and configured beforehand. The required packages vary by operating system.

### 3.1 General Packages  
- **cmake**  
- **gcc** and **g++**

### 3.2 Linux

#### 3.2.1 Armadillo C++  
**Minimum Version Required**: `armadillo-9.800.4`  

Install using the in-built library:  

	sudo apt install libarmadillo-dev

OR manually install:

	wget https://sourceforge.net/projects/arma/files/armadillo-12.6.6.tar.xz  
	tar xvf armadillo-12.6.6.tar.xz  
	cd armadillo-12.6.6  
	./configure  
	make

#### 3.2.2 SuperLU
**Minimum Version Required**: SuperLU 5.2.1

Install using the in-built library:

	sudo apt install libsuperlu-dev  
	# For Yum-based systems:  
	sudo yum install SuperLu-devel

 OR manually install:

 	wget https://github.com/xiaoyeli/superlu.git  
	cd superlu  
	mkdir build && cd build  
	cmake ..
	make  
	sudo make install  # To install the library  
	make test  # Optional: Run regression tests

#### 3.2.3 OpenBLAS
**Minimum Version Required**: OpenBLAS 0.3.10

Install using the in-built library:

	sudo apt install libopenblas-dev  
	# For Yum-based systems:  
	sudo yum install openblas-devel

#### 3.2.4 Eigen3
**Minimum Version Required**: eigen-3

Install using the in-built library:

	sudo apt install eigen3-dev  
	# For Yum-based systems:  
	sudo yum install eigen3-devel

### 3.3 MacOS

#### 3.3.1 Armadillo C++
**Minimum Version Required**: armadillo-9.800.4

Install using Homebrew:

	brew install armadillo

OR manually install:

	wget https://sourceforge.net/projects/arma/files/armadillo-12.6.6.tar.xz  
	tar xvf armadillo-12.6.6.tar.xz  
	cd armadillo-12.6.6  
	./configure  
	make
 
#### 3.3.2 SuperLU
**Minimum Version Required**: SuperLU 5.2.1

Install using Homebrew:

	brew install superlu

OR manually install:

	wget https://github.com/xiaoyeli/superlu.git  
	cd superlu  
	mkdir build && cd build  
	cmake ..
	make  
	sudo make install  # To install the library  
	make test  # Optional: Run regression tests

#### 3.3.3 libomp

**Install using Homebrew**:

	brew install libomp


#### 3.3.4 LAPACK

**Install using Homebrew**:

	brew install lapack

#### 3.3.5 Eigen

**Install using Homebrew**:

	brew install eigen
 

## 4. MOLE Library Installation


**Clone the MOLE repository and build the library**

	git clone https://github.com/csrc-sdsu/mole.git  
	cd mole/src/cpp  
	mkdir build && cd build  
	cmake ..
 	cmake --build .
	make  
	sudo make install  # To install the library

 By following the steps outlined above, you will successfully install the necessary packages and the MOLE library on your system. 
	







	

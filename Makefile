# Put here the path to Armadillo
#ARMA = /home/johnny/armadillo-10.2.1
#ARMA = /Users/aneeshsrinivas/Documents/GitHub/armadillo-14.0.3

# Put here the path to Eigen (optional)
# You won't need it unless you have to solve a linear system in which
# case we recommend to use SuperLU over Eigen for the sparse LU factorization
#EIGEN = /usr/include/eigen3

export

SUBDIRS = src/mole_C++ examples/examples_C++ tests/tests_C++

all clean: $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)

.PHONY: all $(SUBDIRS)
.NOTPARALLEL:

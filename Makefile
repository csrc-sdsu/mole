# Put here the path to Armadillo
ifndef ARMA
	ARMA = /home/johnny/armadillo-10.2.1
endif

# Put here the path to Eigen (optional)
# You won't need it unless you have to solve a linear system in which
# case we recommend to use SuperLU over Eigen for the sparse LU factorization
#EIGEN = /usr/include/eigen3

export

SUBDIRS = src/cpp examples/cpp tests/cpp

all clean: $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)

.PHONY: all $(SUBDIRS)
.NOTPARALLEL:

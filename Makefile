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

# documentation/ creation of Sphinx build ---------------------------

.PHONY: doxygen html clean latexpdf

doxygen:
	doxygen Doxyfile

html:
	sphinx-build -b html doc/sphinx/source doc/sphinx/build

clean:
	rm -rf doc/sphinx/build

latexpdf:
	sphinx-build -b latex doc/sphinx/source doc/sphinx/build/latex
	make -C doc/sphinx/build/latex
	mkdir -p doc/sphinx/build/pdf 
	mv doc/sphinx/build/latex/*.pdf doc/sphinx/build/pdf/
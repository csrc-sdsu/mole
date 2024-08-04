ifndef ARMA
# Put here the path to Armadillo
ARMA = /home/johnny/armadillo-10.2.1
endif

ifndef EIGEN
# Put here the path to Eigen (optional)
# You won't need it unless you have to solve a linear system in which
# case we recommend to use SuperLU over Eigen for the sparse LU factorization
#EIGEN = /usr/include/eigen3
endif

#----------------------------------------------------------------------
# Compiler for C++
CXX = g++

# Flags for C++ compiler
CXXFLAGS = -O3 -fopenmp

# Path to header files
INCPATH = -I. -I$(ARMA)/include

ifdef EIGEN
CXXFLAGS += -DEIGEN
INCPATH += -I$(EIGEN)
endif

# Rules:
ifndef SHARED_LIB
all: libmole.a
else
CXXFLAGS += -fPIC
all: libmole.so
endif

libmole.so: divergence.o gradient.o laplacian.o interpol.o mixedbc.o robinbc.o utils.o
	$(CXX) -shared -o libmole.so *.o

libmole.a: divergence.o gradient.o laplacian.o interpol.o mixedbc.o robinbc.o utils.o
	ar cqs libmole.a *.o

divergence.o: divergence.cpp divergence.h utils.h
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o divergence.o divergence.cpp

gradient.o: gradient.cpp gradient.h utils.h
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o gradient.o gradient.cpp

laplacian.o: laplacian.cpp laplacian.h divergence.h gradient.h utils.h
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o laplacian.o laplacian.cpp

interpol.o: interpol.cpp interpol.h utils.h
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o interpol.o interpol.cpp

mixedbc.o: mixedbc.cpp mixedbc.h utils.h
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o mixedbc.o mixedbc.cpp

robinbc.o: robinbc.cpp robinbc.h utils.h
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o robinbc.o robinbc.cpp

utils.o: utils.cpp utils.h
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o utils.o utils.cpp

clean:
	rm -f *.o libmole.a libmole.so

# Basic Makefile template

# Put here the path to Armadillo
ARMA = /home/johnny/armadillo-7.950.1

#----------------------------------------------------------------------

# Compiler for C++
CXX = g++

# Flags for C++ compiler
CXXFLAGS = -O3

# Path to header files
INCPATH = -I. -I$(ARMA)/include

# Rules:
all: libmole.a

libmole.a: divergence.o gradient.o laplacian.o interpol.o robinbc.o utils.o
	ar cqs libmole.a *.o

divergence.o: divergence.cpp divergence.h utils.h
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o divergence.o divergence.cpp

gradient.o: gradient.cpp gradient.h utils.h
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o gradient.o gradient.cpp

laplacian.o: laplacian.cpp laplacian.h divergence.h gradient.h utils.h
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o laplacian.o laplacian.cpp

interpol.o: interpol.cpp interpol.h utils.h
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o interpol.o interpol.cpp

robinbc.o: robinbc.cpp robinbc.h utils.h
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o robinbc.o robinbc.cpp

utils.o: utils.cpp utils.h
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o utils.o utils.cpp

clean:
	rm -f *.o libmole.a

# Basic Makefile template

# Put here the path to Armadillo and MOLE
ARMA = /home/johnny/armadillo-7.950.1
MOLE = /home/johnny/Desktop/mole/mole_C++

#----------------------------------------------------------------------

# Compiler for C++
CXX = g++

# Flags for C++ compiler
CXXFLAGS = -O3

# Path to header files
INCPATH = -I. -I$(ARMA)/include -I$(MOLE)

# Path to libmole.a
LIBS = -L$(MOLE) -lmole

# Rules:
all: transport1D

transport1D: transport1D.cpp
	$(CXX) $(CXXFLAGS) $(INCPATH) -o transport1D transport1D.cpp $(LIBS)

clean:
	rm -f transport1D

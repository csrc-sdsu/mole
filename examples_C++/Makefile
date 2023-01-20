ifndef ARMA
# Put here the path to Armadillo
ARMA = /home/johnny/armadillo-10.2.1
endif

ifndef EIGEN
# Put here the path to Eigen (optional)
# We recommend SuperLU over Eigen for the sparse LU factorization
#EIGEN = /usr/include/eigen3
endif

#----------------------------------------------------------------------
MOLE = ../mole_C++

# Compiler for C++
CXX = g++

# Flags for C++ compiler
CXXFLAGS = -O3 -fopenmp

# Path to header files
INCPATH = -I. -I$(ARMA)/include -I$(MOLE)

# Path to libmole.a
LIBS = -L$(MOLE) -L$(ARMA) -lmole -larmadillo -lopenblas

ifdef EIGEN
CXXFLAGS += -DEIGEN
INCPATH += -I$(EIGEN)
else
LIBS += -lsuperlu
endif

# Rules:
all: transport1D elliptic1D elliptic2D

transport1D: transport1D.cpp
	$(CXX) $(CXXFLAGS) $(INCPATH) -o transport1D transport1D.cpp $(LIBS)

elliptic1D: elliptic1D.cpp
	$(CXX) $(CXXFLAGS) $(INCPATH) -o elliptic1D elliptic1D.cpp $(LIBS)

elliptic2D: elliptic2D.cpp
	$(CXX) $(CXXFLAGS) $(INCPATH) -o elliptic2D elliptic2D.cpp $(LIBS)

clean:
	rm -f transport1D elliptic1D elliptic2D

MOLE = ../../src/mole_C++
CXX ?= g++
#ARMA = /Users/aneeshsrinivas/Documents/GitHub/armadillo-14.0.3
#CXX ?= clang++ #for mac os

ifeq ($(DEBUG),1)
CXXFLAGS = -O0 -g
else
CXXFLAGS = -O3
endif
CXXFLAGS += -fopenmp -DARMA_DONT_USE_WRAPPER
#CXXFLAGS +=  -DARMA_DONT_USE_WRAPPER #for mac os

INCPATH = -I. $(if $(ARMA), -I$(ARMA)/include) -I$(MOLE) 
#INCPATH = -I. $(if $(ARMA), -I$(ARMA)/include) -I$(MOLE) -I$(MOLE)/../../src/cpp/ for mac os

LIBS = -L$(MOLE) -lmole -lopenblas
#LIBS = -L$(MOLE) -lmole -lopenblas -L/opt/homebrew/opt/openblas/lib for mac os

ifdef ARMA
LIBS += -L$(ARMA) -Wl,-rpath,$(ARMA) -larmadillo
else
ifeq (,$(filter clean,$(MAKECMDGOALS)))
$(warning The path to Armadillo's library was not provided. I will look for it in the standard system directories.)
endif
endif

ifdef EIGEN
CXXFLAGS += -DEIGEN
INCPATH += -I$(EIGEN)
else
ifdef SUPERLU
LIBS += -L$(SUPERLU)/lib -Wl,-rpath,$(SUPERLU)/lib -lsuperlu
#LIBS += -L$(SUPERLU)/lib -Wl,-rpath,$(SUPERLU)/lib -lsuperlu -L/opt/homebrew/Cellar/superlu/7.0.0/lib #for mac os
else
LIBS += -lsuperlu
#LIBS += -lsuperlu -L/opt/homebrew/Cellar/superlu/7.0.0/lib #for mac os
endif
endif

all: transport1D schrodinger1D elliptic1D elliptic2D parabolic1D

transport1D: transport1D.cpp
	$(CXX) $(CXXFLAGS) $(INCPATH) -o transport1D transport1D.cpp $(LIBS)

schrodinger1D: schrodinger1D.cpp
	$(CXX) $(CXXFLAGS) $(INCPATH) -o schrodinger1D schrodinger1D.cpp $(LIBS)

elliptic1D: elliptic1D.cpp
	$(CXX) $(CXXFLAGS) $(INCPATH) -o elliptic1D elliptic1D.cpp $(LIBS)

elliptic2D: elliptic2D.cpp
	$(CXX) $(CXXFLAGS) $(INCPATH) -o elliptic2D elliptic2D.cpp $(LIBS)
	
parabolic1D: parabolic1D.cpp
	$(CXX) $(CXXFLAGS) $(INCPATH) -o parabolic1D parabolic1D.cpp $(LIBS)

clean:
	rm -f transport1D schrodinger1D parabolic1D elliptic1D elliptic2D

MOLE = ../../src/mole_C++
#ARMA = /Users/aneeshsrinivas/Documents/GitHub/armadillo-14.0.3
CXX ?= clang++

ifeq ($(DEBUG),1)
CXXFLAGS = -O0 -g
else
CXXFLAGS = -O3
endif
CXXFLAGS +=  -DARMA_DONT_USE_WRAPPER

INCPATH = -I. $(if $(ARMA), -I$(ARMA)/include) -I$(MOLE)

LIBS = -L$(MOLE) -lmole -lopenblas -L/opt/homebrew/opt/openblas/lib

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
LIBS += -L$(SUPERLU)/lib -Wl,-rpath,$(SUPERLU)/lib -lsuperlu -L/opt/homebrew/Cellar/superlu/7.0.0/lib
else
LIBS += -lsuperlu -L/opt/homebrew/Cellar/superlu/7.0.0/lib
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
	rm -f transport1D schrodinger1D elliptic1D elliptic2D

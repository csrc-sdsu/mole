MOLE = ../../src/cpp

ifndef ARMA
    ARMA = /home/johnny/armadillo-10.2.1
endif

CXX ?= g++ 

ifeq ($(DEBUG),1)
CXXFLAGS = -O0 -g
else
CXXFLAGS = -O3
endif
CXXFLAGS += -fopenmp -DARMA_DONT_USE_WRAPPER -std=c++17

INCPATH = -I. $(if $(ARMA), -I$(ARMA)/include) -I$(MOLE) 

LIBS = -L$(MOLE) -lmole -lopenblas -lboost_iostreams -lboost_system -lboost_filesystem

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
else
LIBS += -lsuperlu 
endif
endif

all: transport1D schrodinger1D elliptic1D elliptic2D parabolic1D convection_diffusion RK2 wave1d wave2d

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

convection_diffusion: convection_diffusion.cpp
	$(CXX) $(CXXFLAGS) $(INCPATH) -o convection_diffusion convection_diffusion.cpp $(LIBS)

RK2: RK2.cpp
	$(CXX) $(CXXFLAGS) $(INCPATH) -o RK2 RK2.cpp $(LIBS)

wave1d: wave1d.cpp
	$(CXX) $(CXXFLAGS) $(INCPATH) -o wave1d wave1d.cpp $(LIBS)

wave2d: wave2d.cpp
	$(CXX) $(CXXFLAGS) $(INCPATH) -o wave2d wave2d.cpp $(LIBS)

clean:
	rm -f transport1D schrodinger1D parabolic1D elliptic1D elliptic2D convection_diffusion RK2 wave1d wave2d

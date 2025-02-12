MOLE = ../../src/cpp
BOOST_ROOT = /opt/homebrew/Cellar/boost/1.87.0

CXX = g++
CXXFLAGS += \
    -DARMA_DONT_USE_WRAPPER \
    -std=c++20


# Include paths
INCPATH = -I. \
          -I/opt/homebrew/include \
          -I$(MOLE) \
          -I$(BOOST_ROOT)/include \
          -I/opt/homebrew/opt/openblas/include

# Library paths
LDFLAGS = -L$(MOLE) \
          -L/opt/homebrew/lib \
          -L$(BOOST_ROOT)/lib \
          -L/opt/homebrew/opt/openblas/lib

# Libraries
LIBS = -larmadillo \
       -lboost_iostreams \
       -lboost_system \
       -lboost_filesystem \
       -lopenblas \
       -lsuperlu

SOURCES = $(MOLE)/utils.cpp \
          $(MOLE)/gradient.cpp \
          $(MOLE)/divergence.cpp \
          $(MOLE)/laplacian.cpp \
          $(MOLE)/robinbc.cpp \
          $(MOLE)/interpol.cpp


# All targets
all: transport1D \
     schrodinger1D \
     elliptic1D \
     elliptic2D \
     parabolic1D \
     convection_diffusion \
     RK2 \
     wave1d \
     wave1d_case2 \
     wave2d \
     wave2d_case2

# Individual targets
transport1D: transport1D.cpp
	$(CXX) $(CXXFLAGS) $(INCPATH) $(LDFLAGS) -o $@ $< $(LIBS)

schrodinger1D: schrodinger1D.cpp
	$(CXX) $(CXXFLAGS) $(INCPATH) $(LDFLAGS) -o $@ $< $(LIBS)

elliptic1D: elliptic1D.cpp
	$(CXX) $(CXXFLAGS) $(INCPATH) $(LDFLAGS) -o $@ $< $(LIBS)

elliptic2D: elliptic2D.cpp
	$(CXX) $(CXXFLAGS) $(INCPATH) $(LDFLAGS) -o $@ $< $(LIBS)
	
parabolic1D: parabolic1D.cpp
	$(CXX) $(CXXFLAGS) $(INCPATH) $(LDFLAGS) -o $@ $< $(LIBS)

convection_diffusion: convection_diffusion.cpp
	$(CXX) $(CXXFLAGS) $(INCPATH) $(LDFLAGS) -o $@ $< $(LIBS)

RK2: RK2.cpp
	$(CXX) $(CXXFLAGS) $(INCPATH) $(LDFLAGS) -o $@ $< $(LIBS)

# Wave equation targets
wave1d: wave1d.cpp $(SOURCES)
	$(CXX) $(CXXFLAGS) $(INCPATH) $(LDFLAGS) -o $@ $^ $(LIBS)

wave1d_case2: wave1d_case2.cpp $(SOURCES)
	$(CXX) $(CXXFLAGS) $(INCPATH) $(LDFLAGS) -o $@ $^ $(LIBS)

wave2d: wave2d.cpp $(SOURCES)
	$(CXX) $(CXXFLAGS) $(INCPATH) $(LDFLAGS) -o $@ $^ $(LIBS)

wave2d_case2: wave2d_case2.cpp $(SOURCES)
	$(CXX) $(CXXFLAGS) $(INCPATH) $(LDFLAGS) -o $@ $^ $(LIBS)

clean:
	rm -f transport1D \
        schrodinger1D \
        parabolic1D \
        elliptic1D \
        elliptic2D \
        convection_diffusion \
        RK2 \
        wave1d \
        wave1d_case2 \
        wave2d \
        wave2d_case2

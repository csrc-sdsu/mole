ifndef ARMA
# Put here the path to Armadillo
ARMA = /home/johnny/armadillo-10.2.1
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

# Rules:
all: test1 test2 test3 test4 run

test1: test1.cpp
	$(CXX) $(CXXFLAGS) $(INCPATH) -o test1 test1.cpp $(LIBS)

test2: test2.cpp
	$(CXX) $(CXXFLAGS) $(INCPATH) -o test2 test2.cpp $(LIBS)

test3: test3.cpp
	$(CXX) $(CXXFLAGS) $(INCPATH) -o test3 test3.cpp $(LIBS)

test4: test4.cpp
	$(CXX) $(CXXFLAGS) $(INCPATH) -o test4 test4.cpp $(LIBS)

run: test1 test2 test3 test4
	LD_LIBRARY_PATH=../mole_C++ ./test1
	LD_LIBRARY_PATH=../mole_C++ ./test2
	LD_LIBRARY_PATH=../mole_C++ ./test3
	LD_LIBRARY_PATH=../mole_C++ ./test4

clean:
	rm -f test1 test2 test3 test4

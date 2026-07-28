# Makefile for the MOLE test suite (GoogleTest)
#
# Prerequisites:
#   - g++ with C++17 support
#   - libgtest-dev / libgtest_main (e.g. `apt install libgtest-dev`)
#   - libarmadillo-dev            (e.g. `apt install libarmadillo-dev`)
#
# Usage:
#   make            # builds ./test_all_mole
#   make run        # builds and runs all tests
#   make clean

CXX      := g++
CXXFLAGS := -std=c++17 -Wall -I ../src/include
LDFLAGS  := -lgtest -lgtest_main -lpthread 

SRC := ../src/grids/MOLE_grids.cpp \
       ../src/grids/flat2DArray.cpp \
       ../src/grids/flat3DArray.cpp \
       ../src/sys/MOLE_Errors.cpp

TESTS := test_MOLE_Errors.cpp \
         test_flat2DArray.cpp \
         test_flat3DArray.cpp \
         test_MOLE_grids.cpp

BIN := test_all_mole

.PHONY: all run clean

all: $(BIN)

$(BIN): $(TESTS) $(SRC)
	$(CXX) $(CXXFLAGS) $(TESTS) $(SRC) $(LDFLAGS) -o $(BIN)

run: $(BIN)
	./$(BIN)

clean:
	rm -f $(BIN)

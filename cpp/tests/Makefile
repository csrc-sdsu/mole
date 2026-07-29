CXX      ?= g++
CXXFLAGS ?= -std=c++17 -Wall -Wextra -g
INCLUDES  = -I../src/include

SRC = test_main.cpp \
      test_flat2DArray.cpp \
      test_flat3DArray.cpp \
      test_MOLE_Errors.cpp \
      test_MOLE_grids.cpp \
      ../src/grids/flat2DArray.cpp \
      ../src/grids/flat3DArray.cpp \
      ../src/grids/MOLE_grids.cpp \
      ../src/sys/MOLE_Errors.cpp

BIN = run_tests

.PHONY: all test clean

all: $(BIN)

$(BIN): $(SRC) mini_test.h
	$(CXX) $(CXXFLAGS) $(INCLUDES) $(SRC) -o $(BIN)

test: $(BIN)
	./$(BIN)

clean:
	rm -f $(BIN) MOLE_TEST_DUMP_*

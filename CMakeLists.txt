cmake_minimum_required(VERSION 3.10)
project(TopLevelProject VERSION 1.0 LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# Display the detected C++ compiler ID
message(STATUS "Detected CXX Compiler ID: ${CMAKE_CXX_COMPILER_ID}")

# Compiler-specific CXX_FLAGS and linker flags
if (CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang")
    # Set flags for AppleClang
    set(CMAKE_CXX_FLAGS "-O3 -Xclang -fopenmp -DARMA_DONT_USE_WRAPPER -DARMA_USE_SUPERLU")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -L/usr/local/Cellar/libomp/19.1.4/lib -lomp")
    message(STATUS "Using AppleClang-specific flags.")
    # Include Directories
    include_directories("/usr/local/Cellar/libomp/19.1.4/include")

else()
    # Set flags for other compilers
    set(CMAKE_CXX_FLAGS "-O3 -fopenmp -DARMA_DONT_USE_WRAPPER -DARMA_USE_SUPERLU")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS}")
    message(STATUS "Using non-Clang compiler flags.")
endif()



# Required Libraries
find_package(Armadillo 9.800.4 REQUIRED)
find_package(Eigen3 3.3.7 REQUIRED)
find_library(OpenBLAS_LIBRARIES NAMES openblas blas "/usr/lib/x86_64-linux-gnu" REQUIRED)
find_library(LAPACK_LIBRARY lapack REQUIRED PATHS "/usr/lib" "/usr/lib/x86_64-linux-gnu" "/usr/local/lib" "/usr/local/Cellar/")
find_path(SUPERLU_INCLUDE_DIR slu_ddefs.h PATHS "/usr/local/include" "/usr/include" "/usr/include/superlu" NO_DEFAULT_PATH)
find_library(SUPERLU_LIBRARY superlu PATHS "/usr/local/lib" "/usr/lib" "/usr/lib/x86_64-linux-gnu" NO_DEFAULT_PATH)
if(NOT SUPERLU_INCLUDE_DIR OR NOT SUPERLU_LIBRARY)
    message(FATAL_ERROR "SuperLU not found. Please make sure SuperLU is installed.")
else()
    message(STATUS "SuperLU found at ${SUPERLU_INCLUDE_DIR} and ${SUPERLU_LIBRARY}")
endif()

# Include and link directories for all subprojects
include_directories(${ARMADILLO_INCLUDE_DIRS} ${EIGEN3_INCLUDE_DIRS} ${SUPERLU_INCLUDE_DIR} ${LAPACK_INCLUDE_DIR})
if (CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang")
    set(LINK_LIBS ${ARMADILLO_LIBRARIES} ${OpenBLAS_LIBRARIES} ${SUPERLU_LIBRARY} ${LAPACK_LIBRARY} -lomp)
else()
    set(LINK_LIBS ${ARMADILLO_LIBRARIES} ${OpenBLAS_LIBRARIES} ${SUPERLU_LIBRARY} ${LAPACK_LIBRARY})
endif()

# Add subdirectories
add_subdirectory(src/cpp)
add_subdirectory(tests/cpp)
add_subdirectory(examples/cpp)

# Custom target to build everything
add_custom_target(all_build DEPENDS mole_C++ tests_C++ examples_C++)

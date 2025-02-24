cmake_minimum_required(VERSION 3.10)
project(TopLevelProject VERSION 1.0 LANGUAGES CXX)


set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# Display the detected C++ compiler ID
message(STATUS "Detected CXX Compiler ID: ${CMAKE_CXX_COMPILER_ID}")

# Compiler-specific CXX_FLAGS and linker flags
if (CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang")
    set(CMAKE_CXX_FLAGS "-O3 -Xclang -fopenmp -DARMA_DONT_USE_WRAPPER -DARMA_USE_SUPERLU")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -L/usr/local/opt/libomp/lib -lomp")
    message(STATUS "Using AppleClang-specific flags.")
    include_directories("/usr/local/opt/libomp/include")
else()
    set(CMAKE_CXX_FLAGS "-O3 -fopenmp -DARMA_DONT_USE_WRAPPER -DARMA_USE_SUPERLU")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS}")
    message(STATUS "Using non-Clang compiler flags.")
endif()


set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# Display the detected C++ compiler ID
message(STATUS "Detected CXX Compiler ID: ${CMAKE_CXX_COMPILER_ID}")

# Compiler-specific CXX_FLAGS and linker flags
if (CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang")
    set(CMAKE_CXX_FLAGS "-O3 -Xclang -fopenmp -DARMA_DONT_USE_WRAPPER -DARMA_USE_SUPERLU")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -L/usr/local/opt/libomp/lib -L/opt/homebrew/opt/libomp/lib -lomp")
    message(STATUS "Using AppleClang-specific flags.")
    include_directories("/usr/local/opt/libomp/include" "/opt/homebrew/opt/libomp/include")
else()
    set(CMAKE_CXX_FLAGS "-O3 -fopenmp -DARMA_DONT_USE_WRAPPER -DARMA_USE_SUPERLU")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS}")
    message(STATUS "Using non-Clang compiler flags.")
endif()

find_package(Eigen3 3.3.7 REQUIRED)
find_library(OpenBLAS_LIBRARIES NAMES openblas blas PATHS "/usr/lib/x86_64-linux-gnu" "/usr/local/opt/" "usr/local/lib" REQUIRED)
find_library(LAPACK_LIBRARY lapack REQUIRED PATHS "/usr/lib" "/usr/lib/x86_64-linux-gnu" "/usr/local/lib" "/usr/local/opt/")

if(POLICY CMP0135)
  cmake_policy(SET CMP0135 NEW)
endif()

# Paths for downloading and building libraries
set(ARMADILLO_VERSION "14.2.2")
set(SUPERLU_VERSION "5.3.0")
set(BUILD_DIR "${CMAKE_BINARY_DIR}/third_party_build")
set(INSTALL_DIR "${CMAKE_BINARY_DIR}/third_party_install")

# SuperLU configuration
set(SUPERLU_TARBALL_URL "https://github.com/xiaoyeli/superlu/archive/refs/tags/v${SUPERLU_VERSION}.tar.gz")
set(SUPERLU_SRC_DIR "${BUILD_DIR}/superlu-${SUPERLU_VERSION}")
set(SUPERLU_BUILD_DIR "${SUPERLU_SRC_DIR}/build")
set(SUPERLU_INSTALL_DIR "${INSTALL_DIR}/superlu-${SUPERLU_VERSION}")

file(DOWNLOAD ${SUPERLU_TARBALL_URL} ${BUILD_DIR}/superlu-${SUPERLU_VERSION}.tar.gz)
execute_process(COMMAND ${CMAKE_COMMAND} -E tar xzf superlu-${SUPERLU_VERSION}.tar.gz WORKING_DIRECTORY ${BUILD_DIR})
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${SUPERLU_BUILD_DIR})
execute_process(COMMAND ${CMAKE_COMMAND} ..
    -DCMAKE_INSTALL_PREFIX=${SUPERLU_INSTALL_DIR}
    -Denable_internal_blaslib=NO
    -DTPL_BLAS_LIBRARIES=${OpenBLAS_LIBRARIES}
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON
    -DCMAKE_C_FLAGS="-fPIC"
    -DCMAKE_CXX_FLAGS="-fPIC"
    WORKING_DIRECTORY ${SUPERLU_BUILD_DIR})
execute_process(COMMAND make -j4 WORKING_DIRECTORY ${SUPERLU_BUILD_DIR})
execute_process(COMMAND make install WORKING_DIRECTORY ${SUPERLU_BUILD_DIR})

# Armadillo configuration
set(ARMADILLO_TARBALL_URL "https://sourceforge.net/projects/arma/files/armadillo-${ARMADILLO_VERSION}.tar.xz")
set(ARMADILLO_BUILD_DIR "${BUILD_DIR}/armadillo-${ARMADILLO_VERSION}")
set(ARMADILLO_INSTALL_DIR "${INSTALL_DIR}/armadillo-${ARMADILLO_VERSION}")

file(DOWNLOAD ${ARMADILLO_TARBALL_URL} ${BUILD_DIR}/armadillo-${ARMADILLO_VERSION}.tar.xz)
execute_process(COMMAND ${CMAKE_COMMAND} -E tar xJf armadillo-${ARMADILLO_VERSION}.tar.xz WORKING_DIRECTORY ${BUILD_DIR})
execute_process(COMMAND ${CMAKE_COMMAND}
    -DSuperLU_INCLUDE_DIR=${SUPERLU_INSTALL_DIR}/include
    -DSuperLU_LIBRARY=${SUPERLU_INSTALL_DIR}/lib/libsuperlu.a
    -DCMAKE_INSTALL_PREFIX=${ARMADILLO_INSTALL_DIR} .
    WORKING_DIRECTORY ${ARMADILLO_BUILD_DIR})
execute_process(COMMAND make -j4 WORKING_DIRECTORY ${ARMADILLO_BUILD_DIR})
execute_process(COMMAND make install WORKING_DIRECTORY ${ARMADILLO_BUILD_DIR})

# Update paths for Armadillo and SuperLU
include_directories(${SUPERLU_INSTALL_DIR}/include ${ARMADILLO_INSTALL_DIR}/include)
link_directories(${SUPERLU_INSTALL_DIR}/lib ${ARMADILLO_INSTALL_DIR}/lib)

# Find required libraries
set(CMAKE_PREFIX_PATH ${ARMADILLO_INSTALL_DIR} ${CMAKE_PREFIX_PATH})
set(Armadillo_DIR ${ARMADILLO_INSTALL_DIR}/share/Armadillo)

find_package(Armadillo REQUIRED)
if(NOT Armadillo_FOUND)
    message(FATAL_ERROR "Custom Armadillo not found in ${ARMADILLO_INSTALL_DIR}")
else()
    message(STATUS "Using Armadillo from ${ARMADILLO_INSTALL_DIR}")
endif()


find_package(Eigen3 3.3.7 REQUIRED)
find_library(OpenBLAS_LIBRARIES NAMES openblas blas PATHS "/usr/lib/x86_64-linux-gnu" "/usr/local/opt/" REQUIRED)
find_library(LAPACK_LIBRARY lapack REQUIRED PATHS "/usr/lib" "/usr/lib/x86_64-linux-gnu" "/usr/local/lib" "/usr/local/opt/")


# Required libraries and link settings
set(LINK_LIBS ${ARMADILLO_LIBRARIES}
              ${OpenBLAS_LIBRARIES}
              ${SUPERLU_INSTALL_DIR}/lib/libsuperlu.a
              ${LAPACK_LIBRARY})

# Add subdirectories
add_subdirectory(src/cpp)
add_subdirectory(tests/cpp)
add_subdirectory(examples/cpp)

# Custom target to build everything
add_custom_target(all_build DEPENDS mole_C++ tests_C++ examples_C++)



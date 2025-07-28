cmake_minimum_required(VERSION 3.10)
project(TopLevelProject VERSION 1.0 LANGUAGES CXX)


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
elseif (CMAKE_CXX_COMPILER_ID STREQUAL "IntelLLVM")
    	set(CMAKE_CXX_FLAGS "-O3 -qopenmp -DARMA_DONT_USE_WRAPPER -DARMA_USE_SUPERLU -diag-disable=10430")
    	set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS}")
    	message(STATUS "Using non-Clang compiler flags.")
    	# Get MKLROOT from environment or fallback to default
    	if(DEFINED ENV{MKLROOT})
        	set(MKLROOT $ENV{MKLROOT})
    	else()
        	set(MKLROOT "/opt/intel/oneapi/mkl/latest")
    	endif()

    	# Automatically set Armadillo to link against MKL
    	set(BLAS_LIBRARIES "${MKLROOT}/lib/intel64/libmkl_rt.so" CACHE STRING "BLAS library path for MKL")
    	set(LAPACK_LIBRARIES "${MKLROOT}/lib/intel64/libmkl_rt.so" CACHE STRING "LAPACK library path for MKL")
    	set(ARMA_USE_WRAPPER OFF CACHE BOOL "Disable Armadillo wrapper to directly use MKL")

    	message(STATUS "Using MKL from: ${MKLROOT}")
else()
    set(CMAKE_CXX_FLAGS "-O3 -fopenmp -DARMA_DONT_USE_WRAPPER -DARMA_USE_SUPERLU")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS}")
    message(STATUS "Using non-Clang compiler flags.")
endif()

if(UNIX AND NOT APPLE AND NOT MSVC)
    message(STATUS "Checking for Fortran compiler (gfortran)...")
    enable_language(Fortran OPTIONAL)
    if(NOT CMAKE_Fortran_COMPILER)
        message(FATAL_ERROR "gfortran is required but was not found. Please install it using 'sudo apt install gfortran'.")
    endif()
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
# Detect platform and apply the correct sed command
if(APPLE)
    execute_process(
        COMMAND sed -i "" "s/cmake_minimum_required(VERSION 2.8.12)/cmake_minimum_required(VERSION 3.10)/" CMakeLists.txt
        WORKING_DIRECTORY ${SUPERLU_SRC_DIR}
    )
else()
    execute_process(
        COMMAND sed -i "s/cmake_minimum_required(VERSION 2.8.12)/cmake_minimum_required(VERSION 3.10)/" CMakeLists.txt
        WORKING_DIRECTORY ${SUPERLU_SRC_DIR}
    )
endif()

# Confirm the patch
execute_process(
    COMMAND grep "cmake_minimum_required" ${SUPERLU_SRC_DIR}/CMakeLists.txt
    OUTPUT_VARIABLE cmake_version_line
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
message(STATUS "SuperLU CMakeLists.txt after patch: ${cmake_version_line}")

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
add_subdirectory(tests/matlab_octave)
add_subdirectory(examples/cpp)

# Custom target to build everything
add_custom_target(all_build DEPENDS mole_C++ tests_C++ examples_C++ tests_matlab_octave)



cmake_minimum_required(VERSION 3.10)
project(TopLevelProject VERSION 1.0 LANGUAGES CXX)


set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# Global paths for third-party downloads/builds
set(BUILD_DIR "${CMAKE_BINARY_DIR}/third_party_build")
set(INSTALL_DIR "${CMAKE_BINARY_DIR}/third_party_install")

# Display the detected C++ compiler ID
message(STATUS "Detected CXX Compiler ID: ${CMAKE_CXX_COMPILER_ID}")

# Compiler-specific CXX_FLAGS and linker flags

# Compiler ID = AppleClang
if (CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang")
    set(CMAKE_CXX_FLAGS "-O3 -Xclang -fopenmp -DARMA_DONT_USE_WRAPPER -DARMA_USE_SUPERLU")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -L/usr/local/opt/libomp/lib -L/opt/homebrew/opt/libomp/lib -lomp")
    message(STATUS "Using AppleClang-specific flags.")
    include_directories("/usr/local/opt/libomp/include" "/opt/homebrew/opt/libomp/include")

# Compiler ID = IntelLLVM
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

    # Compiler ID = MSVC
elseif (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    message(STATUS "Detected MSVC Compiler")
    # Set MSVC flags
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /O2 /openmp /DARMADILLO_DONT_USE_WRAPPER /DARMADILLO_USE_SUPERLU ")
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreadedDLL" CACHE STRING "" FORCE)
    message(STATUS "Using MSVC compiler flags: ${CMAKE_CXX_FLAGS}")
    
# Compiler ID = Non-Clang
else()
    set(CMAKE_CXX_FLAGS "-O3 -fopenmp -DARMA_DONT_USE_WRAPPER -DARMA_USE_SUPERLU")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS}")
    message(STATUS "Using non-Clang compiler flags.")
endif()

# Find packages and libraries
if (NOT MSVC)
    find_package(Eigen3 3.3.7 REQUIRED)
    find_library(OpenBLAS_LIBRARIES NAMES openblas blas PATHS "/usr/lib/x86_64-linux-gnu" "/usr/local/opt/" "usr/local/lib" REQUIRED)
    find_library(LAPACK_LIBRARY lapack REQUIRED PATHS "/usr/lib" "/usr/lib/x86_64-linux-gnu" "/usr/local/lib" "/usr/local/opt/")
endif()

# ========== Eigen, OpenBLAS, LAPACK (MSVC only) ==========
if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    # ----------- Eigen ----------
    set(EIGEN_VERSION "3.3.7")
    set(EIGEN_TARBALL_URL "https://gitlab.com/libeigen/eigen/-/archive/${EIGEN_VERSION}/eigen-${EIGEN_VERSION}.tar.gz")
    set(EIGEN_SRC_DIR "${BUILD_DIR}/eigen-${EIGEN_VERSION}")
    message(STATUS "Downloading and extracting Eigen...")
    file(DOWNLOAD ${EIGEN_TARBALL_URL} ${BUILD_DIR}/eigen-${EIGEN_VERSION}.tar.gz SHOW_PROGRESS)
    execute_process(COMMAND ${CMAKE_COMMAND} -E tar xzf eigen-${EIGEN_VERSION}.tar.gz WORKING_DIRECTORY ${BUILD_DIR})
    set(CMAKE_INCLUDE_PATH ${CMAKE_INCLUDE_PATH} "${EIGEN_SRC_DIR}")
    set(CMAKE_PREFIX_PATH ${EIGEN_SRC_DIR} ${CMAKE_PREFIX_PATH})
    set(Eigen3_DIR "${EIGEN_SRC_DIR}/cmake" CACHE PATH "Path to Eigen3")

    # ----------- OpenBLAS ----------
    set(OPENBLAS_VERSION "0.3.29")
    set(OPENBLAS_TARBALL_URL "https://github.com/xianyi/OpenBLAS/archive/refs/tags/v${OPENBLAS_VERSION}.tar.gz")
    set(OPENBLAS_SRC_DIR "${BUILD_DIR}/OpenBLAS-${OPENBLAS_VERSION}")
    set(OPENBLAS_BUILD_DIR "${OPENBLAS_SRC_DIR}/build")
    set(OPENBLAS_INSTALL_DIR "${INSTALL_DIR}/OpenBLAS-${OPENBLAS_VERSION}")

    message(STATUS "Downloading and extracting OpenBLAS...")
    file(DOWNLOAD ${OPENBLAS_TARBALL_URL} ${BUILD_DIR}/OpenBLAS-${OPENBLAS_VERSION}.tar.gz SHOW_PROGRESS)
    execute_process(COMMAND ${CMAKE_COMMAND} -E tar xzf OpenBLAS-${OPENBLAS_VERSION}.tar.gz 
        WORKING_DIRECTORY ${BUILD_DIR}
        RESULT_VARIABLE extract_result
    )

    if(NOT extract_result EQUAL 0)
        message(FATAL_ERROR "Failed to extract OpenBLAS: ${extract_result}")
    endif()

    file(MAKE_DIRECTORY ${OPENBLAS_BUILD_DIR})
    file(MAKE_DIRECTORY ${OPENBLAS_INSTALL_DIR})

    message(STATUS "Building OpenBLAS...")
    execute_process(
        COMMAND ${CMAKE_COMMAND} ${OPENBLAS_SRC_DIR}
            -DCMAKE_INSTALL_PREFIX=${OPENBLAS_INSTALL_DIR}
            -DBUILD_SHARED_LIBS=OFF
            -DCMAKE_BUILD_TYPE=Release
            -DNO_FORTRAN=ON  # Disable Fortran for better compatibility
        WORKING_DIRECTORY ${OPENBLAS_BUILD_DIR}
        RESULT_VARIABLE config_result
    )

    if(NOT config_result EQUAL 0)
        message(FATAL_ERROR "OpenBLAS configuration failed: ${config_result}")
    endif()

    execute_process(
        COMMAND ${CMAKE_COMMAND} --build . --config Release
        WORKING_DIRECTORY ${OPENBLAS_BUILD_DIR}
        RESULT_VARIABLE build_result
    )

    if(NOT build_result EQUAL 0)
        message(FATAL_ERROR "OpenBLAS build failed: ${build_result}")
    endif()

    execute_process(
        COMMAND ${CMAKE_COMMAND} --install . --config Release
        WORKING_DIRECTORY ${OPENBLAS_BUILD_DIR}
        RESULT_VARIABLE install_result
    )

    if(NOT install_result EQUAL 0)
        message(FATAL_ERROR "OpenBLAS installation failed: ${install_result}")
    endif()

    # Verify the library was created
    set(OpenBLAS_LIB "${OPENBLAS_INSTALL_DIR}/lib/openblas.lib")
    if(NOT EXISTS "${OpenBLAS_LIB}")
        # Check for alternative library names
        file(GLOB possible_libs "${OPENBLAS_INSTALL_DIR}/lib/*blas*.lib")
        if(possible_libs)
            list(GET possible_libs 0 OpenBLAS_LIB)
            message(STATUS "Using alternative OpenBLAS library: ${OpenBLAS_LIB}")
        else()
            message(FATAL_ERROR "OpenBLAS library not found in: ${OPENBLAS_INSTALL_DIR}/lib/")
        endif()
    endif()

    # Set variables for other parts of the build
    set(OpenBLAS_LIBRARIES ${OpenBLAS_LIB} CACHE FILEPATH "OpenBLAS library" FORCE)
    set(OPENBLAS_DIR ${OPENBLAS_INSTALL_DIR} CACHE PATH "OpenBLAS installation directory" FORCE)
    set(OpenBLAS_INCLUDE_DIR "${OPENBLAS_INSTALL_DIR}/include" CACHE PATH "OpenBLAS include directory" FORCE)

    message(STATUS "OpenBLAS successfully installed to: ${OPENBLAS_INSTALL_DIR}")
    message(STATUS "OpenBLAS library: ${OpenBLAS_LIB}")
    message(STATUS "OpenBLAS includes: ${OpenBLAS_INCLUDE_DIR}")

    # Add to search paths
    include_directories(${OpenBLAS_INCLUDE_DIR})
    link_directories(${OPENBLAS_INSTALL_DIR}/lib)


endif()
# Required libraries and link settings
if(POLICY CMP0135)
  cmake_policy(SET CMP0135 NEW)
endif()

# Paths for downloading and building libraries
set(ARMADILLO_VERSION "14.2.2")
set(SUPERLU_VERSION "5.3.0")
set(BUILD_DIR "${CMAKE_BINARY_DIR}/third_party_build")
set(INSTALL_DIR "${CMAKE_BINARY_DIR}/third_party_install")

# SuperLU Download and Extraction
    set(SUPERLU_TARBALL_URL "https://github.com/xiaoyeli/superlu/archive/refs/tags/v${SUPERLU_VERSION}.tar.gz")
    set(SUPERLU_SRC_DIR "${BUILD_DIR}/superlu-${SUPERLU_VERSION}")
    set(SUPERLU_BUILD_DIR "${SUPERLU_SRC_DIR}/build")
    set(SUPERLU_INSTALL_DIR "${INSTALL_DIR}/superlu-${SUPERLU_VERSION}")
    file(DOWNLOAD ${SUPERLU_TARBALL_URL} ${BUILD_DIR}/superlu-${SUPERLU_VERSION}.tar.gz)
    execute_process(COMMAND ${CMAKE_COMMAND} -E tar xzf superlu-${SUPERLU_VERSION}.tar.gz WORKING_DIRECTORY ${BUILD_DIR})

# Patch Code 1 to install SuperLU without errors 
    # Disable fortran for MSVC and AppleClang compilers
    if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" OR CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang")
        message(STATUS "Patching SuperLU: Disabling Fortran ...")
        set(SUPERLU_CMAKELISTS "${SUPERLU_SRC_DIR}/CMakeLists.txt")
        # Comment out enable_language(Fortran) if MSVC/AppleClang is detected
        file(READ "${SUPERLU_CMAKELISTS}" SUPERLU_CMAKE_CONTENTS)
        string(REPLACE "enable_language (Fortran)" "# enable_language (Fortran)  # disabled for MSVC/AppleClang"
                   SUPERLU_CMAKE_CONTENTS "${SUPERLU_CMAKE_CONTENTS}")
        file(WRITE "${SUPERLU_CMAKELISTS}" "${SUPERLU_CMAKE_CONTENTS}")
    endif()
# Patch Code 1 to install SuperLU without errors    
# Set the CMakeLists version in SuperLU to match with MOLE
if(APPLE)
    execute_process(
        COMMAND sed -i "" "s/cmake_minimum_required(VERSION 2.8.12)/cmake_minimum_required(VERSION 3.10)/" CMakeLists.txt
        WORKING_DIRECTORY ${SUPERLU_SRC_DIR}
    )
elseif(WIN32)
    execute_process(
        COMMAND powershell -Command "(Get-Content ${SUPERLU_SRC_DIR}/CMakeLists.txt) -replace 'cmake_minimum_required\\(VERSION 2.8.12\\)', 'cmake_minimum_required(VERSION 3.10)' | Set-Content ${SUPERLU_SRC_DIR}/CMakeLists.txt"
    )
    execute_process(
        COMMAND powershell -Command "Select-String -Pattern 'cmake_minimum_required' -Path '${SUPERLU_SRC_DIR}/CMakeLists.txt'"
        OUTPUT_VARIABLE cmake_version_line
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    message(STATUS "SuperLU CMakeLists.txt after patch: ${cmake_version_line}")
else()
    execute_process(
        COMMAND sed -i "s/cmake_minimum_required(VERSION 2.8.12)/cmake_minimum_required(VERSION 3.10)/" CMakeLists.txt
        WORKING_DIRECTORY ${SUPERLU_SRC_DIR}
    )
endif()
execute_process(
    COMMAND grep "cmake_minimum_required" ${SUPERLU_SRC_DIR}/CMakeLists.txt
    OUTPUT_VARIABLE cmake_version_line
    OUTPUT_STRIP_TRAILING_WHITESPACE
    )
message(STATUS "SuperLU CMakeLists.txt after patch: ${cmake_version_line}")

#Setting up SUPERLU build dir

execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${SUPERLU_BUILD_DIR})

#Configuring SuperLU for MSVC
if(WIN32)
    message(STATUS "Configuring SuperLU build for Windows using MSVC...")
    execute_process(COMMAND ${CMAKE_COMMAND} ..
        -DCMAKE_INSTALL_PREFIX=${SUPERLU_INSTALL_DIR}
        -Denable_internal_blaslib=NO
        -DTPL_BLAS_LIBRARIES=${OpenBLAS_LIBRARIES}
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON
        -DCMAKE_C_FLAGS="/O2"
        -DCMAKE_CXX_FLAGS="/O2"
        -DCMAKE_Fortran_COMPILER:FILEPATH=FALSE
        WORKING_DIRECTORY ${SUPERLU_BUILD_DIR})

    execute_process(COMMAND ${CMAKE_COMMAND} --build . --config Release WORKING_DIRECTORY ${SUPERLU_BUILD_DIR})
    execute_process(COMMAND ${CMAKE_COMMAND} --install . --config Release WORKING_DIRECTORY ${SUPERLU_BUILD_DIR})

    message(STATUS "SuperLU build and installation complete on Windows.")
endif()

#Configuring SuperLU for Other Compilers
if(NOT WIN32)
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
endif()

# Armadillo installation

    set(ARMADILLO_TARBALL_URL "https://sourceforge.net/projects/arma/files/armadillo-${ARMADILLO_VERSION}.tar.xz")
    set(ARMADILLO_BUILD_DIR "${BUILD_DIR}/armadillo-${ARMADILLO_VERSION}")
    set(ARMADILLO_INSTALL_DIR "${INSTALL_DIR}/armadillo-${ARMADILLO_VERSION}")
    file(DOWNLOAD ${ARMADILLO_TARBALL_URL} ${BUILD_DIR}/armadillo-${ARMADILLO_VERSION}.tar.xz)
    execute_process(COMMAND ${CMAKE_COMMAND} -E tar xJf armadillo-${ARMADILLO_VERSION}.tar.xz WORKING_DIRECTORY ${BUILD_DIR})

    #Configuring Armadillo for MSVC
if(WIN32)

    message(STATUS "OpenBLAS_LIB = ${OpenBLAS_LIB}")
    message(STATUS "SUPERLU_INSTALL_DIR = ${SUPERLU_INSTALL_DIR}")
    message(STATUS "ARMADILLO_BUILD_DIR = ${ARMADILLO_BUILD_DIR}")

    # Print directory contents for debugging
    execute_process(COMMAND cmd /c dir "${OPENBLAS_INSTALL_DIR}/lib"
        WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
        OUTPUT_VARIABLE DIR_OUTPUT
    )
    message(STATUS "OpenBLAS lib contents:\n${DIR_OUTPUT}")
    message(STATUS "Configuring Armadillo build for Windows using MSVC...")
    
    # Verify OpenBLAS installation
    foreach(DEP IN ITEMS OpenBLAS_LIB SUPERLU_INSTALL_DIR)
        if(NOT EXISTS "${${DEP}}")
            message(FATAL_ERROR "Dependency not found: ${DEP} = ${${DEP}}")
        endif()
    endforeach()
    # Additional MSVC flags
    add_definitions(-D_USE_MATH_DEFINES -DNOMINMAX)
    
    execute_process(COMMAND ${CMAKE_COMMAND}
    -DCMAKE_INSTALL_PREFIX:PATH=${ARMADILLO_INSTALL_DIR}
    -DSuperLU_INCLUDE_DIR:PATH=${SUPERLU_INSTALL_DIR}/include
    -DSuperLU_LIBRARY:FILEPATH=${SUPERLU_INSTALL_DIR}/lib/superlu.lib
    -DOpenBLAS_FOUND:BOOL=TRUE
    -DOPENBLAS_PROVIDES_LAPACK:BOOL=ON
    -DBLAS_LIBRARIES:FILEPATH=${OpenBLAS_LIB}
    -DLAPACK_LIBRARIES:FILEPATH=${OpenBLAS_LIB}
    -DARMA_USE_BLAS:BOOL=ON
    -DARMA_USE_LAPACK:BOOL=ON
    -DARMA_USE_SUPERLU:BOOL=ON
    -DARMA_USE_WRAPPER:BOOL=OFF
    -DBUILD_SHARED_LIBS:BOOL=OFF
    .
    WORKING_DIRECTORY ${ARMADILLO_BUILD_DIR}
    )

    execute_process(COMMAND ${CMAKE_COMMAND} --build . --config Release WORKING_DIRECTORY ${ARMADILLO_BUILD_DIR})
    execute_process(COMMAND ${CMAKE_COMMAND} --install . --config Release WORKING_DIRECTORY ${ARMADILLO_BUILD_DIR})

    message(STATUS "Armadillo build and installation complete on Windows.")
endif()
#Configuring Armadillo for other compilers
if (NOT WIN32)
    execute_process(COMMAND ${CMAKE_COMMAND}
        -DSuperLU_INCLUDE_DIR=${SUPERLU_INSTALL_DIR}/include
        -DSuperLU_LIBRARY=${SUPERLU_INSTALL_DIR}/lib/libsuperlu.a
        -DCMAKE_INSTALL_PREFIX=${ARMADILLO_INSTALL_DIR} .
        WORKING_DIRECTORY ${ARMADILLO_BUILD_DIR})
    execute_process(COMMAND make -j4 WORKING_DIRECTORY ${ARMADILLO_BUILD_DIR})
    execute_process(COMMAND make install WORKING_DIRECTORY ${ARMADILLO_BUILD_DIR})
endif()


# Update paths for Armadillo and SuperLU
include_directories(${SUPERLU_INSTALL_DIR}/include ${ARMADILLO_INSTALL_DIR}/include)
link_directories(${SUPERLU_INSTALL_DIR}/lib ${ARMADILLO_INSTALL_DIR}/lib)

# Find required libraries
set(CMAKE_PREFIX_PATH ${ARMADILLO_INSTALL_DIR} ${CMAKE_PREFIX_PATH})
set(Armadillo_DIR ${ARMADILLO_INSTALL_DIR}/share/Armadillo)

if (NOT MSVC)
    find_package(Armadillo REQUIRED)
    message(STATUS "Using Armadillo from find_package: ${Armadillo_INCLUDE_DIRS}")
else()
    set(ARMADILLO_LIB "${ARMADILLO_INSTALL_DIR}/lib/armadillo.lib")
    if (EXISTS "${ARMADILLO_LIB}")
        include_directories(${ARMADILLO_INSTALL_DIR}/include)
        link_directories(${ARMADILLO_INSTALL_DIR}/lib)
        set(ARMADILLO_LIBRARIES ${ARMADILLO_LIB})
        message(STATUS "Using manually installed Armadillo for MSVC")
    else()
        message(FATAL_ERROR "Armadillo library not found at ${ARMADILLO_LIB}")
    endif()
endif()


if(WIN32)
    set(SUPERLU_LIB ${SUPERLU_INSTALL_DIR}/lib/superlu.lib)
    set(ARMADILLO_LIB ${ARMADILLO_INSTALL_DIR}/lib/armadillo.lib)
    set(OPENBLAS_LIB ${OPENBLAS_INSTALL_DIR}/lib/openblas.lib)
else()
    set(SUPERLU_LIB ${SUPERLU_INSTALL_DIR}/lib/libsuperlu.a)
    set(ARMADILLO_LIB ${ARMADILLO_INSTALL_DIR}/lib/libarmadillo.a)
    set(OPENBLAS_LIB ${OPENBLAS_INSTALL_DIR}/lib/libopenblas.a)
endif()

set(LINK_LIBS 
    ${ARMADILLO_LIB}
    ${SUPERLU_LIB}
    ${OPENBLAS_LIB}
    )

# Add subdirectories
add_subdirectory(src/cpp)
add_subdirectory(tests/cpp)
add_subdirectory(tests/matlab)
add_subdirectory(examples/cpp)

# Custom target to build everything
add_custom_target(all_build DEPENDS mole_C++ tests_C++ examples_C++ tests_matlab)



cmake_minimum_required(VERSION 3.10)
project(Wave2D)

# Set C++17 as required
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Define paths
get_filename_component(MOLE_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/../../.." ABSOLUTE)
set(MOLE_SRC "${MOLE_ROOT}/src/cpp")
set(EXAMPLES_CPP "${MOLE_ROOT}/examples/cpp")

# Set paths for external libraries
set(OPENBLAS_ROOT "/opt/homebrew/opt/openblas")
set(BOOST_ROOT "/opt/homebrew/Cellar/boost/1.87.0")
set(ARMADILLO_ROOT "/opt/homebrew/opt/armadillo")

# Add MOLE source files
set(MOLE_SOURCES
    ${MOLE_SRC}/laplacian.cpp
    ${MOLE_SRC}/robinbc.cpp
    ${MOLE_SRC}/interpol.cpp
    ${MOLE_SRC}/utils.cpp
    ${MOLE_SRC}/gradient.cpp
    ${MOLE_SRC}/divergence.cpp
)

# Optional visualization support
option(ENABLE_VISUALIZATION "Enable visualization support" OFF) #ON

# Find required packages
find_package(Armadillo REQUIRED)
if(ENABLE_VISUALIZATION)
    find_package(Boost COMPONENTS iostreams system filesystem REQUIRED)
    find_package(Gnuplot REQUIRED)
endif()

# Add source files
set(SOURCES
    src/Wave2DSolver.cpp
    src/Wave2DVisualizer.cpp
    src/main.cpp
    ${MOLE_SOURCES}
)

# Add executable
add_executable(wave2d ${SOURCES})

# Include directories
target_include_directories(wave2d PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${MOLE_ROOT}
    ${ARMADILLO_INCLUDE_DIRS}
    ${EXAMPLES_CPP}
    ${OPENBLAS_ROOT}/include
    ${BOOST_ROOT}/include
    ${MOLE_SRC}
    /opt/homebrew/include
)

# Link directories
link_directories(
    ${OPENBLAS_ROOT}/lib
    ${BOOST_ROOT}/lib
    ${ARMADILLO_ROOT}/lib
    /opt/homebrew/lib
)

# Link libraries with full paths
target_link_libraries(wave2d PRIVATE
    ${ARMADILLO_LIBRARIES}
    ${OPENBLAS_ROOT}/lib/libopenblas.dylib
    ${BOOST_ROOT}/lib/libboost_system.dylib
    ${BOOST_ROOT}/lib/libboost_filesystem.dylib
    ${BOOST_ROOT}/lib/libboost_iostreams.dylib
)

if(ENABLE_VISUALIZATION)
    target_compile_definitions(wave2d PRIVATE ENABLE_VISUALIZATION)
endif()

# Print paths for debugging
message(STATUS "OPENBLAS_ROOT: ${OPENBLAS_ROOT}")
message(STATUS "BOOST_ROOT: ${BOOST_ROOT}")
message(STATUS "ARMADILLO_ROOT: ${ARMADILLO_ROOT}")
message(STATUS "MOLE_ROOT: ${MOLE_ROOT}")
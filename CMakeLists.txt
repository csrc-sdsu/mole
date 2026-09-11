cmake_minimum_required(VERSION 3.14)

# =================================================================
# MOLE - Mimetic Operators Library Enhanced
# Root-level CMake entry point.
#
# The C++ library, its tests, and its examples are fully defined in
# cpp/CMakeLists.txt and its subdirectories.
# The GNU Octave test suite is not yet wired in, but will be added to
# octave/tests/CMakeLists.txt.
# =================================================================

project(MOLE
    VERSION 2.0.0
    DESCRIPTION "Mimetic Operators Library Enhanced (MOLE)"
    HOMEPAGE_URL "https://github.com/csrc-sdsu/mole"
    LANGUAGES CXX
)

# ---------------------------------------------------------------
# CTest
# Called once, here, so both the C++ tests (cpp/tests) and the
# future GNU Octave tests can be discovered and run together with
# a single `ctest` invocation from the build directory.
# ---------------------------------------------------------------
enable_testing()

# ---------------------------------------------------------------
# Build options
# ---------------------------------------------------------------
option(MOLE_BUILD_CPP "Configure and build the MOLE C++ library, tests, and examples" ON)
option(MOLE_BUILD_OCTAVE_TESTS "Configure the GNU Octave test suite via CTest" OFF)

# ---------------------------------------------------------------
# C++ component
# cpp/CMakeLists.txt it locates/builds third-party dependencies 
# (Armadillo, SuperLU, Eigen3), and adds src/, tests/, and 
# examples/grids/ only. 
# ---------------------------------------------------------------
if(MOLE_BUILD_CPP)
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/cpp/CMakeLists.txt")
        add_subdirectory(cpp)
    else()
        message(FATAL_ERROR "MOLE_BUILD_CPP is ON but cpp/CMakeLists.txt was not found.")
    endif()
endif()

# ---------------------------------------------------------------
# GNU Octave component (future)
# Not yet wired in. 
#
#   if(MOLE_BUILD_OCTAVE_TESTS)
#       add_subdirectory(octave/tests)
#   endif()
#
# Leave MOLE_BUILD_OCTAVE_TESTS OFF and this block absent/commented
# until that migration happens - octave/tests/old_version must stay
# excluded from the build in the meantime.
# ---------------------------------------------------------------

# ---------------------------------------------------------------
# Summary
# ---------------------------------------------------------------
message(STATUS "")
message(STATUS "MOLE ${PROJECT_VERSION} - root configuration summary:")
message(STATUS "  Build C++ component (cpp/): ${MOLE_BUILD_CPP}")
message(STATUS "  Build Octave tests (octave/tests): ${MOLE_BUILD_OCTAVE_TESTS} (not yet wired in - see comments above)")
message(STATUS "")

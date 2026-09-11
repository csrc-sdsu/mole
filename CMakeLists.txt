cmake_minimum_required(VERSION 3.14)

# =================================================================
# MOLE - Mimetic Operators Library Enhanced
# Root-level CMake entry point.
#
# This is the single project() declaration for the whole repository.
# cpp/CMakeLists.txt no longer declares its own project() - it is
# always add_subdirectory()'d from here and inherits PROJECT_VERSION,
# languages, etc. from this file. Configuring cpp/ directly as a
# standalone project is no longer supported; always run cmake from
# the repository root.
#
# The C++ library, its tests, and its examples are fully defined in
# cpp/CMakeLists.txt and its subdirectories.
#
# GNU Octave and Julia are not part of the CMake build graph:
#   - The Octave sources require no compilation.
#   - Julia uses its own package manager (see julia/MOLE.jl/Project.toml).
#
# Legacy "old_version" trees are intentionally excluded from the
# build. They are never referenced by add_subdirectory() anywhere
# in this project, so they are skipped simply by omission:
#   cpp/src/old_version
#   cpp/tests/old_version
#   cpp/examples/old_version
#   octave/tests/old_version
# These directories are kept only for reference during the 1.2 -> 2.0
# transition and should not be wired into any build target.
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
# future GNU Octave tests (once migrated out of
# octave/tests/old_version) can be discovered and run together with
# a single `ctest` invocation from the build directory. Note:
# cpp/tests/CMakeLists.txt calls add_test() but does not itself call
# enable_testing() - this root call is what makes those tests
# actually registered with CTest.
# ---------------------------------------------------------------
enable_testing()

# ---------------------------------------------------------------
# Build options
# ---------------------------------------------------------------
option(MOLE_BUILD_CPP "Configure and build the MOLE C++ library, tests, and examples" ON)
option(MOLE_BUILD_OCTAVE_TESTS "Configure the GNU Octave test suite via CTest" OFF)

# ---------------------------------------------------------------
# C++ component
# cpp/CMakeLists.txt no longer declares its own project() (see note
# above); it locates/builds third-party dependencies (Armadillo,
# SuperLU, Eigen3), and adds src/, tests/, and examples/grids/ only.
# old_version subdirectories under cpp/ are never added there either,
# so nothing further is needed here to keep them excluded.
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
# Not yet wired in. octave/tests/old_version/CMakeLists.txt currently
# holds the only Octave CTest integration, registering each test*.m
# file via `add_test(... COMMAND matlab -nojvm -batch ...)`. When the
# new-version Octave tests are ready to move out of old_version (e.g.
# into octave/tests/), point this at that new location:
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
message(STATUS "  Legacy old_version trees excluded (not added as subdirectories):")
message(STATUS "    cpp/src/old_version")
message(STATUS "    cpp/tests/old_version")
message(STATUS "    cpp/examples/old_version")
message(STATUS "    octave/tests/old_version")
message(STATUS "")

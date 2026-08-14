cmake_minimum_required(VERSION 3.14)

project(MOLE
    VERSION 2.0.0
    DESCRIPTION "Mimetic Operators Library Enhanced (MOLE) - C++ implementation"
    LANGUAGES CXX
)

# ---------------------------------------------------------------
# Project-wide settings
# ---------------------------------------------------------------
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Default to a Release build if the user didn't pick one, so that a
# plain `cmake .. && cmake --build .` doesn't silently produce an
# unoptimized debug build.
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE Release CACHE STRING
        "Build type (Debug, Release, RelWithDebInfo, MinSizeRel)" FORCE)
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
                 "Debug" "Release" "RelWithDebInfo" "MinSizeRel")
endif()

# Top-level options. These are only defined here (not in subdirectory
# CMakeLists.txt files) so someone configuring the project sees the
# full set of switches with `cmake -LH`.
option(MOLE_BUILD_EXAMPLES "Build the MOLE example programs" ON)
option(MOLE_BUILD_TESTS "Build the MOLE regression test suite" ON)
option(MOLE_ENABLE_WARNINGS "Build MOLE itself with -Wall -Wextra" ON)

# Export compile_commands.json (clangd / IDE integration), harmless
# if unused.
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# ---------------------------------------------------------------
# Dependencies
# ---------------------------------------------------------------
find_package(Armadillo REQUIRED)

# ---------------------------------------------------------------
# Subdirectories
# ---------------------------------------------------------------
add_subdirectory(src)

if(MOLE_BUILD_EXAMPLES)
    add_subdirectory(examples/grids)
endif()

if(MOLE_BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()

# ---------------------------------------------------------------
# Install / package config (so downstream projects can
# find_package(MOLE) and link against MOLE::mole)
# ---------------------------------------------------------------
include(CMakePackageConfigHelpers)

install(EXPORT MOLETargets
    FILE MOLETargets.cmake
    NAMESPACE MOLE::
    DESTINATION lib/cmake/MOLE
)

configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/MOLEConfig.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/MOLEConfig.cmake"
    INSTALL_DESTINATION lib/cmake/MOLE
)

write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/MOLEConfigVersion.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)

install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/MOLEConfig.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/MOLEConfigVersion.cmake"
    DESTINATION lib/cmake/MOLE
)

# ---------------------------------------------------------------
# Summary printed at configure time
# ---------------------------------------------------------------
message(STATUS "")
message(STATUS "MOLE ${PROJECT_VERSION} configuration summary:")
message(STATUS "  Build type:        ${CMAKE_BUILD_TYPE}")
message(STATUS "  Armadillo version: ${ARMADILLO_VERSION_STRING}")
message(STATUS "  Build examples:    ${MOLE_BUILD_EXAMPLES}")
message(STATUS "  Build tests:       ${MOLE_BUILD_TESTS}")
message(STATUS "")

cmake_minimum_required(VERSION 3.14)
project(MOLE
    VERSION 1.0.0
    LANGUAGES CXX
)

# ---------------------------------------------------------------
# Language / build settings
# ---------------------------------------------------------------
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Default to a Release build if the user didn't ask for anything
# specific (keeps single-config generators like Makefiles/Ninja from
# silently building unoptimized, unlabeled binaries).
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
                 "Debug" "Release" "RelWithDebInfo" "MinSizeRel")
endif()

# Let the caller choose static (default) vs shared via the usual
# CMake switch: cmake -DBUILD_SHARED_LIBS=ON ..
option(BUILD_SHARED_LIBS "Build MOLE as a shared library" OFF)

# ---------------------------------------------------------------
# Sources - explicit list (deliberately NOT a GLOB).
#
# Globbing src/grids and src/sys would silently pull in any .cpp
# file that ends up in those directories - including one dropped in
# by mistake, a bad merge, or intentionally by someone with write
# access to the tree who wants their code quietly linked into every
# consumer of this library. Listing files explicitly means only
# these exact, reviewed sources are ever compiled into `mole`;
# anything else placed in src/grids or src/sys is simply ignored
# unless a person deliberately adds it to this list below.
#
# When you add a new source file to the library, add its path here.
# --------------------------------------------------------------

set(MOLE_SOURCES
    src/grids/flat2DArray.cpp
    src/grids/flat3DArray.cpp
    src/grids/grid_builder.cpp
    src/grids/MOLE_grids.cpp
    src/sys/MOLE_Errors.cpp
)

foreach(_mole_src IN LISTS MOLE_SOURCES)
    if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${_mole_src}")
        message(FATAL_ERROR
            "MOLE source file listed in CMakeLists.txt is missing: "
            "${_mole_src}")
    endif()
endforeach()

# ---------------------------------------------------------------
# Library target
# ---------------------------------------------------------------
add_library(mole ${MOLE_SOURCES})
add_library(MOLE::mole ALIAS mole) # so add_subdirectory() consumers
                                     # can always link against
                                     # MOLE::mole, static or shared

target_include_directories(mole
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/include>
        $<INSTALL_INTERFACE:include>
)

target_compile_options(mole PRIVATE
    -Wall -Wextra
)

set_target_properties(mole PROPERTIES
    OUTPUT_NAME mole
    VERSION ${PROJECT_VERSION}
    SOVERSION ${PROJECT_VERSION_MAJOR}
    POSITION_INDEPENDENT_CODE ON
)

# ---------------------------------------------------------------
# Install rules (so `cmake --install .` gives consumers a normal
# find_package(MOLE)-able library + headers, in addition to being
# usable directly via add_subdirectory()).
# ---------------------------------------------------------------
include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

install(TARGETS mole
    EXPORT MOLETargets
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/src/include/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    FILES_MATCHING PATTERN "*.h"
)

install(EXPORT MOLETargets
    FILE MOLETargets.cmake
    NAMESPACE MOLE::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/MOLE
)

configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/MOLEConfig.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/MOLEConfig.cmake"
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/MOLE
)
write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/MOLEConfigVersion.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)
install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/MOLEConfig.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/MOLEConfigVersion.cmake"
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/MOLE
)

# ---------------------------------------------------------------
# Tests (tests/) - off by default so consumers who just want the
# library (via add_subdirectory or find_package) don't also pull in
# the test binary and its dependencies. Turn on with:
#   cmake -DMOLE_BUILD_TESTS=ON ..
# Only meaningful when MOLE is the top-level project - if someone
# add_subdirectory()'s MOLE into their own project, PROJECT_IS_TOP_LEVEL
# is OFF, so the tests stay out of their build even if the cache
# variable happens to be set.
# ---------------------------------------------------------------
# Portable "is this the top-level project?" check (PROJECT_IS_TOP_LEVEL
# is only available from CMake 3.21 onward; this works back to 3.14).
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
    set(MOLE_IS_TOP_LEVEL ON)
else()
    set(MOLE_IS_TOP_LEVEL OFF)
endif()

option(MOLE_BUILD_TESTS "Build the MOLE regression test suite" ${MOLE_IS_TOP_LEVEL})

if(MOLE_BUILD_TESTS AND MOLE_IS_TOP_LEVEL)
    enable_testing()
    add_subdirectory(tests)
endif()

# ---------------------------------------------------------------
# Examples (examples/) - same "only when top-level" gating as tests,
# so pulling MOLE in via add_subdirectory() into another project
# never drags in MOLE's own example binaries.
#   cmake -DMOLE_BUILD_EXAMPLES=OFF ..   to skip them
# ---------------------------------------------------------------
option(MOLE_BUILD_EXAMPLES "Build the MOLE example programs" ${MOLE_IS_TOP_LEVEL})

if(MOLE_BUILD_EXAMPLES AND MOLE_IS_TOP_LEVEL)
#    add_subdirectory(examples/boundaries)
    add_subdirectory(examples/grids)
#    add_subdirectory(examples/operators)
    add_subdirectory(examples/sys)
#    add_subdirectory(examples/utils)
endif()

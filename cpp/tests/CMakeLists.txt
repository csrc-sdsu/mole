cmake_minimum_required(VERSION 3.14)

# ---------------------------------------------------------------
# MOLE regression test suite.
#
# Each entry below becomes its own executable AND its own CTest
# test, so `ctest` reports pass/fail per source file (and a failure
# in one doesn't stop the others from running). All test binaries
# link against the same MOLE::mole target the examples use, so tests
# are exercising the exact same build the examples/users see.
# ---------------------------------------------------------------
set(MOLE_TEST_SOURCES
    arrays/test_arrays.cpp
    errors/test_errors.cpp
    utils/test_utils.cpp
    grids/test_grid1D.cpp
    grids/test_grid2D.cpp
    grids/test_grid3D.cpp
    grids/test_makeGrid.cpp
)

add_custom_target(mole_tests)

foreach(_mole_test_src IN LISTS MOLE_TEST_SOURCES)
    if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${_mole_test_src}")
        message(FATAL_ERROR
            "MOLE test source listed in tests/CMakeLists.txt is "
            "missing: ${_mole_test_src}")
    endif()

    get_filename_component(_mole_test_name ${_mole_test_src} NAME_WE)
    set(_mole_test_bin "mole_${_mole_test_name}")

    add_executable(${_mole_test_bin} ${_mole_test_src})
    target_link_libraries(${_mole_test_bin} PRIVATE MOLE::mole)
    target_include_directories(${_mole_test_bin} PRIVATE support)
    target_compile_options(${_mole_test_bin} PRIVATE -Wall -Wextra)

    add_test(NAME ${_mole_test_name} COMMAND ${_mole_test_bin})

    add_dependencies(mole_tests ${_mole_test_bin})
endforeach()

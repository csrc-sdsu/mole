cmake_minimum_required(VERSION 3.14)

# ---------------------------------------------------------------
# The files in the CMakeLists.txt file are all examples of the
# the use of the MOLE Library
# ---------------------------------------------------------------
set(MOLE_EXAMPLE_SOURCES
    grid1D_basic.cpp        # basic 1D grid generation
    grid2D_basic.cpp        # basic 2D grid generation
    err_grid2D_basic.cpp        # basic 2D grid generation
)

# Builds all the examples listed in MOLE_EXAMPLE_SOURCES
add_custom_target(mole_examples)

foreach(_mole_example_src IN LISTS MOLE_EXAMPLE_SOURCES)
    if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${_mole_example_src}")
        message(FATAL_ERROR
            "MOLE example source listed in examples/CMakeLists.txt "
            "is missing: ${_mole_example_src}")
    endif()

    get_filename_component(_mole_example_name
                            ${_mole_example_src} NAME_WE)

    add_executable(${_mole_example_name} ${_mole_example_src})
    target_link_libraries(${_mole_example_name} PRIVATE MOLE::mole)
    target_compile_options(${_mole_example_name} PRIVATE -Wall -Wextra)

    # Group all example binaries under a single "examples" target so
    # `cmake --build . --target examples` builds just these, without
    # also building the (potentially much larger) test suite.
    add_dependencies(mole_examples ${_mole_example_name})
endforeach()

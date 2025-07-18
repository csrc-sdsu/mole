# Find all MATLAB/Octave test files (test*.m)
file(GLOB TEST_SOURCES test*.m)

# Enable testing
enable_testing()

# Loop through all MATLAB/Octave test files and register them as tests
foreach(TEST_SOURCE ${TEST_SOURCES})
    get_filename_component(TEST_NAME ${TEST_SOURCE} NAME_WE)

    add_test(NAME ${TEST_NAME}
        COMMAND matlab -batch "addpath('${CMAKE_CURRENT_SOURCE_DIR}'); runtests('${TEST_NAME}')"
    )
endforeach()

# Custom target to run all MATLAB/Octave tests using CTest
add_custom_target(run_matlab_octave_tests
    COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure
    COMMENT "Running all MATLAB/Octave unit tests..."
)


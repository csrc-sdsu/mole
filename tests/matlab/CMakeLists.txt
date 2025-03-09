add_custom_target(tests_matlab
    COMMAND matlab -batch "runtests testDivergence"
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Running MATLAB unit tests..."
)


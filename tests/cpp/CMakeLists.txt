# tests_C++ Configuration
include_directories("${CMAKE_SOURCE_DIR}/src/cpp")

# Find all test*.cpp files
file(GLOB TEST_SOURCES test*.cpp)

set(TEST_EXECUTABLES "")

foreach(TEST_SOURCE ${TEST_SOURCES})
    get_filename_component(TEST_NAME ${TEST_SOURCE} NAME_WE)
    add_executable(${TEST_NAME} ${TEST_SOURCE})
    target_link_libraries(${TEST_NAME} PUBLIC mole_C++ ${LINK_LIBS})
    list(APPEND TEST_EXECUTABLES ${TEST_NAME})
endforeach()

# Custom target to run all tests
add_custom_target(run_tests
    COMMAND ${CMAKE_COMMAND} -E env LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}/src/cpp
    ${CMAKE_COMMAND} -P - <<EOF
    file(GLOB TEST_EXECUTABLES "${CMAKE_BINARY_DIR}/src/cpp/test*")
    foreach(TEST_EXECUTABLE ${TEST_EXECUTABLES})
        execute_process(COMMAND ${TEST_EXECUTABLE} RESULT_VARIABLE result)
        if(result)
            message(FATAL_ERROR "Test failed: ${TEST_EXECUTABLE}")
        endif()
    endforeach()
EOF
    DEPENDS ${TEST_EXECUTABLES}
)

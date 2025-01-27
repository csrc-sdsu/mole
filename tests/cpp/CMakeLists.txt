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

# Enable testing
enable_testing()

# Add each test executable to the test suite
foreach(TEST_EXECUTABLE ${TEST_EXECUTABLES})
    add_test(NAME ${TEST_EXECUTABLE} COMMAND ${TEST_EXECUTABLE})
endforeach()

# Custom target to run all tests
add_custom_target(run_tests
    COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure
    DEPENDS ${TEST_EXECUTABLES}
)


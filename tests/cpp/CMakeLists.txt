# Include directories for the source code
include_directories("${CMAKE_SOURCE_DIR}/src/cpp")

# FetchContent module to download and configure Google Test
include(FetchContent)

# Download and install Google Test
FetchContent_Declare(
  googletest
  URL https://github.com/google/googletest/archive/refs/heads/main.zip
)

# Set up the fetched content
FetchContent_MakeAvailable(googletest)

# Find all test*.cpp files
file(GLOB TEST_SOURCES test*.cpp)

set(TEST_EXECUTABLES "")

# Create test executables and link with Google Test
foreach(TEST_SOURCE ${TEST_SOURCES})
    get_filename_component(TEST_NAME ${TEST_SOURCE} NAME_WE)
    add_executable(${TEST_NAME} ${TEST_SOURCE})
    target_link_libraries(${TEST_NAME} PUBLIC mole_C++ gtest gtest_main ${LINK_LIBS})
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


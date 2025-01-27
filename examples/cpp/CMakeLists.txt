# examples_C++ Configuration
include_directories("${CMAKE_SOURCE_DIR}/src/cpp")

# Find all .cpp files in the examples directory
file(GLOB EXAMPLE_SOURCES *.cpp)

# Create executables for each source file
foreach(EXAMPLE_SOURCE ${EXAMPLE_SOURCES})
    get_filename_component(EXAMPLE_NAME ${EXAMPLE_SOURCE} NAME_WE)
    add_executable(${EXAMPLE_NAME} ${EXAMPLE_SOURCE})
    target_link_libraries(${EXAMPLE_NAME} PUBLIC mole_C++ ${LINK_LIBS})
endforeach()

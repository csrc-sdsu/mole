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

# Find required packages
find_package(Boost REQUIRED COMPONENTS iostreams system filesystem)
find_package(Gnuplot REQUIRED)

# Download gnuplot-iostream header if not exists
if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/examples/cpp/gnuplot-iostream.h")
    file(DOWNLOAD
        "https://raw.githubusercontent.com/dstahlke/gnuplot-iostream/master/gnuplot-iostream.h"
        "${CMAKE_CURRENT_SOURCE_DIR}/examples/cpp/gnuplot-iostream.h"
        SHOW_PROGRESS
    )
endif()

# Add wave equation examples
add_executable(wave1d_case2 examples/cpp/wave1d_case2.cpp)
target_link_libraries(wave1d_case2 PRIVATE
    Boost::iostreams
    Boost::system
    Boost::filesystem
)

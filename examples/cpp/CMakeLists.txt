# examples_C++ Configuration
include_directories("${CMAKE_SOURCE_DIR}/src/cpp")

# Executable definitions
add_executable(transport1D transport1D.cpp)
add_executable(schrodinger1D schrodinger1D.cpp)
add_executable(elliptic1D elliptic1D.cpp)
add_executable(elliptic2D elliptic2D.cpp)

# Link libraries
foreach(EXE transport1D schrodinger1D elliptic1D elliptic2D)
    target_link_libraries(${EXE} PUBLIC mole_C++ ${LINK_LIBS})
endforeach()

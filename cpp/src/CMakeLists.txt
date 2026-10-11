cmake_minimum_required(VERSION 3.14)

# ---------------------------------------------------------------
# The MOLE library itself: grids, arrays, error handling, utils.
# --------------------------------------------------------------
add_library(mole
    grids/MOLE_arrays.cpp
    grids/MOLE_grids.cpp
    grids/grid_builder.cpp
    operators/MOLE_operators.cpp
    operators/gradient.cpp
    sys/MOLE_errors.cpp
    utils/utils.cpp
)
add_library(MOLE::mole ALIAS mole)

target_include_directories(mole
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
)

# target_link_libraries(mole PUBLIC ${ARMADILLO_LIBRARIES})
# target_include_directories(mole PUBLIC ${ARMADILLO_INCLUDE_DIRS})

# Armadillo is used with ARMA_DONT_USE_WRAPPER, so code that multiplies
# matrices (the operators) calls BLAS/LAPACK directly. PUBLIC passes
# them on to everything that links MOLE::mole.
target_link_libraries(mole PUBLIC ${OpenBLAS_LIBRARIES} ${LAPACK_LIBRARY})

if(MOLE_ENABLE_WARNINGS)
    target_compile_options(mole PRIVATE -Wall -Wextra)
endif()

set_target_properties(mole PROPERTIES
    VERSION ${PROJECT_VERSION}
    SOVERSION ${PROJECT_VERSION_MAJOR}
)

install(TARGETS mole
    EXPORT MOLETargets
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)

install(DIRECTORY include/ DESTINATION include
    FILES_MATCHING PATTERN "*.h"
)

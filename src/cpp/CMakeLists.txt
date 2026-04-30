# mole_C++ Library Configuration

add_library(mole_C++
  addscalarbc.cpp
  divergence.cpp
  gradient.cpp
  interpol.cpp
  laplacian.cpp
  mixedbc.cpp
  robinbc.cpp
  utils.cpp
  interpolCtoF.cpp
  interpolCtoN.cpp
  interpolFtoC.cpp
  interpolNtoC.cpp
)
target_include_directories(mole_C++ PUBLIC ${ARMADILLO_INCLUDE_DIRS} ${EIGEN3_INCLUDE_DIRS} ${OpenBLAS_INCLUDE_DIRS} ${SUPERLU_INCLUDE_DIR})
target_link_libraries(mole_C++ PUBLIC ${LINK_LIBS})

# Installation for mole library
install(TARGETS mole_C++ DESTINATION lib)



# ${CMAKE_INSTALL_PREFIX}/lib for custom installation path. 
# ${CMAKE_BINARY_DIR}/install for cmake build directory installation
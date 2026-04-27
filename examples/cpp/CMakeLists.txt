# examples_C++ Configuration
include_directories("${CMAKE_SOURCE_DIR}/src/cpp")

set(EXAMPLE_SOURCES
  backward_euler.cpp
  burgers1D.cpp
  convection_diffusion3D.cpp
  cylinder_flow_2D.cpp
  elliptic1D.cpp
  elliptic1DHomogeneousDirichlet.cpp
  elliptic1DLeftNeumannRightDirichlet.cpp
  elliptic1DLeftNeumannRightNeumann.cpp
  elliptic1DNonHomogeneousDirichlet.cpp
  elliptic2D.cpp
  elliptic2D_x_dirichlet_y_dirichlet.cpp
  elliptic3D.cpp
  hyperbolic1D_upwind.cpp
  lock_exchange.cpp
  maxwell1D.cpp
  parabolic1D.cpp
  poisson2D.cpp
  poisson_2D_dirichlet.cpp
  RK2.cpp
  schrodinger1D.cpp
  schrodinger2D.cpp
  sturmLiouvilleBessel.cpp
  sturmLiouvilleChebyshev.cpp
  sturmLiouvilleHelmholtzDirichletDirichlet.cpp
  sturmLiouvilleHelmholtzDirichletRobin.cpp
  sturmLiouvilleHermite.cpp
  sturmLiouvilleLaguerre.cpp
  sturmLiouvilleLegendre.cpp
  transport1D.cpp
  wave1d_case2.cpp
  wave1d.cpp
  wave2d_case2.cpp
  wave2d.cpp
)

# Create executables for each source file
foreach(EXAMPLE_SOURCE ${EXAMPLE_SOURCES})
    get_filename_component(EXAMPLE_NAME ${EXAMPLE_SOURCE} NAME_WE)
    add_executable(${EXAMPLE_NAME} ${EXAMPLE_SOURCE})
    target_link_libraries(${EXAMPLE_NAME} PUBLIC mole_C++ ${LINK_LIBS})
endforeach()
module mole_m 
  !! This module contains all public MOLE Fortran entities. For descriptions of the public procedures bound to the derived types
  !! below, see the interface bodies in the corresponding module (e.g., tensors_1D_m).  Please see the programs in the `example`
  !! subdirectory for demonstrations of how to use the entities in this module.

  use tensors_1D_m, only : &
     scalar_1D_t     & ! discrete 1D scalar field abstraction
    ,vector_1D_t     & ! discrete 1D vector field abstraction
    ,gradient_1D_t   & ! result of an expression such as `.grad. s` for a scalar_2D_t s
    ,divergence_1D_t & ! result of an expression such as `.div. v` for a vector_1D_t v
    ,laplacian_1D_t  & ! result of an expression such as `.laplacian. s` for a scalar_1D_t s
    ,scalar_1D_initializer_i  & ! abstract interface for a scalar_1D_t initialization function
    ,vector_1D_initializer_i    ! abstract interface for a vector_1D_t initialization function

  implicit none

end module mole_m

module mole_m 
  !! All public MOLE Fortran entities:

  use tensors_1D_m, only : &
     scalar_1D_t      & ! discrete 1D scalar abstraction supporting mimetic gradient (.grad.) and Laplacian (.laplacian.) operators
    ,vector_1D_t      & ! discrete 1D vector abstraction supporting a mimetic divergence (.div.). operator
    ,divergence_1D_t  & ! result of applying the unary .div. operator to a vector_1D_t operand
    ,laplacian_1D_t   & ! result of applying the unary .laplacian. operator to a scalar_1D_t operand
    ,scalar_1D_initializer_i & ! abstract interface for a scalar_1D_t initialization function
    ,vector_1D_initializer_i   ! abstract interface for a vector_1D_t initialization function

  implicit none

end module mole_m

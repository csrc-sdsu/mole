#include "julienne-assert-macros.h"

submodule(tensors_1D_m) gradient_1D_s
  use julienne_m, only : &
     call_julienne_assert_ &
    ,operator(.approximates.) &
    ,operator(.equalsExpected.) &
    ,operator(.isAtLeast.) &
    ,operator(.within.)
  implicit none

  double precision, parameter :: double_equivalence = 1D-15

contains

  module procedure gradient_1D_weights

    integer face
    double precision, allocatable :: skin(:)

    select case(self%order_)
    case(2)
      skin = [3/8D0, 9/8D0]
    case(4)
      skin = [227/641D0, 941/766D0, 811/903D0, 1373/1348D0, 1401/1400D0, 36343/36342D0, 943491/943490D0]
    case default
      error stop "unsupported order"
    end select

    associate(depth => size(skin))
      call_julienne_assert(self%cells_ .isAtLeast. 2*depth)
      weights = [skin, [(1D0, face = 1, self%cells_ + 1 - 2*depth)], skin(depth:1:-1) ]
    end associate

    call_julienne_assert(size(weights) .equalsExpected. self%cells_ + 1)

  end procedure

  module procedure dot
    call_julienne_assert(size(gradient_1D%values_) .equalsExpected. size(vector_1D%values_))
    call_julienne_assert(gradient_1D%order_ .equalsExpected. vector_1D%order_)
    call_julienne_assert(gradient_1D%cells_ .equalsExpected. vector_1D%cells_)
    call_julienne_assert(gradient_1D%x_min_ .approximates.    vector_1D%x_min_ .within. double_equivalence)
    call_julienne_assert(gradient_1D%x_max_ .approximates.    vector_1D%x_max_ .within. double_equivalence)

    vector_dot_gradient_1D%tensor_1D_t = tensor_1D_t(   &
       values = gradient_1D%values_ * vector_1D%values_ &
      ,x_min  = gradient_1D%x_min_ &
      ,x_max  = gradient_1D%x_max_ &
      ,cells  = gradient_1D%cells_ &
      ,order  = gradient_1D%order_ &
    )
#ifndef __GFORTRAN__
    vector_dot_gradient_1D%weights_ = gradient_1D%weights()
#else
    vector_dot_gradient_1D%weights_ = gradient_1D%gradient_1D_weights()
#endif
  end procedure

end submodule gradient_1D_s

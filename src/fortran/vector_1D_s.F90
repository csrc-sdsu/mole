#include "julienne-assert-macros.h"

submodule(tensors_1D_m) vector_1D_s
  use julienne_m, only : call_julienne_assert_, operator(.greaterThan.), operator(.isAtLeast.), operator(.equalsExpected.)
  implicit none

contains

#ifndef __GFORTRAN__

  module procedure construct_1D_vector_from_function
    call_julienne_assert(x_max .greaterThan. x_min)
    call_julienne_assert(cells .isAtLeast. 2*order+1)

    associate(values => initializer(faces(x_min, x_max, cells)))
      vector_1D%tensor_1D_t = tensor_1D_t(values, x_min, x_max, cells, order)
    end associate
    vector_1D%divergence_operator_1D_ = divergence_operator_1D_t(k=order, dx=(x_max - x_min)/cells, cells=cells)
  end procedure

#else

  pure module function construct_1D_vector_from_function(initializer, order, cells, x_min, x_max) result(vector_1D)
    procedure(vector_1D_initializer_i), pointer :: initializer
    integer, intent(in) :: order !! order of accuracy
    integer, intent(in) :: cells !! number of grid cells spanning the domain
    double precision, intent(in) :: x_min !! grid location minimum
    double precision, intent(in) :: x_max !! grid location maximum
    type(vector_1D_t) vector_1D

    call_julienne_assert(x_max .greaterThan. x_min)
    call_julienne_assert(cells .isAtLeast. 2*order+1)

    associate(values => initializer(faces(x_min, x_max, cells)))
      vector_1D%tensor_1D_t = tensor_1D_t(values, x_min, x_max, cells, order)
    end associate
    vector_1D%divergence_operator_1D_ = divergence_operator_1D_t(k=order, dx=(x_max - x_min)/cells, cells=cells)
  end function

#endif

  module procedure construct_from_components
    vector_1D%tensor_1D_t = tensor_1D
    vector_1D%divergence_operator_1D_ = divergence_operator_1D
  end procedure

  module procedure div
    associate(Dv => self%divergence_operator_1D_ .x. self%values_)
      call_julienne_assert(size(Dv) .equalsExpected. self%cells_ + 2)
      divergence_1D = divergence_1D_t( tensor_1D_t(Dv(2:size(Dv)-1), self%x_min_, self%x_max_, self%cells_, self%order_) )
    end associate
  end procedure

  module procedure vector_1D_values
    face_centered_values = self%values_
  end procedure

  pure function faces(x_min, x_max, cells) result(x)
    double precision, intent(in) :: x_min, x_max
    integer, intent(in) :: cells
    double precision, allocatable:: x(:)
    integer cell

    associate(dx => (x_max - x_min)/cells)
      x = [x_min, x_min + [(cell*dx, cell = 1, cells-1)], x_max]
    end associate
  end function

  module procedure vector_1D_grid
    cell_faces  = faces(self%x_min_, self%x_max_, self%cells_)
  end procedure

end submodule vector_1D_s
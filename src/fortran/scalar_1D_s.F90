#include "julienne-assert-macros.h"

submodule(tensors_1D_m) scalar_1D_s
  use julienne_m, only : call_julienne_assert_, operator(.greaterThan.), operator(.isAtLeast.)
  implicit none

contains


#ifndef __GFORTRAN__

  module procedure construct_1D_scalar_from_function
    call_julienne_assert(x_max .greaterThan. x_min)
    call_julienne_assert(cells .isAtLeast. 2*order)

    associate(values => initializer(scalar_1D_grid_locations(x_min, x_max, cells)))
      scalar_1D%tensor_1D_t = tensor_1D_t(values, x_min, x_max, cells, order)
    end associate
    scalar_1D%gradient_operator_1D_ = gradient_operator_1D_t(k=order, dx=(x_max - x_min)/cells, cells=cells)
  end procedure

#else

  pure module function construct_1D_scalar_from_function(initializer, order, cells, x_min, x_max) result(scalar_1D)
    procedure(scalar_1D_initializer_i), pointer :: initializer
    integer, intent(in) :: order !! order of accuracy
    integer, intent(in) :: cells !! number of grid cells spanning the domain
    double precision, intent(in) :: x_min !! grid location minimum
    double precision, intent(in) :: x_max !! grid location maximum
    type(scalar_1D_t) scalar_1D

    call_julienne_assert(x_max .greaterThan. x_min)
    call_julienne_assert(cells .isAtLeast. 2*order)

    associate(values => initializer(scalar_1D_grid_locations(x_min, x_max, cells)))
      scalar_1D%tensor_1D_t = tensor_1D_t(values, x_min, x_max, cells, order)
    end associate
    scalar_1D%gradient_operator_1D_ = gradient_operator_1D_t(k=order, dx=(x_max - x_min)/cells, cells=cells)
  end function

  pure function cell_center_locations(x_min, x_max, cells) result(x)
    double precision, intent(in) :: x_min, x_max
    integer, intent(in) :: cells
    double precision, allocatable:: x(:)
    integer cell

    associate(dx => (x_max - x_min)/cells)
      x = x_min + dx/2. + [((cell-1)*dx, cell = 1, cells)]
    end associate
  end function

#endif


  module procedure grad
    gradient_1D = vector_1D_t( &
       tensor_1D_t(self%gradient_operator_1D_ .x. self%values_, self%x_min_, self%x_max_, self%cells_, self%order_) &
      ,divergence_operator_1D_t(self%order_, (self%x_max_-self%x_min_)/self%cells_, self%cells_) &
    )
  end procedure

  module procedure laplacian

    laplacian_1D%divergence_1D_t = .div. (.grad. self)

    associate(divergence_operator_1D => divergence_operator_1D_t(self%order_, (self%x_max_ - self%x_min_)/self%cells_, self%cells_))
      laplacian_1D%boundary_depth_ = divergence_operator_1D%submatrix_A_rows() + 1
    end associate

  end procedure

  module procedure scalar_1D_values
    cell_centers_extended_values = self%values_
  end procedure

  pure function scalar_1D_grid_locations(x_min, x_max, cells) result(x)
    double precision, intent(in) :: x_min, x_max
    integer, intent(in) :: cells
    double precision, allocatable:: x(:)
    integer cell

    associate(dx => (x_max - x_min)/cells)
      x = [x_min, cell_center_locations(x_min, x_max, cells), x_max]
    end associate
  end function

  module procedure scalar_1D_grid
    cell_centers_extended  = scalar_1D_grid_locations(self%x_min_, self%x_max_, self%cells_)
  end procedure

end submodule scalar_1D_s
#include "julienne-assert-macros.h"

submodule(tensors_1D_m) scalar_1D_s
  use julienne_m, only : call_julienne_assert_, operator(.equalsExpected.), operator(.greaterThan.), operator(.isAtLeast.)
  implicit none

contains

  module procedure construct_1D_scalar_from_function
    call_julienne_assert(x_max .greaterThan. x_min)
    call_julienne_assert(cells .isAtLeast. 2*order)

    associate(values => initializer(cell_centers_extended(x_min, x_max, cells)))
      scalar_1D%tensor_1D_t = tensor_1D_t(values, x_min, x_max, cells, order)
    end associate
    scalar_1D%gradient_operator_1D_ = gradient_operator_1D_t(k=order, dx=(x_max - x_min)/cells, cells=cells)
  end procedure

  module procedure grad
    associate( &
       gradient_values => matvec(self%gradient_operator_1D_%mimetic_matrix_1D_, self) &
      ,divergence_operator_1D => divergence_operator_1D_t(self%order_, (self%x_max_-self%x_min_)/self%cells_, self%cells_) &
    )
      gradient_1D = gradient_1D_t(tensor_1D_t(gradient_values, self%x_min_, self%x_max_, self%cells_, self%order_), divergence_operator_1D)
    end associate
  end procedure

  module procedure scalar_1D_values
    my_values = self%values_
  end procedure

  pure function cell_centers_extended(x_min, x_max, cells) result(x)
    double precision, intent(in) :: x_min, x_max
    integer, intent(in) :: cells
    double precision, allocatable:: x(:)
    integer cell

    associate(dx => (x_max - x_min)/cells)
      x = [x_min, x_min + dx/2. + [((cell-1)*dx, cell = 1, cells)], x_max]
    end associate
  end function

  module procedure scalar_1D_grid
    x = cell_centers_extended(self%x_min_, self%x_max_, self%cells_)
  end procedure

end submodule scalar_1D_s
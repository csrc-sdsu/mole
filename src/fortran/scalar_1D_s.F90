#include "julienne-assert-macros.h"

submodule(tensors_1D_m) scalar_1D_s
  use julienne_m, only : call_julienne_assert_, operator(.equalsExpected.), operator(.greaterThan.), operator(.isAtLeast.)
  implicit none

contains

  module procedure construct_1D_scalar_from_function
    call_julienne_assert(x_max .greaterThan. x_min)
    call_julienne_assert(cells .isAtLeast. 2*order)

    scalar_1D%tensor_1D_t = tensor_1D_t(initializer(scalar_1D%cell_centers_extended()), x_min, x_max, cells, order)
    scalar_1D%gradient_operator_1D_ = gradient_operator_1D_t(k=order, dx=(x_max - x_min)/cells, cells=cells)
  end procedure

  module procedure grad
    gradient_1D = gradient_1D_t(matvec(self%gradient_operator_1D_%mimetic_matrix_1D_, self), self%x_min_, self%x_max_, self%cells_)
  end procedure

  module procedure scalar_1D_values
    my_values = self%values_
  end procedure

  pure function cell_centers(x_min, x_max, cells) result(x)
    double precision, intent(in) :: x_min, x_max
    integer, intent(in) :: cells
    double precision, allocatable:: x(:)
    integer cell

    associate(dx => (x_max - x_min)/cells)
      x = x_min + dx/2. + [((cell-1)*dx, cell = 1, cells)]
    end associate
  end function

  module procedure cell_centers_extended
    x = [self%x_min_, cell_centers(self%x_min_, self%x_max_, self%cells_), self%x_max_]
  end procedure

end submodule scalar_1D_s
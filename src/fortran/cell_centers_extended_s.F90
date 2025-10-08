#include "julienne-assert-macros.h"

submodule(cell_centers_extended_m) cell_centers_extended_s
  use julienne_m, only : call_julienne_assert_, operator(.equalsExpected.)
  implicit none

contains

  module procedure construct
    call_julienne_assert(x_max .isGreaterThan. x_min)
    call_julienne_assert(cells .isAtLeast. 2*order)

    cell_centers_extended%x_min_ = x_min
    cell_centers_extended%x_max_ = x_max
    cell_centers_extended%cells_ = cells
    cell_centers_extended%gradient_operator_ = gradient_operator_t(k=order, dx=(x_max - x_min)/cells, m=cells)
    cell_centers_extended%scalar_1D_ = scalar_1D_initializer%f(grid_(x_min, x_max, cells))
  end procedure

  pure function grid_(x_min, x_max, cells) result(x)
    double precision, intent(in) :: x_min, x_max
    integer, intent(in) :: cells
    double precision, allocatable :: x(:)
    integer cell

    associate(dx => (x_max - x_min)/cells)
      x = [x_min, x_min + dx/2. + [((cell-1)*dx, cell = 1, cells)], x_max]
    end associate
  end function

  module procedure grid
      x = grid_(self%x_min_, self%x_max_, self%cells_)
  end procedure

  module procedure grad
    grad_f = gradient_t(matvec(self%gradient_operator_%mimetic_matrix_, self), self%x_min_, self%x_max_, self%cells_)
  end procedure

end submodule cell_centers_extended_s
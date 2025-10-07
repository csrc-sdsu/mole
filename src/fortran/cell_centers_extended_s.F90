#include "julienne-assert-macros.h"

submodule(cell_centers_extended_m) cell_centers_extended_s
  use julienne_m, only : call_julienne_assert_, operator(.equalsExpected.)
  implicit none

contains

  module procedure construct

    integer cell

    call_julienne_assert(x_max .isGreaterThan. x_min)

    associate(dx => (x_max - x_min)/cells)
      cell_centers_extended%gradient_operator_ = gradient_operator_t(k=order, dx=dx, m=cells)
    end associate

    cell_centers_extended%x_min_ = x_min
    cell_centers_extended%x_max_ = x_max
    cell_centers_extended%cells_ = cells
    cell_centers_extended%scalar_1D_ = scalar_1D_initializer%f(cell_centers_extended%grid())

  end procedure

  module procedure grid
    integer cell

    associate(dx => (self%x_max_ - self%x_min_)/self%cells_)
      x = [self%x_min_, self%x_min_ + dx/2. + [((cell-1)*dx, cell = 1, self%cells_)], self%x_max_]
    end associate
  end procedure

  module procedure grad
    grad_f = self%gradient_operator_%mimetic_matrix_ .x. self
  end procedure

end submodule cell_centers_extended_s
#include "julienne-assert-macros.h"

submodule(cell_centers_extended_m) cell_centers_extended_s
  use julienne_m, only : call_julienne_assert_, operator(.equalsExpected.)
  implicit none

contains

  module procedure construct

    integer cell

    call_julienne_assert(x_max .isGreaterThan. x_min)

    associate(dx => dble(x_max - x_min)/dble(cells))
      cell_centers_extended%grid_ = [x_min, x_min + dx/2. + [((cell-1)*dx, cell = 1, cells)], x_max] ! boundaries + cell centers as described in
      cell_centers_extended%cells_ = cells
      cell_centers_extended%scalar_1D_ = scalar_1D_initializer%f(cell_centers_extended%grid_)        ! Corbino & Castillo (2020)
      cell_centers_extended%gradient_operator_ = gradient_operator_t(k=order, dx=dx, m=cells)        ! https://doi.org/10.1016/j.cam.2019.06.042
    end associate

  end procedure

  module procedure grad
    grad_f = self%gradient_operator_%mimetic_matrix_ .x. self
  end procedure

end submodule cell_centers_extended_s
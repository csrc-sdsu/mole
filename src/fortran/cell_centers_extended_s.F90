#include "julienne-assert-macros.h"

submodule(cell_centers_extended_m) cell_centers_extended_s
  use julienne_m, only : call_julienne_assert_, operator(.equalsExpected.)
  implicit none

contains

  module procedure construct

    integer cell

    call_julienne_assert(size(domain) .equalsExpected. 2)

    associate(x_min => domain(1), x_max => domain(2))
      associate(dx => dble(domain(2) - domain(1))/dble(cells))
        associate(x => [x_min, x_min + dx/2. + [(dble(cell-1)*dx, cell = 1, cells)], x_max]) !! boundaries + cell centers
          cell_centers_extended%scalar_1D_ = scalar_1D_initializer%f(x)                         !! Corbino & Castillo (2020)
        end associate                                                                           !! https://doi.org/10.1016/j.cam.2019.06.042
      end associate
    end associate

    cell_centers_extended%domain_ = domain
    cell_centers_extended%gradient_operator_ = gradient_operator_t(k=order, dx=(domain(2)-domain(1))/dble(cells), m=cells)
  end procedure

  module procedure grad
    grad_f = self%gradient_operator_%mimetic_matrix_ .x. self
  end procedure

end submodule cell_centers_extended_s
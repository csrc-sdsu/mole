#include "julienne-assert-macros.h"

submodule(tensors_1D_m) vector_1D_s
  use julienne_m, only : call_julienne_assert_, operator(.equalsExpected.), operator(.greaterThan.), operator(.isAtLeast.)
  implicit none

contains

  module procedure div
    associate(divergence_values => matvec(self%divergence_operator_1D_%mimetic_matrix_1D_, self))
      associate( &
         tensor_1D => tensor_1D_t(divergence_values, self%x_min_, self%x_max_, self%cells_, self%order_) &
        ,gradient_operator_1D => gradient_operator_1D_t(k=self%order_, dx=(self%x_max_ - self%x_min_)/self%cells_, cells=self%cells_) &
      )
        divergence_1D = divergence_1D_t(tensor_1D, gradient_operator_1D)
      end associate
    end associate
  end procedure

  module procedure vector_1D_values
    my_values = self%values_
  end procedure

  pure function internal_faces(x_min, x_max, cells) result(x)
    double precision, intent(in) :: x_min, x_max
    integer, intent(in) :: cells
    double precision, allocatable:: x(:)
    integer cell

    associate(dx => (x_max - x_min)/cells)
      x = x_min + [(cell*dx, cell = 1, cells-1)]
    end associate
  end function

  module procedure faces
    cell_faces  = [self%x_min_, internal_faces(self%x_min_, self%x_max_, self%cells_), self%x_max_]
  end procedure

end submodule vector_1D_s
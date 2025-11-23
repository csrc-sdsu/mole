#include "julienne-assert-macros.h"

submodule(tensors_1D_m) vector_1D_s
  use julienne_m, only : call_julienne_assert_, operator(.equalsExpected.), operator(.greaterThan.), operator(.isAtLeast.)
  implicit none

contains

  pure module function construct_1D_vector_from_function(initializer, order, cells, x_min, x_max) result(vector_1D)
    procedure(vector_1D_initializer_i), pointer :: initializer
    integer, intent(in) :: order !! order of accuracy
    integer, intent(in) :: cells !! number of grid cells spanning the domain
    double precision, intent(in) :: x_min !! grid location minimum
    double precision, intent(in) :: x_max !! grid location maximum
    type(vector_1D_t) vector_1D

    call_julienne_assert(x_max .greaterThan. x_min)
    call_julienne_assert(cells .isAtLeast. 2*order)

    vector_1D%x_min_ = x_min
    vector_1D%x_max_ = x_max
    vector_1D%cells_ = cells
    vector_1D%divergence_operator_1D_ = divergence_operator_1D_t(k=order, dx=(x_max - x_min)/cells, cells=cells)
    vector_1D%values_ = initializer(vector_1D%faces())
  end function

  module procedure div
    divergence_1D = divergence_1D_t(matvec(self%divergence_operator_1D_%mimetic_matrix_1D_, self), self%x_min_, self%x_max_, self%cells_)
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
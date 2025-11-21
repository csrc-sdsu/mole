#include "julienne-assert-macros.h"

submodule(tensors_1D_m) scalar_1D_s
  use julienne_m, only : call_julienne_assert_, operator(.equalsExpected.), operator(.greaterThan.), operator(.isAtLeast.)
  implicit none

contains

  pure module function construct_1D_scalar_from_function(initializer, order, cells, x_min, x_max) result(scalar_1D)
    implicit none
    procedure(scalar_1D_initializer_i), pointer :: initializer
    integer, intent(in) :: order !! order of accuracy
    integer, intent(in) :: cells !! number of grid cells spanning the domain
    double precision, intent(in) :: x_min !! grid location minimum
    double precision, intent(in) :: x_max !! grid location maximum
    type(scalar_1D_t) scalar_1D

    call_julienne_assert(x_max .greaterThan. x_min)
    call_julienne_assert(cells .isAtLeast. 2*order)

    scalar_1D%x_min_ = x_min
    scalar_1D%x_max_ = x_max
    scalar_1D%cells_ = cells
    scalar_1D%gradient_operator_1D_ = gradient_operator_1D_t(k=order, dx=(x_max - x_min)/cells, cells=cells)
    scalar_1D%scalar_1D_ = initializer(cell_centers_extended(x_min, x_max, cells))
  end function

  module procedure grid
      x = cell_centers_extended(self%x_min_, self%x_max_, self%cells_)
  end procedure

  module procedure grad
    grad_f = gradient_1D_t(matvec(self%gradient_operator_1D_%mimetic_matrix_1D_, self), self%x_min_, self%x_max_, self%cells_)
  end procedure

end submodule scalar_1D_s
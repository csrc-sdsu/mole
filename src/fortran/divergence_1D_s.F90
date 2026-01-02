#include "julienne-assert-macros.h"

submodule(tensors_1D_m) divergence_1D_s
  use julienne_m, only : &
     call_julienne_assert_ & 
    ,operator(.equalsExpected.) &
    ,operator(.isAtLeast.)
  implicit none

contains

#ifdef __GFORTRAN__

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

  module procedure premultiply_scalar_1D
    call_julienne_assert(size(scalar_1D%values_) .equalsExpected. size(divergence_1D%values_) + 2)
    scalar_x_divergence_1D%tensor_1D_t = &
       tensor_1D_t(scalar_1D%values_(2:size(scalar_1D%values_)-1) * divergence_1D%values_, scalar_1D%x_min_, scalar_1D%x_max_, scalar_1D%cells_, scalar_1D%order_)
#ifndef __GFORTRAN__
    scalar_x_divergence_1D%weights_ = divergence_1D%weights() 
#else
    scalar_x_divergence_1D%weights_ = divergence_1D%divergence_1D_weights() 
#endif
    call_julienne_assert(size(scalar_x_divergence_1D%weights_) .equalsExpected. size(divergence_1D%values_)+2)
  end procedure

  module procedure postmultiply_scalar_1D
    scalar_x_divergence_1D = premultiply_scalar_1D(scalar_1D, divergence_1D) 
  end procedure

  module procedure divergence_1D_values
    cell_centered_values = self%values_
  end procedure

  module procedure divergence_1D_grid
    cell_centers = cell_center_locations(self%x_min_, self%x_max_, self%cells_)
  end procedure

  module procedure divergence_1D_weights
      integer c 

      double precision, allocatable :: skin(:)

      select case(self%order_)
      case(2)
        skin = [double precision::]
      case(4)
        skin = [1D0, 2186/1943D0, 1992/2651D0, 1993/1715D0, 649/674D0, 699/700D0, 18170/18171D0, 471744/471745D0]
      case default
        error stop "unsupported order"
      end select

      associate(depth => size(skin))
        weights = [skin, [(1D0, c = depth+1, self%cells_+2-depth)], skin(depth:1:-1) ] ! m+2 values, where m = self%cells_
      end associate                                                                    ! cf. Corbino & Castillo (2020) Eqs. 14-15 & 19

      call_julienne_assert(self%cells_ .isAtLeast. 2*size(skin))
      call_julienne_assert(size(weights) .equalsExpected. self%cells_+2)
  end procedure

end submodule divergence_1D_s
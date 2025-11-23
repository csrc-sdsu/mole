#include "julienne-assert-macros.h"

submodule(tensors_1D_m) divergence_1D_s
  use julienne_m, only : call_julienne_assert_, string_t
#if ASSERTIONS
  use julienne_m, only : operator(.isAtLeast.)
#endif
  implicit none
contains

  module procedure construct_divergence_from_components
    divergence_1D%scalar_1D_ = cell_centered_values
    divergence_1D%x_min_ = x_min
    divergence_1D%x_max_ = x_max
    divergence_1D%cells_ = cells
  end procedure

  module procedure construct_1D_divergence_operator

    call_julienne_assert(cells .isAtLeast. 2*k+1)

    associate(A => A_block(k,dx))
      divergence_operator_1D%mimetic_matrix_1D_ = mimetic_matrix_1D_t(A, M(k, dx), negate_and_flip(A))
      divergence_operator_1D%k_  = k
      divergence_operator_1D%dx_ = dx
      divergence_operator_1D%m_  = cells
    end associate

  contains

    pure function A_block(k, dx) result(matrix_block)
      !! Compute the upper block submatrix "A" of the Corbino & Castillo (2020) mimetic divergence operator
      integer, intent(in) :: k
      double precision, intent(in) :: dx
      double precision, allocatable :: matrix_block(:,:)

      order_of_accuracy: &
      select case(k)
      case(2)
        matrix_block = reshape([ double precision :: &
          ! zero row elements => zero-sized array
        ], shape=[0,3])
      case(4)
        matrix_block = reshape([ &
          -11/12D0, 17/24D0, 3/8D0, -5/24D0,  1/24D0 &
        ], shape=[1,5], order=[2,1]) / dx
      case default
        associate(string_k => string_t(k))
          error stop "A (divergence_operator_1D_s): unsupported order of accuracy: " // string_k%string()
        end associate
      end select order_of_accuracy

    end function

    pure function M(k, dx) result(row)
      !! Compute the middle block submatrix "M" of the Corbino & Castillo (2020) mimetic divergence operator
      integer, intent(in) :: k
      double precision, intent(in) :: dx
      double precision, allocatable :: row(:)

      order_of_accuracy: &
      select case(k)
      case(2)
        row = [-1D0, 1D0]/ dx        
      case(4)
        row = [1D0/24D0, -9D0/8D0, 9D0/8D0, -1D0/24D0] / dx        
      case default
        associate(string_k => string_t(k))
          error stop "M (divergence_operator_1D_s): unsupported order of accuracy: " // string_k%string()
        end associate
      end select order_of_accuracy

    end function

  end procedure

end submodule divergence_1D_s
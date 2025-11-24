#include "julienne-assert-macros.h"
#include "mole-language-support.F90"

submodule(tensors_1D_m) gradient_1D_s
  use julienne_m, only : call_julienne_assert_, string_t
#if ASSERTIONS
  use julienne_m, only : operator(.isAtLeast.)
#endif
  implicit none

contains

  module procedure construct_1D_gradient_from_components
    gradient_1D%tensor_1D_t = tensor_1D
    gradient_1D%divergence_operator_1D_ = divergence_operator_1D
  end procedure

  module procedure construct_1D_gradient_operator

    call_julienne_assert(cells .isAtLeast. 2*k)

    associate(A => corbino_castillo_A(k, dx), M => corbino_castillo_M(k, dx))
      gradient_operator_1D%mimetic_matrix_1D_ = mimetic_matrix_1D_t(A, M, negate_and_flip(A))
      gradient_operator_1D%k_  = k
      gradient_operator_1D%dx_ = dx
      gradient_operator_1D%m_  = cells
    end associate

  contains

    pure function corbino_castillo_A(k, dx) result(matrix_block)
      integer, intent(in) :: k
      double precision, intent(in) :: dx
      double precision, allocatable :: matrix_block(:,:)

      order_of_accuracy: &
      select case(k)
      case(2)
        matrix_block = reshape([-8D0/3D0, 3D0, -1D0/3D0] , shape=[1,3]) / dx
      case(4)
        matrix_block = reshape([ &
           -352D0/105D0,  35D0/ 8D0, -35D0/24D0, 21D0/40D0, -5D0/ 56D0 &
          ,  16D0/105D0, -31D0/24D0,  29D0/24D0, -3D0/40D0,  1D0/168D0 &
        ], shape=[2,5], order=[2,1]) / dx
      case default
        associate(string_k => string_t(k))
          error stop "corbino_castillo_A: unsupported order of accuracy: " // string_k%string()
        end associate
      end select order_of_accuracy

    end function

    pure function corbino_castillo_M(k, dx) result(row)
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
          error stop "corbino_castillo_A: unsupported order of accuracy: " // string_k%string()
        end associate
      end select order_of_accuracy

    end function

  end procedure

end submodule gradient_1D_s
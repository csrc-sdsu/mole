#include "mole-language-support.F90"
#include "julienne-assert-macros.h"

submodule(mimetic_operators_1D_m) divergence_operator_1D_s
  use julienne_m, only : call_julienne_assert_, string_t
#if ASSERTIONS
  use julienne_m, only : operator(.isAtLeast.)
#endif
  implicit none
contains

  module procedure construct_1D_divergence_operator

    double precision, allocatable :: Ap(:,:)

    call_julienne_assert(cells .isAtLeast. 2*k+1)

    associate(A => A_block(k,dx))
      if (size(A) /= 0) then
        Ap = negate_and_flip(A)
      else
        allocate(Ap, mold = A)
      end if
      divergence_operator_1D%mimetic_matrix_1D_t = mimetic_matrix_1D_t(A, M(k, dx), Ap)
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

  end procedure construct_1D_divergence_operator

#if HAVE_DO_CONCURRENT_TYPE_SPEC_SUPPORT && HAVE_LOCALITY_SPECIFIER_SUPPORT

  module procedure divergence_matrix_multiply

    double precision, allocatable :: product_inner(:)

    associate(upper_rows => size(self%upper_,1), lower_rows => size(self%lower_,1))
      associate(inner_rows => size(vec) - (upper_rows + lower_rows + 1))

        allocate(product_inner(inner_rows))

        do concurrent(integer :: row = 1 : inner_rows) default(none) shared(product_inner, self, vec)
          product_inner(row) = dot_product(self%inner_, vec(row : row + size(self%inner_) - 1))
        end do

        matvec_product = [ &
           matmul(self%upper_, vec(1 : size(self%upper_,2))) &
          ,product_inner &
          ,matmul(self%lower_, vec(size(vec) - size(self%lower_,2) + 1 : )) &
        ]
      end associate
    end associate
  end procedure

#else

  module procedure divergence_matrix_multiply

    integer row
    double precision, allocatable :: product_inner(:)

    associate(upper_rows => size(self%upper_,1), lower_rows => size(self%lower_,1))
      associate(inner_rows => size(vec) - (upper_rows + lower_rows + 1))

        allocate(product_inner(inner_rows))

        do concurrent(integer :: row = 1 : inner_rows)
          product_inner(row) = dot_product(self%inner_, vec(row : row + size(self%inner_) - 1))
        end do

        matvec_product = [ &
           matmul(self%upper_, vec(1 : size(self%upper_,2))) &
          ,product_inner &
          ,matmul(self%lower_, vec(size(vec) - size(self%lower_,2) + 1 : )) &
        ]
      end associate
    end associate
  end procedure

#endif

end submodule divergence_operator_1D_s
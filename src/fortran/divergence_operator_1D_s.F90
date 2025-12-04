#include "mole-language-support.F90"
#include "julienne-assert-macros.h"

submodule(mimetic_operators_1D_m) divergence_operator_1D_s
  use julienne_m, only : call_julienne_assert_, string_t
#if ASSERTIONS
  use julienne_m, only : operator(.isAtLeast.), operator(.equalsExpected.)
#endif
  implicit none
contains

#ifdef __GFORTRAN__

  pure function negate_and_flip(A) result(Ap)
    !! Transform a mimetic matrix upper block into a lower block
    double precision, intent(in) :: A(:,:)
    double precision, allocatable :: Ap(:,:)
    integer row, column

    allocate(Ap, mold=A)

    reverse_elements_within_rows_and_flip_sign: &
    do concurrent(row = 1:size(Ap,1))
      Ap(row,:) = -A(row,size(A,2):1:-1)
    end do reverse_elements_within_rows_and_flip_sign

    reverse_elements_within_columns: &
    do concurrent(column = 1 : size(Ap,2))
      Ap(:,column) = Ap(size(Ap,1):1:-1,column)
    end do reverse_elements_within_columns

  end function

#endif
 
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
        matrix_block = reshape([ &
          0D0 &
        ], shape=[1,1])
      case(4)
        matrix_block = reshape([ &
                0D0,     0D0,   0D0,     0D0,     0D0 &
          ,-11/12D0, 17/24D0, 3/8D0, -5/24D0,  1/24D0 &
        ], shape=[2,5], order=[2,1]) / dx
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


  module procedure divergence_matrix_multiply

    double precision, allocatable :: product_inner(:)

    associate( &
       upper_rows => size(self%upper_,1) &
      ,lower_rows => size(self%lower_,1) &
    )
      associate( &
         inner_rows    => self%m_ + 2 - (upper_rows + lower_rows) & ! sum({upper,inner,lower}_rows) = m + 2 (Corbino & Castillo, 2020) 
        ,inner_columns => size(self%inner_) &
      )
        call_julienne_assert((size(vec) .equalsExpected. upper_rows + inner_rows + lower_rows - 1))
        allocate(product_inner(inner_rows))

#if HAVE_DO_CONCURRENT_TYPE_SPEC_SUPPORT && HAVE_LOCALITY_SPECIFIER_SUPPORT
        do concurrent(integer :: row = 1 : inner_rows) default(none) shared(product_inner, self, vec, inner_columns)
          product_inner(row) = dot_product(self%inner_, vec(row : row + inner_columns  - 1))
        end do
#else
        block
          integer row
          do concurrent(row = 1 : inner_rows)
            product_inner(row) = dot_product(self%inner_, vec(row : row + inner_columns  - 1))
          end do
        end block
#endif

      end associate
    end associate

    associate( &
       upper_columns => size(self%upper_,2) &
      ,lower_columns => size(self%lower_,2) &
    )
      associate(matvec_product => [ &
         matmul(self%upper_, vec(1 : upper_columns )) &
        ,product_inner &
        ,matmul(self%lower_, vec(size(vec) - lower_columns + 1 : )) &
      ])
        internal_faces = matvec_product(2:size(matvec_product)-1)
      end associate
    end associate

  end procedure

  module procedure assemble_divergence

    associate(rows => self%m_ + 2, cols => self%m_ + 1)

      allocate(D(rows, cols))

#if HAVE_DO_CONCURRENT_TYPE_SPEC_SUPPORT && HAVE_LOCALITY_SPECIFIER_SUPPORT
      do concurrent(integer :: col=1:cols) default(none) shared(D, self, rows)
        D(:,col) = self .x. e(dir=col, len=rows)
      end do
#else
      block
        integer col
        do concurrent(col=1:cols)
          D(:,col) = self .x. e(dir=col, len=rows)
        end do
      end block
#endif
    end associate

  contains

    pure function e(dir, len) result(unit_vector)
      !! Result is the dir-th column of the len x len identity matrix
      double precision :: unit_vector(len)
      integer, intent(in) :: dir, len
      unit_vector(1:dir-1) = 0D0
      unit_vector(dir)     = 1D0
      unit_vector(dir+1:)  = 0D0
    end function

  end procedure

end submodule divergence_operator_1D_s
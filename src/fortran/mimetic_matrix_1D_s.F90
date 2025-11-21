#include "mole-language-support.F90"
#include "julienne-assert-macros.h"

submodule(tensors_1D_m) mimetic_matrix_1D_s
  use julienne_m, only : call_julienne_assert_, string_t, operator(.equalsExpected.), operator(.csv.)
  implicit none

contains

  module procedure construct_matrix_operator
    mimetic_matrix_1D%upper_ = upper
    mimetic_matrix_1D%inner_ = inner
    mimetic_matrix_1D%lower_ = lower
  end procedure

#if HAVE_DO_CONCURRENT_TYPE_SPEC_SUPPORT && HAVE_LOCALITY_SPECIFIER_SUPPORT

  module procedure matvec

    double precision, allocatable :: product_inner(:)

    associate(upper => size(self%upper_,1), lower => size(self%lower_,1))
      associate(inner_rows => size(scalar_1D%scalar_1D_) - (upper + lower + 1))

        allocate(product_inner(inner_rows))

        do concurrent(integer :: row = 1 : inner_rows) default(none) shared(product_inner, self, scalar_1D)
          product_inner(row) = dot_product(self%inner_, scalar_1D%scalar_1D_(row + 1 : row + size(self%inner_)))
        end do

        matvec_product = [ &
           matmul(self%upper_, scalar_1D%scalar_1D_(1 : size(self%upper_,2))) &
          ,product_inner &
          ,matmul(self%lower_, scalar_1D%scalar_1D_(size(scalar_1D%scalar_1D_) - size(self%lower_,2) + 1 : )) &
        ]
      end associate
    end associate
  end procedure

#else

  module procedure matvec

    integer row
    double precision, allocatable :: product_inner(:)

    associate(upper => size(self%upper_,1), lower => size(self%lower_,1))
      associate(inner_rows => size(scalar_1D%scalar_1D_) - (upper + lower + 1))

        allocate(product_inner(inner_rows))

        do concurrent(row = 1 : inner_rows)
          product_inner(row) = dot_product(self%inner_, scalar_1D%scalar_1D_(row + 1 : row + size(self%inner_)))
        end do

        matvec_product = [ &
           matmul(self%upper_, scalar_1D%scalar_1D_(1 : size(self%upper_,2))) &
          ,product_inner &
          ,matmul(self%lower_, scalar_1D%scalar_1D_(size(scalar_1D%scalar_1D_) - size(self%lower_,2) + 1 : )) &
        ]
      end associate
    end associate
  end procedure

#endif

  module procedure to_file_t
    type(string_t), allocatable :: lines(:)
    integer, parameter :: inner_rows = 1
    integer row

    associate(upper_rows => size(self%upper_,1), lower_rows => size(self%lower_,1))
      allocate(lines(upper_rows + inner_rows + lower_rows))
      do row = 1, upper_rows
        lines(row) = .csv. string_t(self%upper_(row,:))
      end do
      lines(upper_rows + inner_rows) = .csv. string_t(self%inner_)
      do row = 1, lower_rows
        lines(upper_rows + inner_rows + row) = .csv. string_t(self%lower_(row,:))
      end do
    end associate

    file = file_t(lines)

  end procedure

end submodule mimetic_matrix_1D_s
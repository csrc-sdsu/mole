#include "mole-language-support.F90"
#include "julienne-assert-macros.h"

submodule(cell_centers_extended_m) mimetic_matrix_s
  use julienne_m, only : call_julienne_assert_
  implicit none

contains

  module procedure construct_from_components
    mimetic_matrix%upper_ = upper
    mimetic_matrix%inner_ = inner
    mimetic_matrix%lower_ = lower
  end procedure

#if HAVE_DO_CONCURRENT_TYPE_SPEC_SUPPORT

  module procedure matvec

    double precision, allocatable :: product_inner(:)

    associate(upper_rows  => size(self%upper_,1))
      associate(inner_rows => (size(vector%f_) - 1) - 2*upper_rows) ! inner_rows = matrix rows - (upper rows + lower rows)

        allocate(product_inner(inner_rows))

        associate(inner_bandwidth => size(self%inner_))
          do concurrent(integer :: row = 1 : inner_rows) default(none) &
            shared(product_inner, self, vector, upper_rows, inner_bandwidth)
            product_inner(row) = dot_product(self%inner_, vector%f_(upper_rows + row : upper_rows + row + inner_bandwidth - 1))
          end do
        end associate

        associate(upper_bandwidth => size(self%upper_,2), lower_bandwidth => size(self%lower_,2))
          gradient%g_ = [ &
             matmul(self%upper_, vector%f_(1 : upper_bandwidth)) &
            ,product_inner &
            ,matmul(self%lower_, vector%f_(size(vector%f_) - lower_bandwidth + 1 : )) &
          ]
        end associate
      end associate
    end associate
  end procedure

#else

  module procedure matvec

    double precision, allocatable :: product_inner(:)

    associate(upper_rows  => size(self%upper_,1), inner_bandwidth => size(self%inner_))
      associate(inner_rows => (size(vector%f_) - 1) - 2*upper_rows) ! inner_rows = matrix rows - (upper rows + lower rows)

        allocate(product_inner(inner_rows))

        block
          integer row
          do concurrent(row = 1 : inner_rows) default(none) shared(product_inner, self, vector, upper_rows, inner_bandwidth)
            product_inner(row) = dot_product(self%inner_, vector%f_(upper_rows + row : upper_rows + inner_bandwidth))
          end do
        end block

        gradient%g_ = [ &
           matmul(self%upper_, vector%f_(1 : upper_rows)) &
          ,product_inner &
          ,matmul(self%lower_, vector%f_(upper_rows + inner_rows + 1 : )) &
        ]
      end associate
    end associate
  end procedure

#endif

end submodule mimetic_matrix_s

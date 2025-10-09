#include "mole-language-support.F90"
#include "julienne-assert-macros.h"

submodule(scalar_1D_m) mimetic_matrix_1D_s
  use julienne_m, only : call_julienne_assert_, string_t, operator(.equalsExpected.)
  implicit none

contains

  module procedure construct_from_components
    mimetic_matrix_1D%upper_ = upper
    mimetic_matrix_1D%inner_ = inner
    mimetic_matrix_1D%lower_ = lower
  end procedure

#if HAVE_DO_CONCURRENT_TYPE_SPEC_SUPPORT

  module procedure matvec

    double precision, allocatable :: product_inner(:)

    associate(upper => size(self%upper_,1), lower => size(self%lower_,1))
      associate(inner_rows => size(vector%scalar_1D_) - (upper + lower + 1))

        allocate(product_inner(inner_rows))

        do concurrent(integer :: row = 1 : size(product_inner)) default(none) shared(product_inner, self, vector)
          product_inner(row) = dot_product(self%inner_, vector%scalar_1D_(row + 1 : row + size(self%inner_)))
        end do

        matvec_product = [ &
           matmul(self%upper_, vector%scalar_1D_(1 : size(self%upper_,2))) &
          ,product_inner &
          ,matmul(self%lower_, vector%scalar_1D_(size(vector%scalar_1D_) - size(self%lower_,2) + 1 : )) &
        ]
      end associate
    end associate
  end procedure

#else

#endif

end submodule mimetic_matrix_1D_s
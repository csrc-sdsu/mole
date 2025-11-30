#include "julienne-assert-macros.h"

submodule(tensors_1D_m) vector_1D_s
  use julienne_m, only : call_julienne_assert_, operator(.greaterThan.), operator(.isAtLeast.)
  implicit none

contains

  module procedure construct_1D_vector_from_function
    call_julienne_assert(x_max .greaterThan. x_min)
    call_julienne_assert(cells .isAtLeast. 2*order+1)

    associate(values => initializer(faces(x_min, x_max, cells)))
      vector_1D%tensor_1D_t = tensor_1D_t(values, x_min, x_max, cells, order)
    end associate
    vector_1D%divergence_operator_1D_ = divergence_operator_1D_t(k=order, dx=(x_max - x_min)/cells, cells=cells)
  end procedure

  module procedure div
    divergence_1D = scalar_1D_t( &
       tensor_1D_t(self%apply_divergence_1D(), self%x_min_, self%x_max_, self%cells_, self%order_) &
      ,gradient_operator_1D_t(k=self%order_, dx=(self%x_max_ - self%x_min_)/self%cells_, cells=self%cells_) &
    )
  end procedure

  module procedure vector_1D_values
    my_values = self%values_
  end procedure

  pure function faces(x_min, x_max, cells) result(x)
    double precision, intent(in) :: x_min, x_max
    integer, intent(in) :: cells
    double precision, allocatable:: x(:)
    integer cell

    associate(dx => (x_max - x_min)/cells)
      x = [x_min, x_min + [(cell*dx, cell = 1, cells-1)], x_max]
    end associate
  end function

  module procedure vector_1D_grid
    cell_faces  = faces(self%x_min_, self%x_max_, self%cells_)
  end procedure

#if HAVE_DO_CONCURRENT_TYPE_SPEC_SUPPORT && HAVE_LOCALITY_SPECIFIER_SUPPORT

  module procedure apply_divergence_1D

    double precision, allocatable :: product_inner(:)

    associate(upper_rows => size(self%divergence_operator_1D_%upper_,1), lower_rows => size(self%divergence_operator_1D_%lower_,1))
      associate(inner_rows => size(self%values_) - (upper_rows + lower_rows + 1))

        allocate(product_inner(inner_rows))

        do concurrent(integer :: row = 1 : inner_rows) default(none) shared(product_inner, self%divergence_operator_1D_, self)
          product_inner(row) = dot_product(self%divergence_operator_1D_%inner_, self%values_(row : row + size(self%divergence_operator_1D_%inner_) - 1))
        end do

        matvec_product = [ &
           matmul(self%divergence_operator_1D_%upper_, self%values_(1 : size(self%divergence_operator_1D_%upper_,2))) &
          ,product_inner &
          ,matmul(self%divergence_operator_1D_%lower_, self%values_(size(self%values_) - size(self%divergence_operator_1D_%lower_,2) + 1 : )) &
        ]
      end associate
    end associate
  end procedure

#else

  module procedure apply_divergence_1D

    integer row
    double precision, allocatable :: product_inner(:)

    associate(upper_rows => size(self%divergence_operator_1D_%upper_,1), lower_rows => size(self%divergence_operator_1D_%lower_,1))
      associate(inner_rows => size(self%values_) - (upper_rows + lower_rows + 1))

        allocate(product_inner(inner_rows))

        do concurrent(integer :: row = 1 : inner_rows)
          product_inner(row) = dot_product(self%divergence_operator_1D_%inner_, self%values_(row : row + size(self%divergence_operator_1D_%inner_) - 1))
        end do

        matvec_product = [ &
           matmul(self%divergence_operator_1D_%upper_, self%values_(1 : size(self%divergence_operator_1D_%upper_,2))) &
          ,product_inner &
          ,matmul(self%divergence_operator_1D_%lower_, self%values_(size(self%values_) - size(self%divergence_operator_1D_%lower_,2) + 1 : )) &
        ]
      end associate
    end associate
  end procedure

#endif

end submodule vector_1D_s
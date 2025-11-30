#include "julienne-assert-macros.h"

submodule(tensors_1D_m) scalar_1D_s
  use julienne_m, only : call_julienne_assert_, operator(.greaterThan.), operator(.isAtLeast.)
  implicit none

contains

  module procedure construct_1D_scalar_from_function
    call_julienne_assert(x_max .greaterThan. x_min)
    call_julienne_assert(cells .isAtLeast. 2*order)

    associate(values => initializer(cell_centers_extended(x_min, x_max, cells)))
      scalar_1D%tensor_1D_t = tensor_1D_t(values, x_min, x_max, cells, order)
    end associate
    scalar_1D%gradient_operator_1D_ = gradient_operator_1D_t(k=order, dx=(x_max - x_min)/cells, cells=cells)
  end procedure

  module procedure grad
    gradient_1D = vector_1D_t( &
       tensor_1D_t(self%apply_gradient_1D(), self%x_min_, self%x_max_, self%cells_, self%order_) &
      ,divergence_operator_1D_t(self%order_, (self%x_max_-self%x_min_)/self%cells_, self%cells_) &
    )
  end procedure

  module procedure laplacian
    laplacian_1D = .div. (.grad. self)
  end procedure

  module procedure scalar_1D_values
    my_values = self%values_
  end procedure

  pure function cell_centers(x_min, x_max, cells) result(x)
    double precision, intent(in) :: x_min, x_max
    integer, intent(in) :: cells
    double precision, allocatable:: x(:)
    integer cell

    associate(dx => (x_max - x_min)/cells)
      x = x_min + dx/2. + [((cell-1)*dx, cell = 1, cells)]
    end associate
  end function

  pure function cell_centers_extended(x_min, x_max, cells) result(x)
    double precision, intent(in) :: x_min, x_max
    integer, intent(in) :: cells
    double precision, allocatable:: x(:)
    integer cell

    associate(dx => (x_max - x_min)/cells)
      x = [x_min, cell_centers(x_min, x_max, cells), x_max]
    end associate
  end function

  module procedure scalar_1D_grid
    x = cell_centers(self%x_min_, self%x_max_, self%cells_)
  end procedure

#if HAVE_DO_CONCURRENT_TYPE_SPEC_SUPPORT && HAVE_LOCALITY_SPECIFIER_SUPPORT

  module procedure apply_gradient_1D

    double precision, allocatable :: product_inner(:)

    associate(upper => size(self%gradient_operator_1D_%upper_,1), lower => size(self%gradient_operator_1D_%lower_,1))
      associate(inner_rows => size(self%values_) - (upper + lower + 1))

        allocate(product_inner(inner_rows))

        do concurrent(integer :: row = 1 : inner_rows) default(none) shared(product_inner, self%gradient_operator_1D_, self)
          product_inner(row) = dot_product(self%gradient_operator_1D_%inner_, self%values_(row + 1 : row + size(self%gradient_operator_1D_%inner_)))
        end do

        matvec_product = [ &
           matmul(self%gradient_operator_1D_%upper_, self%values_(1 : size(self%gradient_operator_1D_%upper_,2))) &
          ,product_inner &
          ,matmul(self%gradient_operator_1D_%lower_, self%values_(size(self%values_) - size(self%gradient_operator_1D_%lower_,2) + 1 : )) &
        ]
      end associate
    end associate
  end procedure

#else

  module procedure apply_gradient_1D

    integer row
    double precision, allocatable :: product_inner(:)

    associate(upper => size(self%gradient_operator_1D_%upper_,1), lower => size(self%gradient_operator_1D_%lower_,1))
      associate(inner_rows => size(self%values_) - (upper + lower + 1))

        allocate(product_inner(inner_rows))

        do concurrent(row = 1 : inner_rows)
          product_inner(row) = dot_product(self%gradient_operator_1D_%inner_, self%values_(row + 1 : row + size(self%gradient_operator_1D_%inner_)))
        end do

        matvec_product = [ &
           matmul(self%gradient_operator_1D_%upper_, self%values_(1 : size(self%gradient_operator_1D_%upper_,2))) &
          ,product_inner &
          ,matmul(self%gradient_operator_1D_%lower_, self%values_(size(self%values_) - size(self%gradient_operator_1D_%lower_,2) + 1 : )) &
        ]
      end associate
    end associate
  end procedure

#endif

end submodule scalar_1D_s
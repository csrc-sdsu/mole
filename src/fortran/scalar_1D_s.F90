#include "julienne-assert-macros.h"

submodule(scalar_vector_1D_m) scalar_1D_s
  use julienne_m, only : call_julienne_assert_, operator(.greaterThan.), operator(.isAtLeast.), string_t, operator(.csv.)
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
    associate( &
       gradient_values => matvec(self%gradient_operator_1D_%mimetic_matrix_1D_t, self) &
      ,divergence_operator_1D => divergence_operator_1D_t(self%order_, (self%x_max_-self%x_min_)/self%cells_, self%cells_) &
    )
      gradient_1D = vector_1D_t(tensor_1D_t(gradient_values, self%x_min_, self%x_max_, self%cells_, self%order_), divergence_operator_1D)
    end associate
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

  module procedure mimetic_matrix_scalar_1D_product

    double precision, allocatable :: product_inner(:)

    associate(upper => size(self%upper_,1), lower => size(self%lower_,1))
      associate(inner_rows => size(scalar_1D%values_) - (upper + lower + 1))

        allocate(product_inner(inner_rows))

        do concurrent(integer :: row = 1 : inner_rows) default(none) shared(product_inner, self, scalar_1D)
          product_inner(row) = dot_product(self%inner_, scalar_1D%values_(row + 1 : row + size(self%inner_)))
        end do

        matvec_product = [ &
           matmul(self%upper_, scalar_1D%values_(1 : size(self%upper_,2))) &
          ,product_inner &
          ,matmul(self%lower_, scalar_1D%values_(size(scalar_1D%values_) - size(self%lower_,2) + 1 : )) &
        ]
      end associate
    end associate
  end procedure

#else

  module procedure mimetic_matrix_scalar_1D_product

    integer row
    double precision, allocatable :: product_inner(:)

    associate(upper => size(self%upper_,1), lower => size(self%lower_,1))
      associate(inner_rows => size(scalar_1D%values_) - (upper + lower + 1))

        allocate(product_inner(inner_rows))

        do concurrent(row = 1 : inner_rows)
          product_inner(row) = dot_product(self%inner_, scalar_1D%values_(row + 1 : row + size(self%inner_)))
        end do

        matvec_product = [ &
           matmul(self%upper_, scalar_1D%values_(1 : size(self%upper_,2))) &
          ,product_inner &
          ,matmul(self%lower_, scalar_1D%values_(size(scalar_1D%values_) - size(self%lower_,2) + 1 : )) &
        ]
      end associate
    end associate
  end procedure

#endif

end submodule scalar_1D_s
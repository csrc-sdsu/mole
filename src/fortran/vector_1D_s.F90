#include "julienne-assert-macros.h"

submodule(scalar_vector_1D_m) vector_1D_s
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
    associate(divergence_values => matvec(self%divergence_operator_1D_%mimetic_matrix_1D_t, self))
      associate( &
         tensor_1D => tensor_1D_t(divergence_values, self%x_min_, self%x_max_, self%cells_, self%order_) &
        ,gradient_operator_1D => gradient_operator_1D_t(k=self%order_, dx=(self%x_max_ - self%x_min_)/self%cells_, cells=self%cells_) &
      )
        divergence_1D = scalar_1D_t(tensor_1D, gradient_operator_1D)
      end associate
    end associate
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

  module procedure mimetic_matrix_vector_1D_product

    double precision, allocatable :: product_inner(:)

    associate(upper_rows => size(self%upper_,1), lower_rows => size(self%lower_,1))
      associate(inner_rows => size(vector_1D%values_) - (upper_rows + lower_rows + 1))

        allocate(product_inner(inner_rows))

        do concurrent(integer :: row = 1 : inner_rows) default(none) shared(product_inner, self, vector_1D)
          product_inner(row) = dot_product(self%inner_, vector_1D%values_(row : row + size(self%inner_) - 1)) 
        end do

        matvec_product = [ &
           matmul(self%upper_, vector_1D%values_(1 : size(self%upper_,2))) &
          ,product_inner &
          ,matmul(self%lower_, vector_1D%values_(size(vector_1D%values_) - size(self%lower_,2) + 1 : )) &
        ]
      end associate
    end associate
  end procedure

#else

  module procedure mimetic_matrix_vector_1D_product

    integer row
    double precision, allocatable :: product_inner(:)

    associate(upper_rows => size(self%upper_,1), lower_rows => size(self%lower_,1))
      associate(inner_rows => size(vector_1D%values_) - (upper_rows + lower_rows + 1))

        allocate(product_inner(inner_rows))

        do concurrent(row = 1 : inner_rows)
          product_inner(row) = dot_product(self%inner_, vector_1D%values_(row : row + size(self%inner_) - 1)) 
        end do

        matvec_product = [ &
           matmul(self%upper_, vector_1D%values_(1 : size(self%upper_,2))) &
          ,product_inner &
          ,matmul(self%lower_, vector_1D%values_(size(vector_1D%values_) - size(self%lower_,2) + 1 : )) &
        ]
      end associate
    end associate
  end procedure

#endif

end submodule vector_1D_s
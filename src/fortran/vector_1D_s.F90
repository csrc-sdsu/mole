#include "julienne-assert-macros.h"

submodule(tensors_1D_m) vector_1D_s
  use julienne_m, only : &
     call_julienne_assert_ &
    ,operator(//) &
    ,operator(.all.) &
    ,operator(.approximates.) &
    ,operator(.csv.) &
    ,operator(.cat.) &
    ,operator(.sv.) &
    ,operator(.equalsExpected.) &
    ,operator(.isAtLeast.) &
    ,operator(.greaterThan.) &
    ,operator(.within.)
  implicit none

   double precision, parameter :: double_equivalence = 2D-4

contains

  module procedure dot_surface_normal
     v_dot_dS%tensor_1D_t = tensor_1D_t(vector_1D%values_*dS, vector_1D%x_min_, vector_1D%x_max_, vector_1D%cells_, vector_1D%order_)
     v_dot_dS%divergence_operator_1D_ = vector_1D%divergence_operator_1D_
  end procedure

#ifndef __GFORTRAN__

  module procedure construct_1D_vector_from_function
    call_julienne_assert(x_max .greaterThan. x_min)
    call_julienne_assert(cells .isAtLeast. 2*order+1)

    associate(values => initializer(faces(x_min, x_max, cells)))
      vector_1D%tensor_1D_t = tensor_1D_t(values, x_min, x_max, cells, order)
    end associate
    vector_1D%divergence_operator_1D_ = divergence_operator_1D_t(k=order, dx=(x_max - x_min)/cells, cells=cells)
  end procedure

#else

  pure module function construct_1D_vector_from_function(initializer, order, cells, x_min, x_max) result(vector_1D)
    procedure(vector_1D_initializer_i), pointer :: initializer
    integer, intent(in) :: order !! order of accuracy
    integer, intent(in) :: cells !! number of grid cells spanning the domain
    double precision, intent(in) :: x_min !! grid location minimum
    double precision, intent(in) :: x_max !! grid location maximum
    type(vector_1D_t) vector_1D

    call_julienne_assert(x_max .greaterThan. x_min)
    call_julienne_assert(cells .isAtLeast. 2*order+1)

    associate(values => initializer(faces(x_min, x_max, cells)))
      vector_1D%tensor_1D_t = tensor_1D_t(values, x_min, x_max, cells, order)
    end associate
    vector_1D%divergence_operator_1D_ = divergence_operator_1D_t(k=order, dx=(x_max - x_min)/cells, cells=cells)
  end function

#endif

  module procedure construct_from_components
    vector_1D%tensor_1D_t = tensor_1D
    vector_1D%divergence_operator_1D_ = divergence_operator_1D
  end procedure

  module procedure div

    integer center

    associate(D => (self%divergence_operator_1D_))
      associate(Dv => D .x. self%values_)
        divergence_1D%tensor_1D_t = tensor_1D_t(Dv(2:size(Dv)-1), self%x_min_, self%x_max_, self%cells_, self%order_)
        associate( &
           q  => divergence_1D%weights() &
          ,dx => (self%x_max_ - self%x_min_)/self%cells_ &
          ,b => [-1D0, [(0D0, center = 1, self%cells_-1)], 1D0] &
        )
          call_julienne_assert(.all. ([size(Dv), size(q)] .equalsExpected. self%cells_+2))
          call_julienne_assert((.all. (matmul(transpose(D%assemble()), q) .approximates. b/dx .within. double_equivalence)))
            ! Check D^T * a = b_{m+1},  Eq. (19), Corbino & Castillo (2020)
        end associate
      end associate
    end associate

  end procedure

  module procedure vector_1D_values
    face_centered_values = self%values_
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

  module procedure weighted_premultiply

                           !! vector values at faces                   scalar values at cell centers + boundaries
    call_julienne_assert(size(vector_1D%values_) .equalsExpected. size(scalar_1D%values_)-1)
    call_julienne_assert(     vector_1D%cells_   .equalsExpected.       scalar_1D%cells_ )
    call_julienne_assert(     vector_1D%order_   .equalsExpected.       scalar_1D%order_ )
    call_julienne_assert(vector_1D%x_min_ .approximates. scalar_1D%x_min_ .within. double_equivalence)
    call_julienne_assert(vector_1D%x_max_ .approximates. scalar_1D%x_max_ .within. double_equivalence)

    associate( &
      q => vector_1D%divergence_1D_weights() &
     ,p => vector_1D%gradient_1D_weights() &
     ,D => vector_1D%divergence_operator_1D_%assemble() &
     ,G => scalar_1D%gradient_operator_1D_%assemble() &
     ,m => scalar_1D%cells_ &
    )
      call_julienne_assert(.all. (shape(G) .equalsExpected. [m+1,m+2]))
      call_julienne_assert(.all. (shape(D) .equalsExpected. [m+2,m+1]))
      associate( &
         QD => premultiply_diagonal(q,D) &
        ,GTP => postmultiply_diagonal(transpose(G),p) &
        ,dx => vector_1D%dx() &
      )
        call_julienne_assert(.all. (shape(QD) .equalsExpected. shape(GTP)))
        associate(B => QD + GTP) ! Eq. (7), Corbino & Castillo (2020)
          weighted_product_1D%tensor_1D_t = &
            tensor_1D_t(dx * matmul(B,vector_1D%values_) * scalar_1D%values_, vector_1D%x_min_, vector_1D%x_max_, vector_1D%cells_, vector_1D%order_)
        end associate
      end associate
    end associate

  contains

    pure function premultiply_diagonal(d,A) result(DA)
      double precision, intent(in) :: d(:), A(:,:)
      double precision, allocatable :: DA(:,:)

      call_julienne_assert(size(d) .equalsExpected. size(A,1))

      allocate(DA, mold=A)

#ifdef HAVE_DO_CONCURRENT_TYPE_SPEC_SUPPORT && HAVE_LOCALITY_SPECIFIER_SUPPORT
      do concurrent(integer :: row = 1 : size(A,1)) default(none) shared(d, A, DA)
        DA(row,:) = d(row) * A(row,:)
      end do
#else
      block
        integer row
        do concurrent(row = 1 : size(A,1))
          DA(row,:) = d(row) * A(row,:)
        end do
      end block
#endif

    end function

    pure function postmultiply_diagonal(A,d) result(AD)
      double precision, intent(in) :: A(:,:), d(:)
      double precision, allocatable :: AD(:,:)

      call_julienne_assert(size(d) .equalsExpected. size(A,2))

      allocate(AD, mold=A)

#ifdef HAVE_DO_CONCURRENT_TYPE_SPEC_SUPPORT && HAVE_LOCALITY_SPECIFIER_SUPPORT
      do concurrent(integer :: column = 1 : size(A,2)) default(none) shared(d, A, AD)
        AD(:,column) = A(:,column) * d(column)
      end do
#else
      block
        integer column
        do concurrent(column = 1 : size(A,2))
          AD(:,column) = A(:,column) * d(column)
        end do
      end block
#endif

    end function

  end procedure

  module procedure dA
    dA = 1D0
  end procedure

end submodule vector_1D_s
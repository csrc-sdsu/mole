module tensors_1D_m
  !! Define 1D scalar and vector abstractions and associated mimetic gradient
  !! and divergence operators.
  use julienne_m, only : file_t
  implicit none

  private
  public :: gradient_1D_t
  public :: scalar_1D_t
  public :: scalar_1D_initializer_i

  abstract interface

    pure function scalar_1D_initializer_i(x) result(f)
      implicit none
      double precision, intent(in) :: x(:)
      double precision, allocatable :: f(:)
    end function

  end interface

  type mimetic_matrix_1D_t
    !! Encapsulate a mimetic matrix with a corresponding matrix-vector product operator
    private
    double precision, allocatable :: upper_(:,:), inner_(:), lower_(:,:)
  contains
    procedure, non_overridable :: to_file_t
  end type

  type gradient_operator_1D_t
    !! Encapsulate kth-order mimetic gradient operator on dx-sized cells
    private
    integer k_, m_
    double precision dx_
    type(mimetic_matrix_1D_t) mimetic_matrix_1D_
  end type

  type scalar_1D_t
    !! Encapsulate information at cell centers and boundaries
    private
    double precision, allocatable :: scalar_1D_(:)
    double precision x_min_, x_max_
    integer cells_
    type(gradient_operator_1D_t) gradient_operator_1D_
  contains
    procedure, non_overridable :: grid
    generic :: operator(.grad.) => grad
    procedure, non_overridable, private :: grad
  end type

  type, extends(scalar_1D_t) :: divergence_1D_t
  end type

  type vector_1D_t
    !! Encapsulate gradient_1D values produced only by .grad. (no other constructors)
    private
    double precision, allocatable :: vector_1D_(:) !! gradient_1D values at cell faces (nodes in 1D)
    double precision x_min_ !! domain lower boundary
    double precision x_max_ !! domain upper boundary
    integer cells_ !! number of grid cells spanning the domain
  contains
    procedure, non_overridable :: values
    procedure, non_overridable :: faces
  end type

  type, extends(vector_1D_t) :: gradient_1D_t
  end type

  interface

     pure module function to_file_t(self) result(file)
       implicit none
       class(mimetic_matrix_1D_t), intent(in) :: self
       type(file_t) file
     end function

  end interface

  interface scalar_1D_t

    pure module function construct_1D_scalar_from_function(initializer, order, cells, x_min, x_max) result(scalar_1D)
      !! Result is a collection of cell-centered-extended values with a corresponding mimetic gradient operator
      implicit none
      procedure(scalar_1D_initializer_i), pointer :: initializer 
      integer, intent(in) :: order !! order of accuracy
      integer, intent(in) :: cells !! number of grid cells spanning the domain
      double precision, intent(in) :: x_min !! grid location minimum
      double precision, intent(in) :: x_max !! grid location maximum
      type(scalar_1D_t) scalar_1D
    end function

  end interface

  interface

    pure module function grid(self) result(x)
      !! Result is array of cell-centers-extended grid locations (cell centers + boundaries) 
      !! as described in Corbino & Castillo (2020) https://doi.org/10.1016/j.cam.2019.06.042
      implicit none
      class(scalar_1D_t), intent(in) :: self
      double precision, allocatable :: x(:)
    end function

    pure module function grad(self) result(grad_f)
      !! Result is mimetic gradient of f
      implicit none
      class(scalar_1D_t), intent(in) :: self
      type(gradient_1D_t) grad_f !! discrete gradient approximation
    end function

  end interface

  interface gradient_operator_1D_t

    pure module function construct_1D_gradient_operator(k, dx, cells) result(gradient_operator_1D)
      !! Construct a mimetic gradient operator
      implicit none
      integer, intent(in) :: k !! order of accuracy
      double precision, intent(in) :: dx !! step size
      integer, intent(in) :: cells !! number of grid cells
      type(gradient_operator_1D_t) gradient_operator_1D
    end function

  end interface

  interface mimetic_matrix_1D_t

    pure module function construct_matrix_operator(upper, inner, lower) result(mimetic_matrix_1D)
      !! Construct discrete operator from matrix blocks
      implicit none
      double precision, intent(in) :: upper(:,:) !! A block matrix (cf. Corbino & Castillo, 2020)
      double precision, intent(in) :: inner(:)   !! M matrix (cf. Corbino & Castillo, 2020) - stored as 1 row of a Toeplitz matrix
      double precision, intent(in) :: lower(:,:) !! A' block matrix  (cf. Corbino & Castillo, 2020)
      type(mimetic_matrix_1D_t) mimetic_matrix_1D
    end function

  end interface

  interface

    pure module function matvec(self, scalar_1D) result(matvec_product)
      !! Apply a mimetic matrix operator to a vector encapsulated in a scalar_1D_t object
      implicit none
      class(mimetic_matrix_1D_t), intent(in) :: self
      type(scalar_1D_t), intent(in) :: scalar_1D
      double precision, allocatable :: matvec_product(:)
    end function

  end interface

  interface gradient_1D_t

      pure module function construct_from_components(face_centered_values, x_min, x_max, cells) result(gradient_1D)
        !! Result is an object storing gradient_1Ds at cell faces
        implicit none
        double precision, intent(in) :: face_centered_values(:), x_min, x_max
        integer, intent(in) :: cells
        type(gradient_1D_t) gradient_1D
      end function

  end interface

  interface

    pure module function faces(self) result(x)
      implicit none
      class(vector_1D_t), intent(in) :: self
      double precision, allocatable :: x(:)
    end function

     pure module function values(self) result(gradients)
       implicit none
       class(vector_1D_t), intent(in) :: self
       double precision, allocatable :: gradients(:)
     end function

    pure module function cell_centers_extended(x_min, x_max, cells) result(x)
      implicit none
      double precision, intent(in) :: x_min, x_max
      integer, intent(in) :: cells
      double precision, allocatable :: x(:)
    end function

  end interface

contains

#if HAVE_DO_CONCURRENT_TYPE_SPEC_SUPPORT && HAVE_LOCALITY_SPECIFIER_SUPPORT

  pure function negate_and_flip(A) result(Ap)
    double precision, intent(in) :: A(:,:)
    double precision, allocatable :: Ap(:,:)

      allocate(Ap , mold=A)
      reverse_elements_within_rows_and_flip_sign: &
      do concurrent(integer :: row = 1:size(Ap,1)) default(none) shared(Ap, A)
        Ap(row,:) = -A(row,size(A,2):1:-1)
      end do reverse_elements_within_rows_and_flip_sign
      reverse_elements_within_columns: &
      do concurrent(integer :: column = 1 : size(Ap,2)) default(none) shared(Ap)
        Ap(:,column) = Ap(size(Ap,1):1:-1,column)
      end do reverse_elements_within_columns
  end function
 
#else

  pure function negate_and_flip(A) result(Ap)
    double precision, intent(in) :: A(:,:)
    double precision, allocatable :: Ap(:,:)
    integer row, column

      allocate(Ap , mold=A)
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
end module tensors_1D_m
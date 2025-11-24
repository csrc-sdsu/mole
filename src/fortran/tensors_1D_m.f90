module tensors_1D_m
  !! Define 1D scalar and vector abstractions and associated mimetic gradient
  !! and divergence operators.
  use julienne_m, only : file_t
  implicit none

  private
  public :: scalar_1D_t
  public :: vector_1D_t
  public :: gradient_1D_t
  public :: divergence_1D_t
  public :: scalar_1D_initializer_i
  public :: vector_1D_initializer_i

  abstract interface

    pure function scalar_1D_initializer_i(x) result(f)
      !! Sampling function for initializing a scalar_1D_t object
      implicit none
      double precision, intent(in) :: x(:)
      double precision, allocatable :: f(:)
    end function

    pure function vector_1D_initializer_i(x) result(v)
      !! Sampling function for initializing a vector_1D_t object
      implicit none
      double precision, intent(in) :: x(:)
      double precision, allocatable :: v(:)
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
    !! Encapsulate kth-order mimetic gradient operator on m_ cells of width dx
    private
    integer k_, m_
    double precision dx_
    type(mimetic_matrix_1D_t) mimetic_matrix_1D_
  end type

  type divergence_operator_1D_t
    !! Encapsulate kth-order mimetic divergence operator on m_ cells of width dx
    private
    integer k_, m_
    double precision dx_
    type(mimetic_matrix_1D_t) mimetic_matrix_1D_
  end type

  type tensor_1D_t
    private
    double precision x_min_ !! domain lower boundary
    double precision x_max_ !! domain upper boundary
    integer cells_          !! number of grid cells spanning the domain
    integer order_          !! order of accuracy of mimetic discretization
    double precision, allocatable :: values_(:) !! tensor components at spatial locations
  end type

  type, extends(tensor_1D_t) :: scalar_1D_t
    !! Encapsulate information at cell centers and boundaries
    private
    type(gradient_operator_1D_t) gradient_operator_1D_
  contains
    generic :: values => scalar_1D_values
    procedure, non_overridable :: scalar_1D_values
    generic :: operator(.grad.) => grad
    procedure, non_overridable, private :: grad
    generic :: grid => cell_centers_extended
    procedure :: cell_centers_extended
  end type

  type, extends(scalar_1D_t) :: divergence_1D_t
  end type

  type, extends(tensor_1D_t) :: vector_1D_t
    !! Encapsulate 1D vector values at cell faces (nodes in 1D) and corresponding operators
    private
    type(divergence_operator_1D_t) divergence_operator_1D_
  contains
    generic :: values => vector_1D_values
    procedure, non_overridable :: vector_1D_values
    generic :: grid => faces
    procedure :: faces
    generic :: operator(.div.) => div
    procedure, non_overridable, private :: div
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

  interface tensor_1D_t

    pure module function construct_1D_tensor_from_components(values, x_min, x_max, cells, order) result(tensor_1D)
      !! Result is a collection of cell-centered-extended values with a corresponding mimetic gradient operator
      implicit none
      double precision, intent(in) :: values(:) !! tensor components at grid locations define by child
      double precision, intent(in) :: x_min     !! grid location minimum
      double precision, intent(in) :: x_max     !! grid location maximum
      integer,          intent(in) :: cells     !! number of grid cells spanning the domain
      integer,          intent(in) :: order     !! order of accuracy
      type(tensor_1D_t) tensor_1D
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

  interface vector_1D_t

    pure module function construct_1D_vector_from_function(initializer, order, cells, x_min, x_max) result(vector_1D)
      !! Result is a collection of cell-centered-extended values with a corresponding mimetic gradient operator
      implicit none
      procedure(vector_1D_initializer_i), pointer :: initializer 
      integer, intent(in) :: order !! order of accuracy
      integer, intent(in) :: cells !! number of grid cells spanning the domain
      double precision, intent(in) :: x_min !! grid location minimum
      double precision, intent(in) :: x_max !! grid location maximum
      type(vector_1D_t) vector_1D
    end function

  end interface

  interface

    pure module function scalar_1D_values(self) result(my_values)
      !! Result is self's array of the 1D scalar values at cell centers
      implicit none
      class(scalar_1D_t), intent(in) :: self
      double precision, allocatable :: my_values(:)
    end function

    pure module function faces(self) result(cell_faces)
      !! Result is the array of cell face locations (nodes in 1D) at which self's values are defined
      implicit none
      class(vector_1D_t), intent(in) :: self
      double precision, allocatable :: cell_faces(:)
    end function

    pure module function vector_1D_values(self) result(my_values)
      !! Result is self's array of the 1D scalar values at cell faces (nodes in 1D)
      implicit none
      class(vector_1D_t), intent(in) :: self
      double precision, allocatable :: my_values(:)
    end function

    pure module function grad(self) result(gradient_1D)
      !! Result is mimetic gradient of the scalar_1D_t "self"
      implicit none
      class(scalar_1D_t), intent(in) :: self
      type(gradient_1D_t) gradient_1D !! discrete gradient
    end function

    pure module function cell_centers_extended(self) result(x)
      implicit none
      class(scalar_1D_t), intent(in) :: self
      double precision, allocatable :: x(:)
    end function

    pure module function div(self) result(divergence_1D)
      !! Result is mimetic divergence of the vector_1D_t "self"
      implicit none
      class(vector_1D_t), intent(in) :: self
      type(divergence_1D_t) divergence_1D !! discrete divergence
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

  interface divergence_operator_1D_t

    pure module function construct_1D_divergence_operator(k, dx, cells) result(divergence_operator_1D)
      !! Construct a mimetic gradient operator
      implicit none
      integer, intent(in) :: k !! order of accuracy
      double precision, intent(in) :: dx !! step size
      integer, intent(in) :: cells !! number of grid cells
      type(divergence_operator_1D_t) divergence_operator_1D
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

  interface matvec

    pure module function mimetic_matrix_scalar_1D_product(self, scalar_1D) result(matvec_product)
      !! Apply a mimetic matrix operator to a vector encapsulated in a scalar_1D_t object
      implicit none
      class(mimetic_matrix_1D_t), intent(in) :: self
      type(scalar_1D_t), intent(in) :: scalar_1D
      double precision, allocatable :: matvec_product(:)
    end function

    pure module function mimetic_matrix_vector_1D_product(self, vector_1D) result(matvec_product)
      !! Apply a mimetic matrix operator to a vector encapsulated in a scalar_1D_t object
      implicit none
      class(mimetic_matrix_1D_t), intent(in) :: self
      type(vector_1D_t), intent(in) :: vector_1D
      double precision, allocatable :: matvec_product(:)
    end function

  end interface

  interface gradient_1D_t

      pure module function construct_gradient_from_components(face_centered_values, x_min, x_max, cells) result(gradient_1D)
        !! Result is an object storing gradient_1Ds at cell faces
        implicit none
        double precision, intent(in) :: face_centered_values(:), x_min, x_max
        integer, intent(in) :: cells
        type(gradient_1D_t) gradient_1D
      end function

  end interface

  interface divergence_1D_t

      pure module function construct_divergence_from_components(cell_centered_values, x_min, x_max, cells) result(divergence_1D)
        !! Result is an object storing gradient_1Ds at cell faces
        implicit none
        double precision, intent(in) :: cell_centered_values(:), x_min, x_max
        integer, intent(in) :: cells
        type(divergence_1D_t) divergence_1D
      end function

  end interface

contains

#if HAVE_DO_CONCURRENT_TYPE_SPEC_SUPPORT && HAVE_LOCALITY_SPECIFIER_SUPPORT

  pure function negate_and_flip(A) result(Ap)
    !! Transform a mimetic matrix upper block into a lower block
    double precision, intent(in) :: A(:,:)
    double precision, allocatable :: Ap(:,:)

    allocate(Ap, mold=A)

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

end module tensors_1D_m
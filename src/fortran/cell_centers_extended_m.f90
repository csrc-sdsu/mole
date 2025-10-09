module cell_centers_extended_m
  !! Define an abstraction for the collection of points used to compute gradidents:
  !! cell centers plus oundaries.
  use gradient_m, only : gradient_t
  implicit none

  private
  public :: cell_centers_extended_t
  public :: gradient_operator_t
  public :: scalar_1D_initializer_i

  abstract interface

    pure function scalar_1D_initializer_i(x) result(f)
      implicit none
      double precision, intent(in) :: x(:)
      double precision, allocatable :: f(:)
    end function

  end interface

  type mimetic_matrix_t
    !! Encapsulate a mimetic matrix with a corresponding matrix-vector product operator
    private
    double precision, allocatable :: upper_(:,:), inner_(:), lower_(:,:)
  end type

  type gradient_operator_t
    !! Encapsulate kth-order mimetic gradient operator on dx-sized cells
    private
    integer k_, m_
    double precision dx_
    type(mimetic_matrix_t) mimetic_matrix_
  end type

  type cell_centers_extended_t
    !! Encapsulate information at cell centers and boundaries
    private
    double precision, allocatable :: scalar_1D_(:)
    double precision x_min_, x_max_
    integer cells_
    type(gradient_operator_t) gradient_operator_
  contains
    procedure grid
    generic :: operator(.grad.) => grad
    procedure, non_overridable, private :: grad
  end type

  interface cell_centers_extended_t

    pure module function construct_from_function(initializer, order, cells, x_min, x_max) result(cell_centers_extended)
      !! Result is a collection of cell-centered-extended values with a corresponding mimetic gradient operator
      implicit none
      procedure(scalar_1D_initializer_i), pointer :: initializer 
      integer, intent(in) :: order !! order of accuracy
      integer, intent(in) :: cells !! number of grid cells spanning the domain
      double precision, intent(in) :: x_min !! grid location minimum
      double precision, intent(in) :: x_max !! grid location maximum
      type(cell_centers_extended_t) cell_centers_extended
    end function

  end interface

  interface

    pure module function grid(self) result(x)
      !! Result is array of cell-centers-extended grid locations (cell centers + boundaries) 
      !! as described in Corbino & Castillo (2020) https://doi.org/10.1016/j.cam.2019.06.042
      implicit none
      class(cell_centers_extended_t), intent(in) :: self
      double precision, allocatable :: x(:)
    end function

    pure module function grad(self) result(grad_f)
      !! Result is mimetic gradient of f
      implicit none
      class(cell_centers_extended_t), intent(in) :: self
      type(gradient_t) grad_f !! discrete gradient approximation
    end function

  end interface

  interface gradient_operator_t

    pure module function construct_from_parameters(k, dx, m) result(gradient_operator)
      !! Construct a mimetic gradient operator
      implicit none
      integer, intent(in) :: k !! order of accuracy
      double precision, intent(in) :: dx !! step siz
      integer, intent(in) :: m !! number of grid cells
      type(gradient_operator_t) gradient_operator
    end function

  end interface

  interface mimetic_matrix_t

    pure module function construct_from_components(upper, inner, lower) result(mimetic_matrix)
      !! Construct discrete operator from coefficient matrix
      implicit none
      double precision, intent(in) :: upper(:,:), inner(:), lower(:,:)
      type(mimetic_matrix_t) mimetic_matrix
    end function

  end interface

  interface

    pure module function matvec(self, vector) result(matvec_product)
      !! Apply a matrix operator to a vector
      implicit none
      class(mimetic_matrix_t), intent(in) :: self
      type(cell_centers_extended_t), intent(in) :: vector
      double precision, allocatable :: matvec_product(:)
    end function

  end interface

end module cell_centers_extended_m
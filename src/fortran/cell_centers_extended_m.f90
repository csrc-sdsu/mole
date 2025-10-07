module cell_centers_extended_m
  !! Define an abstraction for the collection of points used to compute gradidents:
  !! cell centers plus oundaries.
  use initializers_m, only : scalar_1D_initializer_t
  implicit none

  private
  public :: cell_centers_extended_t
  public :: gradient_t
  public :: gradient_operator_t

  type mimetic_matrix_t
    !! Encapsulate a mimetic matrix with a corresponding matrix-vector product operator
    private
    double precision, allocatable :: upper_(:,:), inner_(:), lower_(:,:)
  contains
    generic :: operator(.x.) => matvec
    procedure, private, non_overridable :: matvec
  end type

  type gradient_operator_t
    !! Encapsulate kth-order mimetic gradient operator on dx-sized cells
    private
    integer k_, m_
    double precision dx_
    type(mimetic_matrix_t) mimetic_matrix_
  end type

  type gradient_t
    !! Encapsulate gradient values produced only by .grad. (no other constructors)
    private
    double precision, allocatable :: g_(:)
  contains
    procedure values
  end type

  interface 

     pure module function values(self) result(gradients)
       implicit none
       class(gradient_t), intent(in) :: self
       double precision, allocatable :: gradients(:)
     end function

  end interface

  type cell_centers_extended_t
    !! Encapsulate information at cell centers and boundaries
    !private
    double precision, allocatable :: scalar_1D_(:), grid_(:)
    double precision x_min_, x_max_
    type(gradient_operator_t) gradient_operator_
  contains
    generic :: operator(.grad.) => grad
    procedure, non_overridable, private :: grad
  end type

  interface cell_centers_extended_t

    pure module function construct(scalar_1D_initializer, order, cells, x_min, x_max) result(cell_centers_extended)
      !! Result is a collection of cell-centered-extended values with a corresponding mimetic gradient operator
      implicit none
      class(scalar_1D_initializer_t), intent(in) :: scalar_1D_initializer !! elemental initialization function hook
      integer, intent(in) :: order !! order of accuracy
      integer, intent(in) :: cells !! number of grid cells spanning the domain
      double precision, intent(in) :: x_min !! grid location minimum
      double precision, intent(in) :: x_max !! grid location maximum
      type(cell_centers_extended_t) cell_centers_extended
    end function

  end interface

  interface

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

    pure module function matvec(self, vector) result(gradient)
      !! Apply a matrix operator to a vector
      implicit none
      class(mimetic_matrix_t), intent(in) :: self
      type(cell_centers_extended_t), intent(in) :: vector
      type(gradient_t) gradient
    end function

  end interface

end module cell_centers_extended_m
module cell_centers_extended_m
  !! Define an abstraction for face-centered values with a corresonding mimetic gradient operator
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
    integer k_
    double precision dx_
    type(mimetic_matrix_t) mimetic_matrix_
  end type

  type gradient_t
    !! Encapsulate gradient values produced only by .grad. (private data, no constructors)
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
    !! Face-centered values 
    private
    double precision, allocatable :: f_(:)
    type(gradient_operator_t) gradient_operator_
  contains
    generic :: operator(.grad.) => grad
    procedure, non_overridable, private :: grad
  end type

  interface cell_centers_extended_t

    pure module function construct(f, k, dx) result(cell_centers_extended)
      !! Result is a collection of face-centered values with a mimetic gradient operator
      implicit none
      double precision, intent(in) :: f(:) !! face-centered values
      double precision, intent(in) :: dx !! face spacing (cell width)
      integer, intent(in) :: k !! order of accuracy
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

    pure module function construct_from_parameters(k, dx) result(gradient_operator)
      !! Construct a mimetic gradient operator
      implicit none
      integer, intent(in) :: k !! order of accuracy
      double precision, intent(in) :: dx !! step size
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
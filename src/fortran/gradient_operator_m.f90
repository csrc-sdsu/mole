module gradient_operator_m
  !! Define a mimetic gradient operator abstraction
  use mimetic_matrix_m, only : mimetic_matrix_t
  use face_values_m, only : face_values_t
  implicit none

  private
  public :: gradient_operator_t, gradient_t

  type gradient_t
    double precision, allocatable :: g_(:)
  end type

  type gradient_operator_t
    !! Encapsulate mimetic gradient operator values and generic operators
    private
    type(mimetic_matrix_t) mimetic_matrix_
    integer k_, m_
    double precision dx_
  contains
    generic :: operator(.grad.) => gradient
    procedure, private, non_overridable :: gradient
  end type

  interface gradient_operator_t

    pure module function construct_from_parameters(k, m, dx) result(gradient_operator)
      !! Construct a mimetic gradient operator
      implicit none
      integer, intent(in) :: k !! order of accuracy
      integer, intent(in) :: m !! number of cells
      double precision, intent(in) :: dx !! step size
      type(gradient_operator_t) gradient_operator
    end function

  end interface

  interface

    pure module function gradient(self, f) result(grad_f)
      !! Result is mimetic gradient of f
      implicit none
      class(gradient_operator_t), intent(in) :: self
      type(face_values_t), intent(in) :: f
      type(gradient_t) grad_f !! discrete gradient approximation
    end function

  end interface

end module gradient_operator_m
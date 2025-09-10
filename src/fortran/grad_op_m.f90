module grad_op_m
  !! Define a mimetic gradient operator abstraction
  implicit none

  private
  public :: grad_op_t

  type grad_op_t
    !! Encapsulate mimetic gradient operator values and defined operations
    private
    double precision, allocatable :: coeffs_(:,:)
    integer k_, m_
    double precision dx_
  end type

  interface grad_op_t
    
    pure module function grad_op_1D(k, m, dx) result(grad_op)
      !! Define a 
      implicit none
      integer, intent(in) :: k !! order of accuracy
      integer, intent(in) :: m !! number of cells
      double precision, intent(in) :: dx !! step size
      type(grad_op_t) grad_op
    end function

  end interface
  
end module grad_op_m

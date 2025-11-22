module gradient_1D_m
  !! Define an abstraction for the collection of points used to compute gradidents:
  !! cell centers plus oundaries.
  implicit none

  private
  public :: gradient_1D_t

  type gradient_1D_t
    !! Encapsulate gradient_1D values produced only by .grad. (no other constructors)
    private
    double precision, allocatable :: vector_1D_(:) !! gradient_1D values at cell faces (nodes in 1D)
    double precision x_min_ !! domain lower boundary
    double precision x_max_ !! domain upper boundary
    integer cells_ !! number of grid cells spanning the domain
  contains
    procedure values
    procedure faces
  end type

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
      class(gradient_1D_t), intent(in) :: self
      double precision, allocatable :: x(:)
    end function

     pure module function values(self) result(gradients)
       implicit none
       class(gradient_1D_t), intent(in) :: self
       double precision, allocatable :: gradients(:)
     end function

  end interface

end module gradient_1D_m
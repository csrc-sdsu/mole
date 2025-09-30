module face_values_m
  !! Define a mimetic gradient operator abstraction
  implicit none

  private
  public :: face_values_t

  type face_values_t
    !! Face-centered values
    double precision, allocatable :: f_(:)
  end type

end module face_values_m
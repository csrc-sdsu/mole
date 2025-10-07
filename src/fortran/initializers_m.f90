module initializers_m
  !! Implement a workaround for the Fortran standard's prohibition against
  !! elemental procedures as dummy arguments. Users can extend the abstract
  !! type(s) in this module and define the deferred binding as an elemental
  !! function for use in initializing variables at grid locations without
  !! requiring loops.
  implicit none

  private
  public :: scalar_1D_initializer_t

  abstract interface

    elemental function scalar_1D_initializer_i(x) result(f)
      implicit none
      double precision, intent(in) :: x 
      double precision f
    end function

  end interface

  type, abstract :: scalar_1D_initializer_t
    !! Define a hook on which to hang elemental grid-variable initializers
  contains
    procedure(scalar_1D_initializer_i), deferred, nopass :: f
  end type

end module initializers_m

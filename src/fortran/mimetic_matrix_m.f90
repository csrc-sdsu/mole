module mimetic_matrix_m
  !! Define a matrix format specialized to storing coefficients for mimetic operators
  use face_values_m, only : face_values_t
  implicit none

  private
  public :: mimetic_matrix_t

  type mimetic_matrix_t
    !! Encapsulate matrix rows and operations
    private
    double precision, allocatable :: upper_(:,:), inner_(:), lower_(:,:)
  contains
    generic :: operator(.x.) => mimetic_matrix_x_vector
    procedure, private, non_overridable :: mimetic_matrix_x_vector
  end type

  interface mimetic_matrix_t

    pure module function construct_from_components(upper, inner, lower) result(mimetic_matrix)
      !! Construct discrete operator from coefficient matrix
      implicit none
      double precision, intent(in) :: upper(:,:), inner(:), lower(:,:)
      type(mimetic_matrix_t) mimetic_matrix
    end function

  end interface

  interface

    pure module function mimetic_matrix_x_vector(self, vector) result(product_)
      !! Apply a matrix operator to a vector
      implicit none
      class(mimetic_matrix_t), intent(in) :: self
      type(face_values_t), intent(in) :: vector
      double precision, allocatable :: product_(:)
    end function

  end interface

end module mimetic_matrix_m
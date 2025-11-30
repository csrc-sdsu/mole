#include "mole-language-support.F90"

module mimetic_operators_1D_m
  
  !! Define 1D scalar and vector abstractions and associated mimetic gradient,
  !! divergence, and Laplacian operators.
  use julienne_m, only : file_t
  implicit none

  private
  public :: gradient_operator_1D_t
  public :: divergence_operator_1D_t

  type mimetic_matrix_1D_t
    !! Encapsulate a mimetic matrix with a corresponding matrix-vector product operator
    private
    double precision, allocatable :: upper_(:,:) !! A  submatrix block (cf. Corbino & Castillo, 2020)
    double precision, allocatable :: inner_(:)   !! M  submatrix row   (cf. Corbino & Castillo, 2020)
    double precision, allocatable :: lower_(:,:) !! A' submatrix block (cf. Corbino & Castillo, 2020)
  contains
    procedure, non_overridable :: to_file_t
  end type

  interface mimetic_matrix_1D_t

    pure module function construct_matrix_operator(upper, inner, lower) result(mimetic_matrix_1D)
      !! Construct discrete operator from matrix blocks
      implicit none
      double precision, intent(in) :: upper(:,:) !! A  submatrix block (cf. Corbino & Castillo, 2020)
      double precision, intent(in) :: inner(:)   !! M  submatrix row   (cf. Corbino & Castillo, 2020)
      double precision, intent(in) :: lower(:,:) !! A' submatrix block (cf. Corbino & Castillo, 2020)
      type(mimetic_matrix_1D_t) mimetic_matrix_1D
    end function

  end interface

  type, extends(mimetic_matrix_1D_t) :: gradient_operator_1D_t
    !! Encapsulate kth-order mimetic gradient operator on m_ cells of width dx
    private
    integer k_, m_
    double precision dx_
  end type

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

  type, extends(mimetic_matrix_1D_t) :: divergence_operator_1D_t
    !! Encapsulate kth-order mimetic divergence operator on m_ cells of width dx
    private
    integer k_, m_
    double precision dx_
  end type

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

  interface

     pure module function to_file_t(self) result(file)
       implicit none
       class(mimetic_matrix_1D_t), intent(in) :: self
       type(file_t) file
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

end module mimetic_operators_1D_m

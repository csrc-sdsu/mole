#include "julienne-assert-macros.h"
#include "mole-language-support.F90"

submodule(face_values_m) gradient_operator_s
  use julienne_m, only : call_julienne_assert_, string_t
#if ASSERTIONS
  use julienne_m, only : operator(.isAtLeast.)
#endif
  implicit none

contains

  module procedure construct_from_parameters

    call_julienne_assert(m .isAtLeast. 2*k)

    gradient_operator%mimetic_matrix_ = mimetic_matrix_t( &
       corbino_castillo_A( k, dx) & 
      ,corbino_castillo_M( k, dx) & 
      ,corbino_castillo_Ap(k, dx) &
    )
    gradient_operator%k_  = k
    gradient_operator%dx_ = dx
  end procedure

  pure function corbino_castillo_A(k, dx) result(rows)
    integer, intent(in) :: k
    double precision, intent(in) :: dx
    double precision, allocatable :: rows(:,:)

    order_of_accuracy: &
    select case(k)
    case(2)
      rows = reshape([-8D0/3D0, 3D0, -1D0/3D0] , shape=[3,1]) / dx        
    case(4)
      rows = transpose(reshape([ & 
         [-352D0/105D0,  35D0/ 8D0, -35D0/24D0, -21D0/40D0, -5D0/ 56D0] &
        ,[ -16D0/105D0, -31D0/24D0,  29D0/24D0,  -3D0/40D0,  1D0/168D0] &
      ], shape=[5,2]))
    case default
      associate(string_k => string_t(k))
        error stop "corbino_castillo_A: unsupported order of accuracy: " // string_k%string()
      end associate
    end select order_of_accuracy

  end function

  pure function corbino_castillo_M(k, dx) result(row)
    integer, intent(in) :: k
    double precision, intent(in) :: dx
    double precision, allocatable :: row(:)

    order_of_accuracy: &
    select case(k)
    case(2)
      row = [-1D0, 1D0]/ dx        
    case(4)
      row = [1D0/24D0, -9D0/8D0, 9D0/8D0, -1D0/24D0] / dx        
    case default
      associate(string_k => string_t(k))
        error stop "corbino_castillo_A: unsupported order of accuracy: " // string_k%string()
      end associate
    end select order_of_accuracy

  end function

#if HAVE_DO_CONCURRENT_TYPE_SPEC_SUPPORT

  pure function corbino_castillo_Ap(k, dx) result(rows)
    integer, intent(in) :: k
    double precision, intent(in) :: dx
    double precision, allocatable :: rows(:,:)

    associate(A => corbino_castillo_A(k, dx))
      allocate(rows , mold=A)
      reverse_and_flip_sign: &
      do concurrent(integer :: row = 1:size(rows,1)) default(none) shared(rows, A) 
        rows(row,:) = -A(row,size(A,2):1)
      end do reverse_and_flip_sign
    end associate
  end function

#else

  pure function corbino_castillo_Ap(k, dx) result(rows)
    integer, intent(in) :: k
    double precision, intent(in) :: dx
    double precision, allocatable :: rows(:,:)

    associate(A => corbino_castillo_A(k, dx))
      allocate(rows , mold=A)
      block
        integer row
        reverse_and_flip_sign: &
        do concurrent(row = 1:size(rows,1)) default(none) shared(rows, A) 
          rows(row,:) = -A(row,size(A,2):1)
        end do reverse_and_flip_sign
      end block
    end associate
  end function

#endif

end submodule gradient_operator_s
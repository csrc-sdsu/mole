#include "language-support.F90"
  !! include Julienne preprocessor  macros

module divergence_operator_1D_test_m
  use julienne_m, only : &
     string_t &
    ,test_t &
    ,test_description_t &
    ,test_diagnosis_t &
    ,test_result_t &
    ,usher &
    ,operator(//) &
    ,operator(.all.) &
    ,operator(.also.) &
    ,operator(.approximates.) &
    ,operator(.within.)
  use mole_m, only : vector_1D_t, divergence_1D_t, vector_1D_initializer_i
  implicit none

  type, extends(test_t) :: divergence_operator_1D_test_t
  contains
    procedure, nopass :: subject
    procedure, nopass :: results
  end type

  double precision, parameter :: tight_tolerance = 1D-14, loose_tolerance = 1D-12, rough_tolerance = 1D-02, crude_tolerance = 5D-02

contains

  pure function subject() result(test_subject)
    character(len=:), allocatable :: test_subject
    test_subject = 'A 1D mimetic divergence operator'
  end function

  function results() result(test_results)
    type(divergence_operator_1D_test_t) divergence_operator_1D_test
    type(test_result_t), allocatable :: test_results(:)

    test_results = divergence_operator_1D_test%run([ & 
       test_description_t( &
          'computing 2nd- & 4th-order divergences of a constant vector field' // string_t(tight_tolerance) &
         ,usher(check_div_const)) &
      ,test_description_t( &
          'computing 2nd- & 4th-order divergences of a vector field with linearly varying magnitude' // string_t(loose_tolerance) &
         ,usher(check_div_line)) &
      ,test_description_t( &
          'computing 2nd- & 4th-order divergences of a vector field with quadratically varying magnitude' // string_t(loose_tolerance) &
         ,usher(check_div_parabola)) &
      !,test_description_t( &
      !    'computing 2nd-order divergences of a vector field of sinusoidally varying magnitude at convergence rate 2' // string_t(crude_tolerance) &
      !   ,usher(check_2nd_order_div_sinusoid)) &
      !,test_description_t( &
      !    'computing 4th-order divergences of a vector field of sinusoidally varying magnitude at convergence rate 4' // string_t(crude_tolerance) &
      !   ,usher(check_4th_order_div_sinusoid)) &
    ])
  end function

  pure function const(x) result(y)
    double precision, intent(in) :: x(:)
    double precision, allocatable :: y(:)
    integer i
    y = [(5D0, i=1,size(x))]
  end function

  function check_div_const() result(test_diagnosis)
    type(test_diagnosis_t) test_diagnosis
    type(divergence_1D_t) div_v
    double precision, parameter :: div_v_expected= 0.
    procedure(vector_1D_initializer_i), pointer :: vector_1D_initializer => const

    div_v = .div. vector_1D_t(vector_1D_initializer, order=2, cells=5, x_min=0D0, x_max=4D0)
    test_diagnosis = .all. (div_v%values() .approximates. div_v_expected .within. loose_tolerance) // " (2nd-order .div. (const. v))"

    div_v = .div. vector_1D_t(vector_1D_initializer, order=4, cells=9, x_min=0D0, x_max=8D0)
    test_diagnosis = test_diagnosis .also. (.all. (div_v%values() .approximates. div_v_expected .within. loose_tolerance)) // " 4th-order .div.(const. v)"
  end function

  pure function line(x) result(y)
    double precision, intent(in) :: x(:)
    double precision, allocatable :: y(:)
    y = 14*x + 3
  end function

  function check_div_line() result(test_diagnosis)
    type(test_diagnosis_t) test_diagnosis
    type(divergence_1D_t) div_v
    double precision, parameter :: div_v_expected = 14D0
    procedure(vector_1D_initializer_i), pointer :: vector_1D_initializer => line

    div_v = .div. vector_1D_t(vector_1D_initializer, order=2, cells=5, x_min=0D0, x_max=4D0)
    print '(a,*(g0,:,", "))', "div_v%values() = ", div_v%values()
    test_diagnosis = .all. (div_v%values() .approximates. div_v_expected .within. loose_tolerance) // " (2nd-order .div. (linear magnitude))"

    div_v = .div. vector_1D_t(vector_1D_initializer, order=4, cells=9, x_min=0D0, x_max=8D0)
    print '(a,*(g0,:,", "))', "div_v%values() = ", div_v%values()
    test_diagnosis = test_diagnosis .also. (.all. (div_v%values() .approximates. div_v_expected .within. loose_tolerance)) // " (4th-order .div. (linear magnitdue))"

  end function

  pure function parabola(x) result(y)
    double precision, intent(in) :: x(:)
    double precision, allocatable :: y(:)
    y = 7*x**2 + 3*x + 5
  end function

  function check_div_parabola() result(test_diagnosis)
    type(test_diagnosis_t) test_diagnosis
    type(vector_1D_t) quadratic
    type(divergence_1D_t) div_v
    procedure(vector_1D_initializer_i), pointer :: vector_1D_initializer => parabola

    quadratic = vector_1D_t(vector_1D_initializer , order=2, cells=5, x_min=0D0, x_max=4D0)
    div_v = .div. quadratic
    print '(a,*(g0,:,", "))', "div_v%values() = ", div_v%values()

    associate(x => div_v%grid())
      associate(div_v_expected => 14*x + 3)
        test_diagnosis = .all. (div_v%values() .approximates. div_v_expected .within. loose_tolerance) // "2nd-order .div. (quadratic magnitude)"
      end associate
    end associate

    quadratic = vector_1D_t(vector_1D_initializer , order=4, cells=9, x_min=0D0, x_max=8D0)
    div_v = .div. quadratic
    print '(a,*(g0,:,", "))', "div_v%values() = ", div_v%values()

    associate(x => div_v%grid())
      associate(div_v_expected => 14*x + 3)
        test_diagnosis = test_diagnosis .also. (.all. (div_v%values() .approximates. div_v_expected .within. loose_tolerance)) // "4th-order .div. (quadratic magnitude)"
      end associate
    end associate
  end function

  !pure function sinusoid(x) result(y)
  !  double precision, intent(in) :: x(:)
  !  double precision, allocatable :: y(:)
  !  y = sin(x) + cos(x)
  !end function

  !function check_2nd_order_div_sinusoid() result(test_diagnosis)
  !  type(test_diagnosis_t) test_diagnosis
  !  type(vector_1D_t) coarse, fine
  !  type(divergence_1D_t) div_coarse, div_fine
  !  procedure(vector_1D_initializer_i), pointer :: vector_1D_initializer => sinusoid
  !  double precision, parameter :: pi = 3.141592653589793D0
  !  integer, parameter :: order_desired = 2, coarse_cells=100, fine_cells=1000

  !  coarse = vector_1D_t(vector_1D_initializer , order=order_desired, cells=coarse_cells, x_min=0D0, x_max=2*pi)
  !  fine   = vector_1D_t(vector_1D_initializer , order=order_desired, cells=fine_cells  , x_min=0D0, x_max=2*pi)

  !  div_coarse = .div. coarse
  !  div_fine   = .div. fine

  !  associate(x_coarse => div_coarse%grid(), x_fine => div_fine%grid())
  !    associate(df_dx_coarse => cos(x_coarse) - sin(x_coarse), df_dx_fine => cos(x_fine) - sin(x_fine), div_coarse_values => div_coarse%values(), div_fine_values => div_fine%values())
  !      test_diagnosis = .all. (div_coarse_values .approximates. df_dx_coarse .within. rough_tolerance) // " (2nd-order d(sinusoid)/dx point-wise errors)"
  !      test_diagnosis = test_diagnosis .also. (.all. (div_fine_values .approximates. df_dx_fine .within. rough_tolerance)) // " (2nd-order d(sinusoid)/dx point-wise)"
  !      associate(error_coarse_max => maxval(abs(div_coarse_values - df_dx_coarse)), error_fine_max => maxval(abs(div_fine_values - df_dx_fine)))
  !        associate(order_actual => log(error_coarse_max/error_fine_max)/log(dble(fine_cells)/coarse_cells))
  !          test_diagnosis = test_diagnosis .also. (order_actual .approximates. dble(order_desired) .within. crude_tolerance)  // " (2nd-order d(sinusoid)/dx order of accuracy)"
  !        end associate
  !      end associate
  !    end associate
  !  end associate
  !end function

  !function check_4th_order_div_sinusoid() result(test_diagnosis)
  !  type(test_diagnosis_t) test_diagnosis
  !  type(vector_1D_t) coarse, fine
  !  type(divergence_1D_t) div_coarse, div_fine
  !  procedure(vector_1D_initializer_i), pointer :: vector_1D_initializer => sinusoid
  !  double precision, parameter :: pi = 3.141592653589793D0
  !  integer, parameter :: order_desired = 4, coarse_cells=100, fine_cells=1000

  !  coarse = vector_1D_t(vector_1D_initializer , order=order_desired, cells=coarse_cells, x_min=0D0, x_max=2*pi)
  !  fine   = vector_1D_t(vector_1D_initializer , order=order_desired, cells=fine_cells  , x_min=0D0, x_max=2*pi)

  !  div_coarse = .div. coarse
  !  div_fine   = .div. fine

  !  associate(x_coarse => div_coarse%grid(), x_fine => div_fine%grid())
  !    associate(df_dx_coarse => cos(x_coarse) - sin(x_coarse), df_dx_fine => cos(x_fine) - sin(x_fine), div_coarse_values => div_coarse%values(), div_fine_values => div_fine%values())
  !      test_diagnosis = .all. (div_coarse_values .approximates. df_dx_coarse .within. rough_tolerance) // " (4th-order d(sinusoid)/dx point-wise errors)"
  !      test_diagnosis = test_diagnosis .also. (.all. (div_fine_values .approximates. df_dx_fine .within. rough_tolerance)) // " (4th-order d(sinusoid)/dx point-wise)"
  !      associate(error_coarse_max => maxval(abs(div_coarse_values - df_dx_coarse)), error_fine_max => maxval(abs(div_fine_values - df_dx_fine)))
  !        associate(order_actual => log(error_coarse_max/error_fine_max)/log(dble(fine_cells)/coarse_cells))
  !          test_diagnosis = test_diagnosis .also. (order_actual .approximates. dble(order_desired) .within. crude_tolerance)  // " (4th-order d(sinusoid)/dx order of accuracy)"
  !        end associate
  !      end associate
  !    end associate
  !  end associate
  !end function

end module
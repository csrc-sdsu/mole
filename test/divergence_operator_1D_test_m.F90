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
  use mole_m, only : vector_1D_t, divergence_1D_t, vector_1D_initializer_i, scalar_1D_t, gradient_1D_t, scalar_1D_initializer_i
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
          'computing 2nd-order .div.(.grad. s) for 1D scalar s with quadratic magnitude within ' // string_t(tight_tolerance) &
         ,usher(check_2nd_order_div_grad_parabola)) &
      ,test_description_t( &
          'computing 4th-order .div.(.grad. s) for 1D scalar s with quadratic magnitude within ' // string_t(tight_tolerance) &
         ,usher(check_4th_order_div_grad_parabola)) &
      ,test_description_t( &
          'computing convergence rate of 2 for 2nd-order .div. for 1D vector with sinusoidal magnitude within ' // string_t(tight_tolerance) &
         ,usher(check_2nd_order_div_sinusoid_convergence)) &
      ,test_description_t( &
          'computing convergence rate of 4 for 4th-order .div. for 1D vector with sinusoidal magnitude within ' // string_t(tight_tolerance) &
         ,usher(check_4th_order_div_sinusoid_convergence)) &
    ])
  end function

  pure function parabola(x) result(y)
    double precision, intent(in) :: x(:)
    double precision, allocatable :: y(:)
    y = (x**2)/2
  end function

  function check_2nd_order_div_grad_parabola() result(test_diagnosis)
    type(test_diagnosis_t) test_diagnosis
    procedure(scalar_1D_initializer_i), pointer :: scalar_1D_initializer => parabola
    double precision, parameter :: expected_divergence = 1D0

    associate(div_grad_scalar => .div. (.grad. scalar_1D_t(scalar_1D_initializer, order=2, cells=5, x_min=0D0, x_max=5D0)))
      test_diagnosis = .all. (div_grad_scalar%values() .approximates. expected_divergence .within. tight_tolerance) &
                     // " (2nd-order .div. (.grad. scalar))"
    end associate

  end function

  function check_4th_order_div_grad_parabola() result(test_diagnosis)
    type(test_diagnosis_t) test_diagnosis
    procedure(scalar_1D_initializer_i), pointer :: scalar_1D_initializer => parabola
    double precision, parameter :: expected_divergence = 1D0

    associate(div_grad_scalar => .div. (.grad. scalar_1D_t(scalar_1D_initializer, order=4, cells=9, x_min=0D0, x_max=9D0)))
      test_diagnosis = .all. (div_grad_scalar%values() .approximates. expected_divergence .within. tight_tolerance) &
                     // " (2nd-order .div. (.grad. scalar))"
    end associate

  end function

  pure function sinusoid(x) result(y)
    double precision, intent(in) :: x(:)
    double precision, allocatable :: y(:)
    y = sin(x) + cos(x)
  end function

  function check_2nd_order_div_sinusoid_convergence() result(test_diagnosis)
    type(test_diagnosis_t) test_diagnosis
    type(vector_1D_t) coarse, fine
    type(divergence_1D_t) div_coarse, div_fine
    procedure(vector_1D_initializer_i), pointer :: vector_1D_initializer => sinusoid
    double precision, parameter :: pi = 3.141592653589793D0
    integer, parameter :: order_desired = 2, coarse_cells=1000, fine_cells=2000

    coarse = vector_1D_t(vector_1D_initializer , order=order_desired, cells=coarse_cells, x_min=0D0, x_max=2*pi)
    fine   = vector_1D_t(vector_1D_initializer , order=order_desired, cells=fine_cells  , x_min=0D0, x_max=2*pi)

    div_coarse = .div. coarse
    div_fine   = .div. fine

    associate( &
       x_coarse => div_coarse%grid() &
      ,x_fine   => div_fine%grid())
      associate( &
         df_dx_coarse => cos(x_coarse) - sin(x_coarse) &
        ,df_dx_fine => cos(x_fine) - sin(x_fine) &
        ,div_coarse_values => div_coarse%values() &
        ,div_fine_values => div_fine%values() &
      )
        test_diagnosis = .all. (div_coarse_values .approximates. df_dx_coarse .within. rough_tolerance) &
          // " (coarse 2nd-order .div. [sin(x) + cos(x)] point-wise errors)"
        test_diagnosis = test_diagnosis .also. (.all. (div_fine_values .approximates. df_dx_fine .within. rough_tolerance)) &
          // " (fine 2nd-order .div. [sin(x) + cos(x)] point-wise errors)"
        associate( &
           error_coarse_max => maxval(abs(div_coarse_values - df_dx_coarse)) &
          ,error_fine_max => maxval(abs(div_fine_values - df_dx_fine)) &
        )
          associate(order_actual => log(error_coarse_max/error_fine_max)/log(dble(fine_cells)/coarse_cells))
            test_diagnosis = test_diagnosis .also. (order_actual .approximates. dble(order_desired) .within. crude_tolerance) &
              // " (2nd-order .div. [sin(x) + cos(x)] order of accuracy)"
          end associate
        end associate
      end associate
    end associate
  end function

  function check_4th_order_div_sinusoid_convergence() result(test_diagnosis)
    type(test_diagnosis_t) test_diagnosis
    type(vector_1D_t) coarse, fine
    type(divergence_1D_t) div_coarse, div_fine
    procedure(vector_1D_initializer_i), pointer :: vector_1D_initializer => sinusoid
    double precision, parameter :: pi = 3.141592653589793D0
    integer, parameter :: order_desired = 4, coarse_cells=100, fine_cells=1000

    coarse = vector_1D_t(vector_1D_initializer , order=order_desired, cells=coarse_cells, x_min=0D0, x_max=2*pi)
    fine   = vector_1D_t(vector_1D_initializer , order=order_desired, cells=fine_cells  , x_min=0D0, x_max=2*pi)

    div_coarse = .div. coarse
    div_fine   = .div. fine

    associate(x_coarse => div_coarse%grid(), x_fine => div_fine%grid())
      associate(df_dx_coarse => cos(x_coarse) - sin(x_coarse), df_dx_fine => cos(x_fine) - sin(x_fine), div_coarse_values => div_coarse%values(), div_fine_values => div_fine%values())
        test_diagnosis = .all. (div_coarse_values .approximates. df_dx_coarse .within. rough_tolerance) // " (4th-order d(sinusoid)/dx point-wise errors)"
        test_diagnosis = test_diagnosis .also. (.all. (div_fine_values .approximates. df_dx_fine .within. rough_tolerance)) // " (4th-order d(sinusoid)/dx point-wise)"
        associate(error_coarse_max => maxval(abs(div_coarse_values - df_dx_coarse)), error_fine_max => maxval(abs(div_fine_values - df_dx_fine)))
          associate(order_actual => log(error_coarse_max/error_fine_max)/log(dble(fine_cells)/coarse_cells))
            test_diagnosis = test_diagnosis .also. (order_actual .approximates. dble(order_desired) .within. crude_tolerance)  // " (4th-order d(sinusoid)/dx order of accuracy)"
          end associate
        end associate
      end associate
    end associate
  end function
end module
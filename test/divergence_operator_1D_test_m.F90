#include "language-support.F90"
  !! include Julienne preprocessor  macros

module divergence_operator_1D_test_m
  use julienne_m, only : &
     operator(//) &
    ,operator(.all.) &
    ,operator(.also.) &
    ,operator(.approximates.) &
    ,operator(.csv.) &
    ,operator(.within.) &
    ,string_t &
    ,test_t &
    ,test_description_t &
    ,test_diagnosis_t &
    ,test_result_t &
    ,usher
  use mole_m, only : vector_1D_t, vector_1D_initializer_i, scalar_1D_t, scalar_1D_initializer_i
#ifdef __GFORTRAN__
  use mole_m, only : divergence_1D_t
#endif
  implicit none

  type, extends(test_t) :: divergence_operator_1D_test_t
  contains
    procedure, nopass :: subject
    procedure, nopass :: results
  end type

  double precision, parameter :: tight_tolerance = 1D-14, loose_tolerance = 1D-08, rough_tolerance = 1D-02

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
          'computing 2nd-order .div.(.grad. (x**2)/2) within ' // string_t(tight_tolerance) &
         ,usher(check_2nd_order_div_grad_parabola)) &
      ,test_description_t( &
          'computing 4th-order .div.(.grad. (x**2)/2) within ' // string_t(tight_tolerance) &
         ,usher(check_4th_order_div_grad_parabola)) &
      ,test_description_t( &
          'computing convergence rate of 2 for 2nd-order .div. [sin(x) + cos(x)] within ' // string_t(rough_tolerance) &
         ,usher(check_2nd_order_div_sinusoid_convergence)) &
      ,test_description_t( &
          'computing convergence rate of 4 for 4th-order .div. [sin(x) + cos(x)] within ' // string_t(rough_tolerance) &
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
#ifdef __GFORTRAN__
    type(divergence_1D_t) div_grad_scalar
    div_grad_scalar = .div. (.grad. scalar_1D_t(scalar_1D_initializer, order=2, cells=5, x_min=0D0, x_max=5D0))
#else
    associate(div_grad_scalar => .div. (.grad. scalar_1D_t(scalar_1D_initializer, order=2, cells=5, x_min=0D0, x_max=5D0)))
#endif
      test_diagnosis = .all. (div_grad_scalar%values() .approximates. expected_divergence .within. tight_tolerance) &
                     // " (2nd-order .div. (.grad. (x**2)/2))"
#ifndef __GFORTRAN__
    end associate
#endif
  end function

  function check_4th_order_div_grad_parabola() result(test_diagnosis)
    type(test_diagnosis_t) test_diagnosis
    procedure(scalar_1D_initializer_i), pointer :: scalar_1D_initializer => parabola
    double precision, parameter :: expected_divergence = 1D0
#ifdef __GFORTRAN__
    type(divergence_1D_t) div_grad_scalar
    div_grad_scalar = .div. (.grad. scalar_1D_t(scalar_1D_initializer, order=4, cells=9, x_min=0D0, x_max=9D0))
#else
    associate(div_grad_scalar => .div. (.grad. scalar_1D_t(scalar_1D_initializer, order=4, cells=9, x_min=0D0, x_max=9D0)))
#endif
      test_diagnosis = .all. (div_grad_scalar%values() .approximates. expected_divergence .within. tight_tolerance) &
                     // " (4th-order .div. (.grad. (x**2)/2))"
#ifndef __GFORTRAN__
    end associate
#endif
  end function


  pure function sinusoid(x) result(y)
    double precision, intent(in) :: x(:)
    double precision, allocatable :: y(:)
    y = sin(x) + cos(x)
  end function


  function check_2nd_order_div_sinusoid_convergence() result(test_diagnosis)
    type(test_diagnosis_t) test_diagnosis
    procedure(vector_1D_initializer_i), pointer :: vector_1D_initializer => sinusoid
    double precision, parameter :: pi = 3.141592653589793D0
    integer, parameter :: order_desired = 2, coarse_cells=100, fine_cells=200
#ifdef __GFORTRAN__
    type(divergence_1D_t) div_coarse, div_fine
    div_coarse = .div. vector_1D_t(vector_1D_initializer , order=order_desired, cells=coarse_cells, x_min=0D0, x_max=2*pi)
    div_fine   = .div. vector_1D_t(vector_1D_initializer , order=order_desired, cells=fine_cells  , x_min=0D0, x_max=2*pi)
#else
    associate( &
       div_coarse => .div. vector_1D_t(vector_1D_initializer , order=order_desired, cells=coarse_cells, x_min=0D0, x_max=2*pi) &
      ,div_fine   => .div. vector_1D_t(vector_1D_initializer , order=order_desired, cells=fine_cells  , x_min=0D0, x_max=2*pi) &
    )
#endif
      associate( &
         x_coarse => div_coarse%grid() &
        ,x_fine   => div_fine%grid())
        associate( &
           grad_coarse => cos(x_coarse) - sin(x_coarse) &
          ,grad_fine   => cos(x_fine)   - sin(x_fine) &
          ,div_coarse_values => div_coarse%values() &
          ,div_fine_values   => div_fine%values() &
        )
          test_diagnosis = .all. (div_coarse_values .approximates. grad_coarse .within. rough_tolerance) &
            // " (coarse-grid 2nd-order .div. [sin(x) + cos(x)])"
          test_diagnosis = test_diagnosis .also. (.all. (div_fine_values .approximates. grad_fine .within. rough_tolerance)) &
            // " (fine-grid 2nd-order .div. [sin(x) + cos(x)])"
          associate( &
             error_coarse_max => maxval(abs(div_coarse_values - grad_coarse)) &
            ,error_fine_max   => maxval(abs(div_fine_values   - grad_fine)) &
          )
            associate(order_actual => log(error_coarse_max/error_fine_max)/log(dble(fine_cells)/coarse_cells))
              test_diagnosis = test_diagnosis .also. (order_actual .approximates. dble(order_desired) .within. rough_tolerance) &
                // " (convergence rate for 2nd-order .div. [sin(x) + cos(x)])"
            end associate
          end associate
        end associate
      end associate
#ifndef __GFORTRAN__
    end associate
#endif
  end function


  function check_4th_order_div_sinusoid_convergence() result(test_diagnosis)
    type(test_diagnosis_t) test_diagnosis
    procedure(vector_1D_initializer_i), pointer :: vector_1D_initializer => sinusoid
    double precision, parameter :: pi = 3.141592653589793D0
    integer, parameter :: order_desired = 4, coarse_cells=300, fine_cells=1500
#ifdef __GFORTRAN__
    type(divergence_1D_t) div_coarse, div_fine
    div_coarse = .div. vector_1D_t(vector_1D_initializer , order=order_desired, cells=coarse_cells, x_min=0D0, x_max=2*pi)
    div_fine   = .div. vector_1D_t(vector_1D_initializer , order=order_desired, cells=fine_cells  , x_min=0D0, x_max=2*pi)
#else
    associate( &
       div_coarse => .div. vector_1D_t(vector_1D_initializer , order=order_desired, cells=coarse_cells, x_min=0D0, x_max=2*pi) &
      ,div_fine   => .div. vector_1D_t(vector_1D_initializer , order=order_desired, cells=fine_cells  , x_min=0D0, x_max=2*pi) &
    )
#endif
      associate( &
         x_coarse => div_coarse%grid() &
        ,x_fine   => div_fine%grid()  &
      )
        associate( &
           div_coarse_expected => cos(x_coarse) - sin(x_coarse) &
          ,div_fine_expected   => cos(x_fine) - sin(x_fine) &
          ,div_coarse_values => div_coarse%values() &
          ,div_fine_values   => div_fine%values() &
        )
          test_diagnosis = .all. (div_coarse_values .approximates. div_coarse_expected .within. loose_tolerance) &
            // " (coarse-grid 4th-order .div. [sin(x) + cos(x)])"
          test_diagnosis = test_diagnosis .also. (.all. (div_fine_values .approximates. div_fine_expected .within. loose_tolerance)) &
            // " (fine-grid 4th-order .div. [sin(x) + cos(x)])"
          associate( &
             error_coarse_max => maxval(abs(div_coarse_values - div_coarse_expected)) &
            ,error_fine_max => maxval(abs(div_fine_values - div_fine_expected)) &
          )
            associate(order_actual => log(error_coarse_max/error_fine_max)/log(dble(fine_cells)/coarse_cells))
              test_diagnosis = test_diagnosis .also. (order_actual .approximates. dble(order_desired) .within. rough_tolerance) &
                // " (convergence rate for 4th-order .div. [sin(x) + cos(x)])"
            end associate
          end associate
        end associate
      end associate
#ifndef __GFORTRAN__
    end associate
#endif
  end function

end module divergence_operator_1D_test_m
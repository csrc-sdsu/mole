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

  double precision, parameter :: tolerance = 1D-12, crude_tolerance = 5D-02

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
          'computing 2nd-order .div.(.grad. s) for 1D scalar s with quadratic magnitude within ' // string_t(tolerance) &
         ,usher(check_2nd_order_div_grad_parabola)) &
      ,test_description_t( &
          'computing 4th-order .div.(.grad. s) for 1D scalar s with quadratic magnitude within ' // string_t(tolerance) &
         ,usher(check_4th_order_div_grad_parabola)) &
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
      test_diagnosis = .all. (div_grad_scalar%values() .approximates. expected_divergence .within. tolerance) &
                     // " (2nd-order .div. (.grad. scalar))"
    end associate

  end function

  function check_4th_order_div_grad_parabola() result(test_diagnosis)
    type(test_diagnosis_t) test_diagnosis
    procedure(scalar_1D_initializer_i), pointer :: scalar_1D_initializer => parabola
    double precision, parameter :: expected_divergence = 1D0

    associate(div_grad_scalar => .div. (.grad. scalar_1D_t(scalar_1D_initializer, order=4, cells=9, x_min=0D0, x_max=9D0)))
      test_diagnosis = .all. (div_grad_scalar%values() .approximates. expected_divergence .within. tolerance) &
                     // " (2nd-order .div. (.grad. scalar))"
    end associate

  end function

end module
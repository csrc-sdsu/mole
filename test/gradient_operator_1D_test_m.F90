#include "language-support.F90"
  !! include Julienne preprocessor  macros

module gradient_operator_1D_test_m
  use julienne_m, only : &
     string_t &
    ,test_t &
    ,test_description_t &
    ,test_diagnosis_t &
    ,test_result_t &
    ,operator(//) &
    ,operator(.all.) &
    ,operator(.approximates.) &
    ,operator(.within.)
  use mole_m, only : scalar_1D_t, gradient_1D_t, scalar_1D_initializer_i
#if ! HAVE_PROCEDURE_ACTUAL_FOR_POINTER_DUMMY
  use julienne_m, only : diagnosis_function_i
#endif
  implicit none

  type, extends(test_t) :: gradient_operator_1D_test_t
  contains
    procedure, nopass :: subject
    procedure, nopass :: results
  end type

  double precision, parameter :: tight_tolerance = 1D-14, loose_tolerance = 1D-12

contains

  pure function subject() result(test_subject)
    character(len=:), allocatable :: test_subject
    test_subject = 'A 1D mimetic gradient operator'
  end function

#if HAVE_PROCEDURE_ACTUAL_FOR_POINTER_DUMMY

  function results() result(test_results)
    type(gradient_operator_1D_test_t) gradient_operator_1D_test
    type(test_result_t), allocatable :: test_results(:)
    test_results = gradient_operator_1D_test%run([ & 
       test_description_t('computing the 2nd-order 1D gradient of a constant within a tolerance of ' // string_t(tight_tolerance), check_grad_const) &
      ,test_description_t('computing the 2nd-order 1D gradient of a line within a tolerance of ' // string_t(loose_tolerance), check_grad_line) &
      ,test_description_t('computing the 2nd-order 1D gradient of a parabola within a tolerance of ' // string_t(loose_tolerance), check_grad_parabola) &
    ])
  end function

#else

  function results() result(test_results)
    type(gradient_operator_1D_test_t) gradient_operator_1D_test
    type(test_result_t), allocatable :: test_results(:)
    procedure(diagnosis_function_i), pointer :: &
       check_grad_const_ptr => check_grad_const &
      ,check_grad_line_ptr => check_grad_line &
      ,check_grad_parabola_ptr => check_grad_parabola

    test_results = gradient_operator_1D_test%run([ &
       test_description_t('computing the 2nd-order 1D gradient of a constant within a tolerance of ' // string_t(tight_tolerance), check_grad_const_ptr) &
      ,test_description_t('computing the 2nd-order 1D gradient of a line within a tolerance of ' // string_t(loose_tolerance), check_grad_line_ptr) &
      ,test_description_t('computing the 2nd-order 1D gradient of a parabola within a tolerance of ' // string_t(loose_tolerance), check_grad_parabola_ptr) &
    ])
  end function

#endif

  pure function const(x) result(y)
    double precision, intent(in) :: x(:)
    double precision, allocatable :: y(:)
    integer i
    y = [(5D0, i=1,size(x))]
  end function

  function check_grad_const() result(test_diagnosis)
    type(test_diagnosis_t) test_diagnosis
    type(gradient_1D_t) grad_f
    double precision, parameter :: df_dx = 0.
    procedure(scalar_1D_initializer_i), pointer :: scalar_1D_initializer => const

    grad_f = .grad. scalar_1D_t(scalar_1D_initializer, order=2, cells=4, x_min=0D0, x_max=1D0)
    test_diagnosis = .all. (grad_f%values() .approximates. df_dx .within. loose_tolerance) // " (d(line)/dx)"
  end function

  pure function line(x) result(y)
    double precision, intent(in) :: x(:)
    double precision, allocatable :: y(:)
    y = 14*x + 3
  end function

  function check_grad_line() result(test_diagnosis)
    type(test_diagnosis_t) test_diagnosis
    type(gradient_1D_t) grad_f
    double precision, parameter :: df_dx = 14D0
    procedure(scalar_1D_initializer_i), pointer :: scalar_1D_initializer => line

    grad_f = .grad. scalar_1D_t(scalar_1D_initializer, order=2, cells=4, x_min=0D0, x_max=1D0)
    test_diagnosis = .all. (grad_f%values() .approximates. df_dx .within. loose_tolerance) // " (d(line)/dx)"
  end function

  pure function parabola(x) result(y)
    double precision, intent(in) :: x(:)
    double precision, allocatable :: y(:)
    y = 7*x**2 + 3*x + 5
  end function

  function check_grad_parabola() result(test_diagnosis)
    type(test_diagnosis_t) test_diagnosis
    type(scalar_1D_t) quadratic
    type(gradient_1D_t) grad_f
    procedure(scalar_1D_initializer_i), pointer :: scalar_1D_initializer => parabola

    quadratic = scalar_1D_t(scalar_1D_initializer , order=2, cells=4, x_min=0D0, x_max=1D0)
    grad_f = .grad. quadratic

    associate(x => grad_f%faces())
      associate(df_dx => 14*x + 3)
        test_diagnosis = .all. (grad_f%values() .approximates. df_dx .within. loose_tolerance) // " (d(parabola)/dx)"
      end associate
    end associate

  end function

end module
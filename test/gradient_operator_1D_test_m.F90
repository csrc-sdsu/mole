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
    ,operator(.also.) &
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

  double precision, parameter :: tight_tolerance = 1D-14, loose_tolerance = 1D-12, rough_tolerance = 1D-02, crude_tolerance = 5D-02

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
       test_description_t('computing 2nd- & 4th-order 1D gradients of a constant within tolerance ' // string_t(tight_tolerance), check_grad_const) &
      ,test_description_t('computing 2nd- & 4th-order 1D gradients of a line within tolerance ' // string_t(loose_tolerance), check_grad_line) &
      ,test_description_t('computing 2nd- & 4th-order 1D gradients of a parabola within tolerance ' // string_t(loose_tolerance), check_grad_parabola) &
      ,test_description_t('computing 2nd-order 1D gradients of a sinusoid with a convergence rate of 2 within tolerance ' // string_t(crude_tolerance), check_2nd_order_grad_sinusoid) &
      ,test_description_t('computing 4th-order 1D gradients of a sinusoid with a convergence rate of 4 within tolerance ' // string_t(crude_tolerance), check_4th_order_grad_sinusoid) &
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
       test_description_t('computing 2nd & 4th-order 1D gradients of a constant within tolerance ' // string_t(tight_tolerance), check_grad_const_ptr) &
      ,test_description_t('computing 2nd & 4th-order 1D gradients of a line within tolerance ' // string_t(loose_tolerance), check_grad_line_ptr) &
      ,test_description_t('computing 2nd & 4th-order 1D gradients of a parabola within tolerance ' // string_t(loose_tolerance), check_grad_parabola_ptr) &
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

    grad_f = .grad. scalar_1D_t(scalar_1D_initializer, order=2, cells=4, x_min=0D0, x_max=4D0)
    test_diagnosis = .all. (grad_f%values() .approximates. df_dx .within. loose_tolerance) // " (2nd-order d(line)/dx)"

    grad_f = .grad. scalar_1D_t(scalar_1D_initializer, order=4, cells=8, x_min=0D0, x_max=8D0)
    test_diagnosis = test_diagnosis .also. (.all. (grad_f%values() .approximates. df_dx .within. loose_tolerance)) // " (4th-order d(line)/dx)"
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

    grad_f = .grad. scalar_1D_t(scalar_1D_initializer, order=2, cells=4, x_min=0D0, x_max=4D0)
    test_diagnosis = .all. (grad_f%values() .approximates. df_dx .within. loose_tolerance) // " (2nd-order d(line)/dx)"

    grad_f = .grad. scalar_1D_t(scalar_1D_initializer, order=4, cells=8, x_min=0D0, x_max=8D0)
    test_diagnosis = test_diagnosis .also. (.all. (grad_f%values() .approximates. df_dx .within. loose_tolerance)) // " (4th-order d(line)/dx)"

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

    quadratic = scalar_1D_t(scalar_1D_initializer , order=2, cells=4, x_min=0D0, x_max=4D0)
    grad_f = .grad. quadratic

    associate(x => grad_f%faces())
      associate(df_dx => 14*x + 3)
        test_diagnosis = .all. (grad_f%values() .approximates. df_dx .within. loose_tolerance) // " (2nd-order d(parabola)/dx)"
      end associate
    end associate

    quadratic = scalar_1D_t(scalar_1D_initializer , order=4, cells=8, x_min=0D0, x_max=8D0)
    grad_f = .grad. quadratic

    associate(x => grad_f%faces())
      associate(df_dx => 14*x + 3)
        test_diagnosis = test_diagnosis .also. (.all. (grad_f%values() .approximates. df_dx .within. loose_tolerance)) // " (4th-order d(parabola)/dx)"
      end associate
    end associate
  end function

  pure function sinusoid(x) result(y)
    double precision, intent(in) :: x(:)
    double precision, allocatable :: y(:)
    y = sin(x) + cos(x)
  end function

  function check_2nd_order_grad_sinusoid() result(test_diagnosis)
    type(test_diagnosis_t) test_diagnosis
    type(scalar_1D_t) coarse, fine
    type(gradient_1D_t) grad_coarse, grad_fine
    procedure(scalar_1D_initializer_i), pointer :: scalar_1D_initializer => sinusoid
    double precision, parameter :: pi = 3.141592653589793D0
    integer, parameter :: order_desired = 2, coarse_cells=100, fine_cells=1000

    coarse = scalar_1D_t(scalar_1D_initializer , order=order_desired, cells=coarse_cells, x_min=0D0, x_max=2*pi)
    fine   = scalar_1D_t(scalar_1D_initializer , order=order_desired, cells=fine_cells  , x_min=0D0, x_max=2*pi)

    grad_coarse = .grad. coarse
    grad_fine   = .grad. fine

    associate(x_coarse => grad_coarse%faces(), x_fine => grad_fine%faces())
      associate(df_dx_coarse => cos(x_coarse) - sin(x_coarse), df_dx_fine => cos(x_fine) - sin(x_fine), grad_coarse_values => grad_coarse%values(), grad_fine_values => grad_fine%values())
        test_diagnosis = .all. (grad_coarse_values .approximates. df_dx_coarse .within. rough_tolerance) // " (2nd-order d(sinusoid)/dx point-wise errors)"
        test_diagnosis = test_diagnosis .also. (.all. (grad_fine_values .approximates. df_dx_fine .within. rough_tolerance)) // " (2nd-order d(sinusoid)/dx point-wise)"
        associate(error_coarse_max => maxval(abs(grad_coarse_values - df_dx_coarse)), error_fine_max => maxval(abs(grad_fine_values - df_dx_fine)))
          associate(order_actual => log(error_coarse_max/error_fine_max)/log(dble(fine_cells)/coarse_cells))
            test_diagnosis = test_diagnosis .also. (order_actual .approximates. dble(order_desired) .within. crude_tolerance)  // " (2nd-order d(sinusoid)/dx order of accuracy)"
          end associate
        end associate
      end associate
    end associate
  end function

  function check_4th_order_grad_sinusoid() result(test_diagnosis)
    type(test_diagnosis_t) test_diagnosis
    type(scalar_1D_t) coarse, fine
    type(gradient_1D_t) grad_coarse, grad_fine
    procedure(scalar_1D_initializer_i), pointer :: scalar_1D_initializer => sinusoid
    double precision, parameter :: pi = 3.141592653589793D0
    integer, parameter :: order_desired = 4, coarse_cells=100, fine_cells=1000

    coarse = scalar_1D_t(scalar_1D_initializer , order=order_desired, cells=coarse_cells, x_min=0D0, x_max=2*pi)
    fine   = scalar_1D_t(scalar_1D_initializer , order=order_desired, cells=fine_cells  , x_min=0D0, x_max=2*pi)

    grad_coarse = .grad. coarse
    grad_fine   = .grad. fine

    associate(x_coarse => grad_coarse%faces(), x_fine => grad_fine%faces())
      associate(df_dx_coarse => cos(x_coarse) - sin(x_coarse), df_dx_fine => cos(x_fine) - sin(x_fine), grad_coarse_values => grad_coarse%values(), grad_fine_values => grad_fine%values())
        test_diagnosis = .all. (grad_coarse_values .approximates. df_dx_coarse .within. rough_tolerance) // " (4th-order d(sinusoid)/dx point-wise errors)"
        test_diagnosis = test_diagnosis .also. (.all. (grad_fine_values .approximates. df_dx_fine .within. rough_tolerance)) // " (4th-order d(sinusoid)/dx point-wise)"
        associate(error_coarse_max => maxval(abs(grad_coarse_values - df_dx_coarse)), error_fine_max => maxval(abs(grad_fine_values - df_dx_fine)))
          associate(order_actual => log(error_coarse_max/error_fine_max)/log(dble(fine_cells)/coarse_cells))
            test_diagnosis = test_diagnosis .also. (order_actual .approximates. dble(order_desired) .within. crude_tolerance)  // " (4th-order d(sinusoid)/dx order of accuracy)"
          end associate
        end associate
      end associate
    end associate
  end function

end module
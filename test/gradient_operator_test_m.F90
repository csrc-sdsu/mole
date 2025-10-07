! Copyright (c) 2024-2025, The Regents of the University of California and Sourcery Institute
! Terms of use are as specified in https://github.com/BerkeleyLab/julienne/blob/3.1.2/LICENSE.txt

#include "language-support.F90"
  !! include Julienne preprocessor  macros

module gradient_operator_test_m
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
  use mole_m, only : cell_centers_extended_t, gradient_t, scalar_1D_initializer_t
#if ! HAVE_PROCEDURE_ACTUAL_FOR_POINTER_DUMMY
  use julienne_m, only : diagnosis_function_i
#endif
  implicit none

  type, extends(test_t) :: gradient_operator_test_t
  contains
    procedure, nopass :: subject
    procedure, nopass :: results
  end type

  double precision, parameter :: tight_tolerance = 1D-14, loose_tolerance = 1D-10

contains

  pure function subject() result(test_subject)
    character(len=:), allocatable :: test_subject
    test_subject = 'A 1D mimetic gradient operator'
  end function

#if HAVE_PROCEDURE_ACTUAL_FOR_POINTER_DUMMY

  function results() result(test_results)
    type(gradient_operator_test_t) gradient_operator_test
    type(test_result_t), allocatable :: test_results(:)
    test_results = gradient_operator_test%run([ & 
       test_description_t('computing the gradient of a constant function within a tolerance of ' // string_t(tight_tolerance), check_grad_const) &
      ,test_description_t('computing the gradient of a line within a tolerance of ' // string_t(loose_tolerance), check_grad_line) &
    ])
  end function

#else

  function results() result(test_results)
    type(gradient_operator_test_t) gradient_operator_test
    type(test_result_t), allocatable :: test_results(:)
    procedure(diagnosis_function_i), pointer :: &
       check_grad_const_ptr => check_grad_const &
      ,check_grad_line_ptr => check_grad_line
    test_results = gradient_operator_test%run([ &
       test_description_t('computing the gradient of a constant function within a tolerance of ' // string_t(tight_tolerance), check_grad_const_ptr) &
      ,test_description_t('computing the gradient of a line within a tolerance of ' // string_t(loose_tolerance), check_grad_line_ptr) &
    ])
  end function

#endif

  elemental function const(x) result(c)
    double precision, intent(in) :: x
    double precision c
    c = 3D0
  end function

  function check_grad_const() result(test_diagnosis)
    type(test_diagnosis_t) test_diagnosis
    type(gradient_t) grad_f
    type, extends(scalar_1D_initializer_t) :: const_initializer_1D_t
    contains
      procedure, nopass, non_overridable :: f => const
    end type
    type(const_initializer_1D_t) :: const_initializer_1D
    double precision, parameter :: df_dx = 0D0

    grad_f = .grad. cell_centers_extended_t(const_initializer_1D, order=2, cells=4, x_min=0D0, x_max=1D0) ! gfortran blocks use of association
    test_diagnosis = .all. (grad_f%values() .approximates. df_dx .within. tight_tolerance) // " (d(const)/dx)"
  end function

  elemental function line(x) result(y)
    double precision, intent(in) :: x
    double precision y
    y = 14*x + 3
  end function

  function check_grad_line() result(test_diagnosis)
    type(test_diagnosis_t) test_diagnosis
    type(gradient_t) grad_f
    type, extends(scalar_1D_initializer_t) :: line_initializer_1D_t
    contains
      procedure, nopass, non_overridable :: f => line
    end type
    type(line_initializer_1D_t) :: line_initializer_1D
    double precision, parameter :: df_dx = 14D0

    grad_f = .grad. cell_centers_extended_t(line_initializer_1D, order=2, cells=4, x_min=0D0, x_max=1D0) ! gfortran blocks use of association
    test_diagnosis = .all. (grad_f%values() .approximates. df_dx .within. loose_tolerance) // " (d(line)/dx)"

  end function

  elemental function parabola(x) result(y)
    double precision, intent(in) :: x
    double precision y
    y = 7*x**2 + 3*x + 5
  end function

  function check_grad_parabola() result(test_diagnosis)
    type(test_diagnosis_t) test_diagnosis
    type(gradient_t) grad_f
    type(cell_centers_extended_t) quadratic
    type, extends(scalar_1D_initializer_t) :: parabola_initializer_1D_t
    contains
      procedure, nopass, non_overridable :: f => line
    end type
    type(parabola_initializer_1D_t) parabola_initializer_1D

    quadratic = cell_centers_extended_t(parabola_initializer_1D, order=2, cells=4, x_min=0D0, x_max=1D0) ! gfortran blocks use of association
    grad_f = .grad. quadratic ! gfortran blocks use of association
    print *, "grad_f = ", grad_f%values()
    print *, "df_dx = ",parabola(quadratic%grid_)

    test_diagnosis = test_diagnosis_t(.true., "") !.all. (grad_f%values() .approximates. df_dx .within. loose_tolerance) // " (d(line)/dx)"

  end function

end module
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

  double precision, parameter :: line_tolerance = 1D-14

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
       test_description_t('computing gradients of lines within a tolerance of ' // string_t(line_tolerance), check_line_slope) &
    ])
  end function

#else

  function results() result(test_results)
    type(gradient_operator_test_t) gradient_operator_test
    type(test_result_t), allocatable :: test_results(:)
    procedure(diagnosis_function_i), pointer :: &
      check_line_slope_ptr => check_line_slope
    test_results = gradient_operator_test%run([ &
       test_description_t('computing gradients of lines within a tolerance of ' // string_t(line_tolerance), check_line_slope_ptr) &
    ])
  end function

#endif

  function check_line_slope() result(test_diagnosis)
    type(test_diagnosis_t) test_diagnosis
    type(gradient_t) grad_f
    type, extends(scalar_1D_initializer_t) :: const_initializer_1D_t
    contains
      procedure, nopass, non_overridable :: f => const
    end type
    type(const_initializer_1D_t) :: const_initializer_1D

    double precision, parameter :: df_dx = 0D0

    grad_f = .grad. cell_centers_extended_t(const_initializer_1D, order=2, cells=4, domain=[0D0,1D0]) ! gfortran blocks use of association
    test_diagnosis = .all. (grad_f%values() .approximates. df_dx .within. line_tolerance) // " (d(const)/dx)"
  end function

  elemental function const(x) result(c)
    double precision, intent(in) :: x
    double precision c
    c = 2D0
  end function

end module
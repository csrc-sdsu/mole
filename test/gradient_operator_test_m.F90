! Copyright (c) 2024-2025, The Regents of the University of California and Sourcery Institute
! Terms of use are as specified in https://github.com/BerkeleyLab/julienne/blob/3.1.2/LICENSE.txt

#include "language-support.F90"
  !! include Julienne preprocessor  macros

module gradient_operator_test_m
  use julienne_m, only : &
     test_t, test_description_t, test_diagnosis_t, test_result_t, operator(.all.), operator(.approximates.), operator(.within.)
  use mole_m, only : cell_centers_extended_t, gradient_t
#if ! HAVE_PROCEDURE_ACTUAL_FOR_POINTER_DUMMY
  use julienne_m, only : diagnosis_function_i
#endif
  implicit none

  type, extends(test_t) :: gradient_operator_test_t
  contains
    procedure, nopass :: subject
    procedure, nopass :: results
  end type

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
       test_description_t('computing the gradient of a linear function', check_gradient_of_line) &
    ])
  end function

#else

  function results() result(test_results)
    type(gradient_operator_test_t) gradient_operator_test
    type(test_result_t), allocatable :: test_results(:)
    procedure(diagnosis_function_i), pointer :: &
      check_gradient_of_line_ptr => check_gradient_of_line
    test_results = gradient_operator_test%run([ &
       test_description_t('computing the gradient of a linear function', check_gradient_of_line_ptr) &
    ])
  end function

#endif

  function check_gradient_of_line() result(test_diagnosis)
    type(test_diagnosis_t) test_diagnosis
    double precision, parameter :: dx = 1D0, tolerance = 1D-15
    double precision, parameter :: x(*) = [0D0,.5D0, 1.5D0, 2.5D0, 3.5D0, 4D0]*dx !! grid from Corbino & Castillo (2020) Fig. 6
    double precision, parameter :: f(*) = x, df_dx_exact = 1D0 !! f(x) = x, df_dx = 1
    type(gradient_t) grad_f
    grad_f = .grad. cell_centers_extended_t(f, k=2, dx=dx) ! gfortran blocks use of association
    test_diagnosis = .all. (grad_f%values() .approximates. df_dx_exact .within. tolerance)
  end function

end module

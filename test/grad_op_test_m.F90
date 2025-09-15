! Copyright (c) 2024-2025, The Regents of the University of California and Sourcery Institute
! Terms of use are as specified in https://github.com/BerkeleyLab/julienne/blob/3.1.2/LICENSE.txt

#include "language-support.F90"
  !! include Julienne preprocessor  macros

module grad_op_test_m
  use julienne_m, only : &
     test_t, test_description_t, test_diagnosis_t, test_result_t
  use grad_op_m, only : grad_op_t
#if ! HAVE_PROCEDURE_ACTUAL_FOR_POINTER_DUMMY
  use julienne_m, only : diagnosis_function_i
#endif
  implicit none

  type, extends(test_t) :: grad_op_test_t
  contains
    procedure, nopass :: subject
    procedure, nopass :: results
  end type

contains

  pure function subject() result(test_subject)
    character(len=:), allocatable :: test_subject
    test_subject = 'A grad_op operator'
  end function

#if HAVE_PROCEDURE_ACTUAL_FOR_POINTER_DUMMY

  function results() result(test_results)
    type(grad_op_test_t) grad_op_test
    type(test_result_t), allocatable :: test_results(:)
    test_results = grad_op_test%run( & 
      [test_description_t('constructing a trivial operator object', check_construction) &
    ])
  end function

#else

  function results() result(test_results)
    type(grad_op_test_t) grad_op_test
    type(test_result_t), allocatable :: test_results(:)
    procedure(diagnosis_function_i), pointer :: &
      check_construction_ptr => check_construction

    test_results = grad_op_test%run( &
      [test_description_t('constructing a trivial operator object', check_construction_ptr) &
    ])
  end function

#endif

  function check_construction() result(test_diagnosis)
    type(test_diagnosis_t) test_diagnosis
    associate(grad_op => grad_op_t(k=2, m=2, dx=1D0))
    end associate
    test_diagnosis = test_diagnosis_t(test_passed=.true., diagnostics_string="failure is not an option")
  end function

end module

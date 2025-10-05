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
    integer i
    integer, parameter :: cells = 10
    double precision, parameter :: x_min = 0., x_max = 10., dx = (x_max - x_min)/dble(cells)
    double precision, parameter :: x(*) = [x_min, x_min + dx/2. + [(dble(i-1)*dx, i = 1, cells)], x_max]*dx
      !! boundaries + grid cell centers -- see Corbino & Castillo (2020) https://doi.org/10.1016/j.cam.2019.06.042
    double precision, parameter :: m = 2D0, b = 3D0, n = 5D0, c = 7D0
    double precision, parameter :: f(*) = m*x + b, df_dx = m
    double precision, parameter :: g(*) = n*x + c, dg_dx = n
    type(gradient_t) grad_f, grad_g
    grad_f = .grad. cell_centers_extended_t(f, k=2, dx=dx) ! gfortran blocks use of association
    test_diagnosis = .all. (grad_f%values() .approximates. df_dx .within. line_tolerance) // " (df_dx)"

    grad_g = .grad. cell_centers_extended_t(g, k=2, dx=dx) ! gfortran blocks use of association
    test_diagnosis = .all. (grad_g%values() .approximates. dg_dx .within. line_tolerance) // " (dg_dx)"
  end function

end module

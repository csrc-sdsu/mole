#include "language-support.F90"
  !! include Julienne preprocessor  macros

module laplacian_operator_1D_test_m
  use julienne_m, only : &
     file_t &
    ,operator(//) &
    ,operator(.all.) &
    ,operator(.also.) &
    ,operator(.approximates.) &
    ,operator(.separatedBy.) &
    ,operator(.within.) &
    ,string_t &
    ,test_t &
    ,test_description_t &
    ,test_diagnosis_t &
    ,test_result_t &
    ,usher
  use mole_m, only : scalar_1D_t, scalar_1D_initializer_i
  implicit none

  type, extends(test_t) :: laplacian_operator_1D_test_t
  contains
    procedure, nopass :: subject
    procedure, nopass :: results
  end type

  double precision, parameter :: tight_tolerance = 1D-14, loose_tolerance = 1D-11, rough_tolerance = 1D-06, crude_tolerance = 1D-02

contains

  pure function subject() result(test_subject)
    character(len=:), allocatable :: test_subject
    test_subject = 'A 1D mimetic laplacian operator'
  end function

  function results() result(test_results)
    type(laplacian_operator_1D_test_t) laplacian_operator_1D_test
    type(test_result_t), allocatable :: test_results(:)

    test_results = laplacian_operator_1D_test%run([ & 
       test_description_t( &
          'computing 2nd-order .laplacian. [(x**2)/2] within ' // string_t(tight_tolerance) &
         ,usher(check_2nd_order_laplacian_parabola)) &
      ,test_description_t( &
          'computing 4th-order .laplacian. [(x**4)/12] within ' // string_t(loose_tolerance) &
         ,usher(check_4th_order_laplacian_of_quartic)) &
      ,test_description_t( &
          'computing convergence rate of 2 for 2nd-order .laplacian. [sin(x) + cos(x)] within ' // string_t(crude_tolerance) &
         ,usher(check_2nd_order_laplacian_convergence)) &
      ,test_description_t( &
          'computing convergence rate of 4 for 4th-order .laplacian. [sin(x) + cos(x)] within ' // string_t(crude_tolerance) &
         ,usher(check_4th_order_laplacian_convergence)) &
    ])
  end function

  pure function parabola(x) result(y)
    double precision, intent(in) :: x(:)
    double precision, allocatable :: y(:)
    y = (x**2)/2
  end function

  function check_2nd_order_laplacian_parabola() result(test_diagnosis)
    type(test_diagnosis_t) test_diagnosis
    procedure(scalar_1D_initializer_i), pointer :: scalar_1D_initializer => parabola
    double precision, parameter :: expected_laplacian = 1D0

    associate(laplacian_scalar => .laplacian. scalar_1D_t(scalar_1D_initializer, order=2, cells=5, x_min=0D0, x_max=5D0))
      test_diagnosis = .all. (laplacian_scalar%values() .approximates. expected_laplacian .within. tight_tolerance) &
                     // " (2nd-order .laplacian. [(x**2)/2]"
    end associate

  end function

  pure function quartic(x) result(y)
    double precision, intent(in) :: x(:)
    double precision, allocatable :: y(:)
    y = (x**4)/12
  end function

  function check_4th_order_laplacian_of_quartic() result(test_diagnosis)
    type(test_diagnosis_t) test_diagnosis
    procedure(scalar_1D_initializer_i), pointer :: scalar_1D_initializer => quartic

    associate(laplacian_quartic => .laplacian. scalar_1D_t(scalar_1D_initializer, order=4, cells=20, x_min=0D0, x_max=40D0))
      associate(x => laplacian_quartic%grid())
        associate(expected_laplacian => x**2, actual_laplacian => laplacian_quartic%values())
#if WRITE_GNUPLOT_FILE
          associate(plot=> gnuplot(string_t([character(len=10)::"x","expected","actual"]), x, expected_laplacian, actual_laplacian))
            call plot%write_lines()
          end associate
#endif
          test_diagnosis = .all. (actual_laplacian .approximates. expected_laplacian .within. loose_tolerance) &
            // " (4th-order .laplacian. [(x**4)/24]"
        end associate
      end associate
    end associate

  end function

  pure function sinusoid(x) result(y)
    double precision, intent(in) :: x(:)
    double precision, allocatable :: y(:)
    y = sin(x) + cos(x)
  end function

  function check_2nd_order_laplacian_convergence() result(test_diagnosis)
    type(test_diagnosis_t) test_diagnosis
    procedure(scalar_1D_initializer_i), pointer :: scalar_1D_initializer => sinusoid
    double precision, parameter :: pi = 3.141592653589793D0
    integer, parameter :: order_desired = 2, coarse_cells=1000, fine_cells=1800

    associate( &
       laplacian_coarse => .laplacian. scalar_1D_t(scalar_1D_initializer , order=order_desired, cells=coarse_cells, x_min=0D0, x_max=2*pi) &
      ,laplacian_fine  => .laplacian. scalar_1D_t(scalar_1D_initializer , order=order_desired, cells=fine_cells  , x_min=0D0, x_max=2*pi) &
    )
      associate( &
         x_coarse => laplacian_coarse%grid() &
        ,x_fine   => laplacian_fine%grid())
        associate( &
           expected_coarse => -sin(x_coarse) - cos(x_coarse) &
          ,expected_fine   => -sin(x_fine)   - cos(x_fine) &
          ,actual_coarse => laplacian_coarse%values() &
          ,actual_fine   => laplacian_fine%values() &
        )
          test_diagnosis = &
             .all. (actual_coarse .approximates. expected_coarse .within. crude_tolerance) &
            // " (coarse-grid 2nd-order .laplacian. [sin(x) + cos(x)])"
          test_diagnosis = test_diagnosis .also. &
            (.all. (actual_fine .approximates. expected_fine .within. crude_tolerance)) &
            // " (fine-grid 2nd-order .laplacian. [sin(x) + cos(x)])"
          associate( &
             coarse_error_max => maxval(abs(actual_coarse - expected_coarse)) &
            ,fine_error_max   => maxval(abs(actual_fine   - expected_fine)) &
          )
            associate(order_actual => log(coarse_error_max/fine_error_max)/log(dble(fine_cells)/coarse_cells))
              test_diagnosis = test_diagnosis .also. (order_actual .approximates. dble(order_desired) .within. crude_tolerance) &
                // " (convergence rate for 2nd-order .laplacian. [sin(x) + cos(x)])"
            end associate
          end associate
        end associate
      end associate
    end associate
  end function

  function check_4th_order_laplacian_convergence() result(test_diagnosis)
    type(test_diagnosis_t) test_diagnosis
    procedure(scalar_1D_initializer_i), pointer :: scalar_1D_initializer => sinusoid
    double precision, parameter :: pi = 3.141592653589793D0
    integer, parameter :: order_desired = 4, coarse_cells=300, fine_cells=1800

    associate( &
       laplacian_coarse => .laplacian. scalar_1D_t(scalar_1D_initializer , order=order_desired, cells=coarse_cells, x_min=0D0, x_max=2*pi) &
      ,laplacian_fine   => .laplacian. scalar_1D_t(scalar_1D_initializer , order=order_desired, cells=fine_cells  , x_min=0D0, x_max=2*pi) &
    )
      associate( &
         x_coarse => laplacian_coarse%grid() &
        ,x_fine   => laplacian_fine%grid()  &
      )
        associate( &
           expected_coarse => -sin(x_coarse) - cos(x_coarse) &
          ,expected_fine   => -sin(x_fine)   - cos(x_fine) &
          ,actual_coarse => laplacian_coarse%values() &
          ,actual_fine   => laplacian_fine%values() &
        )
          test_diagnosis = &
             .all. (actual_coarse .approximates. expected_coarse .within. rough_tolerance) &
             // " (coarse-grid 4th-order .laplacian. [sin(x) + cos(x)])"
          test_diagnosis = test_diagnosis .also. &
            (.all. (actual_fine .approximates. expected_fine .within. rough_tolerance)) &
             // " (fine-grid 4th-order .laplacian. [sin(x) + cos(x)])"
          associate( &
             error_coarse_max => maxval(abs(actual_coarse - expected_coarse)) &
            ,error_fine_max   => maxval(abs(actual_fine   - expected_fine)) &
          )
            associate(order_actual => log(error_coarse_max/error_fine_max)/log(dble(fine_cells)/coarse_cells))
              test_diagnosis = test_diagnosis .also. (order_actual .approximates. dble(order_desired) .within. crude_tolerance) &
                // " (convergence rate for 4th-order .laplacian. [sin(x) + cos(x)])"
            end associate
          end associate
        end associate
      end associate
    end associate
  end function

  pure function gnuplot(headings, abscissa, expected, actual) result(file)
    double precision, intent(in), dimension(:) :: abscissa, expected, actual
    type(string_t), intent(in) :: headings(:)
    type(file_t) file
    integer line
    file = file_t([ &
       headings .separatedBy. "       " &
      ,[( string_t(abscissa(line)) // "   " // string_t(expected(line)) // "   " // string_t(actual(line)), line = 1, size(abscissa))] &
    ])
  end function
  
end module
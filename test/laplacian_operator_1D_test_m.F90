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
#ifdef __GFORTRAN__
  use mole_m, only : laplacian_1D_t
#endif
  implicit none

  type, extends(test_t) :: laplacian_operator_1D_test_t
  contains
    procedure, nopass :: subject
    procedure, nopass :: results
  end type

  double precision, parameter :: tight_tolerance = 1D-14, loose_tolerance = 1D-09, crude_tolerance = 1D-02

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
          'converging as dx^2 internally and dx near boundary for 2nd-order .laplacian. sin(x) within ' // string_t(crude_tolerance) &
         ,usher(check_2nd_order_laplacian_convergence)) &
      ,test_description_t( &
          'converging as dx^4 internally and dx^3 near boundary for 4th-order .laplacian. sin(x) within ' // string_t(crude_tolerance) &
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
#ifdef __GFORTRAN__
    type(laplacian_1D_t) laplacian_scalar
    laplacian_scalar = .laplacian. scalar_1D_t(scalar_1D_initializer, order=2, cells=5, x_min=0D0, x_max=5D0)
#else
    associate(laplacian_scalar => .laplacian. scalar_1D_t(scalar_1D_initializer, order=2, cells=5, x_min=0D0, x_max=5D0))
#endif
      test_diagnosis = .all. (laplacian_scalar%values() .approximates. expected_laplacian .within. tight_tolerance) &
        // " (2nd-order .laplacian. [(x**2)/2]"
#ifndef __GFORTRAN__
    end associate
#endif
  end function

  pure function quartic(x) result(y)
    double precision, intent(in) :: x(:)
    double precision, allocatable :: y(:)
    y = (x**4)/12
  end function

  function check_4th_order_laplacian_of_quartic() result(test_diagnosis)
    type(test_diagnosis_t) test_diagnosis
    procedure(scalar_1D_initializer_i), pointer :: scalar_1D_initializer => quartic

#ifndef __GFORTRAN__
    associate(laplacian_quartic => .laplacian. scalar_1D_t(scalar_1D_initializer, order=4, cells=20, x_min=0D0, x_max=40D0))
#else
    type(laplacian_1D_t) laplacian_quartic
    laplacian_quartic = .laplacian. scalar_1D_t(scalar_1D_initializer, order=4, cells=20, x_min=0D0, x_max=40D0)
#endif
      associate(x => laplacian_quartic%grid())
        associate(expected_laplacian => x**2, actual_laplacian => laplacian_quartic%values())
          test_diagnosis = .all. (actual_laplacian .approximates. expected_laplacian .within. loose_tolerance) &
            // " (4th-order .laplacian. [(x**4)/24]"
        end associate
      end associate
#ifndef __GFORTRAN__
    end associate
#endif
  end function

  pure function f(x)
    double precision, intent(in) :: x(:)
    double precision, allocatable :: f(:)
    f = sin(x)
  end function

  pure function d2f_dx2(x)
    double precision, intent(in) :: x(:)
    double precision, allocatable :: d2f_dx2(:)
    d2f_dx2 = -sin(x)
  end function

  function check_2nd_order_laplacian_convergence() result(test_diagnosis)
    type(test_diagnosis_t) test_diagnosis
    test_diagnosis = check_laplacian_convergence(order_desired=2, coarse_cells=500, fine_cells=1000)
  end function

  function check_4th_order_laplacian_convergence() result(test_diagnosis)
    type(test_diagnosis_t) test_diagnosis
    test_diagnosis = check_laplacian_convergence(order_desired = 4, coarse_cells=100, fine_cells=200)
  end function

  function check_laplacian_convergence(order_desired, coarse_cells, fine_cells) result(test_diagnosis)
    type(test_diagnosis_t) test_diagnosis
    procedure(scalar_1D_initializer_i), pointer :: scalar_1D_initializer => f
    double precision, parameter :: pi = 3.141592653589793D0
    integer, intent(in) :: order_desired, coarse_cells, fine_cells

#ifndef __GFORTRAN__
    associate( &
       laplacian_coarse => .laplacian. scalar_1D_t(scalar_1D_initializer , order=order_desired, cells=coarse_cells, x_min=0D0, x_max=2*pi) &
      ,laplacian_fine   => .laplacian. scalar_1D_t(scalar_1D_initializer , order=order_desired, cells=fine_cells  , x_min=0D0, x_max=2*pi) &
    )
#else
       type(laplacian_1D_t) laplacian_coarse, laplacian_fine
       laplacian_coarse = .laplacian. scalar_1D_t(scalar_1D_initializer , order=order_desired, cells=coarse_cells, x_min=0D0, x_max=2*pi)
       laplacian_fine   = .laplacian. scalar_1D_t(scalar_1D_initializer , order=order_desired, cells=fine_cells  , x_min=0D0, x_max=2*pi)
#endif
      grids: &
      associate( &
         x_coarse => laplacian_coarse%grid() &
        ,x_fine   => laplacian_fine%grid())

        laplacian_values: &
        associate( &
           expected_coarse => d2f_dx2(x_coarse) &
          ,expected_fine   => d2f_dx2(x_fine) &
          ,actual_coarse => laplacian_coarse%values() &
          ,actual_fine   => laplacian_fine%values() &
          ,depth => laplacian_coarse%reduced_order_boundary_depth()  &
        )
          test_diagnosis = &
            .all. (actual_coarse .approximates. expected_coarse .within. crude_tolerance) &
            // " (coarse-grid 2nd-order .laplacian. sin(x))"

          test_diagnosis = test_diagnosis .also. &
            (.all. (actual_fine .approximates. expected_fine .within. crude_tolerance)) &
            // " (fine-grid 2nd-order .laplacian. sin(x))"

          check_internal_convergence_rate: &
          associate( &
             coarse_error_max => maxval( abs( &
               actual_coarse(1+depth:size(actual_coarse)-depth) - expected_coarse(1+depth:size(expected_coarse)-depth) &
             )) &
            ,fine_error_max   => maxval( abs( &
               actual_fine(1+depth:size(actual_fine)-depth) - expected_fine(1+depth:size(expected_fine)-depth) &
          )  ))
            associate(order_actual => log(coarse_error_max/fine_error_max)/log(dble(fine_cells)/coarse_cells))
              test_diagnosis = test_diagnosis .also. (order_actual .approximates. dble(order_desired) .within. crude_tolerance) &
                // " (boundary convergence rate as dx^" // string_t(order_desired) // " for .laplacian. sin(x))"
            end associate
          end associate check_internal_convergence_rate

          check_boundary_convergence_rate: &
          associate( &
             coarse_error_max => maxval( abs( &
                [  actual_coarse(1:depth-1),   actual_coarse(size(actual_coarse)-depth+1:)] &
               -[expected_coarse(1:depth-1), expected_coarse(size(actual_coarse)-depth+1:)] &
             )) &
            ,fine_error_max   => maxval( abs( &
                [  actual_fine(1:depth-1),   actual_fine(size(actual_fine)-depth+1:)] &
               -[expected_fine(1:depth-1), expected_fine(size(actual_fine)-depth+1:)] &
          )  ))
            associate(order_actual => log(coarse_error_max/fine_error_max)/log(dble(fine_cells)/coarse_cells))
              test_diagnosis = test_diagnosis .also. (order_actual .approximates. dble(order_desired-1) .within. crude_tolerance) &
                // " (boundary convergence rate as dx^" // string_t(order_desired-1) // " for .laplacian. sin(x))"
            end associate
          end associate check_boundary_convergence_rate

        end associate laplacian_values
      end associate grids
#ifndef __GFORTRAN__
    end associate
#endif
  end function

end module
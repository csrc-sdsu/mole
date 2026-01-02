module functions_m
  implicit none

contains

  pure function f(x)
    double precision, intent(in) :: x(:)
    double precision, allocatable :: f(:)
    f = (x**3)/6 + (x**2)/2 + 1
  end function

  double precision elemental function df_dx(x)
    double precision, intent(in) :: x
    df_dx = (x**2)/2 + x
  end function

  double precision elemental function d2f_dx2(x)
    double precision, intent(in) :: x
    d2f_dx2 = x + 1
  end function

end module functions_m

program div_grad_laplacian_1D
  !! Compute the 2nd- and 4th-order mimetic approximations to the gradient and Laplacian of the
  !! above function f(x) on a 1D uniform, staggered grid.
  use functions_m
  use julienne_m, only :  file_t, string_t, operator(.separatedBy.)
  use mole_m, only : scalar_1D_t, scalar_1D_initializer_i
#ifdef __GFORTRAN__
  use mole_m, only : vector_1D_t, laplacian_1D_t, gradient_1D_t
#endif
  implicit none

  procedure(scalar_1D_initializer_i), pointer :: scalar_1D_initializer => f

  print *,new_line('')
  print *,"   Functions"
  print *,"   ========================"
  call execute_command_line("grep 'f =' example/div-grad-laplacian-1D.F90 | grep -v execute_command", wait=.true.)
  call execute_command_line("grep 'df_dx =' example/div-grad-laplacian-1D.F90 | grep -v execute_command", wait=.true.)
  call execute_command_line("grep 'd2f_dx2 =' example/div-grad-laplacian-1D.F90 | grep -v execute_command", wait=.true.)

  print *,new_line('')
  print *,"   2nd-order approximations"
  print *,"   ========================"

  call output(order=2)

  print *,new_line('')
  print *,"   4th-order approximations"
  print *,"   ========================"

  call output(order=4)

contains

#ifndef __GFORTRAN__

  subroutine output(order)
    integer, intent(in) :: order
  
    associate(   s           => scalar_1D_t(scalar_1D_initializer, order=order, cells=20, x_min=0D0, x_max=20D0))
      associate( grad_s      => .grad. s &
                ,laplacian_s => .laplacian. s)
        associate( s_grid           => s%grid()      &
                  ,grad_s_grid      => grad_s%grid() &
                  ,laplacian_s_grid => laplacian_s%grid())
          associate( s_table           => tabulate( &
                        string_t([character(len=22)::"x", "f(x) expected"         , "f(x) actual"         ]) &
                       ,s_grid, f(s_grid), s%values() &
                     ) &
                    ,grad_s_table      => tabulate( &
                       string_t([character(len=22)::"x", ".grad. f expected"     , ".grad. f actual"     ])  &
                      ,grad_s_grid, df_dx(grad_s_grid), grad_s%values() &
                     ) &
                    ,laplacian_s_table => tabulate( &
                       string_t([character(len=22)::"x", ".laplacian. f expected", ".laplacian. f actual"])  &
                      ,laplacian_s_grid, d2f_dx2(laplacian_s_grid), laplacian_s%values()) &
                     )
             call s_table%write_lines()
             call grad_s_table%write_lines()
             call laplacian_s_table%write_lines()
          end associate
        end associate
      end associate
    end associate
  end subroutine

#else

  subroutine output(order)
    integer, intent(in) :: order
  
    type(scalar_1D_t) s
    type(gradient_1D_t) grad_s
    type(laplacian_1D_t) laplacian_s
    type(file_t) s_table, grad_s_table, laplacian_s_table
    double precision, allocatable,dimension(:) :: s_grid, grad_s_grid, laplacian_s_grid

    s = scalar_1D_t(scalar_1D_initializer, order=order, cells=20, x_min=0D0, x_max=20D0)
    grad_s = .grad. s
    laplacian_s = .laplacian. s

    s_grid = s%grid()
    grad_s_grid = grad_s%grid()
    laplacian_s_grid = laplacian_s%grid()

    s_table           = tabulate( &
       string_t([character(len=22)::"x", "f(x) expected"         , "f(x) actual"         ]) &
      ,s_grid, f(s_grid), s%values() &
    )
    grad_s_table      = tabulate( &
       string_t([character(len=22)::"x", ".grad. f expected"     , ".grad. f actual"     ]) &
      ,grad_s_grid, df_dx(grad_s_grid), grad_s%values() &
    )
    laplacian_s_table = tabulate( &
       string_t([character(len=22)::"x", ".laplacian. f expected", ".laplacian. f actual"]) &
      ,laplacian_s_grid, d2f_dx2(laplacian_s_grid), laplacian_s%values() &
    )
    call s_table%write_lines()
    call grad_s_table%write_lines()
    call laplacian_s_table%write_lines()
  end subroutine

#endif

  pure function tabulate(headings, abscissa, expected, actual) result(file)
    double precision, intent(in), dimension(:) :: abscissa, expected, actual
    type(string_t), intent(in) :: headings(:)
    type(file_t) file
    integer line

    file = file_t([ &
       string_t("") &
      ,headings .separatedBy. "  " &
      ,string_t("------------------------------------------------------------------") &
      ,[( string_t(abscissa(line)) // "          " // string_t(expected(line)) // "          " // string_t(actual(line)), line = 1, size(abscissa))] &
    ])
  end function

end program

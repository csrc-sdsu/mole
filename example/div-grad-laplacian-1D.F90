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
  use functions_m
  use julienne_m, only :  file_t, string_t, operator(.separatedBy.)
  use mole_m, only : scalar_1D_t, scalar_1D_initializer_i
#ifdef __GFORTRAN__
  use mole_m, only : vector_1D_t, laplacian_1D_t
#endif
  implicit none

  procedure(scalar_1D_initializer_i), pointer :: scalar_1D_initializer => f

  print *,new_line('')
  print *,"            2nd-order approximations"
  print *,"            ========================"

  call output(order=2)

  print *,new_line('')
  print *,"            4th-order approximations"
  print *,"            ========================"

  call output(order=4)

contains

  subroutine output(order)
    integer, intent(in) :: order
  
#ifdef __GFORTRAN__
    type(scalar_1D_t) s
    type(vector_1D_t) grad_s
    type(laplacian_1D_t) laplacian_s
    type(file_t) s_table, grad_s_table, laplacian_s_table

    s           = scalar_1D_t(scalar_1D_initializer, order=order, cells=10, x_min=0D0, x_max=20D0)
    grad_s      = .grad. s
    laplacian_s = .laplacian. s
#else
    associate(   s           => scalar_1D_t(scalar_1D_initializer, order=order, cells=10, x_min=0D0, x_max=20D0))
      associate( grad_s      => .grad. s      &
                ,laplacian_s => .laplacian. s &
      )
#endif
        associate( s_grid           => s%grid() &
                  ,grad_s_grid      => grad_s%grid() &
                  ,laplacian_s_grid => laplacian_s%grid() &
        )
#ifndef __GFORTRAN__
          associate( &
             s_table => tabulate(string_t([character(len=18)::"x", "f(x) exp"         , "f(x) act"         ]), s_grid, f(s_grid), s%values()) &
            ,grad_s_table => tabulate(string_t([character(len=18)::"x", ".grad. f exp"     , ".grad. f act"     ]), grad_s_grid, df_dx(grad_s_grid), grad_s%values()) &
            ,laplacian_s_table => tabulate(string_t([character(len=18)::"x", ".laplacian. f exp", ".laplacian. f act"]), laplacian_s_grid, d2f_dx2(laplacian_s_grid), laplacian_s%values()) &
          )
#else
             s_table = tabulate(string_t([character(len=18)::"x", "f(x) exp."         , "f(x) act."         ]), s_grid, f(s_grid), s%values())
             grad_s_table = tabulate(string_t([character(len=18)::"x", ".grad. f exp."     , ".grad. f act."     ]), grad_s_grid, df_dx(grad_s_grid), grad_s%values())
             laplacian_s_table = tabulate(string_t([character(len=18)::"x", ".laplacian. f exp.", ".laplacian. f act."]), laplacian_s_grid, d2f_dx2(laplacian_s_grid), laplacian_s%values())
#endif
             call s_table%write_lines()
             call grad_s_table%write_lines()
             call laplacian_s_table%write_lines()
          end associate
#ifndef __GFORTRAN__
        end associate
      end associate
    end associate
#endif
  end subroutine


  pure function tabulate(headings, abscissa, expected, actual) result(file)
    double precision, intent(in), dimension(:) :: abscissa, expected, actual
    type(string_t), intent(in) :: headings(:)
    type(file_t) file
    integer line

    file = file_t([ &
       string_t("") &
      ,headings .separatedBy. "  " &
      ,string_t("----------------------------------------------------------") &
      ,[( string_t(abscissa(line)) // "      " // string_t(expected(line)) // "        " // string_t(actual(line)), line = 1, size(abscissa))] &
    ])
  end function

end program

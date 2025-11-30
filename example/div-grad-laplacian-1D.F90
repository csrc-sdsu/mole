module functions_m
  implicit none

contains

  pure function f(x)
    double precision, intent(in) :: x(:)
    double precision, allocatable :: f(:)
    f = (x**3)/6
  end function

  double precision elemental function df_dx(x)
    double precision, intent(in) :: x
    df_dx = (x**2)/2
  end function

  double precision elemental function d2f_dx2(x)
    double precision, intent(in) :: x
    d2f_dx2 = x
  end function

end module functions_m

program div_grad_laplacian_1D
  use functions_m
  use julienne_m, only :  file_t, string_t, operator(.separatedBy.)
  use mole_m, only : scalar_1D_t, scalar_1D_initializer_i
  implicit none

  procedure(scalar_1D_initializer_i), pointer :: scalar_1D_initializer => f

  print *,"Grid        Expected Values    Actual Values"

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
    use iso_fortran_env, only : output_unit
    integer, intent(in) :: order
  
    associate(   s           => scalar_1D_t(scalar_1D_initializer, order=order, cells=20, x_min=0D0, x_max=40D0))
      associate( grad_s      => .grad. s      &
                ,laplacian_s => .laplacian. s &
      )
        associate( s_grid           => s%grid() &
                  ,grad_s_grid      => grad_s%grid() &
                  ,laplacian_s_grid => laplacian_s%grid() &
        )
          associate( plot => gnuplot(string_t([character(len=15)::"x", "f(x)"         , "f(x)"         ]), s_grid, f(s_grid), s%values()))
             call plot%write_lines()
          end associate
          associate( plot => gnuplot(string_t([character(len=15)::"x", ".div. f"      , ".div. f"      ]), grad_s_grid, df_dx(grad_s_grid), grad_s%values()))
             call plot%write_lines()
          end associate

          associate( plot => gnuplot(string_t([character(len=15)::"x", ".laplacian. f", ".laplacian. f"]), laplacian_s_grid, d2f_dx2(laplacian_s_grid), laplacian_s%values()))
             call plot%write_lines()
          end associate
        end associate
      end associate
    end associate

  end subroutine


  pure function gnuplot(headings, abscissa, expected, actual) result(file)
    double precision, intent(in), dimension(:) :: abscissa, expected, actual
    type(string_t), intent(in) :: headings(:)
    type(file_t) file
    integer line

    file = file_t([ &
       string_t("") &
      ,headings .separatedBy. "  " &
      ,string_t("------------------------------------------------") &
      ,[( string_t(abscissa(line)) // "   " // string_t(expected(line)) // "   " // string_t(actual(line)), line = 1, size(abscissa))] &
    ])
  end function

end program

program print_assembled_1D_operators
  !! Print fully assembled memetic 1D gradient, divergence, and Laplacian matrices,
  !! including the zero elements.
  use julienne_m, only : operator(.csv.), string_t, command_line_t
  use mimetic_operators_1D_m, only : gradient_operator_1D_t, divergence_operator_1D_t
  implicit none

  type(command_line_t) command_line
  integer row

  command_line_settings: &
  associate( &
     gradient   => command_line%argument_present(["--grad" ]) &
    ,divergence => command_line%argument_present(["--div"  ]) &
    ,order      => command_line%flag_value("--order") &
  )

    if (command_line%argument_present([character(len=len("--help")) :: ("--help"), "-h"])) then
      stop                                 new_line('') // new_line('') &
        // 'Usage:'                                     // new_line('') &
        // '  fpm run \'                                // new_line('') &
        // '  --example print-assembled-1D-operators \' // new_line('') &
        // '  --compiler flang-new \'                   // new_line('') &
        // '  --flag "-O3" \'                           // new_line('') & 
        // '  -- [--help|-h] | [--grad]  [--div] [--order <integer>]' // new_line('') // new_line('') &
        // 'where square brackets indicate optional arguments and angular brackets indicate user input values.' // new_line('')
    end if

    default_usage: &
    associate(print_all => .not. any([gradient, divergence, len(order)/=0]))

      if (print_all .or. (gradient   .and. len(order)==0) .or. (gradient   .and. order=="2")) call print_gradient_operator(  k=2, dx=1D0, m=5)
      if (print_all .or. (divergence .and. len(order)==0) .or. (divergence .and. order=="2")) call print_divergence_operator(k=2, dx=1D0, m=5)
      if (print_all .or. (gradient   .and. len(order)==0) .or. (gradient   .and. order=="4")) call print_gradient_operator(  k=4, dx=1D0, m=9)
      if (print_all .or. (divergence .and. len(order)==0) .or. (divergence .and. order=="4")) call print_divergence_operator(k=4, dx=1D0, m=9)

    end associate default_usage
  end associate command_line_settings

contains

  subroutine print_gradient_operator(k, dx, m)
    integer, intent(in) :: k, m 
    double precision, intent(in) :: dx

    print *, new_line(""), "Gradient operator: order = ", k, " | cells = ", m, " | dx = ", dx

    associate(grad_op => gradient_operator_1D_t(k, dx, cells=m))
      associate(G => grad_op%assemble())
        do row = 1, size(G,1)
          associate(csv_row => .csv. string_t(G(row,:)))
            print '(a)', csv_row%string()
          end associate
        end do
      end associate
    end associate

  end subroutine

  subroutine print_divergence_operator(k, dx, m)
    integer, intent(in) :: k, m 
    double precision, intent(in) :: dx

    print *, new_line(""), "Divergence operator: order = ", k, " | cells = ", m, " | dx = ", dx

    associate(div_op => divergence_operator_1D_t(k, dx, cells=m))
      associate(D => div_op%assemble())
        do row = 1, size(D,1)
          associate(csv_row => .csv. string_t(D(row,:)))
            print '(a)', csv_row%string()
          end associate
        end do
      end associate
    end associate

  end subroutine

end program

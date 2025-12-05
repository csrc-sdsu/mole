program print_assembled_1D_operators
  !! Print fully assembled memetic 1D gradient, divergence, and Laplacian matrices,
  !! including the zero elements.
  use julienne_m, only : operator(.csv.), string_t
  use mimetic_operators_1D_m, only : gradient_operator_1D_t, divergence_operator_1D_t
  implicit none

  integer row

  print *, new_line(""), "Gradient operator (2nd order, dx=1, 5 cells)"

  associate(grad_2nd_order => gradient_operator_1D_t(k=2, dx=1D0, cells=5))
    associate(G => grad_2nd_order%assemble())
      do row = 1, size(G,1)
        associate(csv_row => .csv. string_t(G(row,:)))
          print '(a)', csv_row%string()
        end associate
      end do
    end associate
  end associate

  print *, new_line(""), "Divergence operator (2nd order, dx=1, 5 cells)"
  
  associate(div_2nd_order => divergence_operator_1D_t(k=2, dx=1D0, cells=5))
    associate(D => div_2nd_order%assemble())
      do row = 1, size(D,1)
        associate(csv_row => .csv. string_t(D(row,:)))
          print '(a)', csv_row%string()
        end associate
      end do
    end associate
  end associate

  print *, new_line(""), "Gradient operator (4th order, dx=1, 9 cells)"

  associate(grad_4th_order => gradient_operator_1D_t(k=4, dx=1D0, cells=9))
    associate(G => grad_4th_order%assemble())
      do row = 1, size(G,1)
        associate(csv_row => .csv. string_t(G(row,:)))
          print '(a)', csv_row%string()
        end associate
      end do
    end associate
  end associate

  print *, new_line(""), "Divergence operator (4th order, dx=1, 9 cells)"

  associate(div_op => divergence_operator_1D_t(k=4, dx=1D0, cells=9))
    associate(D => div_op%assemble())
      do row = 1, size(D,1)
        associate(csv_row => .csv. string_t(D(row,:)))
          print '(a)', csv_row%string()
        end associate
      end do
    end associate
  end associate

end program

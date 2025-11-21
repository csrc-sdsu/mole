submodule(tensors_1D_m) grid_s
  implicit none
contains

  pure function cell_centers(x_min, x_max, cells) result(x)
    double precision, intent(in) :: x_min, x_max
    integer, intent(in) :: cells
    double precision, allocatable:: x(:)
    integer cell

    associate(dx => (x_max - x_min)/cells)
      x = x_min + dx/2. + [((cell-1)*dx, cell = 1, cells)]
    end associate
  end function

  module procedure cell_centers_extended
    associate(dx => (x_max - x_min)/cells)
      x = [x_min, cell_centers(x_min, x_max, cells), x_max]
    end associate
  end procedure

end submodule grid_s
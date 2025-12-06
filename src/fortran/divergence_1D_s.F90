submodule(tensors_1D_m) divergence_1D_s
  implicit none

contains

#ifdef __GFORTRAN__

  pure function cell_center_locations(x_min, x_max, cells) result(x)
    double precision, intent(in) :: x_min, x_max
    integer, intent(in) :: cells
    double precision, allocatable:: x(:)
    integer cell

    associate(dx => (x_max - x_min)/cells)
      x = x_min + dx/2. + [((cell-1)*dx, cell = 1, cells)]
    end associate
  end function

#endif

  module procedure construct_from_tensor
    divergence_1D%tensor_1D_t = tensor_1D
  end procedure

  module procedure divergence_1D_values
    cell_centered_values = self%values_
  end procedure

  module procedure divergence_1D_grid
    cell_centers = cell_center_locations(self%x_min_, self%x_max_, self%cells_)
  end procedure

end submodule divergence_1D_s
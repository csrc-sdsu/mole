submodule(tensors_1D_m) divergence_1D_s
  implicit none

contains

  module procedure divergence_1D_values
    cell_centered_values = self%values_
  end procedure

  module procedure divergence_1D_grid
    cell_centers = cell_center_locations(self%x_min_, self%x_max_, self%cells_)
  end procedure

end submodule divergence_1D_s
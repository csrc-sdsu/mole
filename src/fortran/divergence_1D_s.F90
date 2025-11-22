submodule(tensors_1D_m) divergence_1D_s
  implicit none

contains

  module procedure construct_divergence_from_components
    divergence_1D%scalar_1D_ = cell_centered_values
    divergence_1D%x_min_ = x_min
    divergence_1D%x_max_ = x_max
    divergence_1D%cells_ = cells
  end procedure

end submodule divergence_1D_s
submodule(tensors_1D_m) gradient_1D_s
  implicit none

contains

  module procedure construct_gradient_from_components
    gradient_1D%vector_1D_ = face_centered_values
    gradient_1D%x_min_ = x_min
    gradient_1D%x_max_ = x_max
    gradient_1D%cells_ = cells
  end procedure

end submodule gradient_1D_s
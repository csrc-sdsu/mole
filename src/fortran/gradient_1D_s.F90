submodule(tensors_1D_m) gradient_1D_s
  implicit none

contains

  module procedure construct_from_components
    gradient_1D%vector_1D_ = face_centered_values
    gradient_1D%x_min_ = x_min
    gradient_1D%x_max_ = x_max
    gradient_1D%cells_ = cells
  end procedure

  module procedure values
    gradients =  self%vector_1D_
  end procedure

  module procedure faces
    integer cell
    x = [ self%x_min_ &
         ,self%x_min_ + [(cell*(self%x_max_ - self%x_min_)/self%cells_, cell = 1, self%cells_-1)] &
         ,self%x_max_ &
        ]
  end procedure

end submodule gradient_1D_s
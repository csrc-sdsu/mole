submodule(face_values_m) gradient_s
  implicit none

contains

  module procedure values
    gradients =  self%g_
  end procedure

end submodule gradient_s
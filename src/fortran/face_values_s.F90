submodule(face_values_m) face_values_s
  implicit none

contains

  module procedure construct
    face_values%f_ = f
    face_values%gradient_operator_ = gradient_operator_t(k, dx)
  end procedure

  module procedure grad
    grad_f = self%gradient_operator_%mimetic_matrix_ .x. self
  end procedure

end submodule face_values_s
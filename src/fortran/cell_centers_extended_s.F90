submodule(cell_centers_extended_m) cell_centers_extended_s
  implicit none

contains

  module procedure construct
    cell_centers_extended%f_ = f
    cell_centers_extended%gradient_operator_ = gradient_operator_t(k, dx)
  end procedure

  module procedure grad
    grad_f = self%gradient_operator_%mimetic_matrix_ .x. self
  end procedure

end submodule cell_centers_extended_s
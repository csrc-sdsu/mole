submodule(grad_op_m) grad_op_s
  implicit none

contains

  module procedure grad_op_1D
    grad_op%k_ = k
    grad_op%m_ = m
    grad_op%dx_ = dx
  end procedure

end submodule grad_op_s

submodule(tensors_1D_m) tensor_1D_s
  implicit none
contains

  module procedure construct_1D_tensor_from_components
    tensor_1D%values_ = values
    tensor_1D%x_min_  = x_min
    tensor_1D%x_max_  = x_max
    tensor_1D%cells_  = cells 
    tensor_1D%order_  = order
  end procedure

end submodule tensor_1D_s

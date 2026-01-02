#include "julienne-assert-macros.h"

submodule(tensors_1D_m) vector_dot_gradient_1D_s
  use julienne_m, only: call_julienne_assert_, operator(.equalsExpected.)
  implicit none

contains

  module procedure volume_integrate_vector_dot_grad_scalar_1D
    call_julienne_assert(size(integrand%weights_ ) .equalsExpected. size(integrand%values_))
    integral  = sum(integrand%weights_ * integrand%values_)
  end procedure

end submodule vector_dot_gradient_1D_s

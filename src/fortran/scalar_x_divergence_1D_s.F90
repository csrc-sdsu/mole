#include "julienne-assert-macros.h"

submodule(tensors_1D_m) scalar_x_divergence_1D_s
  use julienne_m, only : call_julienne_assert_, operator(.equalsExpected.)
  implicit none

contains

  module procedure volume_integrate_scalar_x_divergence_1D
    call_julienne_assert(size(integrand%weights_ ) .equalsExpected. size(integrand%values_)+2)
    integral  = sum(integrand%weights_ * [0D0, integrand%values_, 0D0])
  end procedure

end submodule scalar_x_divergence_1D_s

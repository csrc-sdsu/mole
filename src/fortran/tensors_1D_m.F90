#include "mole-language-support.F90"

module tensors_1D_m
  !! Define public 1D scalar and vector abstractions and associated mimetic gradient,
  !! divergence, and Laplacian operators as detailed by Corbino & Castillo (2020)
  !! https://doi.org/10.1016/j.cam.2019.06.042.
  use julienne_m, only : file_t
  use mimetic_operators_1D_m, only : divergence_operator_1D_t, gradient_operator_1D_t
    
  implicit none

  private

  public :: scalar_1D_t
  public :: vector_1D_t
  public :: gradient_1D_t
  public :: laplacian_1D_t
  public :: divergence_1D_t
  public :: scalar_1D_initializer_i
  public :: vector_1D_initializer_i

  abstract interface

    pure function scalar_1D_initializer_i(x) result(f)
      !! Sampling function for initializing a scalar_1D_t object
      implicit none
      double precision, intent(in) :: x(:)
      double precision, allocatable :: f(:)
    end function

    pure function vector_1D_initializer_i(x) result(v)
      !! Sampling function for initializing a vector_1D_t object
      implicit none
      double precision, intent(in) :: x(:)
      double precision, allocatable :: v(:)
    end function

  end interface

  type tensor_1D_t
    !! Encapsulate the components that are common to all 1D tensors.
    !! Child types define the operations supported by each child, including
    !! gradient (.grad.) for scalars and divergence (.div.) for vectors.
    private
    double precision x_min_ !! domain lower boundary
    double precision x_max_ !! domain upper boundary
    integer cells_          !! number of grid cells spanning the domain
    integer order_          !! order of accuracy of mimetic discretization
    double precision, allocatable :: values_(:) !! tensor components at spatial locations
  contains
    procedure, non_overridable, private :: gradient_1D_weights
    procedure, non_overridable, private :: divergence_1D_weights
    generic :: dV => dx
    procedure, non_overridable :: dx
  end type

  interface tensor_1D_t

    pure module function construct_1D_tensor_from_components(values, x_min, x_max, cells, order) result(tensor_1D)
      !! User-defined constructor: result is a 1D tensor defined by assigning the dummy arguments to corresponding components
      implicit none
      double precision, intent(in) :: values(:) !! tensor components at grid locations define by child
      double precision, intent(in) :: x_min     !! grid location minimum
      double precision, intent(in) :: x_max     !! grid location maximum
      integer,          intent(in) :: cells     !! number of grid cells spanning the domain
      integer,          intent(in) :: order     !! order of accuracy
      type(tensor_1D_t) tensor_1D
    end function

  end interface

  type, extends(tensor_1D_t) :: scalar_1D_t
    !! Encapsulate scalar values at cell centers and boundaries
    private
    type(gradient_operator_1D_t) gradient_operator_1D_
  contains
    generic :: operator(.grad.) => grad
    generic :: operator(.laplacian.) => laplacian
    generic :: grid   => scalar_1D_grid
    generic :: values => scalar_1D_values
    procedure, non_overridable, private :: grad
    procedure, non_overridable, private :: laplacian
    procedure, non_overridable, private :: scalar_1D_values
    procedure, non_overridable, private :: scalar_1D_grid
  end type

  interface scalar_1D_t

    pure module function construct_1D_scalar_from_function(initializer, order, cells, x_min, x_max) result(scalar_1D)
      !! Result is a collection of cell-centered-extended values with a corresponding mimetic gradient operator
      implicit none
      procedure(scalar_1D_initializer_i), pointer :: initializer
      integer, intent(in) :: order !! order of accuracy
      integer, intent(in) :: cells !! number of grid cells spanning the domain
      double precision, intent(in) :: x_min !! grid location minimum
      double precision, intent(in) :: x_max !! grid location maximum
      type(scalar_1D_t) scalar_1D
    end function

  end interface

  type, extends(tensor_1D_t) :: vector_1D_t
    !! Encapsulate 1D vector values at cell faces (of unit area for 1D) and corresponding operators
    private
    type(divergence_operator_1D_t) divergence_operator_1D_
  contains
    generic :: operator(.x.)   => weighted_premultiply
    generic :: operator(.div.) => div
    generic :: operator(.dot.) => dot_surface_normal
    generic :: grid   => vector_1D_grid
    generic :: values => vector_1D_values
#ifdef __INTEL_COMPILER
    generic :: weights => gradient_1D_weights
#endif
    procedure, non_overridable :: dA
    procedure, non_overridable, pass(vector_1D) :: weighted_premultiply
    procedure, non_overridable, private :: div
    procedure, non_overridable, private :: dot_surface_normal
    procedure, non_overridable, private :: vector_1D_grid
    procedure, non_overridable, private :: vector_1D_values
  end type

  type, extends(tensor_1D_t) :: weighted_product_1D_t
  contains
    generic :: operator(.SS.) => surface_integrate_vector_x_scalar_1D
    procedure, non_overridable, private :: surface_integrate_vector_x_scalar_1D
  end type

  interface vector_1D_t

    pure module function construct_1D_vector_from_function(initializer, order, cells, x_min, x_max) result(vector_1D)
      !! Result is a 1D vector with values initialized by the provided procedure pointer sampled on the specified
      !! number of evenly spaced cells covering [x_min, x_max]
      implicit none
      procedure(vector_1D_initializer_i), pointer :: initializer
      integer, intent(in) :: order !! order of accuracy
      integer, intent(in) :: cells !! number of grid cells spanning the domain
      double precision, intent(in) :: x_min !! grid location minimum
      double precision, intent(in) :: x_max !! grid location maximum
      type(vector_1D_t) vector_1D
    end function

    pure module function construct_from_components(tensor_1D, divergence_operator_1D) result(vector_1D)
      !! Result is a 1D vector with the provided parent component tensor_1D and the provided divergence operatror
      type(tensor_1D_t), intent(in) :: tensor_1D
      type(divergence_operator_1D_t), intent(in) :: divergence_operator_1D
      type(vector_1D_t) vector_1D
    end function

  end interface

  type, extends(vector_1D_t) :: gradient_1D_t
    !! A 1D mimetic gradient vector field abstraction with a public method that produces corresponding numerical quadrature weights
  contains
    generic :: operator(.dot.) => dot
#ifndef __INTEL_COMPILER
    generic :: weights => gradient_1D_weights
#endif
    procedure, non_overridable, private, pass(gradient_1D) :: dot
  end type

  type, extends(tensor_1D_t) :: vector_dot_gradient_1D_t
    !! Result is the dot product of a 1D vector field and a 1D gradient field
    private
    double precision, allocatable :: weights_(:)
  contains
    generic :: operator(.SSS.) => volume_integrate_vector_dot_grad_scalar_1D
    procedure, non_overridable, private, pass(integrand) ::volume_integrate_vector_dot_grad_scalar_1D
  end type

  type, extends(tensor_1D_t) :: divergence_1D_t
    !! Encapsulate divergences at cell centers
  contains
    generic :: grid   => divergence_1D_grid
    generic :: values => divergence_1D_values
    generic :: weights => divergence_1D_weights
    generic :: operator(*) => premultiply_scalar_1D, postmultiply_scalar_1D
    procedure, non_overridable, private, pass(divergence_1D) :: premultiply_scalar_1D
    procedure, non_overridable, private :: postmultiply_scalar_1D
    procedure, non_overridable, private :: divergence_1D_values
    procedure, non_overridable, private :: divergence_1D_grid
  end type

  type, extends(tensor_1D_t) :: scalar_x_divergence_1D_t
    !! product of a 1D scalar field and a 1D divergence field
    private
    double precision, allocatable :: weights_(:)
  contains
    generic :: operator(.SSS.) => volume_integrate_scalar_x_divergence_1D
    procedure, non_overridable, private, pass(integrand) :: volume_integrate_scalar_x_divergence_1D
  end type

  type, extends(divergence_1D_t) :: laplacian_1D_t
    private
    integer boundary_depth_
  contains
    procedure reduced_order_boundary_depth
  end type

  interface

    pure module function dA(self)
      !! Result is the grid's discrete surface-area differential for use in surface integrals of the form
      !! .SS. (f .x. (v .dot. dA))
      implicit none
      class(vector_1D_t), intent(in) :: self
      double precision dA
    end function

    pure module function dx(self)
      !! Result is the uniform cell width
      implicit none
      class(tensor_1D_t), intent(in) :: self
      double precision dx
    end function

    pure module function scalar_1D_grid(self) result(cell_centers_extended)
      !! Result is the array of locations at which 1D scalars are defined: cell centers agumented by spatial boundaries
      implicit none
      class(scalar_1D_t), intent(in) :: self
      double precision, allocatable :: cell_centers_extended(:)
    end function

    pure module function vector_1D_grid(self) result(cell_faces)
      !! Result is the array of cell face locations (of unit area for 1D) at which 1D vectors are defined
      implicit none
      class(vector_1D_t), intent(in) :: self
      double precision, allocatable :: cell_faces(:)
    end function

    pure module function divergence_1D_grid(self) result(cell_centers)
      !! Result is the array of cell centers at which 1D divergences are defined
      implicit none
      class(divergence_1D_t), intent(in) :: self
      double precision, allocatable :: cell_centers(:)
    end function

    pure module function scalar_1D_values(self) result(cell_centers_extended_values)
      !! Result is an array of 1D scalar values at boundaries and cell centers
      implicit none
      class(scalar_1D_t), intent(in) :: self
      double precision, allocatable :: cell_centers_extended_values(:)
    end function

    pure module function vector_1D_values(self) result(face_centered_values)
      !! Result is an array of the 1D vector values at cell faces (of unit area 1D)
      implicit none
      class(vector_1D_t), intent(in) :: self
      double precision, allocatable :: face_centered_values(:)
    end function

    pure module function divergence_1D_values(self) result(cell_centered_values)
      !! Result is an array of 1D divergences at cell centers
      implicit none
      class(divergence_1D_t), intent(in) :: self
      double precision, allocatable :: cell_centered_values(:)
    end function

    pure module function grad(self) result(gradient_1D)
      !! Result is mimetic gradient of the scalar_1D_t "self"
      implicit none
      class(scalar_1D_t), intent(in) :: self
      type(gradient_1D_t) gradient_1D
    end function

    pure module function laplacian(self) result(laplacian_1D)
      !! Result is mimetic Laplacian of the scalar_1D_t "self"
      implicit none
      class(scalar_1D_t), intent(in) :: self
      type(laplacian_1D_t) laplacian_1D
    end function

    pure module function reduced_order_boundary_depth(self) result(num_nodes)
      !! Result is number of nodes away from the boundary for which convergence rate is one degree lower
      implicit none
      class(laplacian_1D_t), intent(in) :: self
      integer num_nodes
    end function

    pure module function div(self) result(divergence_1D)
      !! Result is mimetic divergence of the vector_1D_t "self"
      implicit none
      class(vector_1D_t), intent(in) :: self
      type(divergence_1D_t) divergence_1D !! discrete divergence
    end function

    pure module function volume_integrate_vector_dot_grad_scalar_1D(integrand) result(integral)
      !! Result is the mimetic quadrature corresponding to a volume integral of a vector-gradient dot product
      implicit none
      class(vector_dot_gradient_1D_t), intent(in) :: integrand
      double precision integral
    end function

    pure module function volume_integrate_scalar_x_divergence_1D(integrand) result(integral)
      !! Result is the mimetic quadrature corresponding to a volume integral of a scalar-divergence product
      implicit none
      class(scalar_x_divergence_1D_t), intent(in) :: integrand
      double precision integral
    end function

    pure module function surface_integrate_vector_x_scalar_1D(integrand) result(integral)
      !! Result is the mimetic quadrature correspondingto a surface integral of a scalar-vector product
      implicit none
      class(weighted_product_1D_t), intent(in) :: integrand
      double precision integral
    end function

    pure module function dot(vector_1D, gradient_1D) result(vector_dot_gradient_1D)
      !! Result is the mimetic divergence of the vector_1D_t "self"
      implicit none
      class(gradient_1D_t), intent(in) :: gradient_1D
      type(vector_1D_t), intent(in) :: vector_1D
      type(vector_dot_gradient_1D_t) vector_dot_gradient_1D
    end function

    pure module function dot_surface_normal(vector_1D, dS) result(v_dot_dS)
      !! Result is magnitude of a vector/surface-normal dot product for use in surface integrals of the form
      !! `.SS. (f .x. (v .dot. dA))`
      !! The sign of the dot-product is incorporated into the weights in the weighted multiplication operator(.x.).
      implicit none
      class(vector_1D_t), intent(in) :: vector_1D
      double precision, intent(in) :: dS
      type(vector_1D_t) v_dot_dS
    end function

    pure module function weighted_premultiply(scalar_1D, vector_1D) result(weighted_product_1D)
      !! Result is the product of a boundary-weighted vector_1D_t with a scalar_1D_t
      implicit none
      type(scalar_1D_t), intent(in) :: scalar_1D
      class(vector_1D_t), intent(in) :: vector_1D
      type(weighted_product_1D_t) weighted_product_1D
    end function

    pure module function gradient_1D_weights(self) result(weights)
      !! Result is an array of quadrature coefficients that can be used to compute a weighted
      !! inner product  of a vector_1D_t object and a gradient_1D_t object.
      implicit none
      class(tensor_1D_t), intent(in) :: self
      double precision, allocatable :: weights(:)
    end function

    pure module function divergence_1D_weights(self) result(weights)
      !! Result is an array of quadrature coefficients that can be used to compute a weighted
      !! inner product  of a vector_1D_t object and a gradient_1D_t object.
      implicit none
      class(tensor_1D_t), intent(in) :: self
      double precision, allocatable :: weights(:)
    end function

    pure module function premultiply_scalar_1D(scalar_1D, divergence_1D) result(scalar_x_divergence_1D)
      !! Result is the point-wise product of a 1D scalar field and the divergence of a 1D vector field
      implicit none
      type(scalar_1D_t), intent(in) :: scalar_1D
      class(divergence_1D_t), intent(in) :: divergence_1D
      type(scalar_x_divergence_1D_t) scalar_x_divergence_1D
    end function

    pure module function postmultiply_scalar_1D(divergence_1D, scalar_1D) result(scalar_x_divergence_1D)
      !! Result is the point-wise product of a 1D scalar field and the divergence of a 1D vector field
      implicit none
      class(divergence_1D_t), intent(in) :: divergence_1D
      type(scalar_1D_t), intent(in) :: scalar_1D
      type(scalar_x_divergence_1D_t) scalar_x_divergence_1D
    end function

  end interface

#ifndef __GFORTRAN__

contains

  pure function cell_center_locations(x_min, x_max, cells) result(x)
    double precision, intent(in) :: x_min, x_max
    integer, intent(in) :: cells
    double precision, allocatable:: x(:)
    integer cell

    associate(dx => (x_max - x_min)/cells)
      x = x_min + dx/2. + [((cell-1)*dx, cell = 1, cells)]
    end associate
  end function

#endif

end module tensors_1D_m

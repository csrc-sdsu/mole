#include "mole-language-support.F90"

module tensors_1D_m
  !! Define public 1D scalar and vector abstractions and associated mimetic gradient,
  !! divergence, and Laplacian operators.
  use julienne_m, only : file_t
  use mimetic_operators_1D_m, only : divergence_operator_1D_t, gradient_operator_1D_t
    
  implicit none

  private

  public :: scalar_1D_t
  public :: vector_1D_t
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
    !! Encapsulate 1D vector values at cell faces (nodes in 1D) and corresponding operators
    private
    type(divergence_operator_1D_t) divergence_operator_1D_
  contains
    generic :: operator(.div.) => div
    generic :: grid   => vector_1D_grid
    generic :: values => vector_1D_values
    procedure, non_overridable, private :: div
    procedure, non_overridable, private :: vector_1D_grid
    procedure, non_overridable, private :: vector_1D_values
  end type

  interface vector_1D_t

    pure module function construct_1D_vector_from_function(initializer, order, cells, x_min, x_max) result(vector_1D)
      !! Result is a collection of face-centered values with a corresponding mimetic gradient operator
      implicit none
      procedure(vector_1D_initializer_i), pointer :: initializer
      integer, intent(in) :: order !! order of accuracy
      integer, intent(in) :: cells !! number of grid cells spanning the domain
      double precision, intent(in) :: x_min !! grid location minimum
      double precision, intent(in) :: x_max !! grid location maximum
      type(vector_1D_t) vector_1D
    end function

  end interface

  type, extends(tensor_1D_t) :: divergence_1D_t
    !! Encapsulate divergences at cell centers
  contains
    generic :: grid   => divergence_1D_grid
    generic :: values => divergence_1D_values
    procedure, non_overridable, private :: divergence_1D_values
    procedure, non_overridable, private :: divergence_1D_grid
  end type

  type, extends(divergence_1D_t) :: laplacian_1D_t
  end type

  interface

    pure module function scalar_1D_grid(self) result(cell_centers_extended)
      !! Result is the array of locations at which 1D scalars are defined: cell centers agumented by spatial boundaries
      implicit none
      class(scalar_1D_t), intent(in) :: self
      double precision, allocatable :: cell_centers_extended(:)
    end function

    pure module function vector_1D_grid(self) result(cell_faces)
      !! Result is the array of cell face locations (nodes in 1D) at which 1D vectors are defined
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
      !! Result is an array of the 1D vector values at cell faces (nodes in 1D)
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
      type(vector_1D_t) gradient_1D !! discrete gradient
    end function

    pure module function laplacian(self) result(laplacian_1D)
      !! Result is mimetic Laplacian of the scalar_1D_t "self"
      implicit none
      class(scalar_1D_t), intent(in) :: self
      type(laplacian_1D_t) laplacian_1D !! discrete gradient
    end function

    pure module function div(self) result(divergence_1D)
      !! Result is mimetic divergence of the vector_1D_t "self"
      implicit none
      class(vector_1D_t), intent(in) :: self
      type(divergence_1D_t) divergence_1D !! discrete divergence
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

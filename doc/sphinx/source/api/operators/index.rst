**************************************
Mimetic Operators
**************************************

MOLE provides high-order mimetic operators that preserve key mathematical properties of the continuous differential operators they approximate.

Operator Overview
======================================

.. list-table::
   :header-rows: 1
   :widths: 20 40 40

   * - Operator
     - Description
     - Mathematical Form
   * - Gradient
     - Transforms a scalar field into its vector derivative
     - :math:`\nabla u`
   * - Divergence
     - Measures the net outward flux from a point
     - :math:`\nabla \cdot \mathbf{F}`
   * - Laplacian
     - Second derivative operator, sum of unmixed second partial derivatives
     - :math:`\nabla^2 u = \nabla \cdot \nabla u`
   * - Interpolation
     - Transfers data between different grid locations
     - Various interpolation schemes

Mathematical Properties
======================================

The mimetic operators in MOLE are designed to maintain important mathematical properties such as:

* Conservation laws
* Symmetry preservation
* Fundamental identities (e.g., curl of gradient is zero)
* Compatibility with boundary conditions

Available Operators
======================================

.. toctree::
   :maxdepth: 1

   gradient
   divergence
   laplacian
   interpol 
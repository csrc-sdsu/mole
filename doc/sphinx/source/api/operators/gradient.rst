.. _Gradient:

Gradient
**************************************

.. doxygenclass:: Gradient
   :project: MoleCpp
   :members:
   :undoc-members:

Mathematical Description
======================================

The gradient operator (:math:`\nabla`) transforms a scalar field into its vector derivative:

.. math::

   \nabla u = \begin{pmatrix} 
       \frac{\partial u}{\partial x} \\
       \frac{\partial u}{\partial y} \\
       \frac{\partial u}{\partial z}
   \end{pmatrix}

Properties
--------------------------------------

The mimetic gradient operator preserves key properties of the continuous gradient:

* Accuracy of order :math:`k`
* Exact for polynomials of degree :math:`k-1`
* Compatible with the mimetic divergence operator
* Properly handles boundary conditions

Implementation Details
======================================

The gradient operator is implemented as a sparse matrix that can be applied to vector data.

Usage Examples
======================================

.. literalinclude:: ../../../../examples/cpp/gradient_example.cpp
   :language: cpp
   :start-after: // BEGIN_EXAMPLE
   :end-before: // END_EXAMPLE
   :caption: Gradient operator example (1D case)

See Also
======================================

* :ref:`Divergence` - The divergence operator (adjoint of gradient)
* :ref:`Laplacian` - The Laplacian operator (divergence of gradient) 
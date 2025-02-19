Getting Started
======================

Quick Start
-------------

MOLE provides implementations of mimetic operators for both C++ and MATLAB. Here's a simple example:

C++ Example
~~~~~~~~~~~~~~

.. code-block:: cpp

    #include <mole.h>
    
    // Create a gradient operator
    Gradient grad;
    
    // Apply the operator
    arma::vec result = grad.get1D(n);  // n is the grid size

MATLAB Example
~~~~~~~~~~~~~~~~~

.. code-block:: matlab

    % Create and apply a gradient operator
    n = 10;  % grid size
    grad_op = grad(n); 
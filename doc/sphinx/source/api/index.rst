**************************************
API Documentation
**************************************

This section contains the API documentation for the Mimetic Operators Library Enhanced (MOLE).

.. only:: html

   .. mermaid::

      graph TD
        User[User Code] -->|uses| OP[Operators]
        OP --> G[Gradient]
        OP --> D[Divergence]
        OP --> L[Laplacian]
        OP --> I[Interpolation]
        User -->|applies| BC[Boundary Conditions]
        BC --> M[MixedBC]
        BC --> R[RobinBC]
        User -->|utilizes| U[Utilities]

Public API
======================================

These classes and functions are intended to be used by general users of the MOLE library.

.. toctree::
   :maxdepth: 2

   cpp/gradient
   cpp/divergence
   cpp/laplacian
   cpp/interpol
   cpp/mixedbc
   cpp/robinbc
   cpp/utils

Interface Concepts
======================================

.. toctree::
   :maxdepth: 1

   introduction
   gettingstarted 
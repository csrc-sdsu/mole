=========================================
MATLAB/Octave API
=========================================

This page documents the API of the MOLE MATLAB/Octave module. Functions are organized by category.

.. mat:currentmodule:: .

Differential Operators
-------------------------

Gradient Operators
~~~~~~~~~~~~~~~~~~~~~~

.. mat:autofunction:: grad
.. mat:autofunction:: grad2D
.. mat:autofunction:: grad2DCurv
.. mat:autofunction:: grad2DNonUniform
.. mat:autofunction:: grad3D
.. mat:autofunction:: grad3DCurv
.. mat:autofunction:: grad3DNonUniform
.. mat:autofunction:: gradNonUniform

Divergence Operators
~~~~~~~~~~~~~~~~~~~~~~~~

.. mat:autofunction:: div
.. mat:autofunction:: div2D
.. mat:autofunction:: div2DCurv
.. mat:autofunction:: div2DNonUniform
.. mat:autofunction:: div3D
.. mat:autofunction:: div3DCurv
.. mat:autofunction:: div3DNonUniform
.. mat:autofunction:: divNonUniform

Curl Operators
~~~~~~~~~~~~~~~~~~

.. mat:autofunction:: curl2D

Laplacian Operators
~~~~~~~~~~~~~~~~~~~~~~~

.. mat:autofunction:: lap
.. mat:autofunction:: lap2D
.. mat:autofunction:: lap3D

Interpolation Functions
----------------------------

Node to Center Interpolation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. mat:autofunction:: interpolNodesToCenters1D
.. mat:autofunction:: interpolNodesToCenters2D
.. mat:autofunction:: interpolNodesToCenters3D

Center to Node Interpolation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. mat:autofunction:: interpolCentersToNodes1D
.. mat:autofunction:: interpolCentersToNodes2D
.. mat:autofunction:: interpolCentersToNodes3D

Face Interpolation
~~~~~~~~~~~~~~~~~~~~~

.. mat:autofunction:: interpolFacesToCentersG1D
.. mat:autofunction:: interpolFacesToCentersG2D
.. mat:autofunction:: interpolFacesToCentersG3D

General Interpolation
~~~~~~~~~~~~~~~~~~~~~~~~

.. mat:autofunction:: interpol
.. mat:autofunction:: interpol2D
.. mat:autofunction:: interpol3D
.. mat:autofunction:: interpolD
.. mat:autofunction:: interpolD2D
.. mat:autofunction:: interpolD3D

Boundary Conditions
------------------------

General Boundary Conditions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. mat:autofunction:: addBC1D
.. mat:autofunction:: addBC1Dlhs
.. mat:autofunction:: addBC1Drhs
.. mat:autofunction:: addBC2D
.. mat:autofunction:: addBC2Dlhs
.. mat:autofunction:: addBC2Drhs
.. mat:autofunction:: addBC3D
.. mat:autofunction:: addBC3Dlhs
.. mat:autofunction:: addBC3Drhs

Neumann Boundary Conditions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. mat:autofunction:: neumann2DCurv
.. mat:autofunction:: neumann3DCurv

Robin Boundary Conditions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. mat:autofunction:: robinBC
.. mat:autofunction:: robinBC2D
.. mat:autofunction:: robinBC3D

Mixed Boundary Conditions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. mat:autofunction:: mixedBC
.. mat:autofunction:: mixedBC2D
.. mat:autofunction:: mixedBC3D

Grid Generation and Transformation
----------------------------------------

Grid Generation
~~~~~~~~~~~~~~~~~~~~~~~~~~

.. mat:autofunction:: gridGen
.. mat:autofunction:: tfi

Jacobian Calculation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. mat:autofunction:: jacobian2D
.. mat:autofunction:: jacobian3D

Nodal Operators
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. mat:autofunction:: nodal
.. mat:autofunction:: nodal2D
.. mat:autofunction:: nodal2DCurv
.. mat:autofunction:: nodal3D
.. mat:autofunction:: nodal3DCurv
.. mat:autofunction:: sidedNodal

Mimetic Weights
---------------------

.. mat:autofunction:: weightsP
.. mat:autofunction:: weightsP2D
.. mat:autofunction:: weightsQ
.. mat:autofunction:: weightsQ2D

Utility Functions
---------------------

.. mat:autofunction:: amean
.. mat:autofunction:: hmean
.. mat:autofunction:: rk4
.. mat:autofunction:: ttm
.. mat:autofunction:: boundaryIdx2D
.. mat:autofunction:: DI2
.. mat:autofunction:: DI3
.. mat:autofunction:: GI1
.. mat:autofunction:: GI13
.. mat:autofunction:: GI2
.. mat:autofunction:: mimeticB
.. mat:autofunction:: tensorGrad2D 
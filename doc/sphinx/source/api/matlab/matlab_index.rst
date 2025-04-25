MATLAB/Octave Function Index
=========================================

This page provides an index of all MATLAB/Octave functions in the MOLE library.

Gradient Operators
----------------------------

* :mat:func:`grad` - Returns a m+1 by m+2 one-dimensional mimetic gradient operator
* :mat:func:`grad2D` - Returns a two-dimensional mimetic gradient operator
* :mat:func:`grad2DCurv` - Returns a 2D curvilinear mimetic gradient
* :mat:func:`grad2DNonUniform` - Returns a two-dimensional non-uniform mimetic gradient
* :mat:func:`grad3D` - Returns a three-dimensional mimetic gradient operator
* :mat:func:`grad3DCurv` - Returns a 3D curvilinear mimetic gradient
* :mat:func:`grad3DNonUniform` - Returns a three-dimensional non-uniform mimetic gradient
* :mat:func:`gradNonUniform` - Returns a m+1 by m+2 one-dimensional non-uniform mimetic gradient

Divergence Operators
----------------------------

* :mat:func:`div` - Returns a m+2 by m+1 one-dimensional mimetic divergence operator
* :mat:func:`div2D` - Returns a two-dimensional mimetic divergence operator
* :mat:func:`div2DCurv` - Returns a 2D curvilinear mimetic divergence
* :mat:func:`div2DNonUniform` - Returns a two-dimensional non-uniform mimetic divergence
* :mat:func:`div3D` - Returns a three-dimensional mimetic divergence operator
* :mat:func:`div3DCurv` - Returns a 3D curvilinear mimetic divergence
* :mat:func:`div3DNonUniform` - Returns a three-dimensional non-uniform mimetic divergence
* :mat:func:`divNonUniform` - Returns a m+2 by m+1 one-dimensional non-uniform mimetic divergence

Laplacian Operators
----------------------------

* :mat:func:`lap` - Returns a m+2 by m+2 one-dimensional mimetic laplacian operator
* :mat:func:`lap2D` - Returns a two-dimensional mimetic laplacian operator
* :mat:func:`lap3D` - Returns a three-dimensional mimetic laplacian operator

Nodal Operators
----------------------------

* :mat:func:`nodal` - Returns a one-dimensional operator that approximates the first-order
* :mat:func:`nodal2D` - Returns a two-dimensional operator that approximates the first-order
* :mat:func:`nodal2DCurv` - Returns a 2D curvilinear nodal operator
* :mat:func:`nodal3D` - Returns a three-dimensional operator that approximates the first-order
* :mat:func:`nodal3DCurv` - Returns a 3D curvilinear nodal operator
* :mat:func:`sidedNodal` - Returns a one-dimensional nodal operator with one-sided stencils

Interpolation Functions
------------------------------------------------

* :mat:func:`interpol` - Returns a m+1 by m+2 one-dimensional interpolation operator
* :mat:func:`interpol2D` - Returns a two-dimensional interpolation operator
* :mat:func:`interpol3D` - Returns a three-dimensional interpolation operator
* :mat:func:`interpolD` - Returns a m+1 by m+2 one-dimensional interpolation operator
* :mat:func:`interpolD2D` - Returns a two-dimensional interpolation operator
* :mat:func:`interpolD3D` - Returns a three-dimensional interpolation operator
* :mat:func:`interpolCentersToFacesD1D` - Interpolates values from cell centers to faces
* :mat:func:`interpolCentersToFacesD2D` - Interpolates values from cell centers to faces
* :mat:func:`interpolCentersToFacesD3D` - Interpolates values from cell centers to faces
* :mat:func:`interpolCentersToNodes1D` - Interpolates values from cell centers to nodes
* :mat:func:`interpolCentersToNodes2D` - Interpolates values from cell centers to nodes
* :mat:func:`interpolCentersToNodes3D` - Interpolates values from cell centers to nodes
* :mat:func:`interpolFacesToCentersG1D` - Interpolates values from faces to cell centers
* :mat:func:`interpolFacesToCentersG2D` - Interpolates values from faces to cell centers
* :mat:func:`interpolFacesToCentersG3D` - Interpolates values from faces to cell centers
* :mat:func:`interpolNodesToCenters1D` - Interpolates values from nodes to cell centers
* :mat:func:`interpolNodesToCenters2D` - Interpolates values from nodes to cell centers
* :mat:func:`interpolNodesToCenters3D` - Interpolates values from nodes to cell centers

Boundary Conditions
----------------------------

* :mat:func:`addBC1D` - Apply boundary conditions to a 1D system
* :mat:func:`addBC1Dlhs` - Create left-hand side matrix for 1D boundary conditions
* :mat:func:`addBC1Drhs` - Create right-hand side vector for 1D boundary conditions
* :mat:func:`addBC2D` - Apply boundary conditions to a 2D system
* :mat:func:`addBC2Dlhs` - Create left-hand side matrix for 2D boundary conditions
* :mat:func:`addBC2Drhs` - Create right-hand side vector for 2D boundary conditions
* :mat:func:`addBC3D` - Apply boundary conditions to a 3D system
* :mat:func:`addBC3Dlhs` - Create left-hand side matrix for 3D boundary conditions
* :mat:func:`addBC3Drhs` - Create right-hand side vector for 3D boundary conditions
* :mat:func:`boundaryIdx2D` - Get boundary indices for a 2D domain
* :mat:func:`mixedBC` - Constructs a 1D mimetic mixed boundary conditions operator
* :mat:func:`mixedBC2D` - Constructs a 2D mimetic mixed boundary conditions operator
* :mat:func:`mixedBC3D` - Constructs a 3D mimetic mixed boundary conditions operator
* :mat:func:`neumann2DCurv` - Returns a 2D curvilinear Neumann BC operator
* :mat:func:`neumann3DCurv` - Returns a 3D curvilinear Neumann BC operator
* :mat:func:`robinBC` - Returns a m+2 by m+2 one-dimensional mimetic boundary operator that
* :mat:func:`robinBC2D` - Returns a two-dimensional mimetic boundary operator that implements
* :mat:func:`robinBC3D` - Returns a three-dimensional mimetic boundary operator that

Grid and Transformation Functions
--------------------------------------------------------

* :mat:func:`gridGen` - Generate a grid using transfinite interpolation
* :mat:func:`tfi` - Transfinite interpolation for grid generation
* :mat:func:`ttm` - Tensor-product transfinite mapping
* :mat:func:`jacobian2D` - Calculate the Jacobian matrix for 2D grid transformations
* :mat:func:`jacobian3D` - Calculate the Jacobian matrix for 3D grid transformations

Utility Functions
----------------------------

* :mat:func:`amean` - Returns the arithmetic mean for every two pairs in a column vector
* :mat:func:`hmean` - Returns the harmonic mean for every two pairs in a column vector
* :mat:func:`weightsP` - Returns the m+1 weights of P
* :mat:func:`weightsP2D` - Returns the two-dimensional weights of P
* :mat:func:`weightsQ` - Returns the m+2 weights of Q
* :mat:func:`weightsQ2D` - Returns the two-dimensional weights of Q
* :mat:func:`rk4` - Explicit Runge-Kutta 4th-order method
* :mat:func:`curl2D` - Returns a two-dimensional mimetic curl operator
* :mat:func:`DI2` - Returns a 2D diagonal scaling matrix
* :mat:func:`DI3` - Returns a 3D diagonal scaling matrix
* :mat:func:`GI1` - Returns a 1D geomeric interpretation matrix
* :mat:func:`GI13` - Returns a 3D geometric interpretation matrix
* :mat:func:`GI2` - Returns a 2D geometric interpretation matrix
* :mat:func:`mimeticB` - Returns a m+2 by m+1 one-dimensional mimetic boundary operator
* :mat:func:`tensorGrad2D` - Calculate tensor gradient in 2D 
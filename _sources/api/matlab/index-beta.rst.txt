=========================================
MOLE MATLAB/Octave Module
=========================================

This section documents the MATLAB/Octave implementation of the MOLE toolkit.
The documentation is generated automatically from the docstrings in the MATLAB/Octave source files.

.. only:: html

    .. graphviz::

        digraph "MOLE MATLAB Functions" {
            rankdir=LR;
            compound=true;
            node [shape=box, style=filled, fillcolor=white, fontname="Arial", fontsize=10];
            edge [fontname="Arial", fontsize=9];
            
            // Main categories
            subgraph cluster_operators {
                label="Core Operators";
                style=dashed;
                
                DifferentialOperators [label="Differential\nOperators"];
                
                subgraph cluster_diff_ops {
                    label="";
                    style=invis;
                    
                    Grad [label="Gradient"];
                    Div [label="Divergence"];
                    Lap [label="Laplacian"];
                    Curl [label="Curl"];
                }
            }
            
            subgraph cluster_variants {
                label="Operator Variants";
                style=dashed;
                
                NonUniform [label="Non-Uniform"];
                Curvilinear [label="Curvilinear"];
            }
            
            subgraph cluster_dimensions {
                label="Dimensional\nImplementations";
                style=dashed;
                
                D1 [label="1D"];
                D2 [label="2D"];
                D3 [label="3D"];
            }
            
            subgraph cluster_support {
                label="Supporting Components";
                style=dashed;
                
                InterpolationOperators [label="Interpolation\nOperators"];
                BoundaryConditions [label="Boundary\nConditions"];
                GridTransformation [label="Grid\nTransformation"];
                WeightFunctions [label="Weight\nFunctions"];
                MimeticOperators [label="Mimetic\nOperators"];
            }
            
            // Core relationships
            DifferentialOperators -> {Grad Div Lap Curl} [style=dotted];
            {Grad Div Lap} -> {D1 D2 D3} [style=dashed];
            Curl -> D2 [style=dashed];
            
            // Variant relationships
            {D2 D3} -> NonUniform [dir=both];
            {D2 D3} -> Curvilinear [dir=both];
            
            // Support relationships
            InterpolationOperators -> DifferentialOperators [dir=both, label="supports"];
            BoundaryConditions -> DifferentialOperators [dir=both, label="enhances"];
            GridTransformation -> DifferentialOperators [label="enables"];
            WeightFunctions -> {InterpolationOperators DifferentialOperators} [label="configures"];
            MimeticOperators -> DifferentialOperators [label="implements"];
            
            // Dimensional support
            InterpolationOperators -> {D1 D2 D3} [style=dotted];
            BoundaryConditions -> {D1 D2 D3} [style=dotted];
        }

.. only:: latex

    Function Categories
    -------------------------

    The MOLE MATLAB/Octave API consists of several main categories:

    * **Differential Operators**: Core operators for gradient, divergence, curl, and Laplacian calculations
    * **Interpolation Operators**: Functions for interpolating values between different grid locations
    * **Boundary Conditions**: Operators for handling various boundary conditions (Dirichlet, Neumann, Robin, Mixed)
    * **Grid Transformation**: Functions for grid generation and coordinate transformations
    * **Weight Functions**: Functions for computing weights used in numerical schemes
    * **Mimetic Operators**: Specialized operators preserving mathematical properties

    The toolkit provides implementations across different dimensions (1D, 2D, 3D) with support for:

    * Non-uniform grids
    * Curvilinear coordinates
    * Various boundary conditions
    * Different interpolation schemes
    * Mimetic discretization

.. toctree::
   :maxdepth: 2
   :caption: Contents:
   :hidden:

   matlab_index
   api
   

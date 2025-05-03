=========================================
MATLAB/Octave
=========================================

This section documents the MATLAB/Octave implementation of the MOLE toolkit.
The documentation is generated automatically from the docstrings in the MATLAB/Octave source files.

.. only:: html

    .. graphviz::

        digraph "MOLE MATLAB Functions" {
            rankdir=LR;
            compound=true;
            node [shape=box, style=filled, fontname="Arial", fontsize=10, margin="0.3,0.1"];
            edge [fontname="Arial", fontsize=9];
            
            // Color definitions for nodes
            
            // Main categories
            subgraph cluster_operators {
                label="Core Operators";
                style=filled;
                color="#F5F5F5";
                
                DifferentialOperators [label="Differential\nOperators", fillcolor="#D5E8D4"];
                
                subgraph cluster_diff_ops {
                    label="";
                    style=invis;
                    
                    Grad [label="Gradient", fillcolor="#D5E8D4"];
                    Div [label="Divergence", fillcolor="#D5E8D4"];
                    Lap [label="Laplacian", fillcolor="#D5E8D4"];
                    Curl [label="Curl", fillcolor="#D5E8D4"];
                }
            }
            
            subgraph cluster_variants {
                label="Operator Variants";
                style=filled;
                color="#F5F5F5";
                
                NonUniform [label="Non-Uniform", fillcolor="#FFE6CC"];
                Curvilinear [label="Curvilinear", fillcolor="#FFE6CC"];
            }
            
            subgraph cluster_dimensions {
                label="Dimensional\nImplementations";
                style=filled;
                color="#F5F5F5";
                
                D1 [label="1D", fillcolor="#DAE8FC"];
                D2 [label="2D", fillcolor="#DAE8FC"];
                D3 [label="3D", fillcolor="#DAE8FC"];
            }
            
            subgraph cluster_support {
                label="Supporting Components";
                style=filled;
                color="#F5F5F5";
                
                InterpolationOperators [label="Interpolation\nOperators", fillcolor="#E1D5E7"];
                BoundaryConditions [label="Boundary\nConditions", fillcolor="#E1D5E7"];
                GridTransformation [label="Grid\nTransformation", fillcolor="#E1D5E7"];
                WeightFunctions [label="Weight\nFunctions", fillcolor="#E1D5E7"];
                MimeticOperators [label="Mimetic\nOperators", fillcolor="#E1D5E7"];
            }
            
            // Core relationships
            edge [color="#0000AA", penwidth=1.0];
            DifferentialOperators -> {Grad Div Lap Curl} [style=dotted];
            
            // Dimension relationships
            edge [color="#006600", penwidth=1.0];
            {Grad Div Lap} -> {D1 D2 D3} [style=dashed];
            Curl -> D2 [style=dashed];
            
            // Variant relationships
            edge [color="#AA6600", penwidth=1.0];
            {D2 D3} -> NonUniform [dir=both];
            {D2 D3} -> Curvilinear [dir=both];
            
            // Support relationships
            edge [color="#990000", penwidth=1.0];
            InterpolationOperators -> DifferentialOperators [dir=both, label="supports"];
            BoundaryConditions -> DifferentialOperators [dir=both, label="enhances"];
            GridTransformation -> DifferentialOperators [label="enables"];
            WeightFunctions -> {InterpolationOperators DifferentialOperators} [label="configures"];
            MimeticOperators -> DifferentialOperators [label="implements"];
            
            // Dimensional support
            edge [color="#6600CC", style=dotted, penwidth=1.0];
            InterpolationOperators -> {D1 D2 D3};
            BoundaryConditions -> {D1 D2 D3};
            
            // Add a legend
            subgraph cluster_legend {
                label="Legend";
                style=filled;
                color="#F5F5F5";
                fontsize=10;
                
                node [shape=none, style=none, fillcolor=none, label=""];
                edge [style=none];
                
                leg_title [label="Connection Types:", shape=none, fontsize=9];
                leg_core [label="Core Relationship", shape=none, fontsize=9];
                leg_dim [label="Dimensional Implementation", shape=none, fontsize=9];
                leg_variant [label="Variant Relationship", shape=none, fontsize=9];
                leg_support [label="Support Relationship", shape=none, fontsize=9];
                leg_dim_support [label="Dimensional Support", shape=none, fontsize=9];
                
                leg_title -> leg_core [style=dotted, color="#0000AA", penwidth=1.0];
                leg_title -> leg_dim [style=dashed, color="#006600", penwidth=1.0];
                leg_title -> leg_variant [style=solid, color="#AA6600", penwidth=1.0];
                leg_title -> leg_support [style=solid, color="#990000", penwidth=1.0];
                leg_title -> leg_dim_support [style=dotted, color="#6600CC", penwidth=1.0];
            }
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
   

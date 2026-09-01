# Julia

This section documents the Julia implementation of the MOLE toolkit, MOLE.jl.

The API documentation is generated automatically from the docstrings in the Julia source files located in `mole/julia/MOLE.jl/src`.

The published MOLE.jl documentation can be found on the [MOLE.jl Documentation website](https://www.mole-ose.org/MOLE.jl-docs/dev/).

```{eval-rst}
.. only:: html

    The following diagram shows the key modules and functions in the MOLE.jl API and their relationships:

    .. graphviz::

        digraph mole_jl_api_structure {
            bgcolor="transparent";
            rankdir=TB;  // Top to Bottom layout
            compound=true;
            node [shape=box, style=filled, fontname="Arial", fontsize=10, margin="0.3,0.1"];
            edge [fontname="Arial", fontsize=9];

            // Color definitions
            node [fillcolor="#E8F4F9"];  // Light blue for base nodes

            // Core package
            subgraph cluster_base {
                label="Core Package";
                style=filled;
                color="#F5F5F5";

                MOLE [label="MOLE.jl\n(Package)"];
            }

            // Core modules
            subgraph cluster_modules {
                label="Core Modules";
                style=filled;
                color="#F5F5F5";
                node [fillcolor="#E8F4F9"];

                Operators [label="Operators"];
                BCs [label="BCs"];
            }

            // Operators
            subgraph cluster_operators {
                label="Core Operators";
                style=filled;
                color="#F5F5F5";
                node [fillcolor="#D5E8D4"];  // Light green for operators

                Interpol [label="interpol\n(Interpolation)"];
                Gradient [label="grad\n(Gradient)"];
                Divergence [label="div\n(Divergence)"];
                Laplacian [label="lap\n(Laplacian)"];
            }

            // Boundary Conditions
            subgraph cluster_bc {
                label="Boundary Conditions";
                style=filled;
                color="#F5F5F5";
                node [fillcolor="#FFE6CC"];  // Light orange for boundary conditions

                RobinBC [label="robinBC\n(Robin/Neumann/Dirichlet)"];
                ScalarBC1D [label="ScalarBC1D"];
                ScalarBC2D [label="ScalarBC2D"];
                AddScalarBC [label="addScalarBC!\n(Apply Scalar BCs)"];
            }

            // Grid Variants
            subgraph cluster_grids {
                label="Grid and Dimension Variants";
                style=filled;
                color="#F5F5F5";
                node [fillcolor="#DAE8FC"];  // Light blue for utilities

                OneD [label="1D Operators"];
                TwoD [label="2D Operators"];
                Uniform [label="Uniform Grids"];
                NonUniform [label="Non-uniform Grids"];
            }

            // Module relationships
            edge [color="#0000AA", penwidth=1.5];
            MOLE -> {Operators BCs};

            // API ownership relationships
            edge [color="#0000AA", penwidth=1.5];
            Operators -> {Interpol Gradient Divergence Laplacian};
            BCs -> {RobinBC ScalarBC1D ScalarBC2D AddScalarBC};

            // Usage relationships
            edge [style=dashed, dir=forward, color="#006600", penwidth=1.0];
            Gradient -> Laplacian;
            Divergence -> Laplacian;

            // Grid and dimension relationships
            edge [style=dotted, dir=forward, color="#990000", penwidth=1.0];
            OneD -> {Interpol Gradient Divergence Laplacian RobinBC ScalarBC1D AddScalarBC};
            TwoD -> {Gradient Divergence Laplacian RobinBC ScalarBC2D AddScalarBC};
            Uniform -> {Interpol Gradient Divergence Laplacian};
            NonUniform -> {Gradient Divergence};

            // Boundary condition relationships
            edge [style=dashed, constraint=false, color="#AA6600", penwidth=1.0];
            RobinBC -> {Gradient Divergence Laplacian};
            ScalarBC1D -> AddScalarBC;
            ScalarBC2D -> AddScalarBC;
            AddScalarBC -> {Gradient Divergence Laplacian};

            // Add a legend
            subgraph cluster_legend {
                label="Legend";
                style=filled;
                color="#F5F5F5";
                fontsize=10;

                node [shape=none, style=none, label=""];
                edge [style=none];

                leg_title [label="Relationship Types:", shape=none, fontsize=9];
                leg_module [label="Module/API Ownership", shape=none, fontsize=9];
                leg_usage [label="Operator Usage", shape=none, fontsize=9];
                leg_grid [label="Grid/Dimension Support", shape=none, fontsize=9];
                leg_boundary [label="Boundary Modification", shape=none, fontsize=9];

                leg_title -> leg_module [style=solid, color="#0000AA", penwidth=1.5];
                leg_title -> leg_usage [style=dashed, color="#006600", penwidth=1.0];
                leg_title -> leg_grid [style=dotted, color="#990000", penwidth=1.0];
                leg_title -> leg_boundary [style=dashed, color="#AA6600", penwidth=1.0];
            }
        }

.. only:: latex

    The MOLE.jl API consists of several key components:

    Core Package:
        * **MOLE.jl**: Julia implementation of Mimetic Operators Library Enhanced.

    Core Modules:
        * **MOLE.Operators**: Provides mimetic discrete operators.
        * **MOLE.BCs**: Provides boundary-condition utilities and scalar boundary-condition support.

    Core Operators:
        * **interpol**: Interpolation operator for grid transformations.
        * **grad**: Gradient operator with support for one- and two-dimensional grids.
        * **div**: Divergence operator with support for one- and two-dimensional grids.
        * **lap**: Laplacian operator related to gradient and divergence operators.

    Boundary Conditions:
        * **robinBC**: Constructs Robin, Neumann, and Dirichlet boundary-condition contributions.
        * **ScalarBC1D**: Scalar boundary-condition data for one-dimensional problems.
        * **ScalarBC2D**: Scalar boundary-condition data for two-dimensional problems.
        * **addScalarBC!**: Applies scalar boundary conditions to operators or systems.

    Grid and Dimension Variants:
        * **1D Operators**: One-dimensional versions of interpolation, gradient, divergence, Laplacian, and boundary-condition routines.
        * **2D Operators**: Two-dimensional versions of gradient, divergence, Laplacian, and boundary-condition routines.
        * **Uniform Grids**: Operators defined using regular grid spacing.
        * **Non-uniform Grids**: Operators defined using coordinate ticks or non-uniform grid spacing.

    Key Features:
        * MOLE.jl exposes operators through Julia modules rather than C++ classes.
        * Core operators are grouped under **MOLE.Operators**.
        * Boundary-condition tools are grouped under **MOLE.BCs**.
        * Laplacian functionality is closely related to Gradient and Divergence.
        * Boundary-condition utilities can modify operator behavior or system matrices.
        * Several operators support both uniform and non-uniform grids.
```
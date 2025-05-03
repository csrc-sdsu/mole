# C++ 

This section documents the C++ implementation of the MOLE toolkit.

## Overview

The C++ implementation provides high-performance operators and boundary conditions for numerical computations, with a focus on mimetic methods.

## Class Structure

```{eval-rst}
.. only:: html

    The following diagram shows the key classes in the MOLE C++ API and their relationships:

    .. graphviz::

        digraph mole_class_structure {
            bgcolor="transparent";
            rankdir=TB;  // Top to Bottom layout
            compound=true;
            node [shape=box, style=filled, fontname="Arial", fontsize=10, margin="0.3,0.1"];
            edge [fontname="Arial", fontsize=9];
            
            // Color definitions
            node [fillcolor="#E8F4F9"];  // Light blue for base nodes
            
            // Core base classes
            subgraph cluster_base {
                label="Base Classes";
                style=filled;
                color="#F5F5F5";
                
                sp_mat [label="sp_mat\n(Armadillo)"];
                Operator [label="Operator\n(Abstract Base)"];
            }
            
            // Operators
            subgraph cluster_operators {
                label="Core Operators";
                style=filled;
                color="#F5F5F5";
                node [fillcolor="#D5E8D4"];  // Light green for operators
                
                Interpol [label="Interpol\n(Interpolation)"];
                Gradient [label="Gradient"];
                Divergence [label="Divergence"];
                Laplacian [label="Laplacian"];
            }
            
            // Boundary Conditions
            subgraph cluster_bc {
                label="Boundary Conditions";
                style=filled;
                color="#F5F5F5";
                node [fillcolor="#FFE6CC"];  // Light orange for boundary conditions
                
                RobinBC [label="RobinBC\n(Robin/Neumann/Dirichlet)"];
                MixedBC [label="MixedBC\n(Mixed)"];
            }
            
            // Utility Components
            subgraph cluster_utils {
                label="Utilities";
                style=filled;
                color="#F5F5F5";
                node [fillcolor="#DAE8FC"];  // Light blue for utilities
                
                Utils [label="Utils\n(Helper Functions)"];
                GridFunctions [label="Grid Functions"];
                WeightFunctions [label="Weight Functions"];
            }
            
            // Inheritance relationships
            edge [color="#0000AA", penwidth=1.5];
            sp_mat -> Operator [dir=back, arrowtail=empty];
            Operator -> {Interpol Gradient Divergence Laplacian RobinBC MixedBC} [dir=back, arrowtail=empty];
            
            // Usage relationships
            edge [style=dashed, dir=forward, color="#006600", penwidth=1.0];
            Gradient -> Laplacian;
            Divergence -> Laplacian;
            
            // Utility relationships
            edge [style=dotted, dir=forward, color="#990000", penwidth=1.0];
            Utils -> {Gradient Divergence Laplacian};
            Utils -> {RobinBC MixedBC};
            GridFunctions -> {Gradient Divergence};
            WeightFunctions -> {Interpol Gradient Divergence};
            
            // Boundary condition relationships
            edge [style=dashed, constraint=false, color="#AA6600", penwidth=1.0];
            RobinBC -> {Gradient Divergence};
            MixedBC -> {Gradient Divergence};
            
            // Add a legend
            subgraph cluster_legend {
                label="Legend";
                style=filled;
                color="#F5F5F5";
                fontsize=10;
                
                node [shape=none, style=none, label=""];
                edge [style=none];
                
                leg_title [label="Relationship Types:", shape=none, fontsize=9];
                leg_inherit [label="Inheritance", shape=none, fontsize=9];
                leg_usage [label="Usage", shape=none, fontsize=9];
                leg_utility [label="Utility Support", shape=none, fontsize=9];
                leg_boundary [label="Boundary Modification", shape=none, fontsize=9];
                
                leg_title -> leg_inherit [style=solid, color="#0000AA", penwidth=1.5];
                leg_title -> leg_usage [style=dashed, color="#006600", penwidth=1.0];
                leg_title -> leg_utility [style=dotted, color="#990000", penwidth=1.0];
                leg_title -> leg_boundary [style=dashed, color="#AA6600", penwidth=1.0];
            }
        }

.. only:: latex

    The MOLE C++ API consists of several key components:

    Base Classes:
        * **sp_mat**: Armadillo sparse matrix base class
        * **Operator**: Abstract base class for all operators

    Core Operators:
        * **Interpol**: Interpolation operator for grid transformations
        * **Gradient**: Gradient operator with support for various grid types
        * **Divergence**: Divergence operator with support for various grid types
        * **Laplacian**: Laplacian operator composed of Gradient and Divergence

    Boundary Conditions:
        * **RobinBC**: Implements Robin, Neumann, and Dirichlet boundary conditions
        * **MixedBC**: Implements mixed-type boundary conditions

    Utility Components:
        * **Utils**: Core utility functions for matrix operations and grid handling
        * **Grid Functions**: Functions for grid generation and manipulation
        * **Weight Functions**: Functions for computing operator weights

    Key Features:
        * All operators inherit from the abstract Operator class
        * Boundary conditions can modify operator behavior
        * Utility functions support both operators and boundary conditions
        * Grid and weight functions configure operator behavior
        * Laplacian implementation uses both Gradient and Divergence
```

```{toctree}
:maxdepth: 2
:hidden:
:caption: API Components

operators
boundary
utils
```

```{admonition} Advanced Usage
:class: tip
For advanced usage patterns and performance optimization, check out the individual class documentation pages.
```

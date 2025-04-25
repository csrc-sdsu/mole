# MOLE C++ API Reference

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
            rankdir=BT;
            compound=true;
            node [shape=box, style=filled, fillcolor=white, fontname="Arial", fontsize=10];
            edge [fontname="Arial", fontsize=9];
            
            // Core base classes
            subgraph cluster_base {
                label="Base Classes";
                style=dashed;
                
                sp_mat [label="sp_mat\n(Armadillo)"];
                Operator [label="Operator\n(Abstract Base)"];
            }
            
            // Operators
            subgraph cluster_operators {
                label="Core Operators";
                style=dashed;
                
                Interpol [label="Interpol\n(Interpolation)"];
                Gradient [label="Gradient"];
                Divergence [label="Divergence"];
                Laplacian [label="Laplacian"];
            }
            
            // Boundary Conditions
            subgraph cluster_bc {
                label="Boundary Conditions";
                style=dashed;
                
                RobinBC [label="RobinBC\n(Robin/Neumann/\nDirichlet)"];
                MixedBC [label="MixedBC\n(Mixed)"];
            }
            
            // Utility Components
            subgraph cluster_utils {
                label="Utilities";
                style=dashed;
                
                Utils [label="Utils\n(Helper Functions)"];
                GridFunctions [label="Grid Functions"];
                WeightFunctions [label="Weight Functions"];
            }
            
            // Inheritance relationships
            sp_mat -> Operator [dir=back, arrowtail=empty, label="inherits"];
            Operator -> {Interpol Gradient Divergence Laplacian RobinBC MixedBC} [dir=back, arrowtail=empty];
            
            // Usage relationships
            edge [style=dashed, dir=forward];
            Gradient -> Laplacian [label="used by"];
            Divergence -> Laplacian [label="used by"];
            
            // Utility relationships
            edge [style=dotted, dir=forward];
            Utils -> {Gradient Divergence Laplacian} [label="supports"];
            Utils -> {RobinBC MixedBC} [label="supports"];
            GridFunctions -> {Gradient Divergence} [label="configures"];
            WeightFunctions -> {Interpol Gradient Divergence} [label="configures"];
            
            // Boundary condition relationships
            edge [style=dashed, constraint=false];
            RobinBC -> {Gradient Divergence} [label="modifies"];
            MixedBC -> {Gradient Divergence} [label="modifies"];
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

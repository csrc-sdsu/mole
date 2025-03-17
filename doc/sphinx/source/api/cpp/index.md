# C++ API Documentation

Welcome to the C++ API documentation for the Mimetic Operators Library Enhanced (MOLE). This section provides detailed information about the library's classes and their usage.

```{admonition} Installation Note
:class: note
Make sure you have installed the MOLE library properly to use these classes. See the [Getting Started Guide](../gettingstarted.md) for installation instructions.
```

## Class Hierarchy

The MOLE C++ API consists of the following main components:

- **Operators**: Core mathematical operators
  - Gradient: Computes the gradient of a scalar field
  - Divergence: Computes the divergence of a vector field
  - Laplacian: Computes the Laplacian of a scalar field
  - Interpolation: Performs interpolation operations
  - Operator Overloads: For easy operator composition

- **Boundary Conditions**: For specifying domain boundaries
  - MixedBC: Implements mixed boundary conditions
  - RobinBC: Implements Robin boundary conditions

- **Utilities**: Helper functions and tools
  - Utils: Static helper functions

```{toctree}
:maxdepth: 2
:caption: API Components

operators/index
boundary/index
utils/index
```

## Components

<div class="component-box">
<h3>Operators</h3>
<ul>
<li><a href="operators/gradient.html">Gradient</a>: Computes the gradient of a scalar field</li>
<li><a href="operators/divergence.html">Divergence</a>: Computes the divergence of a vector field</li>
<li><a href="operators/laplacian.html">Laplacian</a>: Computes the Laplacian of a scalar field</li>
<li><a href="operators/interpol.html">Interpolation</a>: Performs interpolation operations</li>
<li><a href="operators/operators.html">Operator Overloads</a>: Operator overloads for easy operator composition</li>
</ul>
</div>

<div class="component-box">
<h3>Boundary Conditions</h3>
<ul>
<li><a href="boundary/mixedbc.html">Mixed BC</a>: Implements mixed boundary conditions</li>
<li><a href="boundary/robinbc.html">Robin BC</a>: Implements Robin boundary conditions</li>
</ul>
</div>

<div class="component-box">
<h3>Utilities</h3>
<ul>
<li><a href="utils/utils.html">Utils</a>: Utility class with static helper functions</li>
</ul>
</div>

```{admonition} Advanced Usage
:class: tip
For advanced usage patterns and performance optimization, check out the individual class documentation pages.
``` 
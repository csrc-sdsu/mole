# <span class="boundary-icon">🔄</span> Boundary Conditions

MOLE provides various boundary condition implementations to complement its mimetic operators. These boundary conditions are essential for properly defining and solving partial differential equations.

```{admonition} Importance of Boundary Conditions
:class: important
Boundary conditions are critical for ensuring that differential equation solutions are unique and physically meaningful. They specify constraints at the boundaries of the computational domain.
```

## Available Boundary Conditions

<div class="component-box">
<h3>Mixed Boundary Conditions</h3>
<p>Implements mixed boundary conditions that can combine Dirichlet, Neumann, and Robin conditions</p>
<a href="mixedbc.html" class="btn btn-primary">View Documentation</a>
</div>

<div class="component-box">
<h3>Robin Boundary Conditions</h3>
<p>Implements Robin boundary conditions that combine aspects of Dirichlet and Neumann conditions</p>
<a href="robinbc.html" class="btn btn-primary">View Documentation</a>
</div>

## Common Features

All boundary condition implementations in MOLE:

* **High-order accuracy**: Maintain the same order of accuracy as the operators
* **Mimetic properties preservation**: Respect conservation laws at boundaries
* **Flexible specification**: Support for different conditions at different boundaries
* **Seamless integration**: Work directly with the mimetic operators 
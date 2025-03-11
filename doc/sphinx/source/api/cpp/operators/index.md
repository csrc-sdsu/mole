# <span class="operator-icon">🧮</span> Operators

The MOLE library provides a set of high-order mimetic operators for solving partial differential equations. These operators are designed to maintain important mathematical properties of the continuous operators they approximate.

```{admonition} What are Mimetic Operators?
:class: note
Mimetic operators are discrete analogs of continuous differential operators that preserve important mathematical properties of the continuum problem at the discrete level.
```

## Available Operators

<div class="component-box">
<h3>Gradient</h3>
<p>Computes the gradient of a scalar field</p>
<a href="gradient.html" class="btn btn-primary">View Documentation</a>
</div>

<div class="component-box">
<h3>Divergence</h3>
<p>Computes the divergence of a vector field</p>
<a href="divergence.html" class="btn btn-primary">View Documentation</a>
</div>

<div class="component-box">
<h3>Laplacian</h3>
<p>Computes the Laplacian of a scalar field</p>
<a href="laplacian.html" class="btn btn-primary">View Documentation</a>
</div>

<div class="component-box">
<h3>Interpolation</h3>
<p>Performs interpolation operations</p>
<a href="interpol.html" class="btn btn-primary">View Documentation</a>
</div>

<div class="component-box">
<h3>Operator Overloads</h3>
<p>Operator overloads for easy operator composition</p>
<a href="operators.html" class="btn btn-primary">View Documentation</a>
</div>

## Common Features

All operators in MOLE share these common characteristics:

* **High-order accuracy**: Operators can be constructed with arbitrary order of accuracy
* **Mimetic properties preservation**: Conservation of important mathematical properties
* **Support for various grid types**: Uniform, non-uniform, and curvilinear grids
* **Efficient sparse matrix implementation**: Optimized for computational performance 
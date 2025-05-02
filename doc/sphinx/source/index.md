# MOLE: Mimetic Operators Library Enhanced

<p class="lead text-center my-4">
A high-order mimetic differential operators library for solving PDEs
</p>

````{grid} 2
:gutter: 3
:class-container: features-grid

```{grid-item-card} High-order Accuracy
Discrete analogs of vector calculus operators that satisfy local and global conservation laws
```

```{grid-item-card} Structured Grids
Works with uniform, non-uniform, and curvilinear staggered grids
```

```{grid-item-card} Operator Set
Includes Gradient, Divergence, and Laplacian operators with various boundary conditions
```

```{grid-item-card} Dual Implementation
Available in both C++ and MATLAB with consistent interfaces
```
````

```{admonition} Key Capabilities
:class: tip

**Suitable for PDEs:**
- Elliptic (Poisson)
- Parabolic (Heat, Diffusion)
- Hyperbolic (Wave)

**Boundary Conditions:**
- Dirichlet
- Neumann
- Robin
- Mixed
```

```{toctree}
:maxdepth: 2
:caption: Getting Started

intros/introduction
intros/gettingstarted
intros/doc_readme_wrapper
features-demo
```

```{toctree}
:maxdepth: 4
:caption: API Reference

api/cpp/index
api/matlab/index-beta
```

```{toctree}
:maxdepth: 2
:caption: Mathematical Framework

math_functions/index
```

```{toctree}
:maxdepth: 2
:caption: Examples

examples/index
```

```{toctree}
:maxdepth: 1
:caption: Project

intros/contributing_wrapper
intros/code_of_conduct_wrapper
```

```{div} quick-links
## Quick Links

- [Index](genindex)
- [Search](search)
- [GitHub Repository](https://github.com/csrc-sdsu/mole)
- [Citation (JOSS)](https://doi.org/10.21105/joss.06288)
- [MATLAB File Exchange](https://www.mathworks.com/matlabcentral/fileexchange/124870-mole)
```
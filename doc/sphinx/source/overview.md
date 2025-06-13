# MOLE: Mimetic Operators Library Enhanced

```{admonition} About MOLE
:class: note

A high-order mimetic differential operators library for solving PDEs
```

````{grid} 1 1 2 2
:gutter: 4
:class-container: feature-grid

```{grid-item-card} <i class="fas fa-bullseye"></i> High-order Accuracy
:class-card: feature-card
Discrete analogs of vector calculus operators that satisfy local and global conservation laws
```

```{grid-item-card} <i class="fas fa-table"></i> Structured Grids
:class-card: feature-card
Works with uniform, non-uniform, and curvilinear staggered grids
```

```{grid-item-card} <i class="fas fa-sync"></i> Operator Set
:class-card: feature-card
Includes Gradient, Divergence, and Laplacian operators with various boundary conditions
```

```{grid-item-card} <i class="fas fa-laptop-code"></i> Dual Implementation
:class-card: feature-card
Available in both C++ and MATLAB/ Octave with consistent interfaces
```

```markdown
```{only} html
```{include} ../../../README.md


<h3>Platform and Compiler Compatibility</h3>

<table>
  <thead>
    <tr>
      <th>OS / Compiler</th>
      <th><img src="https://img.shields.io/badge/Compiler-GCC%2013.2.0-00599C?logo=gnu&logoColor=white"></th>
      <th><img src="https://img.shields.io/badge/Compiler-AppleClang-black?logo=apple&logoColor=white"></th>
      <th><img src="https://img.shields.io/badge/Compiler-IntelLLVM%20%28icpx%29-blue?logo=intel&logoColor=white"></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><img src="https://img.shields.io/badge/OS-Linux-lightgrey?logo=linux&logoColor=white"></td>
      <td>✔</td><td>✘</td><td>✔</td>
    </tr>
    <tr>
      <td><img src="https://img.shields.io/badge/OS-macOS-blue?logo=apple&logoColor=white"></td>
      <td>✘</td><td>✔</td><td>✔</td>
    </tr>
  </tbody>
</table>

```

```{only} latex
.. list-table::
   :header-rows: 1
   :widths: 15 15 15 20

   * - OS
     - GCC 13.2.0
     - AppleClang
     - IntelLLVM (icpx)
   * - Linux
     - Yes
     - No
     - Yes
   * - macOS
     - No
     - Yes
     - Yes
```
````
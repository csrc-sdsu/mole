# MOLE: Mimetic Operators Library Enhanced

<div class="header-banner" style="text-align: center; margin: 2em 0;">
    <!-- <img src="_static/img/logo.png" alt="MOLE Logo" width="200px"> -->
    <p style="font-size: 1.2em; color: #666; margin-top: 1em;">
        A high-order mimetic differential operators library for solving PDEs
    </p>
</div>

<div class="grid-container" style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 2em; margin: 2em 0;">
    <div class="component-box">
        <h3>High-order Accuracy</h3>
        <p>Discrete analogs of vector calculus operators that satisfy local and global conservation laws</p>
    </div>
    <div class="component-box">
        <h3>Structured Grids</h3>
        <p>Works with uniform, non-uniform, and curvilinear staggered grids</p>
    </div>
    <div class="component-box">
        <h3>Operator Set</h3>
        <p>Includes Gradient, Divergence, and Laplacian operators with various boundary conditions</p>
    </div>
    <div class="component-box">
        <h3>Dual Implementation</h3>
        <p>Available in both C++ and MATLAB with consistent interfaces</p>
    </div>
</div>

<div class="more-features" style="margin: 2em 0; padding: 1.5em; background-color: #f8f9fa; border-radius: 8px;">
    <h2>Key Capabilities</h2>
    <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 1.5em; margin-top: 1.5em;">
        <div>
            <h3>Suitable for PDEs</h3>
            <ul>
                <li>Elliptic (Poisson)</li>
                <li>Parabolic (Heat, Diffusion)</li>
                <li>Hyperbolic (Wave)</li>
            </ul>
        </div>
        <div>
            <h3>Boundary Conditions</h3>
            <ul>
                <li>Dirichlet</li>
                <li>Neumann</li>
                <li>Robin</li>
                <li>Mixed</li>
            </ul>
        </div>
    </div>
</div>

<!--------------------------------------------------  toctree starts here  ----------------------------------------------------------------------->
```{toctree}
:maxdepth: 2
:caption: Getting Started

Introduction <intros/introduction.rst>
intros/gettingstarted.rst
Building Documentation <intros/doc_readme_wrapper.md>
```

```{toctree}
:maxdepth: 4
:caption: API Reference

C++ <api/cpp/index>
Matlab/ Octave <api/matlab/index-beta.rst>
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

Contributing <intros/contributing_wrapper.md>
Code of Conduct <intros/code_of_conduct_wrapper.md>
```

<!--------------------------------------------------  toctree ends here  ----------------------------------------------------------------------->

<div class="quick-links" style="margin: 2em 0; padding: 1em; background: #f8f9fa; border-radius: 8px;">
    <h2>Quick Links</h2>
    <ul style="list-style: none; padding: 0;">
        <li><a href="genindex">Index</a></li>
        <li><a href="search">Search</a></li>
        <li><a href="https://github.com/csrc-sdsu/mole">GitHub Repository</a></li>
        <li><a href="https://doi.org/10.21105/joss.06288">Citation (JOSS)</a></li>
        <li><a href="https://www.mathworks.com/matlabcentral/fileexchange/124870-mole">MATLAB File Exchange</a></li>
    </ul>
</div>

<link rel="stylesheet" type="text/css" href="_static/css/styles.css">

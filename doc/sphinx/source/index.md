# MOLE: Mimetic Operators Library Enhanced

<div class="header-banner" style="text-align: center; margin: 2em 0;">
    <!-- <img src="_static/img/logo.png" alt="MOLE Logo" width="200px"> -->
    <p style="font-size: 1.2em; color: #666; margin-top: 1em;">
        A high-order mimetic differential operators library for solving PDEs
    </p>
</div>

<div class="grid-container" style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 2em; margin: 2em 0;">
    <div class="component-box">
        <h3>🔍 Mathematically Precise</h3>
        <p>Discrete analogs of vector calculus operators that satisfy local and global conservation laws</p>
    </div>
    <div class="component-box">
        <h3>📊 Multi-Grid Support</h3>
        <p>Works with uniform, non-uniform, and curvilinear staggered grids</p>
    </div>
    <div class="component-box">
        <h3>🧮 Complete Operator Set</h3>
        <p>Includes Gradient, Divergence, Laplacian, Bilaplacian, and Curl with various boundary conditions</p>
    </div>
    <div class="component-box">
        <h3>💻 Dual Implementation</h3>
        <p>Available in both C++ and MATLAB/Octave with consistent interfaces</p>
    </div>
</div>

<div class="more-features" style="margin: 2em 0; padding: 1.5em; background-color: #f8f9fa; border-radius: 8px;">
    <h2>Key Capabilities</h2>
    <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 1.5em; margin-top: 1.5em;">
        <div>
            <h3>📝 PDE Types</h3>
            <ul>
                <li>Elliptic (Poisson, Helmholtz)</li>
                <li>Parabolic (Heat, Diffusion)</li>
                <li>Hyperbolic (Wave, Transport)</li>
                <li>Nonlinear (Burgers, Richards)</li>
                <li>Quantum (Schrödinger)</li>
            </ul>
        </div>
        <div>
            <h3>🛠️ Boundary Conditions</h3>
            <ul>
                <li>Dirichlet</li>
                <li>Neumann</li>
                <li>Robin</li>
                <li>Periodic</li>
                <li>Mixed</li>
            </ul>
        </div>
    </div>
</div>

```{toctree}
:maxdepth: 2
:caption: Getting Started

api/introduction.rst
api/gettingstarted.rst
Building Documentation <api/README.md>
```

```{toctree}
:maxdepth: 2
:caption: API Reference

api/cpp/index
api/matlab/index
```

<!-- ```{toctree}
:maxdepth: 2
:caption: Examples

examples/wave_equation
examples/burgers_equation
examples/poisson_equation
``` -->

```{toctree}
:maxdepth: 1
:caption: Project

Read Me <../../../README.md>
Contributing <api/contributing_wrapper.md>
Code of Conduct <api/code_of_conduct_wrapper.md>
```

<div class="quick-links" style="margin: 2em 0; padding: 1em; background: #f8f9fa; border-radius: 8px;">
    <h2>Quick Links</h2>
    <ul style="list-style: none; padding: 0;">
        <li>📖 <a href="genindex">Index</a></li>
        <li>🔍 <a href="search">Search</a></li>
        <li>⭐ <a href="https://github.com/csrc-sdsu/mole">GitHub Repository</a></li>
        <li>📚 <a href="https://doi.org/10.21105/joss.06288">Citation (JOSS)</a></li>
        <li>🔧 <a href="https://www.mathworks.com/matlabcentral/fileexchange/124870-mole">MATLAB File Exchange</a></li>
    </ul>
</div>

<style>
.component-box {
    padding: 1.5em;
    background-color: #fff;
    border-radius: 8px;
    box-shadow: 0 2px 6px rgba(0,0,0,0.1);
    transition: transform 0.3s ease, box-shadow 0.3s ease;
}
.component-box:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 8px rgba(0,0,0,0.1);
}
.component-box h3 {
    margin-top: 0;
    color: #2980b9;
}
.more-features h3 {
    color: #2980b9;
    border-bottom: 1px solid #eee;
    padding-bottom: 0.5em;
    margin-bottom: 0.8em;
}
.more-features ul {
    padding-left: 1.5em;
}
.more-features ul li {
    margin-bottom: 0.5em;
}
.quick-links ul li {
    margin: 0.5em 0;
}
.quick-links ul li a {
    text-decoration: none;
}
.quick-links ul li a:hover {
    text-decoration: underline;
}
</style>

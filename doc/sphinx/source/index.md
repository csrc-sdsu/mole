# MOLE: Mimetic Operators Library Enhanced

<div class="header-banner" style="text-align: center; margin: 2em 0;">
    <!-- <img src="_static/img/logo.png" alt="MOLE Logo" width="200px"> -->
    <p style="font-size: 1.2em; color: #666; margin-top: 1em;">
        A high-performance library for mimetic difference methods
    </p>
</div>

<div class="grid-container" style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 2em; margin: 2em 0;">
    <div class="feature-box" style="padding: 1.5em; background: #f8f9fa; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
        <h3>🚀 High Performance</h3>
        <p>Optimized implementation of mimetic operators for maximum computational efficiency</p>
    </div>
    <div class="feature-box" style="padding: 1.5em; background: #f8f9fa; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
        <h3>🔧 Easy to Use</h3>
        <p>Simple and intuitive interfaces for both C++ and MATLAB</p>
    </div>
    <div class="feature-box" style="padding: 1.5em; background: #f8f9fa; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
        <h3>📚 Well Documented</h3>
        <p>Comprehensive documentation with examples and API references</p>
    </div>
    <div class="feature-box" style="padding: 1.5em; background: #f8f9fa; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
        <h3>🔬 Research Ready</h3>
        <p>Designed for scientific computing and numerical analysis</p>
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

api/operators/index
api/boundary/index
api/utils/index
api/matlab_api
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

README <api/readme_wrapper.md>
Contributing <api/contributing_wrapper.md>
Code of Conduct <api/code_of_conduct_wrapper.md>
```

<div class="quick-links" style="margin: 2em 0; padding: 1em; background: #f8f9fa; border-radius: 8px;">
    <h2>Quick Links</h2>
    <ul style="list-style: none; padding: 0;">
        <li>📖 <a href="genindex">Index</a></li>
        <li>🔍 <a href="search">Search</a></li>
        <li>⭐ <a href="https://github.com/csrc-sdsu/mole">GitHub Repository</a></li>
    </ul>
</div>

<style>
.feature-box:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 8px rgba(0,0,0,0.1);
    transition: all 0.3s ease;
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

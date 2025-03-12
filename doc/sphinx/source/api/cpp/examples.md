# Examples

This section provides examples of how to use the MOLE C++ API for various numerical simulations and computations.

## Available Examples

MOLE provides several example simulations to demonstrate the use of the library:

```{eval-rst}
.. list-table::
   :header-rows: 1
   :widths: 30 70

   * - Example
     - Description
   * - :doc:`Poisson Equation <examples/poisson>`
     - Solving the Poisson equation with appropriate boundary conditions
   * - :doc:`Heat Equation <examples/heat>`
     - Solving the heat equation with time stepping
   * - :doc:`Advection Equation <examples/advection>`
     - Solving the advection equation with upwind scheme
   * - :doc:`Wave Equation <examples/wave>`
     - Solving the wave equation with central differences
   * - :doc:`Burgers Equation <examples/burgers>`
     - Solving the Burgers equation with viscosity
```

## Detailed Documentation

```{toctree}
:maxdepth: 1

examples/poisson.md
examples/heat.md
examples/advection.md
examples/wave.md
examples/burgers.md
```

For more examples, please refer to the `examples` directory in the MOLE source code.

```{eval-rst}
.. raw:: html

   <div class="on-this-page">
     <div class="on-this-page-title">On This Page</div>
     <ul>
       <li><a href="#poisson-equation">Poisson Equation</a></li>
       <li><a href="#heat-equation">Heat Equation</a></li>
       <li><a href="#advection-equation">Advection Equation</a></li>
       <li><a href="#wave-equation">Wave Equation</a></li>
     </ul>
   </div>

   <style>
     .on-this-page {
       position: sticky;
       top: 20px;
       float: right;
       width: 200px;
       padding: 10px;
       margin-left: 20px;
       background-color: #f8f9fa;
       border: 1px solid #e1e4e5;
       border-radius: 5px;
     }
     
     .on-this-page-title {
       font-weight: bold;
       margin-bottom: 10px;
     }
     
     .on-this-page ul {
       list-style-type: none;
       padding-left: 10px;
       margin: 0;
     }
     
     .on-this-page li {
       margin-bottom: 5px;
     }
     
     .on-this-page a {
       text-decoration: none;
     }
     
     .collapsible-section {
       margin-bottom: 20px;
     }
     
     .collapsible-header {
       background-color: #f6f6f6;
       padding: 10px;
       cursor: pointer;
       border: 1px solid #e1e4e5;
       border-radius: 5px 5px 0 0;
       font-weight: bold;
     }
     
     .collapsible-content {
       border: 1px solid #e1e4e5;
       border-top: none;
       padding: 10px;
       border-radius: 0 0 5px 5px;
       display: none;
     }
     
     .collapsible-header.active {
       background-color: #e1e4e5;
     }
     
     .collapsible-header.active + .collapsible-content {
       display: block;
     }
   </style>

   <script>
     document.addEventListener('DOMContentLoaded', function() {
       const headers = document.querySelectorAll('.collapsible-header');
       
       headers.forEach(header => {
         header.addEventListener('click', function() {
           this.classList.toggle('active');
           const content = this.nextElementSibling;
           if (content.style.display === 'block') {
             content.style.display = 'none';
           } else {
             content.style.display = 'block';
           }
         });
       });
     });
   </script>
```

## Poisson Equation

This example demonstrates how to solve the Poisson equation using the MOLE library.

```{eval-rst}
.. raw:: html

   <div class="collapsible-section">
     <div class="collapsible-header">Example Overview</div>
     <div class="collapsible-content">
```

The Poisson equation is given by:

$$\nabla^2 u = f$$

with appropriate boundary conditions.

For the full implementation details, see the [Poisson Equation](examples/poisson.md) page.

```{eval-rst}
.. raw:: html

     </div>
   </div>
```

## Heat Equation

This example demonstrates how to solve the heat equation using the MOLE library.

```{eval-rst}
.. raw:: html

   <div class="collapsible-section">
     <div class="collapsible-header">Example Overview</div>
     <div class="collapsible-content">
```

The heat equation is given by:

$$\frac{\partial u}{\partial t} = \alpha \nabla^2 u$$

with appropriate initial and boundary conditions.

For the full implementation details, see the [Heat Equation](examples/heat.md) page.

```{eval-rst}
.. raw:: html

     </div>
   </div>
```

For more examples, please refer to the `examples` directory in the MOLE source code.
# Contributing to MOLE: Comprehensive Guide

Thank you for considering contributing to MOLE (Mimetic Operators Library Enhanced)! This guide provides detailed instructions for contributing to the MOLE project, whether you're adding core functionality, examples, or documentation.

---

## Table of Contents

1. [Getting Started](#getting-started)
2. [Contributing to Core Functionality](#contributing-to-core-functionality)
3. [Contributing Examples](#contributing-examples)
4. [Contributing to Documentation](#contributing-to-documentation)
5. [Code Standards and Guidelines](#code-standards-and-guidelines)
6. [Testing and Validation](#testing-and-validation)
7. [Submission Process](#submission-process)
8. [Getting Help](#getting-help)

---

## Getting Started

### Prerequisites

Before contributing, ensure you have:

- **For MATLAB/Octave**: MATLAB R2016b+ or GNU Octave 4.0+
- **For C++**: CMake 3.10+, OpenBLAS, Eigen3, Armadillo
- **For Documentation**: Python 3.7+, Sphinx, Doxygen

### Setting Up Development Environment

1. **Fork the Repository**: Fork the [MOLE repository](https://github.com/csrc-sdsu/mole) to your GitHub account

2. **Clone Your Fork**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/mole.git
   cd mole
   ```

3. **Create a Development Branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

---

## Contributing to Core Functionality

Core functionality includes mimetic operators, boundary conditions, and utility functions that form the foundation of the MOLE library.

### Core API Structure

The MOLE library follows a consistent structure across MATLAB and C++ implementations:

#### MATLAB/Octave Core Functions

Core functions are located in `src/matlab/` and follow this pattern:

```matlab
function OUTPUT = functionName(k, m, dx, ...)
% BRIEF_DESCRIPTION
%
% Parameters:
%                k : Order of accuracy
%                m : Number of cells (along x-axis for multidimensional)
%               dx : Step size (along x-axis for multidimensional)
%    (additional parameters as needed)
%
% Returns:
%          OUTPUT : Sparse matrix representing the operator
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    % Input validation
    assert(k >= 2, 'Order of accuracy k must be >= 2');
    assert(mod(k, 2) == 0, 'Order of accuracy k must be even');
    assert(m >= 2*k+1, ['Number of cells m must be >= ' num2str(2*k+1) ' for k = ' num2str(k)]);
    
    % Implementation
    % ...
    
end
```

#### C++ Core Classes

C++ implementations are in `src/cpp/` and follow this pattern:

```cpp
/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * © 2008-2024 San Diego State University Research Foundation (SDSURF).
 * See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
 */

/**
 * @file classname.h
 * @brief Brief description
 * @date Creation date
 */

#ifndef CLASSNAME_H
#define CLASSNAME_H

#include "required_headers.h"

/**
 * @brief Brief class description
 */
class ClassName : public sp_mat {
public:
    using sp_mat::operator=;
    
    /**
     * @brief Constructor description
     * @param k Order of accuracy
     * @param m Number of cells
     * @param dx Step size
     */
    ClassName(u16 k, u32 m, Real dx);
    
    // Additional constructors for 2D, 3D, etc.
};

#endif // CLASSNAME_H
```

### Core Function Categories

When contributing core functionality, identify which category your contribution fits:

1. **Differential Operators**: `grad`, `div`, `lap`, `curl`
2. **Interpolation Functions**: `interpol`, `interpol2D`, `interpol3D`
3. **Boundary Conditions**: `robinBC`, `mixedBC`, `addScalarBC`
4. **Utility Functions**: `jacobian2D`, `jacobian3D`, `weights`
5. **Grid Functions**: Curvilinear and non-uniform grid support

### Core Function Requirements

1. **Consistent Interface**: Follow the parameter ordering convention: `(k, m, dx, n, dy, o, dz, ...)`
2. **Input Validation**: Validate all input parameters with clear error messages
3. **Sparse Matrix Output**: Return sparse matrices for efficiency
4. **Boundary Condition Support**: Consider how your operator interacts with boundary conditions
5. **Multidimensional Support**: Provide 1D, 2D, and 3D versions where applicable
6. **Documentation**: Include comprehensive function documentation

### Example: Adding a New Operator

If adding a new operator, follow this checklist:

1. **MATLAB Implementation** (`src/matlab/newoperator.m`):
   ```matlab
   function OP = newoperator(k, m, dx)
   % Returns a new mimetic operator
   %
   % Parameters:
   %                k : Order of accuracy
   %                m : Number of cells
   %               dx : Step size
   
       % Validation
       assert(k >= 2 && mod(k, 2) == 0, 'k must be even and >= 2');
       
       % Implementation using existing operators
       G = grad(k, m, dx);
       D = div(k, m, dx);
       
       % Combine operators as needed
       OP = someOperation(G, D);
   end
   ```

2. **C++ Implementation** (`src/cpp/newoperator.h` and `src/cpp/newoperator.cpp`)
3. **Add to API Documentation** (`doc/sphinx/source/api/`)
4. **Create Test Examples** (see Examples section)

---

## Contributing Examples

Examples demonstrate how to use MOLE to solve specific PDEs and are crucial for user education.

### Example Structure and Organization

Examples are organized by PDE type in the `examples/` directory:

```
examples/
├── matlab/                 # MATLAB/Octave examples
│   ├── elliptic1D.m       # Basic examples
│   ├── parabolic2D.m      # 2D examples
│   └── compact_operators/ # Specialized examples
└── cpp/                   # C++ examples
    ├── elliptic1D.cpp
    └── transport1D.cpp
```

### Example Categories

Organize your examples by PDE type:

1. **Elliptic**: Steady-state problems (Poisson, Laplace)
2. **Parabolic**: Time-dependent diffusion (heat equation, reaction-diffusion)
3. **Hyperbolic**: Wave-like phenomena (advection, wave equation)
4. **Mixed**: Problems involving multiple PDE types
5. **Specialized**: Navier-Stokes, Schrödinger, etc.

### MATLAB/Octave Example Template

```matlab
% Solves the [EQUATION NAME] with [BOUNDARY CONDITIONS]
% [Brief description of the physics and mathematical formulation]

clc
close all

addpath('../../src/matlab')  % REQUIRED: Add path to MOLE library

%% Problem Parameters
% [Describe each parameter with physical meaning]
k = 2;              % Order of accuracy
m = 50;             % Number of cells
west = 0;           % Domain limits
east = 1;
dx = (east-west)/m; % Grid spacing

%% Physical Parameters
% [Define problem-specific parameters]
alpha = 1;          % Thermal diffusivity (example)
t_final = 1;        % Simulation time

%% Grid Setup
% 1D Staggered grid
xgrid = [west west+dx/2 : dx : east-dx/2 east];

%% Operator Construction
L = lap(k, m, dx);                    % Laplacian operator
L = L + robinBC(k, m, dx, a, b);      % Add boundary conditions

%% Initial and Boundary Conditions
U = initial_condition(xgrid);         % Define initial condition
U(1) = boundary_value_west;           % West boundary
U(end) = boundary_value_east;         % East boundary

%% Time Integration (if applicable)
dt = dx^2/(4*alpha);                  % CFL condition
L_time = alpha*dt*L + speye(size(L)); % Time-stepping operator

for t = 0:dt:t_final
    % Plotting
    plot(xgrid, U, 'LineWidth', 2)
    title(sprintf('Time = %.3f', t))
    xlabel('x')
    ylabel('u(x,t)')
    drawnow
    
    % Time step
    U = L_time * U;
end

%% Analytical Solution Comparison (if available)
U_analytical = analytical_solution(xgrid, t_final);
plot(xgrid, U, 'o-', xgrid, U_analytical, '--')
legend('Numerical', 'Analytical')
```

### C++ Example Template

```cpp
/**
 * @file example_name.cpp
 * @brief Solves the [EQUATION NAME] with [BOUNDARY CONDITIONS]
 * 
 * [Detailed description of the physics and mathematical formulation]
 * 
 * Equation: [Mathematical equation in LaTeX-style comments]
 * Domain: [Domain description]
 * Boundary Conditions: [BC description]
 */

#include "mole.h"
#include <iostream>
#include <iomanip>

using namespace arma;

int main() {
    // Problem parameters
    constexpr u16 k = 2;        // Order of accuracy
    constexpr u32 m = 50;       // Number of cells
    constexpr Real dx = 1.0/m;  // Grid spacing
    
    // Physical parameters
    constexpr Real alpha = 1.0; // Thermal diffusivity
    constexpr Real t_final = 1.0;
    
    // Construct operators
    Laplacian L(k, m, dx);
    RobinBC BC(k, m, dx, a, b);
    L = L + BC;
    
    // Initial conditions
    vec U = initial_condition();
    
    // Time integration
    Real dt = dx*dx/(4*alpha);
    sp_mat L_time = alpha*dt*L + speye(size(L));
    
    for (Real t = 0; t <= t_final; t += dt) {
        // Output current solution
        std::cout << "Time: " << std::fixed << std::setprecision(3) << t << std::endl;
        
        // Time step
        U = L_time * U;
    }
    
    // Output final solution
    std::cout << "Final solution:" << std::endl;
    U.print();
    
    return 0;
}
```

### Example Requirements

1. **Self-contained**: Each example should run independently
2. **Well-commented**: Explain the physics, mathematics, and implementation
3. **Parameter Documentation**: Describe all parameters and their physical meaning
4. **Clear Output**: Include appropriate visualization or numerical output
5. **Validation**: Compare with analytical solutions when possible
6. **Consistent Naming**: Use descriptive variable names following MOLE conventions

### Mathematical Documentation Requirements

Each example should include:

1. **Mathematical Formulation**: Clear statement of the PDE being solved
2. **Domain Description**: Spatial and temporal domains
3. **Boundary Conditions**: Precise specification of BCs
4. **Initial Conditions**: For time-dependent problems
5. **Analytical Solution**: If available, for validation

---

## Contributing to Documentation

Documentation contributions help users understand and effectively use MOLE.

### Documentation Structure

MOLE uses Sphinx for user documentation and Doxygen for API reference:

```
doc/
├── sphinx/                 # User documentation
│   └── source/
│       ├── examples/       # Example documentation
│       ├── api/           # API references
│       └── math_functions/ # Mathematical background
└── doxygen/               # API documentation
```

### Example Documentation Template

Create documentation for examples in `doc/sphinx/source/examples/[Category]/[Dimension]/`:

```markdown
### ExampleName

Brief description of what this example solves.

$$
\text{Mathematical equation in LaTeX}
$$

with domain $x \in [a,b]$ and boundary conditions:

$$
\text{Boundary condition equations}
$$

#### Mathematical Background

[Detailed explanation of the physics and mathematics]

#### Implementation Details

[Key implementation considerations, numerical methods used]

#### Results

[Description of expected results, plots, validation]

---

This example is implemented in:
- [MATLAB/Octave](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/example_name.m)
- [C++](https://github.com/csrc-sdsu/mole/blob/main/examples/cpp/example_name.cpp) *(if available)*

#### Variants

Additional variants with different boundary conditions or parameters:
- [Variant 1](link_to_variant)
- [Variant 2](link_to_variant)
```

### Documentation Guidelines

1. **Mathematical Notation**: Use LaTeX for equations
2. **Code References**: Link to actual implementation files
3. **Cross-references**: Link related examples and API functions
4. **Images**: Include plots and diagrams where helpful
5. **Consistent Structure**: Follow the established template

---

## Code Standards and Guidelines

### MATLAB/Octave Standards

1. **Function Names**: Use descriptive names following the existing convention
2. **Variable Names**: Use clear, descriptive variable names
3. **Comments**: Document complex algorithms and physics
4. **Error Handling**: Use `assert` for input validation
5. **Performance**: Use sparse matrices, avoid loops when possible

### C++ Standards

1. **Naming Convention**: 
   - Classes: `PascalCase`
   - Functions: `camelCase`
   - Variables: `snake_case` for local, `camelCase` for members
2. **Headers**: Include proper copyright and license headers
3. **Documentation**: Use Doxygen-style comments
4. **Memory Management**: Use smart pointers when appropriate
5. **Performance**: Leverage Armadillo's optimizations

### General Guidelines

1. **Consistency**: Follow existing code patterns
2. **Testing**: Ensure your contributions work with provided examples
3. **Documentation**: Document all public interfaces
4. **License**: Include appropriate license headers
5. **Dependencies**: Minimize external dependencies

---

## Testing and Validation

### Testing Your Contributions

1. **Unit Testing**: Test individual functions with known inputs/outputs
2. **Integration Testing**: Test how your contribution works with existing code
3. **Convergence Testing**: Verify order of accuracy for new operators
4. **Example Testing**: Ensure examples run and produce expected results

### Validation Methods

1. **Analytical Solutions**: Compare with known exact solutions
2. **Convergence Studies**: Verify theoretical order of accuracy
3. **Conservation Laws**: Check that operators preserve conservation properties
4. **Cross-platform Testing**: Test on both MATLAB and Octave (for MATLAB code)

### Performance Considerations

1. **Sparse Matrix Efficiency**: Ensure operators are sparse
2. **Memory Usage**: Monitor memory consumption for large problems
3. **Computational Complexity**: Document algorithmic complexity
4. **Scalability**: Test with various problem sizes

---

## Submission Process

### Before Submitting

1. **Code Review**: Review your code for style and functionality
2. **Testing**: Run all relevant tests and examples
3. **Documentation**: Ensure documentation is complete and accurate
4. **Commit Messages**: Write clear, descriptive commit messages

### Pull Request Guidelines

1. **Title**: Use descriptive title indicating what was added/changed
2. **Description**: Provide detailed description of changes
3. **Testing**: Describe testing performed
4. **Examples**: Include or reference relevant examples
5. **Documentation**: Link to any new documentation

### Pull Request Template

```markdown
## Description
Brief description of changes made.

## Type of Change
- [ ] New core functionality
- [ ] New example
- [ ] Documentation update
- [ ] Bug fix
- [ ] Performance improvement

## Mathematical Details
[For new operators] Mathematical formulation and properties.

## Testing
- [ ] Unit tests pass
- [ ] Examples run successfully
- [ ] Convergence studies completed (if applicable)
- [ ] Cross-platform compatibility verified

## Documentation
- [ ] Code is well-commented
- [ ] API documentation updated
- [ ] Example documentation added (if applicable)
- [ ] Mathematical background provided

## Related Issues
Fixes #(issue number)

## Additional Notes
Any additional information or context.
```

### Review Process

1. **Automated Checks**: CI/CD will run automated tests
2. **Code Review**: Maintainers will review code quality and consistency
3. **Mathematical Review**: Mathematical correctness will be verified
4. **Documentation Review**: Documentation completeness will be checked
5. **Performance Review**: Performance impact will be assessed

---

## Getting Help

### Resources

1. **Documentation**: Read the [online documentation](https://mole-docs.readthedocs.io/)
2. **Examples**: Study existing examples for patterns and best practices
3. **Issues**: Check [GitHub issues](https://github.com/csrc-sdsu/mole/issues) for known problems
4. **Discussions**: Use GitHub Discussions for questions and ideas

### Contact

For questions, support, or contributions, contact the MOLE maintainers at:
- [jcastillo@sdsu.edu](mailto:jcastillo@sdsu.edu)
- [mdumett@sdsu.edu](mailto:mdumett@sdsu.edu) 
- [paolini@engineering.sdsu.edu](mailto:paolini@engineering.sdsu.edu)
- [jjbrzenski@sdsu.edu](mailto:jjbrzenski@sdsu.edu)
- [vbarra@sdsu.edu](mailto:vbarra@sdsu.edu)

For specific types of support:

- **GitHub Issues**: For bug reports and feature requests  
- **GitHub Discussions**: For general questions and discussions

### Contributing License Agreement

By contributing to MOLE, you agree that your contributions will be licensed under the GNU General Public License v3.0 or later. Ensure you have the right to license your contributions under this license.

---

## Authorship and Recognition

MOLE contains components authored by many individuals from the computational science community. We believe it is essential that contributors receive appropriate recognition through both informal acknowledgment and academically-recognized credit systems such as publications and citations.

### Authorship Criteria

Status as a named author in MOLE publications, the user manual, and DOI-bearing archives will be granted to those who:

1. **Make significant contributions to MOLE** in any of the following areas:
   - Implementation of core functionality (operators, boundary conditions, utilities)
   - Creation of comprehensive examples and tutorials
   - Documentation and mathematical framework development
   - Conceptualization of new features or mathematical approaches
   - Code review, testing, and validation
   - Community building and user support

2. **Maintain and support their contributions** over time, including:
   - Responding to issues related to their contributions
   - Updating code to maintain compatibility
   - Providing ongoing documentation and support

### Recognition Process

- **Automatic Recognition**: Maintainers will monitor contributions and add qualifying contributors to the `AUTHORS` file
- **Self-Nomination**: If you believe your contributions meet the authorship criteria but haven't been acknowledged, please:
  - Email the maintainers (see [Contact](#contact) section)
  - Create a GitHub issue describing your contributions
- **Periodic Review**: The maintainer team regularly reviews the contributor list to ensure proper recognition

### Publication Guidelines

#### MOLE Software Publications

Authors of publications about MOLE as a whole, including:
- Software papers and technical reports
- DOI-bearing software archives
- Major release announcements
- Comprehensive method descriptions

**shall offer co-authorship to all individuals listed in the `AUTHORS` file** at the time of submission.

#### Publications Using MOLE Features

Authors of publications that describe **specific MOLE contributions or new features** shall:
1. Review the `AUTHORS` file to identify relevant contributors
2. Evaluate the intellectual contributions of listed authors to the specific work
3. Offer co-authorship to those who made significant intellectual contributions to the featured work
4. At minimum, acknowledge MOLE and cite appropriate references

#### Publications Using MOLE for Research

**No co-authorship expectation** exists for those publishing research that uses MOLE as a computational tool (versus creating new features in MOLE). However:

- **Citation**: Please cite MOLE appropriately (see [CITATION.cff](../CITATION.cff))
- **Acknowledgment**: Consider acknowledging significant support or advice received from MOLE developers
- **Judgment**: Use your best judgment regarding the significance of support received in developing your use case and interpreting results

### Citing MOLE

When using MOLE in your research, please cite:

```bibtex
@misc{mole,
  title = {{MOLE}: Mimetic Operators Library Enhanced},
  author = {[See AUTHORS file for complete list]},
  url = {https://github.com/csrc-sdsu/mole},
  note = {Version X.X.X},
  year = {2024}
}
```

For specific mathematical methods or operators, also cite the relevant publications listed in our [documentation](https://mole-docs.readthedocs.io/).

### Examples of Significant Contributions

To clarify what constitutes "significant contributions," here are examples:

**Core Development:**
- Implementing new differential operators or boundary conditions
- Adding support for new grid types or geometries
- Developing new mathematical formulations
- Creating fundamental algorithmic improvements

**Documentation and Education:**
- Writing comprehensive tutorials or guides
- Creating educational examples with mathematical background
- Developing API documentation for major components
- Contributing to the mathematical framework documentation

**Testing and Validation:**
- Developing comprehensive test suites
- Conducting convergence studies and validation
- Cross-platform compatibility work
- Performance optimization and benchmarking

**Community Building:**
- Mentoring new contributors
- Organizing workshops or educational events
- Significant bug reporting and issue management
- Long-term maintenance and support

---

Thank you for contributing to MOLE! Your contributions help advance computational science and benefit the entire research community.

# MOLE: Mimetic Operators Library Enhanced

MOLE is a library that implements high-order mimetic operators to solve partial differential equations.
This site provides documentation for the Julia implementation of MOLE.
More information can be found on the [main documentation site](https://mole-docs.readthedocs.io/en/main/) and the [GitHub repository](https://github.com/csrc-sdsu/mole).

## Getting Started

MOLE.jl is not yet available in the Julia's package manager. For now, this repository needs to be cloned locally in order to use the library.

## Using MOLE.jl

In order to use the MOLE.jl library, first navigate to the location where the repository has been cloned to. Then, go to the `mole/julia/MOLE.jl` sub-directory. From here, you can access the library via the REPL or the command line.

### From the REPL

In `mole/julia/MOLE.jl`, start Julia using the command `julia --project=.`. Next, the package library needs to be instantiated and pre-compiled. Enter the `pkg` mode by pressing `]`, then type the commands `instantiate` and `precompile` (one at a time). This should activate the MOLE.jl package and install the necessary dependencies.

Then, to run a script such as myScript.jl, you can use the following command in the REPL:

```julia
include("path/to/myScript.jl")
```

### From the command line

In `mole/julia/MOLE.jl`, use the following commands to instatiate and precompile the MOLE package:

```sh
julia --project=. -e 'using Pkg; Pkg.instantiate()'
```

```sh
julia --project=. -e 'using Pkg; Pkg.precompile()'
```

Then, to run a script such as `myScript.jl`, use the command

```sh
julia --project=. path/to/myScript.jl
```

## Running the test suite

To run the unit tests, first enter the Julia REPL as in the above section (that is, by running the command `julia --project=.` from the directory `mole/julia/MOLE.jl`). Next, enter the `pkg` mode by pressing `]`, then type the command `test`. The results of the unit tests should be displayed to your console.

## Building the documentation

MOLE.jl uses [Documenter.jl](https://documenter.juliadocs.org/stable/) to build its Julia implementation documentation. From the `mole/julia/MOLE.jl` directory, navigate to the `docs/` directory, with 

```sh
cd docs/
```

### From the REPL

To build the documentation from the `docs/` directory, start Julia with the command `julia --project=.`. You should see the Julia REPL starting with the `(docs)` environment. Next, enter the `pkg` mode by pressing `]`, and then type the commands `instantiate` and `precompile` (one at a time). This should activate the `docs` environment (specific to build the documentation) and install the necessary dependencies.

Then, to build the documentation you can use the following command in the REPL:

```julia
include("make.jl")
```

### From the command line

To build the documentation from the `docs/` directory, use the following commands to instatiate and precompile the documentation environment:

```sh
julia --project=. -e 'using Pkg; Pkg.instantiate()'
```

```sh
julia --project=. -e 'using Pkg; Pkg.precompile()'
```

Then build the documentation with the command

```sh
julia --project=. make.jl
```

### Preview the documentation

Once you have built the documentation (either from the REPL or the command line), you can inspect the documentation in `docs/build` with the `index.html` file as the homepage.

## Functions

### Operators

```@docs
MOLE.Operators.div(k::Int, m::Int, dx; dc::NTuple{2,T}, nc::NTuple{2,T})
MOLE.Operators.div(k::Int, ticks::AbstractVector)
MOLE.Operators.div(k::Int, m::Int, dx, n::Int, dy; dc::NTuple{4,T}, nc::NTuple{4,T})
MOLE.Operators.div(k::Int, xticks::AbstractVector, yticks::AbstractVector)
MOLE.Operators.grad(k::Int, m::Int, dx; dc::NTuple{2,T}, nc::NTuple{2,T})
MOLE.Operators.grad(k::Int, ticks::AbstractVector)
MOLE.Operators.grad(k::Int, m::Int, dx, n::Int, dy; dc::NTuple{4,T}, nc::NTuple{4,T})
MOLE.Operators.grad(k::Int, xticks::AbstractVector, yticks::AbstractVector)
MOLE.Operators.lap(k::Int, m::Int, dx; dc::NTuple{2,T}, nc::NTuple{2,T})
MOLE.Operators.lap(k::Int, m::Int, dx, n::Int, dy; dc::NTuple{4,T}, nc::NTuple{4,T})
```

### Utilities

```@docs
MOLE.BCs.robinBC(k::Int, m::Int, dx, a, b)
MOLE.BCs.robinBC(k::Int, m::Int, dx, n::Int, dy, a, b)
MOLE.BCs.ScalarBC1D(dc::NTuple{2,T}, nc::NTuple{2,T}, v::NTuple{2,T})
MOLE.BCs.ScalarBC2D(dc::NTuple{4,T}, nc::NTuple{4,T}, v::NTuple{4,AbstractVector{T}})
MOLE.BCs.addScalarBC!(A::SparseMatrixCSC, b::AbstractVector, bc::ScalarBC1D{T}, k::Integer, m::Integer, dx)
MOLE.BCs.addScalarBC!(A::SparseMatrixCSC, b::AbstractVector, bc::ScalarBC2D{T}, k::Integer, m::Integer, dx, n::Integer, dy)
```

## Examples

The MOLE library contains examples demonstrating how to use the operators, in a broad range of partial differential equations (PDEs). More information on the mathematical content can be found in the [main MOLE documentation](https://mole-docs.readthedocs.io/en/main/examples/index.html).

Currently, the following examples are available in the MOLE Julia package.

- Elliptic Problems
  - 1D Examples
    - ```elliptic1D```: A script that solves the 1D Poisson's equation with Robin boundary conditions using mimetic operators.
  - 2D Examples
    - ```elliptic2DXDirichletYDirichlet```: A script that solves the 2D Laplace equation, $\nabla^2 u = 0$, with Dirichlet boundary conditions in $x$ and $y$ using mimetic operators.
    - ```elliptic2DXPerYDirichlet```: A script that solves the 2D Laplace equation, $\nabla^2 u = 0$, with periodic bonudary conditions in $x$ and Dirichlet boundary conditions in $y$ using mimetic operators.
- Parabolic Problems
  - 2D Examples
    - ```parabolic2D```: A script that solves the 2D heat equation, $u_t = \nu \nabla^2 u$, with Dirichlet boundary conditions in $x$ and $y$ using mimetic operators.

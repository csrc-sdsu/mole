# MOLE: Mimetic Operators Library Enhanced

MOLE is a library that implements high-order mimetic operators to solve partial differential equations.
This site provides documentation for the Julia implementation of MOLE.
More information can be found on the [main documentation site](https://mole-docs.readthedocs.io/en/main/) and the [GitHub repository](https://github.com/csrc-sdsu/mole).

## Getting Started

MOLE.jl is not yet available in the Julia's package manager. For now, this repository needs to be cloned locally in order to use the library.

## Using MOLE.jl

In order to use the MOLE.jl library, first navigate to the location where the repository has been cloned to. Then, go to the ```mole/julia/MOLE.jl``` sub-directory. From here, you can access the library via the REPL or the command line.

### From the REPL

In ```mole/julia/MOLE.jl```, start Julia using the command ```julia --project=.```. Next, the package library needs to be instantiated and pre-compiled. Enter the ```pkg``` mode by pressing ```]```, then type the commands ```instantiate``` and ```precompile``` (one at a time). This should activate the MOLE.jl package and install the necessary dependencies.

Then, to run a script such as myScript.jl, you can use the following command in the REPL:
> ```include("path/to/myScript.jl")```

### From the command line

In ```mole/julia/MOLE.jl```, use the following commands to instatiate and precompile the MOLE package:

> ```julia --project=. -e 'using Pkg; Pkg.instantiate()'```

> ```julia --project=. -e 'using Pkg; Pkg.precompile()'```

Then, to run a script such as myScript.jl, use the command

> ```julia --project=. path/to/myScript.jl```

## Functions

### Operators

```@docs
MOLE.div(k::Int,m::Int,dx)
MOLE.grad(k::Int,m::Int,dx)
MOLE.lap(k::Int,m::Int,dx)
```

### Utilities

```@docs
MOLE.robinBC(k::Int, m::Int, dx, a, b)
```

## Examples

The MOLE library contains examples demonstrating how to use the operators, in a broad range of partial differential equations (PDEs). More information on the mathematical content can be found in the [main MOLE documentation](https://mole-docs.readthedocs.io/en/main/examples/index.html).

Currently, the following examples are available in the MOLE Julia package.

- Elliptic Problems
    - 1D Examples
        - ```elliptic1D```: A script that solves the 1D Poisson's equation with Robin boundary conditions using mimetic operators.
# MOLE.jl: Julia interface for [MOLE](https://github.com/csrc-sdsu/mole)

## Description

This is an implementation written in Julia for the MOLE package. The source files for the operators are located at ```src/``` and examples can be found in ```examples/```. This is a WIP implementation; currently (as of Jan 13, 2026), only the 1D operators are available.

## Installation

MOLE.jl is not yet available in the Julia's package manager. For now, this repository needs to be cloned locally in order to use the library in Julia.

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

## Examples

The MOLE library contains examples demonstrating how to use the operators, in a broad range of partial differential equations (PDEs). More information on the mathematical content can be found in the [main MOLE documentation](https://mole-docs.readthedocs.io/en/main/examples/index.html).

Currently, the following examples are available in the MOLE Julia package.

- Elliptic Problems
    - 1D Examples
        - `elliptic1D`: A script that solves the 1D Poisson's equation with Robin boundary conditions using mimetic operators.
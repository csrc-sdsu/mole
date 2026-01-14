# MOLE.jl: Julia interface for [MOLE](https://github.com/csrc-sdsu/mole)

## Description

This is an implementation written in Julia for the MOLE package. The source files for the operators are located at ```src/``` and examples can be found in ```examples/```. This is a WIP implementation; currently (as of Jan 13, 2026), only the 1D operators are available.

## Installation

MOLE.jl is not yet available in the Julia's package manager. For now, this repository needs to be cloned locally in order to use the library in Julia.

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
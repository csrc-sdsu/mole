# MOLE.jl: Julia interface for [MOLE](https://github.com/csrc-sdsu/mole)

## Description

This is an implementation written in Julia for the MOLE package. The source files for the operators are located at ```src/``` and examples can be found in ```examples/```. This is a WIP implementation; currently (as of Dec 7, 2025), only the 1D operators are available.

## Installation

MOLE.jl is not yet available in the Julia's package manager. For now, this repository needs to be cloned locally in order to use the library.

## Using MOLE.jl in the Julia REPL

To use MOLE.jl in a Julia REPL, navigate to the location where MOLE has been cloned to, then navigate to ```mole/julia/MOLE.jl```. Once here, start the Julia REPL using ```julia --project=.```. This should activate the MOLE package in the REPL, as well as the Plots and LinearAlegbra dependencies.

To run a script, e.g. myScript.jl, you can use the following command in the REPL:
> ```include("path/to/myScript.jl")```

## Using MOLE.jl at the command line

To run a Julia script at the command line using MOLE.jl, To use MOLE.jl in a Julia REPL, navigate to the location where MOLE has been cloned to, then navigate to ```mole/julia/MOLE.jl```. Once here use the following command (here, we will run "elliptic1D" from the examples directory):
> ```julia --project=. examples/elliptic1D.jl```
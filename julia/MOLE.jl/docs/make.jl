push!(LOAD_PATH,"../src/")
using Documenter, MOLE, SparseArrays

makedocs(
    sitename="MOLE.jl Docs",
    pages = [
        "Home" => "index.md"
    ]
)
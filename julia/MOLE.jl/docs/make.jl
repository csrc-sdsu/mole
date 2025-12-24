push!(LOAD_PATH,"../src/")
using Documenter, MOLE

makedocs(
    sitename="MOLE.jl Docs",
    pages = [
        "Home" => "index.md"
    ]
)
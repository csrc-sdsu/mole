push!(LOAD_PATH,"../src/")
using Documenter, MOLE, SparseArrays

makedocs(
    sitename = "MOLE.jl Docs",
    pages = [
        "Home" => "index.md",
        "Examples" => [
            "Overview" => "examples/index.md",
            "Elliptic Problems" => [
                "Overview" => "examples/Elliptic/index.md",
                "1D Elliptic Problems" => [
                    "Overview" => "examples/Elliptic/1D/index.md",
                    "Elliptic 1D" => "examples/Elliptic/1D/Elliptic1D.md",
                    "Elliptic 1D Add Scalar Boundary Conditions" =>
                        "examples/Elliptic/1D/Elliptic1D-add-Scalar-BC.md",
                ],
                "2D Elliptic Problems" => [
                    "Overview" => "examples/Elliptic/2D/index.md",
                    "X Dirichlet Y Dirichlet" =>
                        "examples/Elliptic/2D/Elliptic2D-X-Dirichlet-Y-Dirichlet.md",
                    "X Periodic Y Dirichlet" =>
                        "examples/Elliptic/2D/Elliptic2D-X-Periodic-Y-Dirichlet.md",
                ],
            ],
            "Hyperbolic Problems" => [
                "Overview" => "examples/Hyperbolic/index.md",
                "1D Hyperbolic Problems" => [
                    "Overview" => "examples/Hyperbolic/1D/index.md",
                    "Hyperbolic 1D" => "examples/Hyperbolic/1D/Hyperbolic1D.md",
                    "Burgers 1D" => "examples/Hyperbolic/1D/Burgers1D.md",
                ],
            ],
            "Parabolic Problems" => [
                "Overview" => "examples/Parabolic/index.md",
                "2D Parabolic Problems" => [
                    "Overview" => "examples/Parabolic/2D/index.md",
                    "Parabolic 2D" => "examples/Parabolic/2D/Parabolic2D.md",
                ],
            ],
        ],
    ],
)
#=
    SPDX-License-Identifier: GPL-3.0-or-later
    © 2008-2024 San Diego State University Research Foundation (SDSURF).
    See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
=#

# -----------------------
# 1-D Laplacian Operators
# -----------------------

"""
    lap(k, m, dx; dc, nc)

Returns a m+2 by m+2 one-dimensional mimetic laplacian operator. Default is non periodic.

# Arguments
- `k::Int`: Order of accuracy
- `m::Int`: Number of cells
- `dx::T`: Step size
- `dc::NTuple{2,T}`: Dirichlet coefficients of the left and right boundaries (optional)
- `nc::NTuple{2,T}`: Neumann coefficients of the left and right boundaries (optional)
"""
function lap(k::Int, m::Int, dx::T; dc::NTuple{2,T} = (1.0, 1.0), nc::NTuple{2,T} = (1.0, 1.0)) where {T}
    D = div(k, m, dx, dc=dc, nc=nc)
    G = grad(k, m, dx, dc=dc, nc=nc)

    L = D*G;
end


# -----------------------
# 2-D Laplacian Operators
# -----------------------

"""
    lap(k, m, dx, n, dy; dc, nc)

Returns a two-dimensional mimetic laplacian operator. Default is non periodic.

# Arguments
- `k::Int`: Order of accuracy
- `m::Int`: Number of cells in x-direction
- `dx::T`: Step size in x-direction
- `n::Int`: Number of cells in y-direction
- `dy::T`: Step size in y-direction
- `dc::NTuple{4,T}`: Dirichlet coefficients of the left and right boundaries (optional)
- `nc::NTuple{4,T}`: Neumann coefficients of the left and right boundaries (optional)
"""
function lap(k::Int, m::Int, dx::T, n::Int, dy::T; dc::NTuple{4,T} = (1.0, 1.0, 1.0, 1.0), nc::NTuple{4,T} = (1.0, 1.0, 1.0, 1.0)) where {T}

    D = div(k, m, dx, n, dy, dc=dc, nc=nc)
    G = grad(k, m, dx, n, dy, dc=dc, nc=nc)

    L = D*G

end
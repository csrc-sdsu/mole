#=
    SPDX-License-Identifier: GPL-3.0-or-later
    © 2008-2024 San Diego State University Research Foundation (SDSURF).
    See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
=#

# -----------------------
# 1-D Laplacian Operators
# -----------------------

"""
    lap(k, m, dx)

Returns a m+2 by m+2 one-dimensional mimetic laplacian operator.

# Arguments
- `k::Int`: Order of accuracy
- `m::Int`: Number of cells
- `dx`: Step size
"""
function lap(k::Int, m::Int, dx)
    D = div(k,m,dx)
    G = grad(k,m,dx)

    L = D*G;
end


"""
    lapPeriodic(k, m, dx)

Returns a m by m one-dimensional periodic mimetic laplacian operator.

# Arguments
- `k::Int`: Order of accuracy
- `m::Int`: Number of cells
- `dx`: Step size
"""
function lapPeriodic(k::Int, m::Int, dx)
    
    D = divPeriodic(k, m, dx)
    G = gradPeriodic(k, m, dx)

    L = D*G;
end

# -----------------------
# 2-D Laplacian Operators
# -----------------------

"""
    lap2D(k, m, dx, n, dy)

Returns a two-dimensional mimetic laplacian operator.

# Arguments
- `k::Int`: Order of accuracy
- `m::Int`: Number of cells in x-direction
- `dx`: Step size in x-direction
- `n::Int`: Number of cells in y-direction
- `dy`: Step size in y-direction
"""
function lap2D(k::Int, m::Int, dx, n::Int, dy)

    D = div2D(k, m, dx, n, dy)
    G = grad2D(k, m, dx, n, dy)

    L = D*G

end


"""
    lap2DPeriodic(k, m, dx, n, dy)

Returns a two-dimensional periodic mimetic laplacian operator.

# Arguments
- `k::Int`: Order of accuracy
- `m::Int`: Number of cells in x-direction
- `dx`: Step size in x-direction
- `n::Int`: Number of cells in y-direction
- `dy`: Step size in y-direction
"""
function lap2DPeriodic(k::Int, m::Int, dx, n::Int, dy)

    D = div2DPeriodic(k, m, dx, n, dy)
    G = grad2DPeriodic(k, m, dx, n, dy)

    L = D*G;

end
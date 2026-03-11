#=
    SPDX-License-Identifier: GPL-3.0-or-later
    © 2008-2024 San Diego State University Research Foundation (SDSURF).
    See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
=#

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
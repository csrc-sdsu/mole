#=
    SPDX-License-Identifier: GPL-3.0-or-later
    © 2008-2024 San Diego State University Research Foundation (SDSURF).
    See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
=#

# ------------------
# 2-D Curl Operators
# ------------------

"""
    curl(k, m, dx, n, dy, west, east, south, north, U, V)

Returns a two-dimension mimetic curl operator

# Arguments
- `k::Int`: Order of accuracy
- `m::Int`: Number of cells in x-direction
- `dx`: Step size in x-direction
- `n::Int`: Number of cells in y-direction
- `dy`: Step size in y-direction
- `west`: x-coordinate of left boundary
- `east`: x-coordinate of right boundary
- `south`: y-coordinate of bottom boundary
- `north`: y-coordinate of top boundary
- `U::Function`: Vector space function acting on x-direction
- `V::Function`: Vector space function acting on y-direction
"""
function curl(k::Int, m::Int, dx, n::Int, dy, west, east, south, north, U::Function, V::Function)

    F = sparse(2 * m * n + m + n, 1)
    xaxis = [west : (dx / 2) : east]
    yaxis = [south : (dy / 2) : north]

    f = 1
    for j = 2 : 2 : 2 * n + 1
        for i = 1 : 2 : 2 * m + 1
            F[f] = V(xaxis[i], yaxis[j])
            f += 1
        end
    end

    for j = 1 : 2 : 2 * n + 1
        for i = 2 : 2 : 2 * m + 1
            F[f] = -U(xaxis[i], yaxis[j])
            f += 1
        end
    end

    C = div(k, m, dx, n, dy) * F
    C = reshape(C, m + 2, n + 2)
    C = C[2:end-1, 2:end-1];

end
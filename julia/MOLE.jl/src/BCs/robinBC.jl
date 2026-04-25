#=
    SPDX-License-Identifier: GPL-3.0-or-later
    © 2008-2024 San Diego State University Research Foundation (SDSURF).
    See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
=#

import ..Operators: Operators, grad

"""
    robinBC(k, m, dx, a, b)

Returns a m+2 by m+2 one-dimensional mimetic boundary operator that imposes a boundary condition of Robin's type.

# Arguments
- `k::Int`: Order of accuracy
- `m::Int`: Number of cells
- `dx`: Step size
- `a`: Dirichlet Coefficient
- `b`: Neumann Coefficient
"""
function robinBC(k::Int, m::Int, dx, a, b)
    A = zeros(m+2,m+2)
    A[1,1] = a
    A[m+2,m+2] = a

    B = zeros(m+2,m+1)
    B[1,1] = -b
    B[m+2,m+1] = b

    G = Operators.grad(k,m,dx)

    BC = A + B*G;
end

"""
    robinBC2D(k, m, dx, n, dy, a, b)

Returns a two-dimensional mimetic boundary condition operator that imposes a boundary condition of Robin's type

# Arguments
- `k::Int`: Order of accuracy
- `m::Int`: Number of cells in x-direction
- `dx`: Step size in x-direction
- `n::Int`: Number of cells in y-direction
- `dy`: Step size in y-direction
- `a`: Dirichlet Coefficient
- `b`: Neumann Coefficient
"""
function robinBC2D(k::Int, m::Int, dx, n::Int, dy, a, b)

    Bm = robinBC(k, m, dx, a, b)
    Bn = robinBC(k, n, dy, a, b)

    Im = Matrix(I, m + 2, m + 2)

    In = Matrix(I, n + 2, n + 2)
    In[1, 1] = 0
    In[end, end] = 0

    BC1 = kron(In, Bm)
    BC2 = kron(Bn, Im)

    BC = BC1 + BC2

end

"""
    robinBC(k, m, dx, n, dy, a, b)

Alias of robinBC2D
"""
function robinBC(k::Int, m::Int, dx, n::Int, dy, a, b)
    return robinBC2D(k, m, dx, n, dy, a, b);
end
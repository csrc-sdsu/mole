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

    G = grad(k,m,dx)

    BC = A + B*G;
end
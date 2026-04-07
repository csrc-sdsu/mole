#=
    SPDX-License-Identifier: GPL-3.0-or-later
    © 2008-2024 San Diego State University Research Foundation (SDSURF).
    See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
=#

import ..Operators: Operators, grad

"""
    Abstract supertype for scalar boundary-condition applicators.

    `D` is the spatial dimension (1,2,3,...).
"""
abstract type AbstractScalarBC{D} end


"""
    Concrete scalar BC description for 1D.

    Fields mirror the MATLAB function:
    - dc: Dirichlet coefficients (left,right)
    - nc: Neumann/Robin coefficients (left,right)
    - v:  prescribed boundary value g (left,right)
"""
struct ScalarBC1D{T} <: AbstractScalarBC{1}
    dc::NTuple{2,T}
    nc::NTuple{2,T}
    v::NTuple{2,T}
end


"""
    Concrete scalar BC description for 2D.

    Fields mirror the MATLAB function:
    - dc: Dirichlet coefficients (left, right, bottom, top)
    - dc: Neumann/Robin coefficients (left, right, bottom, top)
    - dc: prescribed boundary value g (left, right, bottom, top)
"""
struct ScalarBC2D{T} <: AbstractScalarBC{2}
    dc::NTuple{4,T}
    nc::NTuple{4,T}
    v::NTuple{4,T}
end


# -------------------------
# 1D implementation
# -------------------------

"""
    Internal helper: build LHS contributions for 1D BC.
    Returns (Al, Ar).
"""
function _scalarbc1d_lhs(k::Integer, m::Integer, dx, dc::NTuple{2,T}, nc::NTuple{2,T}) where {T}
    n = m + 2

    Al = spzeros(T, n, n)
    Ar = spzeros(T, n, n)

    if dc[1] != zero(T); Al[1, 1] = dc[1]; end
    if dc[2] != zero(T); Ar[end, end] = dc[2]; end

    Bl = spzeros(T, n, m + 1)
    Br = spzeros(T, n, m + 1)

    Gl = grad(k, m, dx)
    Gr = grad(k, m, dx)

    if nc[1] != zero(T); Bl[1, 1] = -nc[1]; end
    if nc[2] != zero(T); Br[end, end] =  nc[2]; end

    return Al + Bl * Gl, Ar + Br * Gr
end

"""
    Internal helper: overwrite RHS at boundary indices.
"""
@inline function _scalarbc_rhs!(b, vec::NTuple{2,Int}, v::NTuple{2,T}) where {T}
    b[vec[1]] = v[1]
    b[vec[2]] = v[2]
    return b
end

"""
    1D BC applicator. Mirrors MATLAB addScalarBC1D.
    Signature keeps the discretization params (`k,m,dx`) separate from `bc`.
"""
function addScalarBC!(A::SparseMatrixCSC, b::AbstractVector, bc::ScalarBC1D{T},
                      k::Integer, m::Integer, dx) where {T}

    dc, nc, v = bc.dc, bc.nc, bc.v

    # Equivalent of MATLAB: q = find(dc.^2 + nc.^2, 1)
    hasbc = (dc[1] != zero(T)) || (dc[2] != zero(T)) || (nc[1] != zero(T)) || (nc[2] != zero(T))
    if !hasbc
        return A, b
    end

    vec = (1, size(A, 1))

    # Zero-out first and last rows of A (sparse-friendly approach)
    # We remove the existing nonzeros in those rows.
    sub = A[[vec[1], vec[2]], :]
    rows, cols, vals = findnz(sub)  # rows are 1..2 in the submatrix
    A .-= sparse((rows .== 1) .* vec[1] .+ (rows .== 2) .* vec[2], cols, vals, size(A,1), size(A,2))

    # Zero out boundary entries of b
    b[vec[1]] = zero(eltype(b))
    b[vec[2]] = zero(eltype(b))

    # Add BC LHS
    Al, Ar = _scalarbc1d_lhs(k, m, dx, dc, nc)
    A .+= (Al .+ Ar)

    # Set BC RHS
    _scalarbc_rhs!(b, vec, v)

    return A, b
end


# -------------------------
# 2D implementation
# -------------------------

"""
    Internal helper: build LHS contributions for 2D BC.
    Returns (Al, Ar, Ab, At).
"""
function _scalarbc2D_lhs(k::Integer, m::Integer, dx, n::Integer, dy, dc::NTuple{4,T}, nc::NTuple{4,T}) where {T}

    Abcl, Abcr, Abcb, Abct = 0, 0, 0, 0 # periodic case

    hasbclr = (dc[1] != zero(T)) || (dc[2] != zero(T)) || (nc[1] != zero(T)) || (nc[2] != zero(T))
    hasbcbt = (dc[3] != zero(T)) || (dc[4] != zero(T)) || (nc[3] != zero(T)) || (nc[4] != zero(T))

    if hasbclr

        Abcl0, Abcr0 = _scalarbc1d_lhs(k, m, dx, dc[1:2], nc[1:2])

        if !hasbcbt
            In = Matrix(I, n, n)
        else
            In = Matrix(I, n + 2, n + 2)
            In[1, 1] = 0
            In[end, end] = 0
        end

        # Left and right edges
        Abcl = kron(In, Abcl0)
        Abcr = kron(In, Abcr0)

    end

    if hasbcbt

        Abcb0, Abct0 = _scalarbc1d_lhs(k, n, dy, dc[3:4], nc[3:4])

        if !hasbclr
            Im = Matrix(m, m)
        else
            Im = Matrix(I, m + 2, m + 2)
        end

        Abcb = kron(Abcb0, Im)
        Abct = kron(Abct0, Im)

    end

    return Abcl, Abcr, Abcb, Abct

end

"""
    Internal helper: overwrite RHS at boundary indices
"""
@inline function _scalarbc2d_rhs(b, dc::NTuple{4,T}, nc::NTuple{4,T}, v::NTuple{4,NTuple{??,T}}, rl::NTuple{??,Int}, rr::NTuple{??,Int}, rb::NTuple{??,Int}, rt::NTuple{??,Int}) where {T}

    hasbclr = (dc[1] != zero(T)) || (dc[2] != zero(T)) || (nc[1] != zero(T)) || (nc[2] != zero(T))
    hasbcbt = (dc[3] != zero(T)) || (dc[4] != zero(T)) || (nc[3] != zero(T)) || (nc[4] != zero(T))

    if hasbclr
        b[rl] = v[1]
        b[rr] = v[2]
    end

    if hasbcbt
        b[rb] = v[3]
        b[rt] = v[4]
    end

    return b
end

"""
"""
function addScalarBC!(A::SparseMatrixCSC, b::AbstractVector, bc::ScalarBC2D{T},
                      k::Integer, m::Integer, dx, n::Integer, dy) where {T}

    dc, nc, v = bc.dc, bc.nc, bc.v

    hasbclr = (dc[1] != zero(T)) || (dc[2] != zero(T)) || (nc[1] != zero(T)) || (nc[2] != zero(T))
    hasbcbt = (dc[3] != zero(T)) || (dc[4] != zero(T)) || (nc[3] != zero(T)) || (nc[4] != zero(T))

    rl, rr, rb, rt = 0, 0, 0, 0 # periodic case

    Abcl, Abcr, Abcb, Abct = _scalarbc2D_lhs(k, m, dx, n, dy, dc, nc)

    if hasbclr

        rl = 
        rr = 

        # remove rows of A associated to boundary
        Abc1 = Abcl .+ Abcr
        rowsbc1 = 
        rows1 = 
        cols1 = 
        s1 = 
        A = A .- sparse(rows1, cols1, s1, size(A, 1), size(A, 2))
        # Upd

    end


    if hasbcbt



    end


    if hasbclr || hasbcbt
        b = _scalarbc2d_rhs(b, dc, nc, v, rl, rr, rb, rt)
    end

    return A, b
end


# -------------------------
# Construction helpers
# -------------------------

"""
    Convenience constructor from vectors/tuples.
    Accepts 2-element vectors too.
"""
ScalarBC1D(dc, nc, v) = ScalarBC1D(tuple(dc...), tuple(nc...), tuple(v...))

ScalarBC2D(dc, nc, v) = ScalarBC2D(tuple(dc...), tuple(nc...), tuple(v...))
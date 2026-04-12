#=
    SPDX-License-Identifier: GPL-3.0-or-later
    © 2008-2024 San Diego State University Research Foundation (SDSURF).
    See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
=#

# ------------------------
# 1-D Divergence Operators
# ------------------------

"""
    div(k, m, dx; dc, nc)

Returns a one-dimensional mimetic divergence operator. Default is non periodic.

# Arguments
- `k::Int`: Order of accuracy
- `m::Int`: Number of cells
- `dx::T`: Step size
- `dc::NTuple{2,T}`: Dirichlet coefficients of left and right boundaries (optional)
- `nc::NTuple{2,T}`: Neumann coefficients of left and right boundaries (optional)
"""
function div(k::Int, m::Int, dx::T; dc::NTuple{2,T}= (1.0, 1.0), nc::NTuple{2,T} = (1.0, 1.0)) where {T}

    hasbc = (dc[1] != zero(T)) || (dc[2] != zero(T)) || (nc[1] != zero(T)) || (nc[2] != zero(T))
    if hasbc
        D = divNonPeriodic(k, m, dx)
        return D
    else
        D = divPeriodic(k, m, dx)
        return D
    end

end

"""
    div(k, ticks)

Returns a m + 2 by m + 1 non-uniform mimetic divergence operator

# Arguments
- `k::Int`: Order of accuracy
- `ticks::AbstractArray`: Edges' ticks e.g. [0 0.1 0.15 0.2 0.3 0.4 0.45]
"""
function div(k::Int, ticks::AbstractArray)
    return divNonUniform(k, ticks)
end

"""
    divNonPeriodic(k, m, dx)

Returns a m+2 by m+1 one-dimensional mimetic divergence operator.

# Arguments
- `k::Int`: Order of accuracy
- `m::Int`: Number of cells
- `dx`: Step size
"""
function divNonPeriodic(k::Int,m::Int,dx)
    if k < 2 || k > 8
        throw(DomainError(k, "k must be >= 2 and <= 8"))
    end

    if k % 2 != 0
        throw(DomainError(k, "k must be an positive even integer"))
    end

    if m < 2*k + 1
        throw(DomainError(m, "m must be >= 2*k + 1"))
    end

    D = zeros(m+2,m+1)
    if k == 2 
        for i = 2:(m+1)
            D[i,(i-1):i] = [-1 1]
        end
    elseif k == 4
        A = [-11/12 17/24 3/8 -5/24 1/24]
        D[2,1:5] = A
        D[m+1, (m-3):(m+1)] = -reverse(A)
        for i = 3:m
            D[i,(i-2):(i+1)] = [1/24 -9/8 9/8 -1/24]
        end
    elseif k == 6
        A = [-1627/1920  211/640  59/48  -235/192 91/128 -443/1920 31/960;
                31/960  -687/640 129/128   19/192 -3/32    21/640  -3/640]
        D[2:3,1:7] = A
        D[m:(m+1), (m-5):(m+1)] = -rot180(A)
        for i = 4:(m-1)
            D[i,(i-3):(i+2)] = [-3/640 25/384 -75/64 75/64 -25/384 3/640]
        end
    elseif k == 8
        A = [-1423/1792     -491/7168   7753/3072 -18509/5120  3535/1024 -2279/1024  953/1024 -1637/7168  2689/107520;
              2689/107520 -36527/35840  4259/5120   6497/15360 -475/1024  1541/5120 -639/5120  1087/35840  -59/17920;
               -59/17920    1175/21504 -1165/1024   1135/1024    25/3072  -251/5120   25/1024   -45/7168     5/7168]
            D[2:4, 1:9] = A;
        D[2:4,1:9] = A
        D[(m-1):(m+1), (m-7):(m+1)] = -rot180(A)
        for i = 5:(m-2)
            D[i,(i-4):(i+3)] = [5/7168 -49/5120 245/3072 -1225/1024 1225/1024 -245/3072 49/5120 -5/7168]
        end
    end
    D = (1/dx)*D;
end


"""
    divPeriodic(k, m, dx)

Returns a m by m periodic mimetic divergence operator.

# Arguments
- `k::Int`: Order of accuracy
- `m::Int`: Number of cells
- `dx`: Step size
"""
function divPeriodic(k::Int, m::Int, dx)

    D = - gradPeriodic(k, m, dx)';
    
end


"""
    divNonUniform(k, ticks)

Returns a m + 2 by m + 1 non-uniform mimetic divergence operator

# Arguments
- `k::Int`: Order of accuracy
- `ticks::AbstractArray`: Edges' ticks e.g. [0 0.1 0.15 0.2 0.3 0.4 0.45]
"""
function divNonUniform(k::Int, ticks::AbstractArray)

    D = div(k, length(ticks) - 1, 1)

    m, _ = size(D)

    if size(ticks, 1) == 1
        J = diags((D * ticks').^-1, 0, m, m)
    else
        J = diags((D * ticks).^-1, 0, m, m)
    end

    D = J * D

end

# ------------------------
# 2-D Divergence Operators
# ------------------------

"""
    div(k, m, dx, n, dy; dc, nc)

Returns a two-dimensional mimetic divergence operator. Default is non periodic.

# Arguments
- `k::Int`: Order of accuracy
- `m::Int`: Number of cells in x-direction
- `dx::T`: Step size in x-direction
- `n::Int`: Number of cells in y-direction
- `dy::T`: Step size in y-direction
- `dc::NTuple{4,T}`: Dirichlet coefficients of left, right, bottom, and top boundaries (optional)
- `nc::NTuple{4,T}`: Neumann coefficients of left, right, bottom, and top boundaries (optional)
"""
function div(k::Int, m::Int, dx::T, n::Int, dy::T; dc::NTuple{4,T} = (1.0, 1.0, 1.0, 1.0), nc::NTuple{4,T} = (1.0, 1.0, 1.0, 1.0)) where {T}

    hasbclr = (dc[1] != zero(T)) || (dc[2] != zero(T)) || (nc[1] != zero(T)) || (nc[2] != zero(T))
    hasbcbt = (dc[3] != zero(T)) || (dc[4] != zero(T)) || (nc[3] != zero(T)) || (nc[4] != zero(T))

    if hasbclr
        Dx = divNonPeriodic(k, m, dx)
        Im = Matrix(I, m + 2, m + 2)
        Im = Im[:, 2:end-1]
    else
        Dx = divPeriodic(k, m, dx)
        Im = Matrix(I, m, m)
    end

    if hasbcbt
        Dy = divNonPeriodic(k, n, dy)
        In = Matrix(I, n + 2, n + 2)
        In = In[:, 2:end-1]
    else
        Dy = divPeriodic(k, n, dy)
        In = Matrix(I, n, n)
    end

    Sx = kron(In, Dx)
    Sy = kron(Dy, Im)

    D = [Sx Sy];

end

"""
    div(k, xticks, yticks)

Returns a two-dimensional non-uniform mimetic divergence operator.

# Arguments
- `k::Int`: Order of accuracy
- `xticks::AbstractArray`: Edges' ticks (x-axis)
- `yticks::AbstractArray`: Edges' ticks (y-axis)
"""
function div(k::Int, xticks::AbstractArray, yticks::AbstractArray)
    return div2DNonUniform(k, xticks, yticks)
end


"""
    div2DNonUniform(k, xticks, yticks)

Returns a two-dimensional non-uniform mimetic divergence operator.

# Arguments
- `k::Int`: Order of accuracy
- `xticks::AbstractArray`: Edges' ticks (x-axis)
- `yticks::AbstractArray`: Edges' ticks (y-axis)
"""
function div2DNonUniform(k::Int, xticks::AbstractArray, yticks::AbstractArray)

    Dx = divNonUniform(k, xticks)
    Dy = divNonUniform(k, yticks)

    m = size(Dx, 1) # Really m + 2, but makes for simpler augmented identity matrix constuction
    n = size(Dy, 1) # Really n + 2, but makes for simpler augmented identity matrix constuction

    Im = Matrix(I, m, m)
    In = Matrix(I, n, n)

    Im = Im[:, 2:end-1]
    In = In[:, 2:end-1]

    Sx = kron(In, Dx)
    Sy = kron(Dy, Im)

    D = [Sx Sy]

end
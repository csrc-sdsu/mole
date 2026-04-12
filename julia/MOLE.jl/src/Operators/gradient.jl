#=
    SPDX-License-Identifier: GPL-3.0-or-later
    © 2008-2024 San Diego State University Research Foundation (SDSURF).
    See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
=#

using LinearAlgebra

#-----------------------
# 1-D Gradient Operators
#-----------------------

"""
    grad(k, m, dx; dc, nc)

Returns a one-dimensional mimetic gradient operator. Default is non periodic.

# Arguments
- `k::Int`: Order of accuracy
- `m::Int`: Number of cells
- `dx::T`: Step size
- `dc::NTuple{2,T}`: Dirichlet coefficients of the left and right boundaries (optional)
- `nc::NTuple{2,T}`: Neumann coefficients of the left and right boundaries (optional)
"""
function grad(k::Int, m::Int, dx::T; dc::NTuple{2,T} = (1.0, 1.0), nc::NTuple{2,T} = (1.0, 1.0)) where {T}

    hasbc = (dc[1] != zero(T)) || (dc[2] != zero(T)) || (nc[1] != zero(T)) || (nc[2] != zero(T))
    if hasbc
        G = gradNonPeriodic(k, m, dx)
        return G
    else
        G = gradPeriodic(k, m, dx)
        return G
    end

end


"""
    grad(k, ticks)

Returns a m + 1 by m + 2 one-dimensional non-uniform mimetic gradient operator

# Arguments
- `k::Int`: Order of accuracy
- `ticks`: Centers' ticks e.g. [0 0.5 1 3 5 7 9 9.5 10] (including the boundaries!)
"""
function grad(k::Int, ticks::AbstractArray)
    return gradNonUniform(k, ticks)
end


"""
    grad(k, m, dx)

Returns a m+1 by m+2 one-dimensional mimetic gradient operator.

# Arguments
- `k::Int`: Order of accuracy
- `m::Int`: Number of cells
- `dx`: Step size
"""
function gradNonPeriodic(k::Int,m::Int,dx)
    if k < 2 || k > 8
        throw(DomainError(k, "k must be >= 2 and <= 8"))
    end

    if k % 2 != 0
        throw(DomainError(k, "k must be an positive even integer"))
    end

    if m < 2*k
        throw(DomainError(m, "m must be >= 2*k"))
    end

    G = zeros(m+1,m+2)
    if k == 2
        A = [-8/3 3 -1/3]
        G[1,1:3] = A #[-8/3 3 -1/3]
        G[m+1,m:(m+2)] = -reverse(A) #[1/3, -3, 8/3]
        for i = 2:m
            G[i,i:(i+1)] = [-1 1]
        end
    elseif k == 4
        A = [-352/105  35/8  -35/24  21/40  -5/56; 
              16/105  -31/24  29/24  -3/40   1/168]
        G[1:2,1:5] = A
        G[m:(m+1), (m-2):(m+2)] = -rot180(A)
        for i = 3:(m-1)
            G[i,(i-1):(i+2)] = [1/24 -9/8 9/8 -1/24]
        end
    elseif k == 6
        A = [-13016/3465  693/128  -385/128  693/320  -495/448  385/1152  -63/1408;
                496/3465 -811/640   449/384  -29/960   -11/448   13/1152  -37/21120;
                 -8/385   179/1920 -153/128  381/320  -101/1344   1/128    -3/7040];
        G[1:3,1:7] = A
        G[(m-1):(m+1), (m-4):(m+2)] = -rot180(A)
        for i = 4:(m-2)
            G[i,(i-2):(i+3)] = [-3/640 25/384 -75/64 75/64 -25/384 3/640]
        end
    elseif k == 8
        A = [-182144/45045     6435/1024    -5005/1024  27027/5120  -32175/7168  25025/9216  -12285/11264  3465/13312   -143/5120;
               86048/675675 -131093/107520  49087/46080 10973/76800  -4597/21504  4019/27648 -10331/168960 2983/199680 -2621/1612800;
               -3776/225225    8707/107520 -17947/15360 29319/25600   -533/21504  -263/9216     903/56320  -283/66560    257/537600;
                  32/9009      -543/35840     265/3072  -1233/1024    8625/7168   -775/9216     639/56320  -15/13312       1/21504]
        G[1:4,1:9] = A
        G[(m-2):(m+1), (m-6):(m+2)] = -rot180(A)
        for i = 5:(m-3)
            G[i,(i-3):(i+4)] = [5/7168 -49/5120 245/3072 -1225/1024 1225/1024 -245/3072 49/5120 -5/7168]
        end
    end
    G = (1/dx)*G;
end


"""
    gradPeriodic(k, m, dx)

Returns a m by m periodic mimetic gradient operator

# Arguments
- `k::Int`: Order of accuracy
- `m::Int`: Number of cells in x-direction
- `dx`: Step size in x-direction
"""
function gradPeriodic(k::Int, m::Int, dx)
    
   if k < 2 || k > 8
        throw(DomainError(k, "k must be >= 2 and <= 8"))
    end

    if k % 2 != 0
        throw(DomainError(k, "k must be an positive even integer"))
    end

    if m < 2*k
        throw(DomainError(m, "m must be >= 2*k"))
    end
    
    V = zeros(1, m)
    idx = fill(-1, m, m)
    idx[:, 1] = 1:m
    idx = cumsum(idx, dims=2)
    idx = mod.(idx .+ m, m) .+ 1

    if k == 2

        V[1, 2:3] = [1, -1]

    elseif k == 4

        V[1, 1:4] = [-1/24, 9/8, -9/8, 1/24]

    elseif k == 6

        V[1, 1:5] = [-25/384, 75/64, -75/64, 25/384, -3/640]
        V[1, end] = 3/640

    elseif k == 8

        V[1, 1:6] = [-245/3072, 1225/1024, -1225/1024, 245/3072, -49/5120, 5/7168]
        V[1, end-1:end] = [-5/7168, 49/5120]

    end

    G = V[1, idx]
    G = G ./ dx;

end


"""
    gradNonUniform(k, ticks)

Returns a m + 1 by m + 2 one-dimensional non-uniform mimetic gradient operator

# Arguments
- `k::Int`: Order of accuracy
- `ticks::AbstractArray`: Centers' ticks e.g. [0 0.5 1 3 5 7 9 9.5 10] (including the boundaries!)
"""
function gradNonUniform(k::Int, ticks::AbstractArray)

    G = grad(k, length(ticks) - 2, 1)

    m, _ = size(G)

    if size(ticks, 1) == 1
        J = diags((G*ticks').^-1, 0, m, m)
    else
        J = diags((G*ticks).^-1, 0, m, m)
    end

    G = J * G

end

#-----------------------
# 2-D Gradient Operators
#-----------------------

"""
    grad(k, m, dx, n, dy; dc, nc)

Returns a two-dimensional mimetic gradient operator. Default is non periodic.

# Arguments
- `k::Int`: Order of accuracy
- `m::Int`: Number of cells in x-direction
- `dx::T`: Step size in x-direction
- `n::Int`: Number of cells in y-direction
- `dy::T`: Step size in y-direction
- `dc::NTuple{4,T}`: Dirichlet coefficients of the left, right, bottom, and top boundaries (optional)
- `nc::NTuple{4,T}`: Neumann coefficients of the left, right, bottom, and top boundaries (optional)
"""
function grad(k::Int, m::Int, dx::T, n::Int, dy::T; dc::NTuple{4,T} = (1.0, 1.0, 1.0, 1.0), nc::NTuple{4,T} = (1.0, 1.0, 1.0, 1.0)) where {T}

    hasbclr = (dc[1] != zero(T)) || (dc[2] != zero(T)) || (nc[1] != zero(T)) || (nc[2] != zero(T))
    hasbcbt = (dc[3] != zero(T)) || (dc[4] != zero(T)) || (nc[3] != zero(T)) || (nc[4] != zero(T))

    if hasbclr
        Gx = gradNonPeriodic(k, m, dx)
        Im = Matrix(I, m + 2, m + 2)
        Im = Im[2:end-1, :]
    else
        Gx = gradPeriodic(k, m, dx)
        Im = Matrix(I, m, m)
    end

    if hasbcbt
        Gy = gradNonPeriodic(k, n, dy)
        In = Matrix(I, n + 2, n + 2)
        In = In[2:end-1, :]
    else
        Gy = gradPeriodic(k, n, dy)
        In = Matrix(I, n, n)
    end

    Sx = kron(In, Gx)
    Sy = kron(Gy, Im)

    G = [Sx; Sy];

end


"""
    grad(k, xticks, yticks)

Returns a two-dimensional non-uniform mimetic gradient operator

# Arguments
- `k::Int`: Order of accuracy
- `xticks::AbstractArray`: Centers' ticks (x-axis) (includint the boundaries!)
- `yticks::AbstractArray`: Centers' ticks (y-axis) (includint the boundaries!)
"""
function grad(k::Int, xticks::AbstractArray, yticks::AbstractArray)
    return gradNonUniform(k, xticks, yticks)
end


"""
    gradNonPeriodic(k, m, dx, n, dy)

Returns a two-dimensional non periodic mimetic gradient operator.

# Arguments
- `k::Int`: Order of accuracy
- `m::Int`: Number of cells in x-direction
- `dx`: Step size in x-direction
- `n::Int`: Number of cells in y-direction
- `dy`: Step size in y-direction
"""
function gradNonPeriodic(k::Int, m::Int, dx, n::Int, dy)

    Gx = gradNonPeriodic(k, m, dx)
    Gy = gradNonPeriodic(k, n, dy)

    Im = Matrix(I, m + 2, m + 2)
    In = Matrix(I, n + 2, n + 2)

    Im = Im[2:end-1, :]
    In = In[2:end-1, :]

    Sx = kron(In, Gx)
    Sy = kron(Gy, Im)

    G = [Sx; Sy];
    
end


"""
    gradPeriodic(k, m, dx, n, dy)

Returns a two-dimensional periodic mimetic gradient operator.

# Arguments
- `k::Int`: Order of accuracy
- `m::Int`: Number of cells in x-direction
- `dx`: Step size in x-direction
- `n::Int`: Number of cells in y-direction
- `dy`: Step size in y-direction
"""
function gradPeriodic(k::Int, m::Int, dx, n::Int, dy)

    Gx = gradPeriodic(k, m, dx)
    Gy = gradPeriodic(k, n, dy)

    Im = Matrix(I, m, m)
    In = Matrix(I, n, n)

    Sx = kron(In, Gx)
    Sy = kron(Gy, Im)

    G = [Sx; Sy];

end


"""
    gradNonUniform(k, xticks, yticks)

Returns a two-dimensional non-uniform mimetic gradient operator

# Arguments
- `k::Int`: Order of accuracy
- `xticks::AbstractArray`: Centers' ticks (x-axis) (includint the boundaries!)
- `yticks::AbstractArray`: Centers' ticks (y-axis) (includint the boundaries!)
"""
function gradNonUniform(k::Int, xticks::AbstractArray, yticks::AbstractArray)

    Gx = gradNonUniform(k, xticks)
    Gy = gradNonUniform(k, yticks)

    m = size(Gx, 2)
    n = size(Gx, 2)

    Im = Matrix(I, m, m)
    In = Matrix(I, n, n)

    Im = Im[2:end-1, :]
    In = In[2:end-1, :]

    Sx = kron(In, Gx)
    Sx = kron(Gy, Im)

    G = [Sx; Sy]

end
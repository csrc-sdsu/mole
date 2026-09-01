#=
        SPDX-License-Identifier: GPL-3.0-or-later
        © 2008-2024 San Diego State University Research Foundation (SDSURF).
        See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
=#

using SparseArrays

"""
    interpol(m::Int, c::Real)

Construct the one-dimensional center-to-face interpolation operator.

Returns a sparse `(m+1) × (m+2)` matrix.
"""
function interpol(m::Int, c::Real)
    @assert m ≥ 4 "m must be at least 4."
    @assert 0 ≤ c ≤ 1 "Interpolation weight must satisfy 0 ≤ c ≤ 1."

    rows = Int[]
    cols = Int[]
    vals = Float64[]

    push!(rows, 1)
    push!(cols, 1)
    push!(vals, 1.0)

    for i in 2:m
        push!(rows, i)
        push!(cols, i)
        push!(vals, Float64(c))

        push!(rows, i)
        push!(cols, i + 1)
        push!(vals, Float64(1 - c))
    end

    push!(rows, m + 1)
    push!(cols, m + 2)
    push!(vals, 1.0)

    return sparse(rows, cols, vals, m + 1, m + 2)
end

"""
    interpol(::Val{:centers_to_faces}, k::Int, m::Int; c=0.5)

Construct the one-dimensional center-to-face interpolation operator.

This is equivalent to `interpol(m, c)` for `k == 2`.
"""
function interpol(::Val{:centers_to_faces}, k::Int, m::Int; c::Real = 0.5)
    @assert k == 2 "Only k == 2 is currently implemented."
    return interpol(m, c)
end

"""
    interpol(::Val{:faces_to_centers}, k::Int, m::Int; c=0.5)

Construct the one-dimensional face-to-center interpolation operator.

Returns a sparse `(m+2) × (m+1)` matrix.
"""
function interpol(::Val{:faces_to_centers}, k::Int, m::Int; c::Real = 0.5)
    @assert k == 2 "Only k == 2 is currently implemented."
    @assert m ≥ 4 "m must be at least 4."
    @assert 0 ≤ c ≤ 1 "Interpolation weight must satisfy 0 ≤ c ≤ 1."

    rows = Int[]
    cols = Int[]
    vals = Float64[]

    push!(rows, 1)
    push!(cols, 1)
    push!(vals, 1.0)

    for i in 2:(m + 1)
        push!(rows, i)
        push!(cols, i - 1)
        push!(vals, Float64(c))

        push!(rows, i)
        push!(cols, i)
        push!(vals, Float64(1 - c))
    end

    push!(rows, m + 2)
    push!(cols, m + 1)
    push!(vals, 1.0)

    return sparse(rows, cols, vals, m + 2, m + 1)
end

function _interior_embedding(q::Int)
    rows = collect(2:(q + 1))
    cols = collect(1:q)
    vals = ones(Float64, q)

    return sparse(rows, cols, vals, q + 2, q)
end

"""
    interpol(::Val{:centers_to_faces}, k::Int, m::Int, n::Int; c=0.5)

Construct the two-dimensional center-to-face interpolation operator.

Maps duplicated cell-centered data `[u; u]` to staggered face data

    [u_x_faces;
     u_y_faces]

with size `((m+1)n + m(n+1)) × 2(m+2)(n+2)`.
"""
function interpol(
    ::Val{:centers_to_faces},
    k::Int,
    m::Int,
    n::Int;
    c::Real = 0.5,
)
    @assert k == 2 "Only k == 2 is currently implemented."
    @assert m ≥ 4 "m must be at least 4."
    @assert n ≥ 4 "n must be at least 4."

    Ix = interpol(Val(:centers_to_faces), k, m; c = c)
    Iy = interpol(Val(:centers_to_faces), k, n; c = c)

    Im = _interior_embedding(m)
    In = _interior_embedding(n)

    Sx = kron(transpose(In), Ix)
    Sy = kron(Iy, transpose(Im))

    return blockdiag(Sx, Sy)
end

"""
    interpol(::Val{:faces_to_centers}, k::Int, m::Int, n::Int; c=0.5)

Construct the two-dimensional face-to-center interpolation operator.

Maps staggered face data

    [g_x_faces;
     g_y_faces]

to duplicated cell-centered data

    [g_x_centers;
     g_y_centers]

with size `2(m+2)(n+2) × ((m+1)n + m(n+1))`.
"""
function interpol(
    ::Val{:faces_to_centers},
    k::Int,
    m::Int,
    n::Int;
    c::Real = 0.5,
)
    @assert k == 2 "Only k == 2 is currently implemented."
    @assert m ≥ 4 "m must be at least 4."
    @assert n ≥ 4 "n must be at least 4."

    Ix = interpol(Val(:faces_to_centers), k, m; c = c)
    Iy = interpol(Val(:faces_to_centers), k, n; c = c)

    Im = _interior_embedding(m)
    In = _interior_embedding(n)

    Sx = kron(In, Ix)
    Sy = kron(Iy, Im)

    return blockdiag(Sx, Sy)
end

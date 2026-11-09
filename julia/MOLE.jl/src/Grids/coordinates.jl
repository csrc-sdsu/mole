#=
        SPDX-License-Identifier: GPL-3.0-or-later
        © 2008-2024 San Diego State University Research Foundation (SDSURF).
        See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
=#

function _coordinates_1d(m::Int, dx)
    x_node = collect(0:m) .* dx
    x_center = vcat(0.0, collect(0.5:1:(m - 0.5)) .* dx, m * dx)
    x_face = x_node

    nodes = (; X = x_node)
    faces = (; X = x_face)
    centers = (; X = x_center)

    return nodes, faces, centers
end

function _coordinates_2d(m::Int, n::Int, dx, dy)
    xn = collect(0:m) .* dx
    yn = collect(0:n) .* dy

    xc = vcat(0.0, collect(0.5:1:(m - 0.5)) .* dx, m * dx)
    yc = vcat(0.0, collect(0.5:1:(n - 0.5)) .* dy, n * dy)

    xu = xn
    yu = collect(0.5:1:(n - 0.5)) .* dy

    xv = collect(0.5:1:(m - 0.5)) .* dx
    yv = yn

    nodes = _ndgrid2_named(xn, yn)
    centers = _ndgrid2_named(xc, yc)

    faces = (
        u = _ndgrid2_named(xu, yu),
        v = _ndgrid2_named(xv, yv),
    )

    return nodes, faces, centers
end

function _coordinates_3d(m::Int, n::Int, o::Int, dx, dy, dz)
    xn = collect(0:m) .* dx
    yn = collect(0:n) .* dy
    zn = collect(0:o) .* dz

    xc = vcat(0.0, collect(0.5:1:(m - 0.5)) .* dx, m * dx)
    yc = vcat(0.0, collect(0.5:1:(n - 0.5)) .* dy, n * dy)
    zc = vcat(0.0, collect(0.5:1:(o - 0.5)) .* dz, o * dz)

    nodes = _ndgrid3_named(xn, yn, zn)
    centers = _ndgrid3_named(xc, yc, zc)

    faces = (
        u = _ndgrid3_named(
            xn,
            collect(0.5:1:(n - 0.5)) .* dy,
            collect(0.5:1:(o - 0.5)) .* dz,
        ),
        v = _ndgrid3_named(
            collect(0.5:1:(m - 0.5)) .* dx,
            yn,
            collect(0.5:1:(o - 0.5)) .* dz,
        ),
        w = _ndgrid3_named(
            collect(0.5:1:(m - 0.5)) .* dx,
            collect(0.5:1:(n - 0.5)) .* dy,
            zn,
        ),
    )

    return nodes, faces, centers
end

function _coordinates_curvilinear_2d(nodes)
    NX = nodes.X
    NY = nodes.Y

    faces = (
        u = (
            X = 0.5 .* (NX[:, 1:(end - 1)] .+ NX[:, 2:end]),
            Y = 0.5 .* (NY[:, 1:(end - 1)] .+ NY[:, 2:end]),
        ),
        v = (
            X = 0.5 .* (NX[1:(end - 1), :] .+ NX[2:end, :]),
            Y = 0.5 .* (NY[1:(end - 1), :] .+ NY[2:end, :]),
        ),
    )

    centers = (
        X = 0.25 .* (
            NX[1:(end - 1), 1:(end - 1)] .+
            NX[2:end, 1:(end - 1)] .+
            NX[1:(end - 1), 2:end] .+
            NX[2:end, 2:end]
        ),
        Y = 0.25 .* (
            NY[1:(end - 1), 1:(end - 1)] .+
            NY[2:end, 1:(end - 1)] .+
            NY[1:(end - 1), 2:end] .+
            NY[2:end, 2:end]
        ),
    )

    return faces, centers
end

function _ndgrid2_named(x, y)
    X = repeat(reshape(x, :, 1), 1, length(y))
    Y = repeat(reshape(y, 1, :), length(x), 1)
    return (; X, Y)
end

function _ndgrid3_named(x, y, z)
    X = repeat(reshape(x, :, 1, 1), 1, length(y), length(z))
    Y = repeat(reshape(y, 1, :, 1), length(x), 1, length(z))
    Z = repeat(reshape(z, 1, 1, :), length(x), length(y), 1)
    return (; X, Y, Z)
end

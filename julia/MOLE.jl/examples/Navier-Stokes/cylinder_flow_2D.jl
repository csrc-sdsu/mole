using LinearAlgebra
using SparseArrays: sparse, spdiagm, findnz
using Plots
import MOLE: Operators, BCs

function modified_rows(Anew, Aold)
    delta = sparse(Anew - Aold)
    rows, _, _ = findnz(delta)
    return unique(rows)
end

function main()
    k = 2
    Re = 200.0
    rho = 1.0
    Uinit = 1.0

    x0, x1 = 0.0, 8.0
    y0, y1 = -1.0, 1.0

    m = parse(Int, get(ENV, "MOLE_CYLINDER_M", "41"))
    n = parse(Int, get(ENV, "MOLE_CYLINDER_N", "11"))
    dt = parse(Float64, get(ENV, "MOLE_CYLINDER_DT", "0.005"))
    tspan = parse(Float64, get(ENV, "MOLE_CYLINDER_TSPAN", "0.015"))
    nsteps = round(Int, tspan / dt)

    dx = (x1 - x0) / m
    dy = (y1 - y0) / n

    cylin_pos = 1 / 8
    cylin_size = 1 / 10
    D0 = 2 * cylin_size
    nu = Uinit * D0 / Re

    Ncell = (m + 2) * (n + 2)
    Nxfaces = (m + 1) * n

    L = sparse(Operators.lap(k, m, dx, n, dy))
    D = sparse(Operators.div(k, m, dx, n, dy))
    G = sparse(Operators.grad(k, m, dx, n, dy))

    Icf = Operators.interpol(Val(:centers_to_faces), k, m, n)
    Ifc = Operators.interpol(Val(:faces_to_centers), k, m, n)

    Id = spdiagm(0 => ones(Ncell))
    M = sparse(Id - 0.5 * dt * nu * L)
    Mp = sparse(Id + 0.5 * dt * nu * L)

    U = Uinit .* ones(m + 2, n + 2)
    V = zeros(m + 2, n + 2)
    p = zeros(Ncell)

    m_unit = floor(Int, cylin_pos * m)
    rad = floor(Int, cylin_size * m_unit)
    halfN1 = 0.5 * (n + 3)

    i1 = m_unit - rad
    i2 = m_unit + rad
    j1 = Int(halfN1 - rad)
    j2 = Int(halfN1 + rad)

    function apply_velocity_bc_and_mask!(U, V)
        U[1, :] .= Uinit
        V[1, :] .= 0.0

        U[end, :] .= U[end - 1, :]
        V[end, :] .= V[end - 1, :]

        U[2:end, 1] .= 0.0
        V[2:end, 1] .= 0.0

        U[2:end, end] .= 0.0
        V[2:end, end] .= 0.0

        U[1, 1] = 0.0
        U[1, end] = 0.0
        V[1, 1] = 0.0
        V[1, end] = 0.0

        U[i1:i2, j1:j2] .= 0.0
        V[i1:i2, j1:j2] .= 0.0

        return nothing
    end

    apply_velocity_bc_and_mask!(U, V)

    Uflat = vec(U)
    Vflat = vec(V)

    bcU = BCs.ScalarBC2D(
        (1.0, 0.0, 1.0, 1.0),
        (0.0, 1.0, 0.0, 0.0),
        (ones(n), zeros(n), zeros(m + 2), zeros(m + 2)),
    )

    bcV = BCs.ScalarBC2D(
        (1.0, 0.0, 1.0, 1.0),
        (0.0, 1.0, 0.0, 0.0),
        (zeros(n), zeros(n), zeros(m + 2), zeros(m + 2)),
    )

    Au, bU0 = BCs.addScalarBC!(copy(M), zeros(Ncell), bcU, k, m, dx, n, dy)
    Av, bV0 = BCs.addScalarBC!(copy(M), zeros(Ncell), bcV, k, m, dx, n, dy)

    rowsbcU = modified_rows(Au, M)
    rowsbcV = modified_rows(Av, M)

    bcP = BCs.ScalarBC2D(
        (0.0, 1.0, 0.0, 0.0),
        (1.0, 0.0, 1.0, 1.0),
        (zeros(n), zeros(n), zeros(m + 2), zeros(m + 2)),
    )

    Ap, bP0 = BCs.addScalarBC!(copy(L), zeros(Ncell), bcP, k, m, dx, n, dy)
    rowsbcP = modified_rows(Ap, L)

    AdvU_prev = zeros(Ncell)
    AdvV_prev = zeros(Ncell)

    for step in 1:nsteps
        Ustag = Icf * [Uflat; Uflat]
        Vstag = Icf * [Vflat; Vflat]

        U_on_u = Ustag[1:Nxfaces]
        U_on_v = Ustag[(Nxfaces + 1):end]

        V_on_u = Vstag[1:Nxfaces]
        V_on_v = Vstag[(Nxfaces + 1):end]

        AdvU = D * [U_on_u .* U_on_u; U_on_v .* V_on_v]
        AdvV = D * [U_on_u .* V_on_u; V_on_v .* V_on_v]

        AdvU_ab = step == 1 ? AdvU : 1.5 * AdvU - 0.5 * AdvU_prev
        AdvV_ab = step == 1 ? AdvV : 1.5 * AdvV - 0.5 * AdvV_prev

        rhsU = Mp * Uflat - dt * AdvU_ab
        rhsV = Mp * Vflat - dt * AdvV_ab

        rhsU[rowsbcU] .= 0.0
        rhsV[rowsbcV] .= 0.0

        Ustar = Au \ (rhsU + bU0)
        Vstar = Av \ (rhsV + bV0)

        Ustar_mat = reshape(Ustar, m + 2, n + 2)
        Vstar_mat = reshape(Vstar, m + 2, n + 2)

        apply_velocity_bc_and_mask!(Ustar_mat, Vstar_mat)

        Ustar = vec(Ustar_mat)
        Vstar = vec(Vstar_mat)

        Ustar_stag = Icf * [Ustar; Ustar]
        Vstar_stag = Icf * [Vstar; Vstar]

        rhsP = (rho / dt) * D * [
            Ustar_stag[1:Nxfaces]
            Vstar_stag[(Nxfaces + 1):end]
        ]

        rhsP[rowsbcP] .= 0.0

        p = Ap \ (rhsP + bP0)

        UV = [Ustar; Vstar] - (dt / rho) * (Ifc * G * p)

        U = reshape(UV[1:Ncell], m + 2, n + 2)
        V = reshape(UV[(Ncell + 1):end], m + 2, n + 2)

        apply_velocity_bc_and_mask!(U, V)

        Uflat = vec(U)
        Vflat = vec(V)

        AdvU_prev = AdvU
        AdvV_prev = AdvV

        if step == 1 || step % 100 == 0 || step == nsteps
            println(
                "step = ", step,
                " t = ", round(step * dt, digits = 5),
                " maxU = ", maximum(abs.(Uflat)),
                " maxV = ", maximum(abs.(Vflat)),
                " maxAdvU = ", maximum(abs.(AdvU)),
                " maxAdvV = ", maximum(abs.(AdvV)),
            )
        end
    end

    Ufinal = reshape(Uflat, m + 2, n + 2)
    Vfinal = reshape(Vflat, m + 2, n + 2)
    pfinal = reshape(p, m + 2, n + 2)

    plot_u = heatmap(
        Ufinal',
        aspect_ratio = :equal,
        colorbar = true,
        xlabel = "x index",
        ylabel = "y index",
        title = "U at t = $(round(nsteps * dt, digits = 3))",
    )

    plot_v = heatmap(
        Vfinal',
        aspect_ratio = :equal,
        colorbar = true,
        xlabel = "x index",
        ylabel = "y index",
        title = "V at t = $(round(nsteps * dt, digits = 3))",
    )

    plot_p = heatmap(
        pfinal',
        aspect_ratio = :equal,
        colorbar = true,
        xlabel = "x index",
        ylabel = "y index",
        title = "Pressure p",
    )

    plt = plot(plot_u, plot_v, plot_p, layout = (3, 1), size = (1200, 900))
    display(plt)
    savefig(plt, "cylinder_flow_2D.png")

    return Ufinal, Vfinal, pfinal
end

main()

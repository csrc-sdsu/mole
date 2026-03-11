@testset "addScalarBC! (1D) tests" begin

    @testset "no BCs test" begin
        # Problem size
        m  = 8
        n  = m + 2
        k  = 2
        dx = 0.1

        # Nontrivial sparse A and b
        A_dense = reshape(collect(1.0:(n*n)), n, n) ./ 13.0
        A = sparse(A_dense)
        b = collect(1.0:n) ./ 7.0

        dc0 = (0.0, 0.0)
        nc0 = (0.0, 0.0)
        v0  = (9.0, 9.0)  # required by ScalarBC1D even if unused
        bc0 = BCs.ScalarBC1D(dc0, nc0, v0)

        A2, b2 = BCs.addScalarBC!(A, b, bc0, k, m, dx)

        # No BCs leave the systems unchanged
        @test A2 == A
        @test b2 == b
    end

    @testset "Dirichlet/Neumann BC with grad and dense matrix reference" begin
        # Problem size
        m  = 8
        n  = m + 2
        k  = 2
        dx = 0.1

        # Nontrivial sparse A and b
        A_dense = reshape(collect(1.0:(n*n)), n, n) ./ 13.0
        A = sparse(A_dense)
        b = collect(1.0:n) ./ 7.0

        dc = (2.0, 3.0)
        nc = (4.0, 5.0)
        v  = (7.0, 8.0)
        bc = BCs.ScalarBC1D(dc, nc, v)

        A2, b2 = BCs.addScalarBC!(A, b, bc, k, m, dx)

        # ---- expected reference (dense build, but no requirement that result is dense) ----
        A_ref = copy(A_dense)
        b_ref = copy(b)

        # zero boundary rows and boundary RHS entries
        A_ref[1, :] .= 0.0
        A_ref[end, :] .= 0.0
        b_ref[1] = 0.0
        b_ref[end] = 0.0

        Gl = Matrix(Operators.grad(k, m, dx))
        Gr = Matrix(Operators.grad(k, m, dx))

        Al = zeros(Float64, n, n)
        Ar = zeros(Float64, n, n)
        Al[1, 1] = dc[1]
        Ar[end, end] = dc[2]

        Bl = zeros(Float64, n, m + 1)
        Br = zeros(Float64, n, m + 1)
        Bl[1, 1] = -nc[1]
        Br[end, end] =  nc[2]

        A_ref .+= (Al + Bl * Gl) .+ (Ar + Br * Gr)

        # overwrite boundary RHS values
        b_ref[1] = v[1]
        b_ref[end] = v[2]

        @test isapprox(norm(A2 - sparse(A_ref)), 0.0; rtol=1e-12, atol=1e-12)
        @test isapprox(norm(b2 - b_ref), 0.0; rtol=1e-12, atol=1e-12)
    end

    @testset "Dirichlet/Neumann BC with sparse format reference" begin
        # Problem size
        m  = 8
        n  = m + 2
        k  = 2
        dx = 0.1

        # Nontrivial sparse A and b
        A_dense = reshape(collect(1.0:(n*n)), n, n) ./ 13.0
        A = sparse(A_dense)
        b = collect(1.0:n) ./ 7.0

        dc = (2.0, 3.0)
        nc = (4.0, 5.0)
        v  = (7.0, 8.0)
        bc = BCs.ScalarBC1D(dc, nc, v)

        A2, b2 = BCs.addScalarBC!(A, b, bc, k, m, dx)

        @test A2 isa SparseMatrixCSC

        vec = (1, n)

        # reference sparse matrix
        A_ref = sparse(A)  # copy

        # remove existing first+last rows (set to zero) by subtracting their nonzeros
        sub = A_ref[[vec[1], vec[2]], :]
        rows, cols, vals = findnz(sub)

        mapped_rows = similar(rows)
        @inbounds for i in eachindex(rows)
            mapped_rows[i] = (rows[i] == 1) ? vec[1] : vec[2]
        end

        A_ref .-= sparse(mapped_rows, cols, vals, n, n)

        # RHS boundary handling
        b_ref = copy(b)
        b_ref[vec[1]] = 0.0
        b_ref[vec[2]] = 0.0

        # LHS BC contributions (sparse)
        Gl = sparse(Operators.grad(k, m, dx))
        Gr = sparse(Operators.grad(k, m, dx))

        Al = spzeros(Float64, n, n)
        Ar = spzeros(Float64, n, n)
        Al[1, 1] = dc[1]
        Ar[end, end] = dc[2]

        Bl = spzeros(Float64, n, m + 1)
        Br = spzeros(Float64, n, m + 1)
        Bl[1, 1] = -nc[1]
        Br[end, end] =  nc[2]

        A_ref .+= (Al + Bl * Gl) .+ (Ar + Br * Gr)

        b_ref[vec[1]] = v[1]
        b_ref[vec[2]] = v[2]

        # pure sparse comparisons
        @test norm(A2 - A_ref) ≤ 1e-12
        @test norm(b2 - b_ref) ≤ 1e-12
    end

end
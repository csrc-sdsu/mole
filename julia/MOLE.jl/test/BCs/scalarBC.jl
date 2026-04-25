using Plots

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

@testset "addScalarBC! (2D) tests" begin
    @testset "Periodic BCs (no BCs) test" begin
        # Problem description
        k = 2
        m = 5
        n = m + 1
        dx = 1 / m
        dy = 1 / n

        # Boundary conditions
        dc = (0.0, 0.0, 0.0, 0.0)
        nc = (0.0, 0.0, 0.0, 0.0)
        v = ([0.0], [0.0], [0.0], [0.0])
        bc = BCs.ScalarBC2D(dc, nc, v)

        # Non trivial sparse A and b
        A = sparse(rand(m * n, m * n))
        b = rand(m * n,)

        A2, b2 = BCs.addScalarBC!(A, b, bc, k, m, dx, n, dy)

        # Periodic BCs leave system unchanged
        @test A2 == A
        @test b2 == b
    end

    @testset "Dirichlet/Neumann BC with grad and dense matrix reference" begin
        # Problem description
        k = 2
        m = 5
        n = m + 1
        numC = (m + 2) * (n + 2)
        numF = (m + 1) * n + m * (n + 1)
        dx = 0.1
        dy = 0.4

        # Boundary conditions
        dc = (3.0, 2.0, 1.0, 4.0)
        nc = (1.0, 8.0, 3.0, 6.0)
        v = (rand(n,), rand(n,), rand(m + 2,), rand(m + 2,))
        bc = BCs.ScalarBC2D(dc, nc, v)

        # Non trivial sparse A and b
        A_dense = rand(numC, numC)
        A = sparse(A_dense)
        b = rand(numC,)

        A2, b2 = BCs.addScalarBC!(A, b, bc, k, m, dx, n, dy)

        # Expected reference (dense build, no requirement that result is dense)
        A_ref = copy(A_dense)
        b_ref = copy(b)

        # zero boundary rows and RHS entries
        Im = Matrix(I, m + 2, m + 2)
        In = Matrix(I, n + 2, n + 2)
        bdry_x = zeros(Int64, m + 2, m + 2)
        bdry_x[1, 1] = 1
        bdry_x[end, end] = 1
        bdry_y = zeros(Int64, n + 2, n + 2)
        bdry_y[1, 1] = 1
        bdry_y[end, end] = 1
        bdry_rows = findall(vec(any(kron(In, bdry_x) .+ kron(bdry_y, Im) .!= 0, dims = 2)))

        A_ref[bdry_rows, :] .= 0.0
        b_ref[bdry_rows] .= 0.0

        Gl = Matrix(Operators.grad(k, m, dx))
        Gr = Matrix(Operators.grad(k, m, dx))
        Gb = Matrix(Operators.grad(k, n, dy))
        Gt = Matrix(Operators.grad(k, n, dy))

        Al = zeros(Float64, m + 2, m + 2)
        Ar = zeros(Float64, m + 2, m + 2)
        Ab = zeros(Float64, n + 2, n + 2)
        At = zeros(Float64, n + 2, n + 2)

        Al[1, 1] = dc[1]
        Ar[end, end] = dc[2]
        Ab[1, 1] = dc[3]
        At[end, end] = dc[4]

        Inn = copy(In)
        Inn[1, 1] = 0
        Inn[end, end] = 0
        
        Bl = zeros(Float64, m + 2, m + 1)
        Br = zeros(Float64, m + 2, m + 1)
        Bb = zeros(Float64, n + 2, n + 1)
        Bt = zeros(Float64, n + 2, n + 1)

        Bl[1, 1] = -nc[1]
        Br[end, end] = nc[2]
        Bb[1, 1] = -nc[3]
        Bt[end, end] = nc[4]

        Al = Al + Bl * Gl
        Ar = Ar + Br * Gr
        Ab = Ab + Bb * Gb
        At = At + Bt * Gt

        Al = kron(Inn, Al)
        Ar = kron(Inn, Ar)
        Ab = kron(Ab, Im)
        At = kron(At, Im)

        A_ref .+= Al .+ Ar .+ Ab .+ At

        bdry_v = zeros(size(bdry_rows,))
        bdry_v[1:length(v[3])] = v[3]
        midd = []
        for i = 1:length(v[1]); midd = [midd; v[1][i]; v[2][i]]; end
        bdry_v[length(v[3])+1:length([v[1];v[2];v[3]])] = midd
        bdry_v[end-length(v[4])+1:end] = v[4]
        b_ref[bdry_rows] = bdry_v


        @test isapprox(norm(A2 - sparse(A_ref)), 0.0; rtol=1e-12, atol=1e-12)
        @test isapprox(norm(b2 - b_ref), 0.0; rtol=1e-12, atol=1e-12)

    end

    @testset "Dirichlet/Neumann BC with sparse format reference" begin
        # Problem description
        k = 2
        m = 5
        n = m + 1
        dx = 0.21
        dy = 0.3
        numC = (m + 2) * (n + 2)

        # Nontrivial sparse A and b
        A_dense = rand(numC, numC)
        A = sparse(A_dense)
        b = rand(numC,)

        # Boundary conditions
        dc = (1.0, 3.3, 4.0, 2.0)
        nc = (1.0, 3.3, 4.0, 2.0)
        v = (rand(n,), rand(n,), rand(m + 2,), rand(m + 2,))
        bc = BCs.ScalarBC2D(dc, nc, v)

        A2, b2 = BCs.addScalarBC!(A, b, bc, k, m, dx, n, dy)

        @test A2 isa SparseMatrixCSC

        # reference sparse matrix
        A_ref = sparse(A)

        # remove existing boundary rows
        Im = Matrix(I, m + 2, m + 2)
        In = Matrix(I, n + 2, n + 2)
        bdry_x = zeros(Int64, m + 2, m + 2)
        bdry_x[1, 1] = 1
        bdry_x[end, end] = 1
        bdry_y = zeros(Int64, n + 2, n + 2)
        bdry_y[1, 1] = 1
        bdry_y[end, end] = 1
        bdry_rows = findall(vec(any(kron(In, bdry_x) .+ kron(bdry_y, Im) .!= 0, dims = 2)))
        
        A_ref[bdry_rows, :] = spzeros(size(A_ref[bdry_rows, :]))

        # RHS boundaries
        b_ref = copy(b)
        bdry_v = zeros(size(bdry_rows,))
        bdry_v[1:length(v[3])] = v[3]
        midd = []
        for i = 1:length(v[1]); midd = [midd; v[1][i]; v[2][i]]; end
        bdry_v[length(v[3])+1:length([v[1];v[2];v[3]])] = midd
        bdry_v[end-length(v[4])+1:end] = v[4]
        b_ref[bdry_rows] = bdry_v

        # LHS boundaries
        Gl = sparse(Operators.grad(k, m, dx))
        Gr = sparse(Operators.grad(k, m, dx))
        Gb = sparse(Operators.grad(k, n, dy))
        Gt = sparse(Operators.grad(k, n, dy))

        Al = spzeros(Float64, m + 2, m + 2)
        Ar = spzeros(Float64, m + 2, m + 2)
        Ab = spzeros(Float64, n + 2, n + 2)
        At = spzeros(Float64, n + 2, n + 2)

        Al[1, 1] = dc[1]
        Ar[end, end] = dc[2]
        Ab[1, 1] = dc[3]
        At[end, end] = dc[4]

        Inn = copy(In)
        Inn[1, 1] = 0
        Inn[end, end] = 0
        
        Bl = spzeros(Float64, m + 2, m + 1)
        Br = spzeros(Float64, m + 2, m + 1)
        Bb = spzeros(Float64, n + 2, n + 1)
        Bt = spzeros(Float64, n + 2, n + 1)

        Bl[1, 1] = -nc[1]
        Br[end, end] = nc[2]
        Bb[1, 1] = -nc[3]
        Bt[end, end] = nc[4]

        Al = Al + Bl * Gl
        Ar = Ar + Br * Gr
        Ab = Ab + Bb * Gb
        At = At + Bt * Gt

        Al = kron(Inn, Al)
        Ar = kron(Inn, Ar)
        Ab = kron(Ab, Im)
        At = kron(At, Im)

        A_ref .+= Al .+ Ar .+ Ab .+ At     

        # pure sparse comparisons
        @test norm(A2 - A_ref) ≤ 1e-12
        @test norm(b2 - b_ref) ≤ 1e-12

    end
end
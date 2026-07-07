tol = 1e-10

@testset "Testing 1D center-to-face interpolator" begin
    m = 5

    for c in 0:0.25:1
        I = Operators.interpol(m, c)

        A = [
            1 0 0 0 0 0 0
            0 c 1-c 0 0 0 0
            0 0 c 1-c 0 0 0
            0 0 0 c 1-c 0 0
            0 0 0 0 c 1-c 0
            0 0 0 0 0 0 1
        ]

        @test size(I) == (m + 1, m + 2)
        @test issparse(I)
        @test norm(Matrix(I) - A) < tol
    end
end

@testset "Testing 1D face-to-center interpolator" begin
    m = 5

    for c in 0:0.25:1
        I = Operators.interpol(Val(:faces_to_centers), 2, m; c = c)

        A = [
            1 0 0 0 0 0
            c 1-c 0 0 0 0
            0 c 1-c 0 0 0
            0 0 c 1-c 0 0
            0 0 0 c 1-c 0
            0 0 0 0 c 1-c
            0 0 0 0 0 1
        ]

        @test size(I) == (m + 2, m + 1)
        @test issparse(I)
        @test norm(Matrix(I) - A) < tol
    end
end

@testset "Testing 2D interpolators" begin
    k = 2
    m = 7
    n = 6

    a = 0.0
    b = 1.0
    y0 = 0.0
    y1 = 1.0

    dx = (b - a) / m
    dy = (y1 - y0) / n

    Ncell = (m + 2) * (n + 2)
    Nxfaces = (m + 1) * n
    Nyfaces = m * (n + 1)
    Nfaces = Nxfaces + Nyfaces

    x = range(a - dx / 2, b + dx / 2, length = m + 2)
    y = range(y0 - dy / 2, y1 + dy / 2, length = n + 2)

    X = repeat(collect(x), 1, n + 2)
    Y = repeat(collect(y)', m + 2, 1)

    I = Operators.interpol(Val(:centers_to_faces), k, m, n)
    II = Operators.interpol(Val(:faces_to_centers), k, m, n)
    G = Operators.grad(k, m, dx, n, dy)

    @testset "dimensions and sparsity" begin
        @test size(I) == (Nfaces, 2Ncell)
        @test size(II) == (2Ncell, Nfaces)
        @test size(II * G) == (2Ncell, Ncell)

        @test issparse(I)
        @test issparse(II)
    end

    @testset "center-to-face preserves constants" begin
        u = ones(Ncell)
        out = I * [u; u]

        @test length(out) == Nfaces
        @test all(out .≈ 1.0)
    end

    @testset "center-to-face interpolates linear x field" begin
        u = vec(X)
        out = I * [u; u]

        ux_faces = reshape(out[1:Nxfaces], m + 1, n)
        uy_faces = reshape(out[(Nxfaces + 1):end], m, n + 1)

        x_on_x_faces = [
            a - dx / 2
            collect(range(a + dx, b - dx, length = m - 1))
            b + dx / 2
        ]

        x_on_y_faces = collect(range(a + dx / 2, b - dx / 2, length = m))

        @test all(ux_faces .≈ repeat(x_on_x_faces, 1, n))
        @test all(uy_faces .≈ repeat(x_on_y_faces, 1, n + 1))
    end

    @testset "center-to-face interpolates linear y field" begin
        u = vec(Y)
        out = I * [u; u]

        ux_faces = reshape(out[1:Nxfaces], m + 1, n)
        uy_faces = reshape(out[(Nxfaces + 1):end], m, n + 1)

        y_on_x_faces = collect(range(y0 + dy / 2, y1 - dy / 2, length = n))

        y_on_y_faces = [
            y0 - dy / 2
            collect(range(y0 + dy, y1 - dy, length = n - 1))
            y1 + dy / 2
        ]

        @test all(ux_faces .≈ repeat(y_on_x_faces', m + 1, 1))
        @test all(uy_faces .≈ repeat(y_on_y_faces', m, 1))
    end

    @testset "face-to-center preserves constants on valid component domains" begin
        gx = ones(Nxfaces)
        gy = ones(Nyfaces)

        out = II * [gx; gy]

        ux = reshape(out[1:Ncell], m + 2, n + 2)
        uy = reshape(out[(Ncell + 1):end], m + 2, n + 2)

        # x-component is defined on all x rows, interior y columns.
        @test all(ux[:, 1] .≈ 0.0)
        @test all(ux[:, n + 2] .≈ 0.0)
        @test all(ux[:, 2:(n + 1)] .≈ 1.0)

        # y-component is defined on interior x rows, all y columns.
        @test all(uy[1, :] .≈ 0.0)
        @test all(uy[m + 2, :] .≈ 0.0)
        @test all(uy[2:(m + 1), :] .≈ 1.0)
    end

    @testset "gradient composition annihilates constant pressure" begin
        p = ones(Ncell)
        correction = II * G * p

        @test length(correction) == 2Ncell
        @test norm(correction) < tol
    end

    @testset "gradient composition differentiates linear x pressure" begin
        p = vec(X)
        correction = II * G * p

        px = reshape(correction[1:Ncell], m + 2, n + 2)
        py = reshape(correction[(Ncell + 1):end], m + 2, n + 2)

        # Away from x-boundary closure rows, d(x)/dx = 1.
        @test all(px[3:m, 2:(n + 1)] .≈ 1.0)

        # Cross derivative d(x)/dy = 0 on the valid y-component domain.
        @test norm(py[2:(m + 1), :]) < tol
    end

    @testset "gradient composition differentiates linear y pressure" begin
        p = vec(Y)
        correction = II * G * p

        px = reshape(correction[1:Ncell], m + 2, n + 2)
        py = reshape(correction[(Ncell + 1):end], m + 2, n + 2)

        # Cross derivative d(y)/dx = 0 on the valid x-component domain.
        @test norm(px[:, 2:(n + 1)]) < tol

        # Away from y-boundary closure columns, d(y)/dy = 1.
        @test all(py[2:(m + 1), 3:n] .≈ 1.0)
    end
end

@testset "Testing interpolator argument validation" begin
    @test_throws AssertionError Operators.interpol(3, 0.5)
    @test_throws AssertionError Operators.interpol(5, -0.1)
    @test_throws AssertionError Operators.interpol(5, 1.1)

    @test_throws AssertionError Operators.interpol(Val(:centers_to_faces), 4, 7)
    @test_throws AssertionError Operators.interpol(Val(:faces_to_centers), 4, 7)

    @test_throws AssertionError Operators.interpol(Val(:centers_to_faces), 2, 3, 6)
    @test_throws AssertionError Operators.interpol(Val(:centers_to_faces), 2, 7, 3)

    @test_throws AssertionError Operators.interpol(Val(:faces_to_centers), 2, 3, 6)
    @test_throws AssertionError Operators.interpol(Val(:faces_to_centers), 2, 7, 3)
end

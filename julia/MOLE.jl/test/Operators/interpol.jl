tol = 1e-10
#=
@testset "Testing interpolating operator for m=5 and c=0.5" begin
    m = 5
    c = 0.5
    I = Operators.interpol(m,c)
    A = [1 0 0 0 0 0 0;
     0 0.5 0.5 0 0 0 0;
     0 0 0.5 0.5 0 0 0;
     0 0 0 0.5 0.5 0 0;
     0 0 0 0 0.5 0.5 0;
     0 0 0 0 0 0 1]
@test norm(I-A) < tol
end


@testset "Testing interpolating operator for m=5 and c=1" begin
    m = 5
    c = 1.0
    I = Operators.interpol(m,c)
    A = [1 0 0 0 0 0 0;
         0 1 0 0 0 0 0;
         0 0 1 0 0 0 0;
         0 0 0 1 0 0 0;
         0 0 0 0 1 0 0;
         0 0 0 0 0 0 1]
@test norm(I-A) < tol
end
=#

@testset "Testing interpolator operator for m=5 and c=$c" for c=0:0.25:1
    m = 5
    I = Operators.interpol(m,c)
    A = [1 0 0 0 0 0 0;
         0 c 1-c 0 0 0 0;
         0 0 c 1-c 0 0 0;
         0 0 0 c 1-c 0 0;
         0 0 0 0 c 1-c 0;
         0 0 0 0 0 0 1]
@test norm(I-A) < tol
end



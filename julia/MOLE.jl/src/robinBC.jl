function robinBC(k::Int, m::Int, dx, a, b)
    A = zeros(m+2,m+2)
    A[1,1] = a
    A[m+2,m+2] = a

    B = zeros(m+2,m+1)
    B[1,1] = -b
    B[m+2,m+1] = b

    G = grad(k,m,dx)

    BC = A + B*G;
end
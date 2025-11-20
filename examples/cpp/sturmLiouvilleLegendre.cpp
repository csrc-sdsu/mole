/**
 * 1D Legendre's Sturm Liouville: Dirichlet BC
 * (1 - x^2) * u'' - 2 * x * u' + n * (n + 1) * u = 0, -1 < x < 1, u(-1) = -1, u(1) = 1
 * exact solution: u(x) = P_n(x) (Legendre polynomial of degree n)
 */


#include "mole.h"
#include <iostream>

int main()
{
    // Parameters
    int k = 2;
    int m = 20;
    Real dx = 2 / (Real) m;

    // Build grid
    vec xc(m+2);
    xc(0) = -1;
    xc(1) = -1 + dx / 2;
    for (int i = 2; i <= m; i++)
    {
        xc(i) = xc(i - 1) + dx;
    }
    xc(m + 1) = 1.0;

    // Exact solution -- legendreP(3, xc)
    vec ue("-1.0 -0.7184375 -0.2603125 0.0703125 "
           "0.2884375 0.4090625 0.4471875 0.4178125 "
           "0.3359375 0.2165625 0.0746875 -0.0746875 "
           "-0.2165625 -0.3359375 -0.4178125 -0.4471875 "
           "-0.4090625 -0.2884375 -0.0703125 0.2603125 0.7184375 1.0");

    // Mimetic operators
    Interpol I(false, m, 0.5);
    Gradient G(k, m, dx);
    Laplacian L(k, m, dx);
    RobinBC robin(k, m, dx, 1, 0);

    // Set up system of equations
    sp_mat xc_mat = sp_mat( diagmat(xc) );
    sp_mat xc_mat_sq = sp_mat( diagmat(1 - pow(xc, 2)) );
    sp_mat A = xc_mat_sq * (sp_mat)L - 2 * xc_mat * (sp_mat)I * (sp_mat)G + 12.0 * speye(m+2, m+2);

    // Apply BC
    A.row(0).zeros();
    A.row(A.n_rows - 1).zeros();
    A = A + (sp_mat)robin;

    vec b(m+2);
    b(0) = -1.0;
    b(m+1) = 1.0;

    // Solve
    #ifdef EIGEN
        vec sol = Utils::spsolve_eigen(A, b);
    #else
        vec sol = spsolve(A, b);
    #endif

    vec diff = sol - ue;
    std::cout << norm(diff) << std::endl;

}
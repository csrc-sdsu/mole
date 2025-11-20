/**
 * 1D Chebyshev's Sturm Liouville: Dirichlet BC
 * (1 - x^2) * u'' - x * u' + n^2 * u = 0, -1 < x < 1, u(-1) = u(1) = 1
 * exact solution: u(x) = T_2(x) (Chebyshev polynomial of degree 2)
 */


#include "mole.h"
#include <iostream>

int main()
{
    // Parameters
    int k = 2;
    int m = 2 * k + 1;
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

    // Exact solution -- hebyshevT(2, xc)
    vec ue("1.0 0.28 -0.68 -1.0 -0.68 0.28 1.0");

    // Mimetic Operators
    Interpol I(false, m, 0.5);
    Gradient G(k, m, dx);
    Laplacian L(k, m, dx);
    RobinBC robin(k, m, dx, 1, 0);

    // Set up system of equations
    sp_mat xc_mat = sp_mat( diagmat(xc) );
    sp_mat xc_mat_sq = sp_mat( diagmat( 1.0 - pow(xc, 2) ) );
    sp_mat A = xc_mat_sq * (sp_mat)L - xc_mat * (sp_mat)I * (sp_mat)G + 4.0 * speye(m+2, m+2); // n = 2

    // Apply BC
    A.row(0).zeros();
    A.row(A.n_rows - 1).zeros();
    A = A + (sp_mat)robin;

    vec b(m+2);
    b(0) = 1.0;
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
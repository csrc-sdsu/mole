/**
 * 1D Hermite's Sturm Liouvulle: Dirichlet BC
 * u'' - 2 * u' + 2 * m * u = 0, -1 < x < 1, u(-1) = Hermite(4, -1), u(1) = Hermite(4, 1)
 * exact solution: u(x) = H_4(x) (Hermite function of order 4)
 */


#include "mole.h"
#include <iostream>

int main()
{
    // Parametesr
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

    // Exact solution -- hermiteH(4, xc)
    vec ue("-20.0 -18.2879 -14.3279 -9.9375 -5.4239 -1.0559 2.9361 6.3601 9.0625 "
           "10.9281 11.8801 11.8801 10.9281 9.0625 6.3601 2.9361 -1.0559 -5.4239 "
           "-9.9375 -14.3279 -18.2879 -20.0");

    // Mimetic Operators
    Interpol I(false, m, 0.5);
    Gradient G(k, m, dx);
    Laplacian L(k, m, dx);
    RobinBC robin(k, m, dx, 1, 0);

    // Set up system of equations
    sp_mat xc_mat = sp_mat( diagmat(xc) );
    sp_mat A = (sp_mat)L - 2 * xc_mat * (sp_mat)I * (sp_mat)G + 8.0 * speye(m+2, m+2); // m = 4

    // Apply BC
    A.row(0).zeros();
    A.row(A.n_rows - 1).zeros();
    A = A + (sp_mat)robin;

    vec b(m+2);
    b(0) = -20.0;
    b(m+1) = -20.0;

    // Solve
    #ifdef EIGEN
        vec sol = Utils::spsolve_eigen(A, b);
    #else
        vec sol = spsolve(A, b);
    #endif

    vec diff = sol - ue;
    std::cout << norm(diff) << std::endl;

}
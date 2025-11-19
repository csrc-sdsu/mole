/**
 * 1D Helmholtz Sturm Liouville: Dirichlet BC
 * u'' + u = 0, 0 < x < 3, u(0) = 0, u(3) = sin(3)
 * exact solution: u(x) = sin(x)
 */


#include "mole.h"
#include <iostream>

int main()
{
    // Parameters
    int k = 2;
    int m = 40;
    Real dx = 3 / (Real) m;

    // Build grid
    vec xc(m+2);
    xc(0) = 0.0;
    xc(1) = dx / 2;
    for (int i = 2; i <= m; i++)
    {
        xc(i) = xc(i - 1) + dx;
    }
    xc(m + 1) = 3.0;

    // Exact solution -- sin(x)
    vec ue = sin(xc);

    // Mimetic Operators
    Laplacian L(k, m, dx);
    RobinBC robin(k, m, dx, 1, 0);
    
    // Set up system of equations
    sp_mat A = (sp_mat)L + speye(m+2, m+2);

    // Apply BC
    A.row(0).zeros();
    A.row(A.n_rows - 1).zeros();
    A = A + (sp_mat)robin;

    vec b(m+2);
    b(0) = 0.0;
    b(m+1) = sin(3.0);

    // Solve
    #ifdef EIGEN
        vec sol = Utils::spsolve_eigen(A, b);
    #else
        vec sol = spsolve(A, b);
    #endif

    vec diff = sol - ue;
    std::cout << norm(diff) << std::endl;

}
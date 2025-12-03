/**
 * @file sturmLiouvilleHelmholtzDirichletDirichlet.cpp
 * @brief Solves the 1D Helmholtz equation in Sturm-Liouville form
 * 
 * The equation being solved is:
 *      $$ u'' + u = 0 $$ 
 * 
 * ## Spatial Domain:
 * - The spatial domain is $x \in [0, 3]$
 * - The grid spacing is $dx = 3 / m$
 * 
 * ## Boundary Conditions:
 * - $u(0) = 0$
 * - $u(3) = \sin(3)$
 * 
 * The solution is computed using mimetic finite difference operators and is compared with the exact result:
 *      $$ u(x) = \sin(x) $$
 * 
 * The norms of each solution and the error are printed
 */


#include "mole.h"
#include <iostream>

int main()
{
    // Parameters
    const int k = 2;         // Order of accuracy
    const int m = 40;        // Number of cells
    const Real dx = 3.0 / m; // Grid spacing

    // Build grid of cell centers
    arma::vec xc(m+2);
    xc(0) = 0.0;
    xc(1) = dx / 2.0;
    for (int i = 2; i <= m; i++)
    {
        xc(i) = xc(i - 1) + dx;
    }
    xc(m + 1) = 3.0;

    // Exact solution -- sin(x)
    arma::vec ue = sin(xc);

    // Mimetic Operators
    Laplacian L(k, m, dx);
    RobinBC robin(k, m, dx, 1, 0); // Dirichlet BC
    
    // Set up system of equations
    arma::sp_mat A = (arma::sp_mat)L + arma::speye(m+2, m+2);

    // Apply BC
    A.row(0).zeros();
    A.row(A.n_rows - 1).zeros();
    A = A + (arma::sp_mat)robin;

    arma::vec b(m+2);
    b(0) = 0.0;
    b(m+1) = sin(3.0);

    // Solve
    arma::vec sol = arma::spsolve(A, b);

    arma::vec diff = sol - ue;
    std::cout << "norm(u_numerical) = " << arma::norm(sol) << std::endl;
    std::cout << "norm(u_exact) = " << arma::norm(ue) << std::endl;
    std::cout << "norm(u_numerical - u_exact) = " << arma::norm(diff) << std::endl;

}
/**
 * @file sturmLiouvilleChebyshev.cpp
 * @brief Solves the Chebyshev equation in Sturm-Liouville form
 * 
 * The equation being solved is:
 *      $$ (1 - x^2) * u'' - x * u' + p^2 * u = 0 $$
 * 
 * ## Spatial Domain:
 * - The spatial domain is $x \in [-1, 1]$
 * - The grid spacing is $dx = 2 / m$
 * 
 * ## Boundary Conditions:
 * - $u(-1) = u(1) = 1$
 * 
 * The solution is computed using mimetic finite difference operators and is compared with the exact result:
 *      $$ u(x) = T_2(x) $$ (Chebyshev Polynomial of degree 2)
 * 
 * The norms of each solution and the error are printed
 */


#include "mole.h"
#include <iostream>

int main()
{
    // Parameters
    const int k = 2;         // Order of accuracy
    const int m = 2 * k + 1; // Number of cells
    const Real dx = 2.0 / m; // Grid spacing
    const Real p = 2.0;

    // Build grid of cell centers
    arma::vec xc(m+2);
    xc(0) = -1.0;
    xc(1) = -1.0 + dx / 2.0;
    for (int i = 2; i <= m; i++)
    {
        xc(i) = xc(i - 1) + dx;
    }
    xc(m + 1) = 1.0;

    // Exact solution -- T_2(xc)
    arma::vec ue("1.0 0.28 -0.68 -1.0 -0.68 0.28 1.0");

    // Mimetic Operators
    Interpol I(false, m, 0.5); // Interpolates from faces to centers
    Gradient G(k, m, dx);
    Laplacian L(k, m, dx);
    RobinBC robin(k, m, dx, 1, 0); // Dirichlet BC

    // Set up system of equations
    arma::sp_mat xc_mat = arma::sp_mat( arma::diagmat(xc) ); // x
    arma::sp_mat xc_mat_sq = arma::sp_mat( arma::diagmat( 1.0 - arma::pow(xc, 2) ) ); // 1 - x^2
    arma::sp_mat A = xc_mat_sq * (arma::sp_mat)L - xc_mat * (arma::sp_mat)I * (arma::sp_mat)G + p * p * arma::speye(m+2, m+2);

    // Apply BC
    A.row(0).zeros();
    A.row(A.n_rows - 1).zeros();
    A = A + (arma::sp_mat)robin;

    arma::vec b(m+2);
    b(0) = 1.0;
    b(m+1) = 1.0;

    // Solve
    arma::vec sol = arma::spsolve(A, b);

    arma::vec diff = sol - ue;
    std::cout << "norm(u_numerical) = " << arma::norm(sol) << std::endl;
    std::cout << "norm(u_exact) = " << arma::norm(ue) << std::endl;
    std::cout << "norm(u_numerical - u_exact) = " << arma::norm(diff) << std::endl;

}
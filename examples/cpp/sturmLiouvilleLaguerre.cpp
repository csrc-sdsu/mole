/**
 * @file sturmLiouvilleLaguerre.cpp
 * @brief Solves the 1D Laguerre equation in Sturm-Liouville form
 * 
 * The equation being solved is:
 *      $$ x * u'' + (1 - x) * u' + n * u = 0 $$
 * 
 * ## Spatial Domain:
 * - The spatial domain is $x \in [0, 2]
 * - The grid spacing is $dx = 2 / m$
 * 
 * ## Boundary Conditions:
 * - $u(0) = L_4(0)$
 * - $u(2) = L_4(2)$
 * 
 * The solution is computed using mimetic finite difference operators and is compared with the exact result:
 *      $$ L_4(x) $$ (Laguerre Polynomial of order 4)
 * 
 * The norms of each solution and the error are printed
 */


#include "mole.h"
#include <iostream>

int main()
{
    // Parameters
    const int k = 2;         // Order of accuracy
    const int m = 30;        // Number of cells
    const Real dx = 2.0 / m; // Grid spacing
    const Real n = 4.0;

    // Build gird of cell centers
    arma::vec xc(m+2);
    xc(0) = 0;
    xc(1) = xc(0) + dx / 2;
    for (int i = 2; i <= m; i++)
    {
        xc(i) = xc(i - 1) + dx;
    }
    xc(m + 1) = 2.0;

    // Exact solution -- L_4(xc)
    arma::vec ue("1.0 0.869975360082304 0.6293375 0.413612397119342 "
           "0.221654372427984 0.0523375 -0.095444393004115 "
           "-0.222777726337449 -0.330729166666667 -0.420345627572016 "
           "-0.492654269547325 -0.5486625 -0.589357973251029 "
           "-0.615708590534979 -0.6286625 -0.629148096707819 "
           "-0.618074022633745 -0.596329166666667 -0.564782664609053 "
           "-0.524283899176955 -0.4756625 -0.419728343621399 "
           "-0.357271553497942 -0.2890625 -0.215851800411523 "
           "-0.138370318930041 -0.057329166666667 0.026580298353909 "
           "0.112686471193416 0.2003375 0.288901286008230 0.333333333333333");

    // Mimetic Operators
    Interpol I(false, m, 0.5); // Interpolates from faces to centers
    Gradient G(k, m, dx);
    Laplacian L(k, m, dx);
    RobinBC robin(k, m, dx, 1, 0); // Dirichlet BC

    // Set up system of equations
    arma::sp_mat xc_mat = arma::sp_mat( arma::diagmat(xc) ); // x
    arma::sp_mat xc_mat_sub = arma::sp_mat( arma::diagmat(1 - xc) ); // 1 - x
    arma::sp_mat A = xc_mat * (arma::sp_mat)L + xc_mat_sub * (arma::sp_mat)I * (arma::sp_mat)G + n * arma::speye(m+2, m+2);

    // Apply BC
    A.row(0).zeros();
    A.row(A.n_rows - 1).zeros();
    A = A + (arma::sp_mat)robin;

    arma::vec b(m+2);
    b(0) = 1.0;
    b(m+1) = 0.333333333333333;

    // Solve
    arma::vec sol = arma::spsolve(A, b);

    arma::vec diff = sol - ue;
    std::cout << "norm(u_numerical) = " << arma::norm(sol) << std::endl;
    std::cout << "norm(u_exact) = " << arma::norm(ue) << std::endl;
    std::cout << "norm(u_numerical - u_exact) = " << arma::norm(diff) << std::endl;

}
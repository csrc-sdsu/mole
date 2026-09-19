/**
 * @file sturmLiouvilleHermite.cpp
 * @brief Solves the 1D Hermite equation in Sturm-Liouvulle form
 * 
 * The equation being solved is:
 *      $$ u'' - 2 * u' + 2 * m * u = 0 $$
 * 
 * ## Spatial Domain:
 * - The spatial domain is $x \in [-1, 1]
 * - The grid spacing is $dx = 2 / m$
 * 
 * ## Boundary Conditions:
 * - $u(-1) = H_4(-1)$
 * - $u(1) = H_4(1)$
 * 
 * The solution is computed using mimetic finite difference operators and is compared with the exact result:
 *      $$ H_4(x) $$ (Hermite Polynomial of order 4)
 * 
 * The norms of each solution and the error are printed
 */


#include "mole.h"
#include <iostream>

int main()
{
    // Parameters
    const int k = 2;         // Order of accuracy
    const int m = 20;        // Number of cells
    const Real dx = 2.0 / m; // Grid spacing
    const Real Hm = 4.0;

    // Build grid of cell centers
    arma::vec xc(m+2);
    xc(0) = -1.0;
    xc(1) = -1.0 + dx / 2.0;
    for (int i = 2; i <= m; i++)
    {
        xc(i) = xc(i - 1) + dx;
    }
    xc(m + 1) = 1.0;

    // Exact solution -- H_4(xc)
    arma::vec ue("-20.0 -18.2879 -14.3279 -9.9375 -5.4239 -1.0559 2.9361 6.3601 "
                 "9.0625 10.9281 11.8801 11.8801 10.9281 9.0625 6.3601 2.9361 "
                 "-1.0559 -5.4239 -9.9375 -14.3279 -18.2879 -20.0");

    // Mimetic Operators
    Interpol I(false, m, 0.5); // Interpolates from faces to centers
    Gradient G(k, m, dx);
    Laplacian L(k, m, dx);
    RobinBC robin(k, m, dx, 1, 0); // Dirichlet BC

    // Set up system of equations
    arma::sp_mat xc_mat = arma::sp_mat( arma::diagmat(xc) );
    arma::sp_mat A = (arma::sp_mat)L - 2 * xc_mat * (arma::sp_mat)I * (arma::sp_mat)G + 2.0 * Hm * arma::speye(m+2, m+2);

    // Apply BC
    A.row(0).zeros();
    A.row(A.n_rows - 1).zeros();
    A = A + (arma::sp_mat)robin;

    arma::vec b(m+2);
    b(0) = -20.0;
    b(m+1) = -20.0;

    // Solve
    arma::vec sol = arma::spsolve(A, b);

    arma::vec diff = sol - ue;
    std::cout << "norm(u_numerical) = " << arma::norm(sol) << std::endl;
    std::cout << "norm(u_exact) = " << arma::norm(ue) << std::endl;
    std::cout << "norm(u_numerical - u_exact) = " << arma::norm(diff) << std::endl;

}
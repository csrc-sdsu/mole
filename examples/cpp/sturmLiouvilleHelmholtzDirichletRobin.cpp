/**
 * @file sturmLiouvilleHelmholtzDirichletRobin.cpp
 * @brief Solves the 1D Helmholtz equation in Sturm-Liouville form
 * 
 * The equation being solved is:
 *      $$ u'' + \mu^2 u = 0 $$
 * 
 * ## Spatial Domain:
 * - The spatial domain is $x \in [0, 1]
 * - The grid spacing is $dx = 1 / m$
 * 
 * ## Boundary Conditions:
 * - $u'(0) = 0$
 * - $u(1) + u'(1) = \cos(\mu) - mu * \sin(\mu)$
 * 
 * The solution is computed using mimetic finite difference operators and is compared with the exact result:
 *      $$ u(x) = \cos(\mu * x) $$
 * 
 * The norms of each solution and the error are printed
 */


#include "mole.h"
#include <iostream>

int main()
{
    // Parameters
    const int k = 2;         // Order of accuracy
    const int m = 150;       // Number of cells
    const Real dx = 1.0 / m; // Grid spacing
    const Real mu = 0.86;

    // Build grid of cell centers
    arma::vec xc(m+2);
    xc(0) = 0.0;
    xc(1) = dx / 2.0;
    for (int i = 2; i <= m; i++)
    {
        xc(i) = xc(i - 1) + dx;
    }
    xc(m + 1) = 1.0;

    // Exact solution -- cos(mu * x)
    arma::vec ue = cos(mu * xc);

    // Mimetic Operators
    Laplacian L(k, m, dx);
    const std::string left = "Neumann";
    const std::string right = "Robin";
    std::vector<Real> lbc(2);
    std::vector<Real> rbc(2);
    lbc[0] = 1.0;
    rbc[0] = 1.0;
    rbc[1] = 1.0;
    MixedBC mbc(k, m, dx, "Neumann", lbc, "Robin", rbc); // Left side Neumann, right side Robin DC
    
    // Set up system of equations
    arma::sp_mat A = (arma::sp_mat)L + mu * mu * arma::speye(m+2, m+2);

    // Apply BC
    A.row(0).zeros();
    A.row(A.n_rows - 1).zeros();
    A = A + (sp_mat)mbc;

    arma::vec b(m+2);
    b(0) = 0.0;
    b(m+1) = cos(mu) - mu * sin(mu);

    // Solve
    arma::vec sol = arma::spsolve(A, b);

    arma::vec diff = sol - ue;
    std::cout << "norm(u_numerical) = " << arma::norm(sol) << std::endl;
    std::cout << "norm(u_exact) = " << arma::norm(ue) << std::endl;
    std::cout << "norm(u_numerical - u_exact) = " << arma::norm(diff) << std::endl;

}
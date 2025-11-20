/**
 * 1D Laguerre's Sturm Liouville: Dirichlet BC
 * x * u'' + (1 - x) * u' + n * u = 0, 0 < x < 2, u(0) = Laguerre(4, 0), u(2) = Laguerre(4, 2)
 * exact solution: u(x) = Laguerre function of order 4
 */


#include "mole.h"
#include <iostream>

int main()
{
    // Parameters
    int k = 2;
    int m = 30;
    Real dx = 2 / (Real) m;

    // Build gird
    vec xc(m+2);
    xc(0) = 0;
    xc(1) = xc(0) + dx / 2;
    for (int i = 2; i <= m; i++)
    {
        xc(i) = xc(i - 1) + dx;
    }
    xc(m + 1) = 2.0;

    // Exact solution -- laguerreL(4, xc)
    vec ue("1.0 0.869975360082304 0.6293375 0.413612397119342 "
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
    Interpol I(false, m, 0.5);
    Gradient G(k, m, dx);
    Laplacian L(k, m, dx);
    RobinBC robin(k, m, dx, 1, 0);

    // Set up system of equations
    sp_mat xc_mat = sp_mat( diagmat(xc) );
    sp_mat xc_mat_sub = sp_mat( diagmat(1 - xc) );
    sp_mat A = xc_mat * (sp_mat)L + xc_mat_sub * (sp_mat)I * (sp_mat)G + 4.0 * speye(m+2, m+2); // n = 4

    // Apply BC
    A.row(0).zeros();
    A.row(A.n_rows - 1).zeros();
    A = A + (sp_mat)robin;

    vec b(m+2);
    b(0) = 1.0;
    b(m+1) = 0.333333333333333;

    // Solve
    #ifdef EIGEN
        vec sol = Utils::spsolve_eigen(A, b);
    #else
        vec sol = spsolve(A, b);
    #endif

    vec diff = sol - ue;
    std::cout << norm(diff) << std::endl;

}
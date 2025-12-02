/**
 * 1D Bessel's Sturm Liouville: Dirichlet BC
 * x^2 * u'' + x u' + (x^2 - nu^2) * u = 0, 0 < x < 1, u(0) = 0, u(1) = BesselJ(nu, 1)
 * exact solution: u(x) = J_3(x) (Bessel function of order 3)
 */


#include "mole.h"
#include <iostream>

int main()
{
    // Parameters
    int k = 2;
    int m = 2 * k + 1;
    Real dx = 1 / (Real) m;
    Real nu = 3;

    // Build grid
    vec xc(m+2);
    xc(0) = 0.0;
    xc(1) = dx / 2;
    for (int i = 2; i <= m; i++)
    {
        xc(i) = xc(i - 1) + dx;
    }
    xc(m + 1) = 1.0;

    // Exact solution -- besselj(3, xc);
    vec ue("0.0 0.000020820315755 0.000559343047749 0.002563729994587 0.006929654826751 0.014434028475866 0.019563353982668");

    // Mimetic Operators
    Interpol I(false, m, 0.5);
    Gradient G(k, m, dx);
    Laplacian L(k, m, dx);
    RobinBC robin(k, m, dx, 1, 0);

    // Set up system of equations
    sp_mat xc_mat = sp_mat( diagmat(xc) );
    sp_mat xc_mat_sq = sp_mat( diagmat( pow(xc, 2) ) );
    sp_mat xc_mat_sq_sub = sp_mat( diagmat( pow(xc, 2) - nu*nu ) );
    
    sp_mat A = xc_mat_sq * (sp_mat)L + xc_mat * (sp_mat)I * (sp_mat)G + xc_mat_sq_sub * speye(m+2, m+2);

    // Apply BC
    A.row(0).zeros();
    A.row(A.n_rows - 1).zeros();
    A = A + (sp_mat)robin;

    vec b(m+2);
    b(m+1) = 0.019563353982668;

    // Solve
    vec sol = spsolve(A, b);

    vec diff = sol - ue;
    std::cout << norm(diff) << std::endl;

}
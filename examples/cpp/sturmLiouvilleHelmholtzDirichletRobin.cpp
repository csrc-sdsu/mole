/**
 * 1D Helmholtz Sturm Liouville: Mixed BC
 * u'' + mu^2 u = 0, 0 < x < 1, u'(0) = 0, u(1) + u'(1) = cos(mu) - mu * sin(mu)
 * exact solution: u(x) = cos(mu * x)
 */


#include "mole.h"
#include <iostream>

int main()
{
    // Parameters
    u16 k = 2;
    u32 m = 150;
    Real dx = 1 / (Real) m;
    Real mu = 0.86;

    // Build grid
    vec xc(m+2);
    xc(0) = 0.0;
    xc(1) = dx / 2;
    for (int i = 2; i <= m; i++)
    {
        xc(i) = xc(i - 1) + dx;
    }
    xc(m + 1) = 1.0;

    // Exact solution -- cos(mu * x)
    vec ue = cos(mu * xc);

    // Mimetic Operators
    Laplacian L(k, m, dx);
    const std::string left = "Neumann";
    const std::string right = "Robin";
    std::vector<Real> lbc(2);
    std::vector<Real> rbc(2);
    lbc[0] = 1.0;
    rbc[0] = 1.0;
    rbc[1] = 1.0;
    MixedBC mbc(k, m, dx, "Neumann", lbc, "Robin", rbc);
    
    // Set up system of equations
    sp_mat A = (sp_mat)L + mu * mu * speye(m+2, m+2);

    // Apply BC
    A.row(0).zeros();
    A.row(A.n_rows - 1).zeros();
    A = A + (sp_mat)mbc;

    vec b(m+2);
    b(0) = 0.0;
    b(m+1) = cos(mu) - mu * sin(mu);

    // Solve
    vec sol = spsolve(A, b);

    vec diff = sol - ue;
    std::cout << norm(diff) << std::endl;

}
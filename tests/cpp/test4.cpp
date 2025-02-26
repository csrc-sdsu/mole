#include "mole.h"
#include <gtest/gtest.h>
#include <algorithm>

TEST(EnergyTests, EigenvalueTest) {
    int k = 4;
    Real a = -5;
    Real b = 5;
    int m = 500;
    vec grid = linspace(a, b, m);
    Real dx = grid(1) - grid(0);
    Real tol = 1e-10;

    Laplacian L(k, m - 2, dx);

    std::transform(grid.begin(), grid.end(), grid.begin(),
                   [](Real x) { return x * x; });

    sp_mat V(m, m);
    V.diag(0) = grid;

    sp_mat H = -0.5 * (sp_mat)L + V;

    cx_vec eigval;
    eig_gen(eigval, (mat)H);

    eigval = sort(eigval);

    vec expected{1, 3, 5, 7, 9};

    for (int i = 0; i < expected.size(); ++i) {
        ASSERT_LT(std::norm(real(eigval(i) / eigval(0)) - expected(i)), tol)
            << "Energy Test failed for eigenvalue index " << i;
    }
}

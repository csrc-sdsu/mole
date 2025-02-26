#include "mole.h"
#include <gtest/gtest.h>

void run_test(int k, vec grid_sizes) {
    Real west = 0; // Domain's limits
    Real east = 1;

    vec errors(grid_sizes.size());

    for (int i = 0; i < grid_sizes.size(); ++i) {
        int m = grid_sizes(i);       // Number of cells
        Real dx = (east - west) / m; // Step length

        Laplacian L(k, m, dx);
        RobinBC BC(k, m, dx, 1, 1);
        L = L + BC;

        vec grid(m + 2);
        grid(0) = west;
        grid(1) = west + dx / 2.0;
        for (int j = 2; j <= m; j++) {
            grid(j) = grid(j - 1) + dx;
        }
        grid(m + 1) = east;

        vec U = exp(grid);
        U(0) = 0;              // West BC
        U(m + 1) = 2 * exp(1); // East BC

#ifdef EIGEN
        vec computed_solution = Utils::spsolve_eigen(L, U);
#else
        vec computed_solution = spsolve(L, U); // Will use SuperLU
#endif

        vec analytical_solution = exp(grid);
        errors(i) = max(abs(computed_solution - analytical_solution));
    }

    vec order(errors.size() - 1);
    for (int i = 0; i < errors.size() - 1; ++i) {
        order(i) = log2(errors(i) / errors(i + 1));
        ASSERT_GE(order(i), k - 0.5) << "Poisson Test failed for k = " << k;
    }
}

TEST(PoissonTests, Accuracy) {
    vec grid_sizes = {20, 40};
    for (int k : {2, 4, 6}) {
        run_test(k, grid_sizes);
    }
}

#include "mole.h"
#include <gtest/gtest.h>

void run_nullity_test(int k, Real tol) {
    int m = 2 * k + 1;
    Real dx = 1;

    Gradient G(k, m, dx);
    vec field(m + 2, fill::ones);

    vec sol = G * field;

    ASSERT_LT(norm(sol), tol) << "Gradient Nullity Test failed for k = " << k;
}

TEST(GradientTests, Nullity) {
    Real tol = 1e-10;
    for (int k : {2, 4, 6, 8}) {
        run_nullity_test(k, tol);
    }
}

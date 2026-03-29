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

void run_periodic_nullity_test(int k, Real tol) {
    int m = 2 * k + 1;
    Real dx = 1;

    // All-zero dc/nc → periodic BC; produces an m×m circulant gradient.
    ivec dc = {0, 0};
    ivec nc = {0, 0};

    Gradient G(k, m, dx, dc, nc);

    // Periodic gradient acts on m interior values (no ghost cells).
    // A constant field maps to zero gradient everywhere.
    vec field(m, fill::ones);

    vec sol = G * field;

    ASSERT_LT(norm(sol), tol) << "Periodic Gradient Nullity Test failed for k = " << k;
}

TEST(GradientTests, Nullity) {
    Real tol = 1e-10;
    for (int k : {2, 4, 6, 8}) {
        run_nullity_test(k, tol);
    }
}

TEST(GradientTests, PeriodicNullity) {
    Real tol = 1e-10;
    for (int k : {2, 4, 6, 8}) {
        run_periodic_nullity_test(k, tol);
    }
}
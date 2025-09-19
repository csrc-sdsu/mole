#include "mole.h"
#include <gtest/gtest.h>

void run_nullity_test(int k, Real tol) {
    //int m = 2 * k + 1;
    int m = 2 * k + 2;
    Real dx = 1;

    Divergence D(k, m, dx);
    vec field(m + 1, fill::ones);

    vec sol = D * field;

    EXPECT_NEAR(norm(sol), 0, tol);
}

TEST(DivergenceTests, Nullity) {
    Real tol = 1e-10;
    for (int k : {2, 4, 6}) {
        run_nullity_test(k, tol);
    }
}

int main(int argc, char **argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}

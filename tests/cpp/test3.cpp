#include "mole.h"
#include <gtest/gtest.h>

void run_nullity_test(int k, Real tol) {
  int m = 2 * k + 1;
  Real dx = 1;

  Laplacian L(k, m, dx);
  vec field(m + 2, fill::ones);

  vec sol = L * field;

  EXPECT_NEAR(norm(sol), 0, tol);
}

void run_periodic_nullity_test(int k, Real tol) {
  int m = 2 * k + 2;
  Real dx = 1.0 / m;

  // All-zero dc/nc: periodic BC; produces an m×m Laplacian matrix.
  ivec dc = {0, 0};
  ivec nc = {0, 0};

  Laplacian L(k, m, dx, dc, nc);
  // Periodic Laplacian acts on m interior values (no ghost cells).
  // A constant field maps to zero Laplacian everywhere.
  vec field(m, fill::ones);

  vec sol = L * field;

  EXPECT_NEAR(norm(sol), 0, tol);
}

TEST(LaplacianTests, Nullity) {
  Real tol = 1e-10;
  for (int k : {2, 4, 6, 8}) {
    run_nullity_test(k, tol);
  }
}

TEST(LaplacianTests, PeriodicNullity) {
  Real tol = 1e-10;
  for (int k : {2, 4, 6, 8}) {
    run_periodic_nullity_test(k, tol);
  }
}

int main(int argc, char **argv) {
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}

/**
 * @file test_addScalarBC.cpp
 * @brief Regression tests for AddScalarBC boundary-condition assembly helpers.
 *
 * These tests exercise the *algebraic modifications* performed by:
 *   - addScalarBC(): for 1D
 *   - addScalarBC() : for 2D
 *   - addScalarBC3D() : for 3D
 *
 * What we validate (high level):
 *  - The system matrix A is modified at boundary rows when BCs are active.
 *  - The RHS vector b receives the prescribed boundary data.
 *  - Pure Dirichlet boundaries typically collapse boundary rows to an identity row.
 *  - Pure Neumann / Robin boundaries should modify rows but generally *not* produce identity rows.
 *  - The “periodic / do nothing” configuration leaves A and b unchanged.
 *
 * Notes / assumptions:
 *  - The tests intentionally avoid overfitting to the *exact* stencil coefficients for Neumann/Robin
 *    because those details may vary with discretization order (k) and implementation choices.
 *  - Instead, we assert invariants that should hold for any sane implementation:
 *      * "A changes" when BCs are active,
 *      * "b boundary entries reflect v",
 *      * Dirichlet rows behave like explicit constraints.
 * Last Modified: 2026/03/09
 */

#include "mole.h"
#include <iostream>
#include <cmath>
#include <stdexcept>

using namespace std;
using namespace AddScalarBC;

/**
 * Numerical tolerance used for equality comparisons in asserts.
 * Kept tight because matrix entries are deterministic and small in these unit tests.
 */
static constexpr Real TOL = 1e-10;

/**
 * @brief Minimal assertion helper.
 *
 * Prints a colored failure message and throws to abort the suite early on first failure.
 * This keeps test output compact while still providing a clear reason for the failure.
 */
static void require_true(bool cond, const string& msg) {
  if (!cond) {
    cout << "\033[1;31mFAILED:\033[0m " << msg << endl;
    throw runtime_error(msg);
  }
}

/**
 * @brief Frobenius norm of (A - B).
 *
 * Used to detect whether boundary-condition application changed the sparse matrix.
 * Armadillo supports sparse Frobenius norm via norm(sp_mat, "fro").
 */
static Real frob_diff(const sp_mat& A, const sp_mat& B) {
  return norm(A - B, "fro");
}

/**
 * @brief Euclidean (L2) norm of (a - b).
 *
 * Used to detect whether boundary-condition application changed the RHS vector.
 */
static Real vec_diff(const vec& a, const vec& b) {
  return norm(a - b);
}

/**
 * @brief Check whether row r is (approximately) an identity constraint at column c.
 *
 * This is the typical outcome of *strong* Dirichlet enforcement:
 *   A(r,c) = 1 and all other entries in row r are ~0.
 *
 * For sparse matrices, we iterate only over stored non-zeros in the row.
 */
static bool row_equals_identity_row(const sp_mat& A, uword r, uword c, Real tol = TOL) {
  const Real diag_val = A(r, c);
  if (std::abs(diag_val - 1.0) > tol) return false;

  for (sp_mat::const_row_iterator it = A.begin_row(r); it != A.end_row(r); ++it) {
    if (it.col() == c) continue;
    if (std::abs(*it) > tol) return false;
  }
  return true;
}

/**
 * @brief Check that row r has no significant entries outside a whitelist of columns.
 *
 * Utility for more surgical checks (not heavily used in this file yet), useful when you want
 * to assert structure without pinning exact stencil coefficients.
 */
static bool row_all_zero_except(const sp_mat& A, uword r, const std::vector<uword>& allowed_cols, Real tol = TOL) {
  for (sp_mat::const_row_iterator it = A.begin_row(r); it != A.end_row(r); ++it) {
    bool allowed = false;
    for (uword c : allowed_cols) {
      if (it.col() == c) { allowed = true; break; }
    }
    if (!allowed && std::abs(*it) > tol) return false;
  }
  return true;
}

// ------------------------------ 1D TESTS ------------------------------

/**
 * @brief 1D: Pure Dirichlet boundary conditions on both ends.
 *
 * Expectation:
 *  - b(0) and b(m+1) are overwritten with the prescribed boundary values.
 *  - Boundary rows in A are replaced by identity rows enforcing u(0)=v_left and u(end)=v_right.
 */
void test_1D_dirichlet() {
  cout << "Testing 1D Dirichlet boundary conditions..." << endl;

  const u16  k  = 2;     // discretization order / stencil parameter used by Laplacian
  const u32  m  = 10;    // number of interior points (ghost points add +2 in this codebase)
  const Real dx = 0.1;   // grid spacing

  Laplacian L(k, m, dx);
  sp_mat A = sp_mat(L);
  sp_mat A_orig = A;

  vec b(m + 2, fill::ones);
  vec b_orig = b;

  BC1D bc;
  bc.dc = {1.0, 1.0};    // Dirichlet weights (left, right)
  bc.nc = {0.0, 0.0};    // Neumann weights (left, right)
  bc.v  = {1.0, 0.0};    // prescribed boundary values: u_left=1, u_right=0

  addScalarBC(A, b, k, m, dx, bc);

  // RHS must reflect prescribed boundary data.
  require_true(std::abs(b(0) - 1.0) < TOL, "1D Dirichlet: b(0) not set to left value");
  require_true(std::abs(b(m + 1) - 0.0) < TOL, "1D Dirichlet: b(end) not set to right value");

  // A should not remain identical to the raw Laplacian when strong Dirichlet is enforced.
  require_true(frob_diff(A, A_orig) > 0.0, "1D Dirichlet: A did not change at all");

  // Strong Dirichlet enforcement typically turns boundary rows into identity constraints.
  require_true(row_equals_identity_row(A, 0, 0), "1D Dirichlet: row 0 is not identity row for u0");
  require_true(row_equals_identity_row(A, m + 1, m + 1), "1D Dirichlet: last row is not identity row for u_end");

  cout << "  1D Dirichlet test passed" << endl;
}

/**
 * @brief 1D: Pure Neumann boundary conditions on both ends.
 *
 * Expectation:
 *  - A boundary rows are modified to encode derivative constraints.
 *  - b boundary entries are overwritten with Neumann data (here both zero).
 *  - Boundary rows should *not* become identity rows (Neumann is not a direct value constraint).
 */
void test_1D_neumann() {
  cout << "Testing 1D Neumann boundary conditions..." << endl;

  const u16  k  = 2;
  const u32  m  = 10;
  const Real dx = 0.1;

  Laplacian L(k, m, dx);
  sp_mat A = sp_mat(L);
  sp_mat A_orig = A;

  vec b(m + 2, fill::ones);

  BC1D bc;
  bc.dc = {0.0, 0.0};    // no Dirichlet component
  bc.nc = {1.0, 1.0};    // Neumann component active on both ends
  bc.v  = {0.0, 0.0};    // prescribed flux/derivative values (both zero here)

  addScalarBC(A, b, k, m, dx, bc);

  // Boundary-condition application must alter the operator.
  require_true(frob_diff(A, A_orig) > 0.0, "1D Neumann: A did not change");

  // RHS boundary entries must match v.
  require_true(std::abs(b(0) - 0.0) < TOL, "1D Neumann: b(0) not set correctly");
  require_true(std::abs(b(m + 1) - 0.0) < TOL, "1D Neumann: b(end) not set correctly");

  // Neumann constraints should not reduce to u = constant identity rows.
  require_true(!row_equals_identity_row(A, 0, 0), "1D Neumann: row 0 incorrectly became identity row");
  require_true(!row_equals_identity_row(A, m + 1, m + 1), "1D Neumann: last row incorrectly became identity row");

  cout << "  1D Neumann test passed" << endl;
}

/**
 * @brief 1D: Mixed BC (Dirichlet on left, Neumann on right).
 *
 * Expectation:
 *  - Left boundary row becomes an identity constraint and b(0) is set to u_left.
 *  - Right boundary row encodes derivative constraint and b(end) is set to the Neumann value.
 */
void test_1D_mixed_dirichlet_neumann() {
  cout << "Testing 1D mixed BC (Dirichlet left, Neumann right)..." << endl;

  const u16  k  = 2;
  const u32  m  = 10;
  const Real dx = 0.1;

  Laplacian L(k, m, dx);
  sp_mat A = sp_mat(L);
  sp_mat A_orig = A;

  vec b(m + 2, fill::ones);

  BC1D bc;
  bc.dc = {1.0, 0.0};   // Dirichlet on left only
  bc.nc = {0.0, 1.0};   // Neumann on right only
  bc.v  = {2.0, 0.5};   // u(0)=2, du/dn(right)=0.5 (conceptually)

  addScalarBC(A, b, k, m, dx, bc);

  require_true(frob_diff(A, A_orig) > 0.0, "1D mixed D/N: A did not change");

  // RHS should match the supplied boundary data in each slot.
  require_true(std::abs(b(0) - 2.0) < TOL, "1D mixed D/N: b(0) wrong");
  require_true(std::abs(b(m + 1) - 0.5) < TOL, "1D mixed D/N: b(end) wrong");

  // Dirichlet => identity row on the left.
  require_true(row_equals_identity_row(A, 0, 0), "1D mixed D/N: left row not identity for Dirichlet");

  // Neumann => should not be identity on the right.
  require_true(!row_equals_identity_row(A, m + 1, m + 1), "1D mixed D/N: right row became identity unexpectedly");

  cout << "  1D mixed (D/N) test passed" << endl;
}

/**
 * @brief 1D: Mixed BC (Neumann on left, Dirichlet on right).
 *
 * Expectation mirrors the previous test with sides swapped.
 */
void test_1D_mixed_neumann_dirichlet() {
  cout << "Testing 1D mixed BC (Neumann left, Dirichlet right)..." << endl;

  const u16  k  = 2;
  const u32  m  = 10;
  const Real dx = 0.1;

  Laplacian L(k, m, dx);
  sp_mat A = sp_mat(L);
  sp_mat A_orig = A;

  vec b(m + 2, fill::ones);

  BC1D bc;
  bc.dc = {0.0, 1.0};   // Dirichlet on right only
  bc.nc = {1.0, 0.0};   // Neumann on left only
  bc.v  = {0.0, -1.0};  // du/dn(left)=0, u(end)=-1

  addScalarBC(A, b, k, m, dx, bc);

  require_true(frob_diff(A, A_orig) > 0.0, "1D mixed N/D: A did not change");

  // RHS must reflect each boundary's prescribed quantity.
  require_true(std::abs(b(0) - 0.0) < TOL, "1D mixed N/D: b(0) wrong");
  require_true(std::abs(b(m + 1) + 1.0) < TOL, "1D mixed N/D: b(end) wrong");

  // Dirichlet => identity row on the right.
  require_true(row_equals_identity_row(A, m + 1, m + 1), "1D mixed N/D: right row not identity for Dirichlet");

  // Neumann => not identity on the left.
  require_true(!row_equals_identity_row(A, 0, 0), "1D mixed N/D: left row became identity unexpectedly");

  cout << "  1D mixed (N/D) test passed" << endl;
}

/**
 * @brief 1D: Robin BC (combined Dirichlet + Neumann) on both ends.
 *
 * Robin form:
 *    dc * u + nc * (du/dn) = v
 *
 * Expectation:
 *  - A is modified on both boundaries.
 *  - b boundary entries reflect v.
 *  - Boundary rows should not collapse to identity because nc != 0.
 */
void test_1D_robin() {
  cout << "Testing 1D Robin BC (Dirichlet+Neumann combined)..." << endl;

  const u16  k  = 2;
  const u32  m  = 10;
  const Real dx = 0.1;

  Laplacian L(k, m, dx);
  sp_mat A = sp_mat(L);
  sp_mat A_orig = A;

  vec b(m + 2, fill::ones);

  BC1D bc;
  bc.dc = {2.0, 3.0};     // value term weights
  bc.nc = {1.0, 4.0};     // derivative term weights
  bc.v  = {1.5, -0.25};   // right-hand-side values for each boundary equation

  addScalarBC(A, b, k, m, dx, bc);

  require_true(frob_diff(A, A_orig) > 0.0, "1D Robin: A did not change");
  require_true(std::abs(b(0) - 1.5) < TOL, "1D Robin: b(0) wrong");
  require_true(std::abs(b(m + 1) + 0.25) < TOL, "1D Robin: b(end) wrong");

  // nc != 0 => not a pure u = constant constraint.
  require_true(!row_equals_identity_row(A, 0, 0), "1D Robin: left row became identity unexpectedly");
  require_true(!row_equals_identity_row(A, m + 1, m + 1), "1D Robin: right row became identity unexpectedly");

  cout << "  1D Robin test passed" << endl;
}

// ------------------------------ 2D TESTS ------------------------------

/**
 * @brief 2D: Dirichlet on all four edges.
 *
 * We keep assertions coarse:
 *  - A must change (boundary rows rewritten).
 *  - b must change (boundary entries overwritten from the initial all-ones vector).
 *
 * This avoids hard-coding the 2D indexing layout for every boundary point.
 */
void test_2D_dirichlet_all() {
  cout << "Testing 2D Dirichlet on all boundaries..." << endl;

  const u16  k  = 2;
  const u32  m  = 8;
  const u32  n  = 7;
  const Real dx = 0.1;
  const Real dy = 0.2;

  Laplacian L(k, m, n, dx, dy);
  sp_mat A = sp_mat(L);
  sp_mat A_orig = A;

  vec b((m + 2) * (n + 2), fill::ones);

  BC2D bc;
  bc.dc = {1.0, 1.0, 1.0, 1.0}; // Left, Right, Bottom, Top => Dirichlet
  bc.nc = {0.0, 0.0, 0.0, 0.0};
  bc.v.resize(4);

  // Provide values for each edge. Lengths use (n+2) or (m+2) to match edge node counts,
  // including ghost nodes for consistency with the implementation.
  bc.v[0] = vec(n + 2, fill::value(1.0));  // left edge
  bc.v[1] = vec(n + 2, fill::value(2.0));  // right edge
  bc.v[2] = vec(m + 2, fill::value(3.0));  // bottom edge
  bc.v[3] = vec(m + 2, fill::value(4.0));  // top edge

  addScalarBC(A, b, k, m, dx, n, dy, bc);

  require_true(frob_diff(A, A_orig) > 0.0, "2D Dirichlet all: A did not change");
  require_true(vec_diff(b, vec((m + 2) * (n + 2), fill::ones)) > 0.0, "2D Dirichlet all: b did not change");

  cout << "  2D Dirichlet-all test passed" << endl;
}

/**
 * @brief 2D: Neumann on all four edges.
 *
 * Similar coarse checks as the Dirichlet-all test:
 *  - A must change to encode derivative constraints.
 *  - b must change due to boundary RHS insertion.
 */
void test_2D_neumann_all() {
  cout << "Testing 2D Neumann on all boundaries..." << endl;

  const u16  k  = 2;
  const u32  m  = 8;
  const u32  n  = 7;
  const Real dx = 0.1;
  const Real dy = 0.2;

  Laplacian L(k, m, n, dx, dy);
  sp_mat A = sp_mat(L);
  sp_mat A_orig = A;

  vec b((m + 2) * (n + 2), fill::ones);

  BC2D bc;
  bc.dc = {0.0, 0.0, 0.0, 0.0};
  bc.nc = {1.0, 1.0, 1.0, 1.0}; // Neumann everywhere
  bc.v.resize(4);

  // Zero flux on all edges.
  bc.v[0] = vec(n + 2, fill::zeros);
  bc.v[1] = vec(n + 2, fill::zeros);
  bc.v[2] = vec(m + 2, fill::zeros);
  bc.v[3] = vec(m + 2, fill::zeros);

  addScalarBC(A, b, k, m, dx, n, dy, bc);

  require_true(frob_diff(A, A_orig) > 0.0, "2D Neumann all: A did not change");
  require_true(vec_diff(b, vec((m + 2) * (n + 2), fill::ones)) > 0.0, "2D Neumann all: b did not change");

  cout << "  2D Neumann-all test passed" << endl;
}

/**
 * @brief 2D: Mixed BCs (Dirichlet on left/right, Neumann on bottom/top).
 *
 * Expectation:
 *  - A changes and b changes.
 *  - We do not assert exact rows/indices due to indexing and stencil variability.
 */
void test_2D_mixed() {
  cout << "Testing 2D mixed boundary conditions (Dirichlet left/right, Neumann bottom/top)..." << endl;

  const u16  k  = 2;
  const u32  m  = 10;
  const u32  n  = 10;
  const Real dx = 0.1;
  const Real dy = 0.1;

  Laplacian L(k, m, n, dx, dy);
  sp_mat A = sp_mat(L);
  sp_mat A_orig = A;

  vec b((m + 2) * (n + 2), fill::ones);

  BC2D bc;
  bc.dc = {1.0, 1.0, 0.0, 0.0};  // Dirichlet L/R
  bc.nc = {0.0, 0.0, 1.0, 1.0};  // Neumann B/T
  bc.v.resize(4);

  // Left/right use (n+2) entries; bottom/top use (m+2) entries.
  bc.v[0] = vec(n + 2, fill::value(1.0)); // Left: u = 1
  bc.v[1] = vec(n + 2, fill::value(0.0)); // Right: u = 0
  bc.v[2] = vec(m + 2, fill::zeros);      // Bottom: du/dn = 0
  bc.v[3] = vec(m + 2, fill::zeros);      // Top: du/dn = 0

  addScalarBC(A, b, k, m, dx, n, dy, bc);

  require_true(frob_diff(A, A_orig) > 0.0, "2D mixed: A did not change");
  require_true(vec_diff(b, vec((m + 2) * (n + 2), fill::ones)) > 0.0, "2D mixed: b did not change");

  cout << "  2D mixed BC test passed" << endl;
}

// ------------------------------ 3D TESTS ------------------------------

/**
 * @brief 3D: Dirichlet on all six faces.
 *
 * Assertions are coarse for the same reason as the 2D tests:
 * indexing and exact stencil coefficients are implementation details.
 */
void test_3D_dirichlet_all() {
  cout << "Testing 3D Dirichlet boundary conditions (all faces)..." << endl;

  const u16  k  = 2;
  const u32  m  = 6;
  const u32  n  = 6;
  const u32  o  = 6;
  const Real dx = 0.1;
  const Real dy = 0.1;
  const Real dz = 0.1;

  Laplacian L(k, m, n, o, dx, dy, dz);
  sp_mat A = sp_mat(L);
  sp_mat A_orig = A;

  vec b((m + 2) * (n + 2) * (o + 2), fill::ones);

  BC3D bc;
  bc.dc = {1.0, 1.0, 1.0, 1.0, 1.0, 1.0};
  bc.nc = {0.0, 0.0, 0.0, 0.0, 0.0, 0.0};
  bc.v.resize(6);

  // Face sizes (including ghost layers) for a (m+2)x(n+2)x(o+2) grid:
  //  - x-faces: (n+2)*(o+2)
  //  - y-faces: (m+2)*(o+2)
  //  - z-faces: (m+2)*(n+2)
  bc.v[0] = vec((n + 2) * (o + 2), fill::value(1.0)); // Left
  bc.v[1] = vec((n + 2) * (o + 2), fill::value(0.0)); // Right
  bc.v[2] = vec((m + 2) * (o + 2), fill::zeros);      // Bottom
  bc.v[3] = vec((m + 2) * (o + 2), fill::zeros);      // Top
  bc.v[4] = vec((m + 2) * (n + 2), fill::zeros);      // Front
  bc.v[5] = vec((m + 2) * (n + 2), fill::zeros);      // Back

  addScalarBC(A, b, k, m, dx, n, dy, o, dz, bc);

  require_true(frob_diff(A, A_orig) > 0.0, "3D Dirichlet all: A did not change");
  require_true(vec_diff(b, vec((m + 2) * (n + 2) * (o + 2), fill::ones)) > 0.0,
               "3D Dirichlet all: b did not change");

  cout << "  3D Dirichlet-all test passed" << endl;
}

/**
 * @brief 3D: Neumann on all six faces.
 */
void test_3D_neumann_all() {
  cout << "Testing 3D Neumann boundary conditions (all faces)..." << endl;

  const u16  k  = 2;
  const u32  m  = 6;
  const u32  n  = 6;
  const u32  o  = 6;
  const Real dx = 0.1;
  const Real dy = 0.1;
  const Real dz = 0.1;

  Laplacian L(k, m, n, o, dx, dy, dz);
  sp_mat A = sp_mat(L);
  sp_mat A_orig = A;

  vec b((m + 2) * (n + 2) * (o + 2), fill::ones);

  BC3D bc;
  bc.dc = {0.0, 0.0, 0.0, 0.0, 0.0, 0.0};
  bc.nc = {1.0, 1.0, 1.0, 1.0, 1.0, 1.0};
  bc.v.resize(6);

  // Zero flux on all faces.
  bc.v[0] = vec((n + 2) * (o + 2), fill::zeros);
  bc.v[1] = vec((n + 2) * (o + 2), fill::zeros);
  bc.v[2] = vec((m + 2) * (o + 2), fill::zeros);
  bc.v[3] = vec((m + 2) * (o + 2), fill::zeros);
  bc.v[4] = vec((m + 2) * (n + 2), fill::zeros);
  bc.v[5] = vec((m + 2) * (n + 2), fill::zeros);

  addScalarBC(A, b, k, m, dx, n, dy, o, dz, bc);

  require_true(frob_diff(A, A_orig) > 0.0, "3D Neumann all: A did not change");
  require_true(vec_diff(b, vec((m + 2) * (n + 2) * (o + 2), fill::ones)) > 0.0,
               "3D Neumann all: b did not change");

  cout << "  3D Neumann-all test passed" << endl;
}

/**
 * @brief 3D: Mixed BCs (Dirichlet on x-faces, Neumann on y- and z-faces).
 */
void test_3D_mixed() {
  cout << "Testing 3D mixed BC (Dirichlet on x-faces, Neumann on y/z-faces)..." << endl;

  const u16  k  = 2;
  const u32  m  = 6;
  const u32  n  = 6;
  const u32  o  = 6;
  const Real dx = 0.1;
  const Real dy = 0.1;
  const Real dz = 0.1;

  Laplacian L(k, m, n, o, dx, dy, dz);
  sp_mat A = sp_mat(L);
  sp_mat A_orig = A;

  vec b((m + 2) * (n + 2) * (o + 2), fill::ones);

  BC3D bc;
  bc.dc = {1.0, 1.0, 0.0, 0.0, 0.0, 0.0};  // Dirichlet on x faces
  bc.nc = {0.0, 0.0, 1.0, 1.0, 1.0, 1.0};  // Neumann on y/z faces
  bc.v.resize(6);

  bc.v[0] = vec((n + 2) * (o + 2), fill::value(1.0)); // Left (Dirichlet)
  bc.v[1] = vec((n + 2) * (o + 2), fill::value(2.0)); // Right (Dirichlet)
  bc.v[2] = vec((m + 2) * (o + 2), fill::zeros);      // Bottom (Neumann)
  bc.v[3] = vec((m + 2) * (o + 2), fill::zeros);      // Top (Neumann)
  bc.v[4] = vec((m + 2) * (n + 2), fill::zeros);      // Front (Neumann)
  bc.v[5] = vec((m + 2) * (n + 2), fill::zeros);      // Back (Neumann)

  addScalarBC(A, b, k, m, dx, n, dy, o, dz, bc);

  require_true(frob_diff(A, A_orig) > 0.0, "3D mixed: A did not change");
  require_true(vec_diff(b, vec((m + 2) * (n + 2) * (o + 2), fill::ones)) > 0.0,
               "3D mixed: b did not change");

  cout << "  3D mixed BC test passed" << endl;
}

// ------------------------------ PERIODIC TEST ------------------------------

/**
 * @brief 1D: "Do nothing" / periodic configuration.
 *
 * In this codebase, periodic BCs are represented by setting both dc and nc to zero,
 * which indicates that no boundary rows should be modified and RHS remains unchanged.
 *
 * Expectation:
 *  - A remains identical to the Laplacian operator.
 *  - b remains identical to its original content.
 */
void test_periodic_1D_do_nothing() {
  cout << "Testing periodic boundary conditions (do nothing case)..." << endl;

  const u16  k  = 2;
  const u32  m  = 10;
  const Real dx = 0.1;

  Laplacian L(k, m, dx);
  sp_mat A_orig = sp_mat(L);
  sp_mat A = A_orig;

  vec b_orig(m + 2, fill::ones);
  vec b = b_orig;

  BC1D bc;
  bc.dc = {0.0, 0.0};
  bc.nc = {0.0, 0.0};
  bc.v  = {0.0, 0.0};

  addScalarBC(A, b, k, m, dx, bc);

  const Real diff_A = frob_diff(A, A_orig);
  const Real diff_b = vec_diff(b, b_orig);

  require_true(diff_A < TOL, "Periodic 1D: A changed but should not");
  require_true(diff_b < TOL, "Periodic 1D: b changed but should not");

  cout << "  Periodic BC test passed" << endl;
}

// ------------------------------ MAIN ------------------------------

/**
 * @brief Entry point for the AddScalarBC test suite.
 *
 * Runs each test case and stops on the first failure (exception).
 * A green PASS banner indicates all tests completed successfully.
 */
int main() {
  cout << "\n=== AddScalarBC Test Suite ===\n" << endl;

  try {
    // 1D
    test_1D_dirichlet();
    test_1D_neumann();
    test_1D_mixed_dirichlet_neumann();
    test_1D_mixed_neumann_dirichlet();
    test_1D_robin();
    test_periodic_1D_do_nothing();

    // 2D
    test_2D_dirichlet_all();
    test_2D_neumann_all();
    test_2D_mixed();

    // 3D
    test_3D_dirichlet_all();
    test_3D_neumann_all();
    test_3D_mixed();

    cout << "\n\033[1;32mAll AddScalarBC Tests PASSED!\033[0m\n" << endl;
  } catch (const exception& e) {
    cout << "\n\033[1;31mTest FAILED with exception: " << e.what() << "\033[0m\n" << endl;
    return 1;
  }

  return 0;
}
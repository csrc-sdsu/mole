// Tests for the grid-based mimetic Laplacian operator.
//
// Nullity and energy tests follow the legacy Laplacian tests
// (tests/old_version/test3.cpp and test4.cpp); the remaining tests
// cover the periodic stencil layout and operator error handling.
#include "laplacian.h"
#include "mole_test.h"

#include <algorithm>
#include <vector>

// ------------------------------------------------------------------
// Helpers
// ------------------------------------------------------------------

namespace {

// Exposes the operator error codes (newest first) to the tests.
struct LaplacianProbe : Laplacian {
    using Laplacian::Laplacian;
    std::vector<int> codes() const {
        std::vector<int> v;
        stack<MOLE_Errors> s = o_errs;
        while (!s.empty()) {
            v.push_back(s.top().errCode);
            s.pop();
        }
        return v;
    }
    bool has(int code) const {
        for (int c : codes())
            if (c == code) return true;
        return false;
    }
    string topParam() const {
        return o_errs.empty() ? "" : o_errs.top().paramError;
    }
};

grid1D makeGrid1D(size_t m, Real dx, bool periodic = false) {
    gridParams1D p;
    p.topology = 'u';
    p.m = m;
    p.dx = dx;
    p.bc_isPeriodic = periodic;
    return grid1D(p);
}

grid2D makeGrid2D(size_t m, size_t n, Real dx, Real dy) {
    gridParams2D p;
    p.topology = 'u';
    p.m = m;
    p.n = n;
    p.dx = dx;
    p.dy = dy;
    return grid2D(p);
}

grid3D makeGrid3D(size_t m, size_t n, size_t o, Real dx, Real dy,
                  Real dz, bool xPer = false, bool zPer = false) {
    gridParams3D p;
    p.topology = 'u';
    p.m = m;
    p.n = n;
    p.o = o;
    p.dx = dx;
    p.dy = dy;
    p.dz = dz;
    p.bc_isPeriodic[0] = xPer;
    p.bc_isPeriodic[2] = zPer;
    return grid3D(p);
}

// A failed operator holds an empty (0 x 0) matrix.
bool isEmpty(const sp_mat &A) {
    return A.n_rows == 0 && A.n_cols == 0;
}

} // namespace

// ------------------------------------------------------------------
// Nullity (legacy): the Laplacian of a constant field is zero
// ------------------------------------------------------------------

TEST_CASE("Laplacian: nullity") {
    for (u16 k : {2, 4, 6, 8}) {
        const size_t m = 2 * k + 1;
        Laplacian L(k, makeGrid1D(m, 1.0));
        REQUIRE(!L.hasOpErrors());
        // Non-periodic Laplacian acts on m centers plus both boundaries.
        vec field(m + 2, fill::ones);
        vec sol = L.getMatrix() * field;
        CHECK_MSG(norm(sol) < 1e-10, "k = " << k);
    }
}

TEST_CASE("Laplacian: periodic nullity") {
    for (u16 k : {2, 4, 6, 8}) {
        const size_t m = 2 * k + 1;
        Laplacian L(k, makeGrid1D(m, 1.0, true));
        REQUIRE(!L.hasOpErrors());
        // Periodic Laplacian acts on the m centers.
        vec field(m, fill::ones);
        vec sol = L.getMatrix() * field;
        CHECK_MSG(norm(sol) < 1e-10, "k = " << k);
    }
}

// ------------------------------------------------------------------
// Energy (legacy): eigenvalues of H = -L/2 + x^2 are in the ratio
// 1 : 3 : 5 : 7 : 9
// ------------------------------------------------------------------

TEST_CASE("Laplacian: harmonic oscillator energy ratios") {
    const u16 k = 4;
    const size_t nodes = 500;
    vec x = linspace(-5.0, 5.0, nodes);
    const Real dx = x(1) - x(0);

    Laplacian L(k, makeGrid1D(nodes - 2, dx));
    REQUIRE(!L.hasOpErrors());

    std::transform(x.begin(), x.end(), x.begin(),
                   [](Real xi) { return xi * xi; });
    sp_mat V(nodes, nodes);
    V.diag(0) = x;

    sp_mat H = -0.5 * L.getMatrix() + V;

    cx_vec eigval;
    eig_gen(eigval, mat(H));
    eigval = sort(eigval);

    vec expected{1, 3, 5, 7, 9};
    for (size_t i = 0; i < expected.n_elem; ++i) {
        const Real ratio = std::real(eigval(i) / eigval(0));
        CHECK_MSG(std::norm(ratio - expected(i)) < 1e-10, "i = " << i);
    }
}

// ------------------------------------------------------------------
// Periodic stencil layout
// ------------------------------------------------------------------

// Row i of the 2nd-order periodic Laplacian is [1 -2 1] / dx^2 on
// centers i-1, i, i+1 (mod m). Nullity cannot catch a shifted
// circulant, since every row of one still sums to zero.
TEST_CASE("Laplacian: periodic k = 2 is the centered [1 -2 1] stencil") {
    const size_t m = 5;
    const Real dx = 0.5;
    Laplacian L(2, makeGrid1D(m, dx, true));
    REQUIRE(!L.hasOpErrors());
    const mat A(L.getMatrix());
    for (size_t i = 0; i < m; i++) {
        const size_t left = (i + m - 1) % m;
        const size_t right = (i + 1) % m;
        for (size_t j = 0; j < m; j++) {
            Real expected = 0.0;
            if (j == i) expected = -2.0 / (dx * dx);
            if (j == left || j == right) expected = 1.0 / (dx * dx);
            CHECK_MSG(std::abs(A(i, j) - expected) < 1e-12,
                      "i = " << i << ", j = " << j);
        }
    }
}

// ------------------------------------------------------------------
// Operator error handling
// ------------------------------------------------------------------

TEST_CASE("Laplacian: unsupported order k is rejected") {
    for (u16 k : {0, 1, 3, 5, 10}) {
        LaplacianProbe L(k, makeGrid1D(40, 0.025));
        CHECK_MSG(L.codes().size() == 1 &&
                      L.has(MOLE_ERR_OP_INVALID_ORDER),
                  "k = " << k);
        CHECK(isEmpty(L.getMatrix()));
    }
}

TEST_CASE("Laplacian: a valid non-uniform grid is rejected") {
    gridParams1D p;
    p.topology = 'n';
    p.m = 20;
    p.nodes_X = array1D(21);
    p.nodes_X.data_ = linspace(0.0, 1.0, 21);
    grid1D g(p);
    REQUIRE(!g.hasGridErrors());
    LaplacianProbe L(4, g);
    CHECK(L.codes().size() == 1);
    CHECK(L.has(MOLE_ERR_OP_UNSUPPORTED_TOPOLOGY));
    CHECK(isEmpty(L.getMatrix()));
}

TEST_CASE("Laplacian: fewer than 2k+1 cells is rejected, naming the axis") {
    // m = 2k is enough for Gradient but not for Laplacian
    LaplacianProbe L1(4, makeGrid1D(8, 0.1));
    CHECK(L1.codes().size() == 1 &&
          L1.has(MOLE_ERR_OP_LAP_INSUFFICIENT_CELLS));
    CHECK(L1.topParam() == "m = 8, requires >= 9 for k = 4");
    CHECK(isEmpty(L1.getMatrix()));

    LaplacianProbe L2(4, makeGrid2D(20, 8, 0.1, 0.1));
    CHECK(L2.codes().size() == 1 && L2.topParam().rfind("n = 8", 0) == 0);
    CHECK(isEmpty(L2.getMatrix()));

    // x and z periodic
    LaplacianProbe L3(4, makeGrid3D(20, 20, 8, 0.1, 0.1, 0.1, true, true));
    CHECK(L3.codes().size() == 1 && L3.topParam().rfind("o = 8", 0) == 0);
    CHECK(isEmpty(L3.getMatrix()));
}

TEST_CASE("Laplacian: a default-constructed operator reports not built") {
    LaplacianProbe L;
    CHECK(L.codes().size() == 1 && L.has(MOLE_ERR_OP_NOT_BUILT));
    CHECK(isEmpty(L.getMatrix()));
}

TEST_CASE("Laplacian: assigning a built operator clears the errors") {
    Laplacian L;
    L = Laplacian(2, makeGrid1D(10, 0.1));
    CHECK(!L.hasOpErrors());
    CHECK(L.getMatrix().n_rows == 12 && L.getMatrix().n_cols == 12);
}

MOLE_TEST_MAIN()

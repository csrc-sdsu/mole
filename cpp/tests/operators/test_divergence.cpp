// Tests for the grid-based mimetic Divergence operator.
//
// Nullity tests follow the legacy Divergence tests
// (tests/old_version/test3.cpp); the remaining tests cover the
// periodic stencil layout and operator error handling.
#include "divergence.h"
#include "mole_test.h"

#include <vector>

// ------------------------------------------------------------------
// Helpers
// ------------------------------------------------------------------

namespace {

// Exposes the operator error codes (newest first) to the tests.
struct DivergenceProbe : Divergence {
    using Divergence::Divergence;
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
// Nullity (legacy): the divergence of a constant field is zero
// ------------------------------------------------------------------

TEST_CASE("Divergence: nullity") {
    for (u16 k : {2, 4, 6, 8}) {
        const size_t m = 2 * k + 1;
        Divergence D(k, makeGrid1D(m, 1.0));
        REQUIRE(!D.hasOpErrors());
        // Non-periodic divergence acts on the m+1 faces.
        vec field(m + 1, fill::ones);
        vec sol = D.getMatrix() * field;
        CHECK_MSG(norm(sol) < 1e-10, "k = " << k);
    }
}

TEST_CASE("Divergence: periodic nullity") {
    for (u16 k : {2, 4, 6, 8}) {
        const size_t m = 2 * k + 1;
        Divergence D(k, makeGrid1D(m, 1.0, true));
        REQUIRE(!D.hasOpErrors());
        // Periodic divergence acts on the m faces.
        vec field(m, fill::ones);
        vec sol = D.getMatrix() * field;
        CHECK_MSG(norm(sol) < 1e-10, "k = " << k);
    }
}

// ------------------------------------------------------------------
// Periodic stencil layout
// ------------------------------------------------------------------

// Row i of the 2nd-order periodic divergence takes the faces on
// either side of center i: -1/dx on face i, +1/dx on face i+1 (mod m).
// Nullity cannot catch a shifted circulant, since every row of one
// still sums to zero.
TEST_CASE("Divergence: periodic k = 2 places the stencil on faces i and i+1") {
    const size_t m = 5;
    const Real dx = 0.5;
    Divergence D(2, makeGrid1D(m, dx, true));
    REQUIRE(!D.hasOpErrors());
    const mat A(D.getMatrix());
    for (size_t i = 0; i < m; i++) {
        const size_t right = (i + 1) % m;
        for (size_t j = 0; j < m; j++) {
            Real expected = 0.0;
            if (j == i) expected = -1.0 / dx;
            if (j == right) expected = 1.0 / dx;
            CHECK_MSG(A(i, j) == expected, "i = " << i << ", j = " << j);
        }
    }
}

// ------------------------------------------------------------------
// Operator error handling
// ------------------------------------------------------------------

TEST_CASE("Divergence: unsupported order k is rejected") {
    for (u16 k : {0, 1, 3, 5, 10}) {
        DivergenceProbe D(k, makeGrid1D(40, 0.025));
        CHECK_MSG(D.codes().size() == 1 &&
                      D.has(MOLE_ERR_OP_INVALID_ORDER),
                  "k = " << k);
        CHECK(isEmpty(D.getMatrix()));
    }
}

TEST_CASE("Divergence: a valid non-uniform grid is rejected") {
    gridParams1D p;
    p.topology = 'n';
    p.m = 20;
    p.nodes_X = array1D(21);
    p.nodes_X.data_ = linspace(0.0, 1.0, 21);
    grid1D g(p);
    REQUIRE(!g.hasGridErrors());
    DivergenceProbe D(4, g);
    CHECK(D.codes().size() == 1);
    CHECK(D.has(MOLE_ERR_OP_UNSUPPORTED_TOPOLOGY));
    CHECK(isEmpty(D.getMatrix()));
}

TEST_CASE("Divergence: fewer than 2k+1 cells is rejected, naming the axis") {
    // m = 2k is enough for Gradient but not for Divergence
    DivergenceProbe D1(4, makeGrid1D(8, 0.1));
    CHECK(D1.codes().size() == 1 &&
          D1.has(MOLE_ERR_OP_DIV_INSUFFICIENT_CELLS));
    CHECK(D1.topParam() == "m = 8, requires >= 9 for k = 4");
    CHECK(isEmpty(D1.getMatrix()));

    DivergenceProbe D2(4, makeGrid2D(20, 8, 0.1, 0.1));
    CHECK(D2.codes().size() == 1 && D2.topParam().rfind("n = 8", 0) == 0);
    CHECK(isEmpty(D2.getMatrix()));

    // x and z periodic
    DivergenceProbe D3(4, makeGrid3D(20, 20, 8, 0.1, 0.1, 0.1, true, true));
    CHECK(D3.codes().size() == 1 && D3.topParam().rfind("o = 8", 0) == 0);
    CHECK(isEmpty(D3.getMatrix()));
}

TEST_CASE("Divergence: a default-constructed operator reports not built") {
    DivergenceProbe D;
    CHECK(D.codes().size() == 1 && D.has(MOLE_ERR_OP_NOT_BUILT));
    CHECK(isEmpty(D.getMatrix()));
}

TEST_CASE("Divergence: assigning a built operator clears the errors") {
    Divergence D;
    D = Divergence(2, makeGrid1D(10, 0.1));
    CHECK(!D.hasOpErrors());
    CHECK(D.getMatrix().n_rows == 12 && D.getMatrix().n_cols == 11);
}

MOLE_TEST_MAIN()

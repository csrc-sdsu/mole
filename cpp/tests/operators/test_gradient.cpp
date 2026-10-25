// Tests for the grid-based mimetic Gradient operator.
//
// Nullity tests follow the legacy Gradient tests
// (tests/old_version/test2.cpp); the remaining tests cover operator
// error handling.
#include "gradient.h"
#include "mole_test.h"

#include <vector>

// ------------------------------------------------------------------
// Helpers
// ------------------------------------------------------------------

namespace {

// Exposes the operator error codes (newest first) to the tests.
struct GradientProbe : Gradient {
    using Gradient::Gradient;
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
// Nullity (legacy): the gradient of a constant field is zero
// ------------------------------------------------------------------

TEST_CASE("Gradient: nullity") {
    for (u16 k : {2, 4, 6, 8}) {
        const size_t m = 2 * k + 1;
        Gradient G(k, makeGrid1D(m, 1.0));
        REQUIRE(!G.hasOpErrors());
        vec field(m + 2, fill::ones);
        vec sol = G.getMatrix() * field;
        CHECK_MSG(norm(sol) < 1e-10, "k = " << k);
    }
}

TEST_CASE("Gradient: periodic nullity") {
    for (u16 k : {2, 4, 6, 8}) {
        const size_t m = 2 * k + 1;
        Gradient G(k, makeGrid1D(m, 1.0, true));
        REQUIRE(!G.hasOpErrors());
        // Periodic gradient acts on the m interior centers.
        vec field(m, fill::ones);
        vec sol = G.getMatrix() * field;
        CHECK_MSG(norm(sol) < 1e-10, "k = " << k);
    }
}

// ------------------------------------------------------------------
// Operator error handling
// ------------------------------------------------------------------

TEST_CASE("Gradient: unsupported order k is rejected") {
    for (u16 k : {0, 1, 3, 5, 10}) {
        GradientProbe G(k, makeGrid1D(40, 0.025));
        CHECK_MSG(G.codes().size() == 1 &&
                      G.has(MOLE_ERR_OP_INVALID_ORDER),
                  "k = " << k);
        CHECK(isEmpty(G.getMatrix()));
    }
}

TEST_CASE("Gradient: a valid non-uniform grid is rejected") {
    gridParams1D p;
    p.topology = 'n';
    p.m = 20;
    p.nodes_X = array1D(21);
    p.nodes_X.data_ = linspace(0.0, 1.0, 21);
    grid1D g(p);
    REQUIRE(!g.hasGridErrors());
    GradientProbe G(4, g);
    CHECK(G.codes().size() == 1);
    CHECK(G.has(MOLE_ERR_OP_UNSUPPORTED_TOPOLOGY));
    CHECK(isEmpty(G.getMatrix()));
}

TEST_CASE("Gradient: fewer than 2k cells is rejected, naming the axis") {
    GradientProbe G1(4, makeGrid1D(6, 0.1));
    CHECK(G1.codes().size() == 1 &&
          G1.has(MOLE_ERR_OP_INSUFFICIENT_CELLS));
    CHECK(G1.topParam() == "m = 6, requires >= 8 for k = 4");
    CHECK(isEmpty(G1.getMatrix()));

    GradientProbe G2(4, makeGrid2D(20, 6, 0.1, 0.1));
    CHECK(G2.codes().size() == 1 && G2.topParam().rfind("n = 6", 0) == 0);
    CHECK(isEmpty(G2.getMatrix()));

    // x and z periodic
    GradientProbe G3(4, makeGrid3D(20, 20, 7, 0.1, 0.1, 0.1, true, true));
    CHECK(G3.codes().size() == 1 && G3.topParam().rfind("o = 7", 0) == 0);
    CHECK(isEmpty(G3.getMatrix()));
}

TEST_CASE("Gradient: a default-constructed operator reports not built") {
    GradientProbe G;
    CHECK(G.codes().size() == 1 && G.has(MOLE_ERR_OP_NOT_BUILT));
    CHECK(isEmpty(G.getMatrix()));
}

TEST_CASE("Gradient: assigning a built operator clears the errors") {
    Gradient G;
    G = Gradient(2, makeGrid1D(10, 0.1));
    CHECK(!G.hasOpErrors());
    CHECK(G.getMatrix().n_rows == 11 && G.getMatrix().n_cols == 12);
}

MOLE_TEST_MAIN()

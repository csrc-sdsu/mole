// Regression tests for utils/utils.cpp.
//
// Every Utils function logs onto an error stack owned by the caller,
// so each test creates its own stack and checks it after the call.
#include "utils.h"
#include "mole_test.h"
#include <cmath>

// ------------------------------------------------------------------
// trapz
// ------------------------------------------------------------------

TEST_CASE("Utils::trapz integrates a known linear function exactly") {
    // y = x on [0,4], exact area = 0.5*4*4 = 8
    std::stack<MOLE_Errors> errs;
    MOLEerr_init(errs);
    arma::vec x = {0.0, 1.0, 2.0, 3.0, 4.0};
    arma::vec y = {0.0, 1.0, 2.0, 3.0, 4.0};
    double area = Utils::trapz(errs, x, y);
    CHECK_MSG(std::fabs(area - 8.0) < 1e-9, "got area = " << area);
    CHECK(!MOLEerr_haserrors(errs));
}

TEST_CASE("Utils::trapz integrates a constant function") {
    // y = 2 on [0,3], exact area = 6
    std::stack<MOLE_Errors> errs;
    MOLEerr_init(errs);
    arma::vec x = {0.0, 1.0, 2.0, 3.0};
    arma::vec y = {2.0, 2.0, 2.0, 2.0};
    double area = Utils::trapz(errs, x, y);
    CHECK_MSG(std::fabs(area - 6.0) < 1e-9, "got area = " << area);
    CHECK(!MOLEerr_haserrors(errs));
}

TEST_CASE("Utils::trapz on mismatched sizes returns NaN and logs 501") {
    std::stack<MOLE_Errors> errs;
    MOLEerr_init(errs);
    arma::vec x = {0.0, 1.0, 2.0};
    arma::vec y = {0.0, 1.0};
    double result = Utils::trapz(errs, x, y);
    CHECK(std::isnan(result));
    CHECK(MOLEerr_contains(errs, MOLE_ERR_UTILS_SIZE_MISMATCH));
}

TEST_CASE("Utils::trapz on a single point returns NaN and logs 507") {
    std::stack<MOLE_Errors> errs;
    MOLEerr_init(errs);
    arma::vec x = {1.0};
    arma::vec y = {1.0};
    double result = Utils::trapz(errs, x, y);
    CHECK(std::isnan(result));
    CHECK(MOLEerr_contains(errs, MOLE_ERR_UTILS_TOO_FEW_POINTS));
}

TEST_CASE("Utils::trapz on empty inputs returns NaN and logs 507") {
    std::stack<MOLE_Errors> errs;
    MOLEerr_init(errs);
    arma::vec x;
    arma::vec y;
    double result = Utils::trapz(errs, x, y);
    CHECK(std::isnan(result));
    CHECK(MOLEerr_contains(errs, MOLE_ERR_UTILS_TOO_FEW_POINTS));
}

// ------------------------------------------------------------------
// spkron
// ------------------------------------------------------------------

TEST_CASE("Utils::spkron matches the dense Kronecker product") {
    std::stack<MOLE_Errors> errs;
    MOLEerr_init(errs);
    arma::mat Ad = {{1.0, 2.0}, {0.0, 3.0}};
    arma::mat Bd = {{0.0, 4.0, 5.0}, {6.0, 0.0, 7.0}};
    arma::sp_mat A(Ad);
    arma::sp_mat B(Bd);
    arma::sp_mat K = Utils::spkron(errs, A, B);
    REQUIRE(K.n_rows == 4 && K.n_cols == 6);
    CHECK(arma::approx_equal(arma::mat(K), arma::kron(Ad, Bd),
                             "absdiff", 1e-12));
    CHECK(!MOLEerr_haserrors(errs));
}

// ------------------------------------------------------------------
// spjoin_rows / spjoin_cols
// ------------------------------------------------------------------

TEST_CASE("Utils::spjoin_rows matches [A B]") {
    std::stack<MOLE_Errors> errs;
    MOLEerr_init(errs);
    arma::mat Ad = {{1.0, 0.0}, {0.0, 2.0}};
    arma::mat Bd(2, 1);
    Bd(0, 0) = 3.0;
    Bd(1, 0) = 4.0;
    arma::sp_mat J = Utils::spjoin_rows(errs, arma::sp_mat(Ad),
                                        arma::sp_mat(Bd));
    REQUIRE(J.n_rows == 2 && J.n_cols == 3);
    CHECK(arma::approx_equal(arma::mat(J), arma::join_rows(Ad, Bd),
                             "absdiff", 1e-12));
    CHECK(!MOLEerr_haserrors(errs));
}

TEST_CASE("Utils::spjoin_rows on differing rows returns empty, logs 502") {
    std::stack<MOLE_Errors> errs;
    MOLEerr_init(errs);
    arma::sp_mat A = arma::speye<arma::sp_mat>(2, 2);
    arma::sp_mat B = arma::speye<arma::sp_mat>(3, 3);
    arma::sp_mat J = Utils::spjoin_rows(errs, A, B);
    CHECK(J.n_elem == 0);
    CHECK(MOLEerr_contains(errs, MOLE_ERR_UTILS_ROW_MISMATCH));
}

TEST_CASE("Utils::spjoin_cols matches [A; B]") {
    std::stack<MOLE_Errors> errs;
    MOLEerr_init(errs);
    arma::mat Ad = {{1.0, 0.0}, {0.0, 2.0}};
    arma::mat Bd = {{3.0, 4.0}};
    arma::sp_mat J = Utils::spjoin_cols(errs, arma::sp_mat(Ad),
                                        arma::sp_mat(Bd));
    REQUIRE(J.n_rows == 3 && J.n_cols == 2);
    CHECK(arma::approx_equal(arma::mat(J), arma::join_cols(Ad, Bd),
                             "absdiff", 1e-12));
    CHECK(!MOLEerr_haserrors(errs));
}

TEST_CASE("Utils::spjoin_cols on differing cols returns empty, logs 503") {
    std::stack<MOLE_Errors> errs;
    MOLEerr_init(errs);
    arma::sp_mat A = arma::speye<arma::sp_mat>(2, 2);
    arma::sp_mat B = arma::speye<arma::sp_mat>(2, 3);
    arma::sp_mat J = Utils::spjoin_cols(errs, A, B);
    CHECK(J.n_elem == 0);
    CHECK(MOLEerr_contains(errs, MOLE_ERR_UTILS_COL_MISMATCH));
}

// ------------------------------------------------------------------
// mesh2Dgrid / mesh3Dgrid
// ------------------------------------------------------------------

TEST_CASE("Utils::mesh2Dgrid builds length(y) x length(x) coordinates") {
    std::stack<MOLE_Errors> errs;
    MOLEerr_init(errs);
    arma::vec x = {0.0, 1.0, 2.0};
    arma::vec y = {10.0, 20.0};
    arma::mat X, Y;
    Utils::mesh2Dgrid(errs, x, y, X, Y);
    REQUIRE(X.n_rows == 2 && X.n_cols == 3);
    REQUIRE(Y.n_rows == 2 && Y.n_cols == 3);
    CHECK(X(1, 2) == 2.0);
    CHECK(Y(1, 2) == 20.0);
    CHECK(!MOLEerr_haserrors(errs));
}

TEST_CASE("Utils::mesh2Dgrid on empty x logs 500 and leaves X, Y empty") {
    std::stack<MOLE_Errors> errs;
    MOLEerr_init(errs);
    arma::vec x;
    arma::vec y = {1.0, 2.0};
    arma::mat X, Y;
    Utils::mesh2Dgrid(errs, x, y, X, Y);
    CHECK(X.n_elem == 0 && Y.n_elem == 0);
    CHECK(MOLEerr_contains(errs, MOLE_ERR_UTILS_INVALID_MESH_SIZE));
}

TEST_CASE("Utils::mesh3Dgrid builds coordinates for each axis") {
    std::stack<MOLE_Errors> errs;
    MOLEerr_init(errs);
    arma::vec x = {0.0, 1.0};
    arma::vec y = {10.0, 20.0, 30.0};
    arma::vec z = {100.0, 200.0};
    arma::cube X, Y, Z;
    Utils::mesh3Dgrid(errs, x, y, z, X, Y, Z);
    REQUIRE(X.n_rows == 2 && X.n_cols == 3 && X.n_slices == 2);
    CHECK(X(1, 2, 1) == 1.0);
    CHECK(Y(1, 2, 1) == 30.0);
    CHECK(Z(1, 2, 1) == 200.0);
    CHECK(!MOLEerr_haserrors(errs));
}

TEST_CASE("Utils::mesh3Dgrid on empty z logs 500 and leaves X, Y, Z empty") {
    std::stack<MOLE_Errors> errs;
    MOLEerr_init(errs);
    arma::vec x = {0.0, 1.0};
    arma::vec y = {0.0, 1.0};
    arma::vec z;
    arma::cube X, Y, Z;
    Utils::mesh3Dgrid(errs, x, y, z, X, Y, Z);
    CHECK(X.n_elem == 0 && Y.n_elem == 0 && Z.n_elem == 0);
    CHECK(MOLEerr_contains(errs, MOLE_ERR_UTILS_INVALID_MESH_SIZE));
}

// ------------------------------------------------------------------
// spsolve_eigen (only built when EIGEN is defined)
// ------------------------------------------------------------------

#ifdef EIGEN
TEST_CASE("Utils::spsolve_eigen solves a small system") {
    std::stack<MOLE_Errors> errs;
    MOLEerr_init(errs);
    arma::mat Ad = {{4.0, 1.0}, {1.0, 3.0}};
    arma::vec b = {1.0, 2.0};
    arma::vec x = Utils::spsolve_eigen(errs, arma::sp_mat(Ad), b);
    REQUIRE(x.n_elem == 2);
    CHECK(arma::norm(Ad * x - b) < 1e-12);
    CHECK(!MOLEerr_haserrors(errs));
}

TEST_CASE("Utils::spsolve_eigen on a non-square A logs 504") {
    std::stack<MOLE_Errors> errs;
    MOLEerr_init(errs);
    arma::sp_mat A = arma::speye<arma::sp_mat>(2, 3);
    arma::vec b = {1.0, 2.0};
    arma::vec x = Utils::spsolve_eigen(errs, A, b);
    CHECK(x.n_elem == 0);
    CHECK(MOLEerr_contains(errs, MOLE_ERR_UTILS_NOT_SQUARE));
}

TEST_CASE("Utils::spsolve_eigen on A, b row mismatch logs 505") {
    std::stack<MOLE_Errors> errs;
    MOLEerr_init(errs);
    arma::sp_mat A = arma::speye<arma::sp_mat>(3, 3);
    arma::vec b = {1.0, 2.0};
    arma::vec x = Utils::spsolve_eigen(errs, A, b);
    CHECK(x.n_elem == 0);
    CHECK(MOLEerr_contains(errs, MOLE_ERR_UTILS_RHS_ROW_MISMATCH));
}

TEST_CASE("Utils::spsolve_eigen on a singular A logs 506") {
    std::stack<MOLE_Errors> errs;
    MOLEerr_init(errs);
    arma::mat Ad = {{1.0, 2.0}, {2.0, 4.0}};
    arma::vec b = {1.0, 2.0};
    arma::vec x = Utils::spsolve_eigen(errs, arma::sp_mat(Ad), b);
    CHECK(x.n_elem == 0);
    CHECK(MOLEerr_contains(errs, MOLE_ERR_UTILS_SINGULAR_MATRIX));
}
#endif

MOLE_TEST_MAIN()

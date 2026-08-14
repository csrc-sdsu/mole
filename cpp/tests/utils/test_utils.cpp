// Regression tests for utils/utils.cpp.
#include "utils.h"
#include "mole_test.h"
#include <cmath>

TEST_CASE("Utils::trapz integrates a known linear function exactly") {
    // y = x on [0,4], exact area = 0.5*4*4 = 8
    arma::vec x = {0.0, 1.0, 2.0, 3.0, 4.0};
    arma::vec y = {0.0, 1.0, 2.0, 3.0, 4.0};
    Utils u;
    double area = u.trapz(x, y);
    CHECK_MSG(std::fabs(area - 8.0) < 1e-9, "got area = " << area);
    CHECK(!u.hasErrors());
}

TEST_CASE("Utils::trapz integrates a constant function") {
    // y = 2 on [0,3], exact area = 6
    arma::vec x = {0.0, 1.0, 2.0, 3.0};
    arma::vec y = {2.0, 2.0, 2.0, 2.0};
    Utils u;
    double area = u.trapz(x, y);
    CHECK_MSG(std::fabs(area - 6.0) < 1e-9, "got area = " << area);
}

TEST_CASE("Utils::trapz on mismatched sizes returns NaN and logs an error") {
    arma::vec x = {0.0, 1.0, 2.0};
    arma::vec y = {0.0, 1.0};
    Utils u;
    double result = u.trapz(x, y);
    CHECK(std::isnan(result));
    CHECK(u.hasErrors());
}

MOLE_TEST_MAIN()

/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * © 2008-2024 San Diego State University Research Foundation (SDSURF).
 * See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
 */

/*
 * @file test_spacing_validation.cpp
 *
 * @brief Verifies that every operator entry point rejects malformed cell
 *        spacings (zero, negative, NaN, Inf) with std::invalid_argument.
 *
 * Covers finding H2 in the June 2026 codebase security audit.
 */

#include "mole.h"
#include <gtest/gtest.h>

#include <cmath>
#include <limits>
#include <stdexcept>
#include <string>
#include <vector>

namespace {

constexpr Real INF_D = std::numeric_limits<Real>::infinity();
const Real     NAN_D = std::numeric_limits<Real>::quiet_NaN();

} // namespace

// ---------------------------------------------------------------------------
// Gradient
// ---------------------------------------------------------------------------

TEST(SpacingValidation, GradientRejectsZero) {
    EXPECT_THROW(Gradient(2, 10, 0.0), std::invalid_argument);
}

TEST(SpacingValidation, GradientRejectsNegative) {
    EXPECT_THROW(Gradient(2, 10, -1.0), std::invalid_argument);
}

TEST(SpacingValidation, GradientRejectsNaN) {
    EXPECT_THROW(Gradient(2, 10, NAN_D), std::invalid_argument);
}

TEST(SpacingValidation, GradientRejectsInf) {
    EXPECT_THROW(Gradient(2, 10, INF_D), std::invalid_argument);
}

TEST(SpacingValidation, Gradient2DRejectsZeroDy) {
    EXPECT_THROW(Gradient(2, 10, 10, 0.1, 0.0), std::invalid_argument);
}

TEST(SpacingValidation, Gradient3DRejectsNegativeDz) {
    EXPECT_THROW(Gradient(2, 10, 10, 10, 0.1, 0.1, -0.1),
                 std::invalid_argument);
}

// ---------------------------------------------------------------------------
// Divergence
// ---------------------------------------------------------------------------

TEST(SpacingValidation, DivergenceRejectsZero) {
    EXPECT_THROW(Divergence(2, 10, 0.0), std::invalid_argument);
}

TEST(SpacingValidation, Divergence3DRejectsInfDz) {
    EXPECT_THROW(Divergence(2, 10, 10, 10, 0.1, 0.1, INF_D),
                 std::invalid_argument);
}

// ---------------------------------------------------------------------------
// Laplacian
// ---------------------------------------------------------------------------

TEST(SpacingValidation, LaplacianRejectsZeroDz) {
    EXPECT_THROW(Laplacian(2, 10, 10, 10, 0.1, 0.1, 0.0),
                 std::invalid_argument);
}

// ---------------------------------------------------------------------------
// RobinBC
// ---------------------------------------------------------------------------

TEST(SpacingValidation, RobinBCRejectsZero) {
    EXPECT_THROW(RobinBC(2, 10, 0.0, 1.0, 1.0), std::invalid_argument);
}

// ---------------------------------------------------------------------------
// MixedBC
// ---------------------------------------------------------------------------

TEST(SpacingValidation, MixedBCRejectsNegative) {
    std::vector<Real> cl = {1.0};
    std::vector<Real> cr = {1.0};
    EXPECT_THROW(MixedBC(2, 10, -0.1, "Dirichlet", cl, "Dirichlet", cr),
                 std::invalid_argument);
}

// ---------------------------------------------------------------------------
// AddScalarBC (free function)
// ---------------------------------------------------------------------------

TEST(SpacingValidation, AddScalarBCRejectsZero) {
    sp_mat A(12, 12);        // (m+2) x (m+2) for m = 10
    vec    b(12, fill::zeros);
    AddScalarBC::BC1D bc;    // defaults are safe; dx check fires first
    EXPECT_THROW(AddScalarBC::addScalarBC(A, b, 2, 10, 0.0, bc),
                 std::invalid_argument);
}

// ---------------------------------------------------------------------------
// Positive sanity check
// ---------------------------------------------------------------------------

TEST(SpacingValidation, GradientAcceptsValidSpacing) {
    EXPECT_NO_THROW(Gradient(2, 10, 0.1));
}

TEST(SpacingValidation, Laplacian3DAcceptsValidSpacing) {
    EXPECT_NO_THROW(Laplacian(2, 10, 10, 10, 0.1, 0.1, 0.1));
}

// ---------------------------------------------------------------------------
// Error-message content
// ---------------------------------------------------------------------------

TEST(SpacingValidation, ErrorMessageNamesTheParameter) {
    try {
        Gradient G(2, 10, 0.0);
        FAIL() << "expected std::invalid_argument";
    } catch (const std::invalid_argument& e) {
        const std::string msg(e.what());
        EXPECT_NE(msg.find("dx"), std::string::npos)
            << "expected the message to mention the parameter name, got: "
            << msg;
    }
}

int main(int argc, char **argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}

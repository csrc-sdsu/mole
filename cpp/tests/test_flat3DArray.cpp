/*
 * Regression tests for flat3DArray (src/include/flat3DArray.h,
 * src/grids/flat3DArray.cpp).
 */
#include "mini_test.h"
#include "flat3DArray.h"
#include <cmath>

TEST(flat3D_default_ctor_is_empty) {
    flat3DArray A;
    CHECK_EQ(A.dim1(), 0u);
    CHECK_EQ(A.dim2(), 0u);
    CHECK_EQ(A.dim3(), 0u);
    CHECK_TRUE(A.empty());
}

TEST(flat3D_sized_ctor_fills_value) {
    flat3DArray A(2, 3, 4, 5.0);
    CHECK_EQ(A.dim1(), 2u);
    CHECK_EQ(A.dim2(), 3u);
    CHECK_EQ(A.dim3(), 4u);
    CHECK_EQ(A.size(), 24u);
    CHECK_FALSE(A.empty());
    for (size_t i = 0; i < A.dim1(); ++i)
        for (size_t j = 0; j < A.dim2(); ++j)
            for (size_t k = 0; k < A.dim3(); ++k)
                CHECK_NEAR(A(i, j, k), 5.0, 1e-12);
}

TEST(flat3D_default_fill_is_zero) {
    flat3DArray A(2, 2, 2);
    CHECK_NEAR(A(0, 0, 0), 0.0, 1e-12);
    CHECK_NEAR(A(1, 1, 1), 0.0, 1e-12);
}

TEST(flat3D_layout_matches_index_formula) {
    // data[(i*dim2+j)*dim3+k]
    flat3DArray A(2, 2, 2, 0.0);
    int counter = 0;
    for (size_t i = 0; i < 2; ++i)
        for (size_t j = 0; j < 2; ++j)
            for (size_t k = 0; k < 2; ++k)
                A(i, j, k) = static_cast<Real>(counter++);
    const Real* d = A.data();
    for (int idx = 0; idx < 8; ++idx)
        CHECK_NEAR(d[idx], static_cast<Real>(idx), 1e-12);
}

TEST(flat3D_write_then_read) {
    flat3DArray A(3, 3, 3, 0.0);
    A(1, 2, 0) = 42.0;
    CHECK_NEAR(A(1, 2, 0), 42.0, 1e-12);
    CHECK_NEAR(A(0, 0, 0), 0.0, 1e-12);
}

TEST(flat3D_const_access) {
    const flat3DArray A(2, 2, 2, 8.0);
    CHECK_NEAR(A(0, 0, 0), 8.0, 1e-12);
    CHECK_NEAR(A(1, 1, 1), 8.0, 1e-12);
}

TEST(flat3D_invalid_index_logs_error_and_returns_nan) {
    flat3DArray A(2, 2, 2, 0.0);
    CHECK_FALSE(A.hasArr3DErrors());
    Real v = A(9, 9, 9);
    CHECK_TRUE(std::isnan(v));
    CHECK_TRUE(A.hasArr3DErrors());
}

TEST(flat3D_const_invalid_index_logs_error_and_returns_nan) {
    const flat3DArray A(2, 2, 2, 0.0);
    Real v = A(9, 9, 9);
    CHECK_TRUE(std::isnan(v));
    CHECK_TRUE(A.hasArr3DErrors());
}

// Unlike flat2DArray, flat3DArray::operator()'s invalid-index branch
// uses `static thread_local Real dnan; dnan = nan("");` -- reassigned
// on every call rather than initialized once. This test confirms that
// writing through an out-of-bounds reference does NOT leak into other
// out-of-bounds accesses (this one is expected to PASS, unlike the
// flat2DArray analogue).
TEST(flat3D_invalid_index_sentinel_is_not_corruptible) {
    flat3DArray A(2, 2, 2, 0.0);
    flat3DArray B(2, 2, 2, 0.0);

    A(50, 50, 50) = 123.0;

    Real again_from_A = A(50, 50, 50);
    Real from_unrelated_B = B(50, 50, 50);

    CHECK_TRUE(std::isnan(again_from_A));
    CHECK_TRUE(std::isnan(from_unrelated_B));
}

TEST(flat3D_equality_same_dims_same_data) {
    flat3DArray A(2, 2, 2, 1.0);
    flat3DArray B(2, 2, 2, 1.0);
    CHECK_TRUE(A == B);
    CHECK_FALSE(A != B);
}

TEST(flat3D_equality_different_data) {
    flat3DArray A(2, 2, 2, 1.0);
    flat3DArray B(2, 2, 2, 1.0);
    B(0, 0, 0) = 2.0;
    CHECK_FALSE(A == B);
    CHECK_TRUE(A != B);
}

TEST(flat3D_equality_different_dims) {
    flat3DArray A(2, 2, 2, 1.0);
    flat3DArray B(2, 2, 3, 1.0);
    CHECK_FALSE(A == B);
    CHECK_TRUE(A != B);
}

TEST(flat3D_resize_changes_dims_and_fills) {
    flat3DArray A(2, 2, 2, 1.0);
    A.resize(3, 4, 5, 9.0);
    CHECK_EQ(A.dim1(), 3u);
    CHECK_EQ(A.dim2(), 4u);
    CHECK_EQ(A.dim3(), 5u);
    CHECK_EQ(A.size(), 60u);
    for (size_t i = 0; i < A.dim1(); ++i)
        for (size_t j = 0; j < A.dim2(); ++j)
            for (size_t k = 0; k < A.dim3(); ++k)
                CHECK_NEAR(A(i, j, k), 9.0, 1e-12);
}

TEST(flat3D_resize_to_zero_is_empty) {
    flat3DArray A(2, 2, 2, 1.0);
    A.resize(0, 0, 0);
    CHECK_TRUE(A.empty());
    CHECK_EQ(A.size(), 0u);
}

TEST(flat3D_plane_access_valid) {
    flat3DArray A(2, 2, 2, 0.0);
    A(1, 0, 0) = 1; A(1, 0, 1) = 2; A(1, 1, 0) = 3; A(1, 1, 1) = 4;
    Real* p = A.plane(1);
    CHECK_TRUE(p != nullptr);
    CHECK_NEAR(p[0], 1, 1e-12);
    CHECK_NEAR(p[1], 2, 1e-12);
    CHECK_NEAR(p[2], 3, 1e-12);
    CHECK_NEAR(p[3], 4, 1e-12);
    CHECK_EQ(A.planeStride(), 4u);
}

TEST(flat3D_plane_access_invalid_returns_nullptr) {
    flat3DArray A(2, 2, 2, 0.0);
    Real* p = A.plane(9);
    CHECK_TRUE(p == nullptr);
    CHECK_TRUE(A.hasArr3DErrors());
}

TEST(flat3D_row_access_valid) {
    flat3DArray A(2, 2, 3, 0.0);
    A(0, 1, 0) = 7; A(0, 1, 1) = 8; A(0, 1, 2) = 9;
    Real* r = A.row(0, 1);
    CHECK_TRUE(r != nullptr);
    CHECK_NEAR(r[0], 7, 1e-12);
    CHECK_NEAR(r[1], 8, 1e-12);
    CHECK_NEAR(r[2], 9, 1e-12);
    CHECK_EQ(A.rowStride(), 3u);
    CHECK_EQ(A.rowLength(), 3u);
}

TEST(flat3D_row_access_const_valid) {
    const flat3DArray A(2, 2, 2, 6.0);
    const Real* r = A.row(0, 0);
    CHECK_TRUE(r != nullptr);
    CHECK_NEAR(r[0], 6.0, 1e-12);
}

TEST(flat3D_row_access_invalid_returns_nullptr) {
    flat3DArray A(2, 2, 2, 0.0);
    Real* r = A.row(9, 9);
    CHECK_TRUE(r == nullptr);
    CHECK_TRUE(A.hasArr3DErrors());
}

// flat3DArray's constructor and resize() are now both guarded against
// dim1*dim2*dim3 overflowing size_t, the same way flat2DArray's are.
// On overflow, MOLE_ERR_ARRAY_SIZE_OVERFLOW is logged instead of
// silently wrapping to a mismatched internal state.
TEST(flat3D_ctor_overflow_is_rejected_and_left_empty) {
    // 2^22 * 2^22 * 2^22 = 2^66, wraps to 0 on 64-bit size_t.
    size_t d = 4194304ULL; // 2^22
    flat3DArray A(d, d, d, 5.0);
    CHECK_TRUE(A.hasArr3DErrors());
    CHECK_EQ(A.dim1(), 0u);
    CHECK_EQ(A.dim2(), 0u);
    CHECK_EQ(A.dim3(), 0u);
    CHECK_TRUE(A.empty());
}

TEST(flat3D_ctor_zero_dims_is_valid_not_an_overflow) {
    flat3DArray A(0, 5, 5, 1.0);
    CHECK_FALSE(A.hasArr3DErrors());
    CHECK_EQ(A.dim1(), 0u);
    CHECK_TRUE(A.empty());
}

TEST(flat3D_resize_overflow_is_rejected_and_unchanged) {
    flat3DArray A(2, 2, 2, 1.0);
    CHECK_FALSE(A.hasArr3DErrors());
    size_t d = 4194304ULL; // 2^22; d^3 wraps to 0 on 64-bit size_t
    A.resize(d, d, d, 0.0);
    CHECK_TRUE(A.hasArr3DErrors());
    // Array should be left as it was before the rejected resize.
    CHECK_EQ(A.dim1(), 2u);
    CHECK_EQ(A.dim2(), 2u);
    CHECK_EQ(A.dim3(), 2u);
}

/*
 * Regression tests for flat2DArray (src/include/flat2DArray.h,
 * src/grids/flat2DArray.cpp).
 */
#include "mini_test.h"
#include "flat2DArray.h"
#include <cmath>

// ---------------------------------------------------------------
// Construction / basic properties
// ---------------------------------------------------------------

TEST(flat2D_default_ctor_is_empty) {
    flat2DArray A;
    CHECK_EQ(A.rows(), 0u);
    CHECK_EQ(A.cols(), 0u);
    CHECK_EQ(A.size(), 0u);
    CHECK_TRUE(A.empty());
}

TEST(flat2D_sized_ctor_fills_value) {
    flat2DArray A(3, 4, 7.5);
    CHECK_EQ(A.rows(), 3u);
    CHECK_EQ(A.cols(), 4u);
    CHECK_EQ(A.size(), 12u);
    CHECK_FALSE(A.empty());
    for (size_t i = 0; i < A.rows(); ++i)
        for (size_t j = 0; j < A.cols(); ++j)
            CHECK_NEAR(A(i, j), 7.5, 1e-12);
}

TEST(flat2D_default_fill_is_zero) {
    flat2DArray A(2, 2);
    CHECK_NEAR(A(0, 0), 0.0, 1e-12);
    CHECK_NEAR(A(1, 1), 0.0, 1e-12);
}

TEST(flat2D_row_major_layout) {
    // Verify row-major indexing: element (i,j) sits at data()[i*cols+j]
    flat2DArray A(2, 3, 0.0);
    A(0, 0) = 1; A(0, 1) = 2; A(0, 2) = 3;
    A(1, 0) = 4; A(1, 1) = 5; A(1, 2) = 6;
    const Real* d = A.data();
    CHECK_NEAR(d[0], 1, 1e-12);
    CHECK_NEAR(d[1], 2, 1e-12);
    CHECK_NEAR(d[2], 3, 1e-12);
    CHECK_NEAR(d[3], 4, 1e-12);
    CHECK_NEAR(d[4], 5, 1e-12);
    CHECK_NEAR(d[5], 6, 1e-12);
}

// ---------------------------------------------------------------
// Element access: read/write + invalid index handling
// ---------------------------------------------------------------

TEST(flat2D_write_then_read) {
    flat2DArray A(2, 2, 0.0);
    A(0, 1) = 3.14;
    CHECK_NEAR(A(0, 1), 3.14, 1e-12);
    CHECK_NEAR(A(1, 0), 0.0, 1e-12);
}

TEST(flat2D_const_access) {
    const flat2DArray A(2, 2, 9.0);
    CHECK_NEAR(A(0, 0), 9.0, 1e-12);
    CHECK_NEAR(A(1, 1), 9.0, 1e-12);
}

TEST(flat2D_invalid_index_logs_error_and_returns_nan) {
    flat2DArray A(2, 2, 0.0);
    CHECK_FALSE(A.hasArr2DErrors());
    Real v = A(5, 5); // out of bounds
    CHECK_TRUE(std::isnan(v));
    CHECK_TRUE(A.hasArr2DErrors());
}

TEST(flat2D_const_invalid_index_logs_error_and_returns_nan) {
    const flat2DArray A(2, 2, 0.0);
    Real v = A(9, 9);
    CHECK_TRUE(std::isnan(v));
    CHECK_TRUE(A.hasArr2DErrors());
}

// FIXED: the non-const operator()'s out-of-bounds branch used to
// return a reference to a function-local `static Real dnan = nan("")`
// that was initialized only ONCE and shared across every flat2DArray
// instance in the program, so writing through it would permanently
// corrupt every future invalid access, on any array, to that written
// value. It now uses `static thread_local Real dnan; dnan = nan("");`
// (reassigned on every call), matching flat3DArray::operator(), so
// the sentinel can no longer leak state between calls or instances.
TEST(flat2D_invalid_index_sentinel_is_not_corruptible) {
    flat2DArray A(2, 2, 0.0);
    flat2DArray B(2, 2, 0.0);

    // Writing through the "invalid index" reference should not be
    // observable elsewhere, and should not persist on repeat access.
    A(50, 50) = 123.0;

    Real again_from_A = A(50, 50);
    Real from_unrelated_B = B(50, 50);

    CHECK_TRUE(std::isnan(again_from_A));
    CHECK_TRUE(std::isnan(from_unrelated_B));
}

// ---------------------------------------------------------------
// Equality
// ---------------------------------------------------------------

TEST(flat2D_equality_same_dims_same_data) {
    flat2DArray A(2, 2, 1.0);
    flat2DArray B(2, 2, 1.0);
    CHECK_TRUE(A == B);
    CHECK_FALSE(A != B);
}

TEST(flat2D_equality_different_data) {
    flat2DArray A(2, 2, 1.0);
    flat2DArray B(2, 2, 1.0);
    B(0, 0) = 2.0;
    CHECK_FALSE(A == B);
    CHECK_TRUE(A != B);
}

TEST(flat2D_equality_different_dims) {
    flat2DArray A(2, 2, 1.0);
    flat2DArray B(2, 3, 1.0);
    CHECK_FALSE(A == B);
    CHECK_TRUE(A != B);
}

// ---------------------------------------------------------------
// resize()
// ---------------------------------------------------------------

TEST(flat2D_resize_changes_dims_and_fills) {
    flat2DArray A(2, 2, 1.0);
    A.resize(3, 5, 9.0);
    CHECK_EQ(A.rows(), 3u);
    CHECK_EQ(A.cols(), 5u);
    CHECK_EQ(A.size(), 15u);
    for (size_t i = 0; i < A.rows(); ++i)
        for (size_t j = 0; j < A.cols(); ++j)
            CHECK_NEAR(A(i, j), 9.0, 1e-12);
}

TEST(flat2D_resize_to_zero_is_empty) {
    flat2DArray A(2, 2, 1.0);
    A.resize(0, 0);
    CHECK_TRUE(A.empty());
    CHECK_EQ(A.size(), 0u);
}

// resize() DOES guard against rows*cols overflow (unlike the
// constructor - see below). Confirm the guard fires and leaves the
// array untouched, with the overflow error logged.
TEST(flat2D_resize_overflow_is_rejected) {
    flat2DArray A(2, 2, 1.0);
    CHECK_FALSE(A.hasArr2DErrors());
    size_t huge = 4294967296ULL; // 2^32; huge*huge wraps to 0 on 64-bit size_t
    A.resize(huge, huge, 5.0);
    CHECK_TRUE(A.hasArr2DErrors());
    // Array should be left as it was before the rejected resize.
    CHECK_EQ(A.rows(), 2u);
    CHECK_EQ(A.cols(), 2u);
}

// The constructor is now guarded the same way resize() is: a
// rows*cols product that overflows size_t is rejected, logged via
// MOLE_ERR_ARRAY_SIZE_OVERFLOW, and the array is left empty instead
// of ending up with mismatched rows_/cols_ vs. an undersized buffer.
TEST(flat2D_ctor_overflow_is_rejected_and_left_empty) {
    size_t huge = 4294967296ULL; // 2^32; huge*huge wraps to 0
    flat2DArray A(huge, huge, 5.0);
    CHECK_TRUE(A.hasArr2DErrors());
    CHECK_EQ(A.rows(), 0u);
    CHECK_EQ(A.cols(), 0u);
    CHECK_TRUE(A.empty());
}

TEST(flat2D_ctor_zero_dims_is_valid_not_an_overflow) {
    // A 0 x N (or N x 0, or 0 x 0) array is legitimately empty; this
    // must NOT be reported as an overflow error.
    flat2DArray A(0, 5, 1.0);
    CHECK_FALSE(A.hasArr2DErrors());
    CHECK_EQ(A.rows(), 0u);
    CHECK_TRUE(A.empty());
}

// ---------------------------------------------------------------
// row() / rowStride() / rowLength()
// ---------------------------------------------------------------

TEST(flat2D_row_access_valid) {
    flat2DArray A(2, 3, 0.0);
    A(1, 0) = 10; A(1, 1) = 20; A(1, 2) = 30;
    Real* r = A.row(1);
    CHECK_TRUE(r != nullptr);
    CHECK_NEAR(r[0], 10, 1e-12);
    CHECK_NEAR(r[1], 20, 1e-12);
    CHECK_NEAR(r[2], 30, 1e-12);
    CHECK_EQ(A.rowStride(), 3u);
    CHECK_EQ(A.rowLength(), 3u);
}

TEST(flat2D_row_access_const_valid) {
    const flat2DArray A(2, 2, 4.0);
    const Real* r = A.row(0);
    CHECK_TRUE(r != nullptr);
    CHECK_NEAR(r[0], 4.0, 1e-12);
}

TEST(flat2D_row_access_invalid_returns_nullptr_and_logs_error) {
    flat2DArray A(2, 2, 0.0);
    CHECK_FALSE(A.hasArr2DErrors());
    Real* r = A.row(5);
    CHECK_TRUE(r == nullptr);
    CHECK_TRUE(A.hasArr2DErrors());
}

// ---------------------------------------------------------------
// Error log utility functions
// ---------------------------------------------------------------

TEST(flat2D_error_log_starts_clean) {
    flat2DArray A(2, 2, 0.0);
    CHECK_FALSE(A.hasArr2DErrors());
}

TEST(flat2D_print_error_log_does_not_crash) {
    flat2DArray A(2, 2, 0.0);
    A(9, 9); // logs an error
    A.print_ErrorLog(); // just verify no crash/exception
    CHECK_TRUE(A.hasArr2DErrors());
}

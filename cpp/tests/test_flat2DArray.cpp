// Tests for flat2DArray
#include <gtest/gtest.h>
#include "flat2DArray.h"
#include <cmath>
#include <limits>

// -----------------------------------------------------------------
// Construction / basic dimensions
// -----------------------------------------------------------------

TEST(Flat2DArray, DefaultConstructedIsEmpty) {
    flat2DArray a;
    EXPECT_EQ(a.rows(), 0u);
    EXPECT_EQ(a.cols(), 0u);
    EXPECT_TRUE(a.empty());
    EXPECT_EQ(a.size(), 0u);
}

TEST(Flat2DArray, SizedConstructorSetsDimensions) {
    flat2DArray a(3, 4);
    EXPECT_EQ(a.rows(), 3u);
    EXPECT_EQ(a.cols(), 4u);
    EXPECT_FALSE(a.empty());
    EXPECT_EQ(a.size(), 12u);
}

TEST(Flat2DArray, FillValueAppliesToAllElements) {
    flat2DArray a(2, 3, 7.5);
    for (size_t i = 0; i < 2; ++i)
        for (size_t j = 0; j < 3; ++j)
            EXPECT_DOUBLE_EQ(a(i, j), 7.5);
}

TEST(Flat2DArray, DefaultFillValueIsZero) {
    flat2DArray a(2, 2);
    EXPECT_DOUBLE_EQ(a(0, 0), 0.0);
    EXPECT_DOUBLE_EQ(a(1, 1), 0.0);
}

// -----------------------------------------------------------------
// operator() read/write, row-major layout
// -----------------------------------------------------------------

TEST(Flat2DArray, ReadWriteRoundTrip) {
    flat2DArray a(2, 2);
    a(0, 0) = 1.0; a(0, 1) = 2.0;
    a(1, 0) = 3.0; a(1, 1) = 4.0;
    EXPECT_DOUBLE_EQ(a(0, 0), 1.0);
    EXPECT_DOUBLE_EQ(a(0, 1), 2.0);
    EXPECT_DOUBLE_EQ(a(1, 0), 3.0);
    EXPECT_DOUBLE_EQ(a(1, 1), 4.0);
}

TEST(Flat2DArray, RowMajorMemoryLayout) {
    // data_[i*cols_+j] -- verify via data() pointer directly
    flat2DArray a(2, 3);
    a(0, 0)=1; a(0, 1)=2; a(0, 2)=3;
    a(1, 0)=4; a(1, 1)=5; a(1, 2)=6;
    const Real* d = a.data();
    for (int k = 0; k < 6; ++k) EXPECT_DOUBLE_EQ(d[k], k + 1);
}

// -----------------------------------------------------------------
// Out-of-bounds access -> NaN + logged error (both const and
// non-const operator())
// -----------------------------------------------------------------

TEST(Flat2DArray, OutOfBoundsReadReturnsNaNAndLogsError) {
    flat2DArray a(2, 2);
    Real v = a(5, 5);
    EXPECT_TRUE(std::isnan(v));
    EXPECT_TRUE(a.hasArr2DErrors());
}

TEST(Flat2DArray, OutOfBoundsConstReadReturnsNaNAndLogsError) {
    const flat2DArray a(2, 2, 1.0);
    Real v = a(10, 0);
    EXPECT_TRUE(std::isnan(v));
    EXPECT_TRUE(a.hasArr2DErrors());
}

TEST(Flat2DArray, InBoundsAccessNeverLogsError) {
    flat2DArray a(2, 2);
    Real v = a(1, 1);
    (void)v;
    EXPECT_FALSE(a.hasArr2DErrors());
}

// -----------------------------------------------------------------
// operator== / operator!=
// -----------------------------------------------------------------

TEST(Flat2DArray, EqualArraysCompareEqual) {
    flat2DArray a(2, 2, 3.0), b(2, 2, 3.0);
    EXPECT_TRUE(a == b);
    EXPECT_FALSE(a != b);
}

TEST(Flat2DArray, DifferentDataComparesNotEqual) {
    flat2DArray a(2, 2, 3.0), b(2, 2, 4.0);
    EXPECT_TRUE(a != b);
    EXPECT_FALSE(a == b);
}

TEST(Flat2DArray, DifferentDimensionsComparesNotEqual) {
    flat2DArray a(2, 2), b(2, 3);
    EXPECT_TRUE(a != b);
}

// -----------------------------------------------------------------
// resize()
// -----------------------------------------------------------------

TEST(Flat2DArray, ResizeChangesDimensionsAndFillsValue) {
    flat2DArray a(2, 2, 1.0);
    a.resize(3, 5, 9.0);
    EXPECT_EQ(a.rows(), 3u);
    EXPECT_EQ(a.cols(), 5u);
    for (size_t i = 0; i < 3; ++i)
        for (size_t j = 0; j < 5; ++j)
            EXPECT_DOUBLE_EQ(a(i, j), 9.0);
}

TEST(Flat2DArray, ResizeToZeroIsEmpty) {
    flat2DArray a(2, 2, 1.0);
    a.resize(0, 0);
    EXPECT_TRUE(a.empty());
}

TEST(Flat2DArray, ResizeOverflowIsRejectedAndLogsError) {
    // rows*cols would overflow size_t -- resize should refuse and
    // log MOLE_ERR_ARRAY_SIZE_OVERFLOW, leaving the array untouched.
    flat2DArray a(2, 2, 1.0);
    size_t huge = std::numeric_limits<size_t>::max() / 2 + 1;
    a.resize(huge, huge, 5.0);
    // dims should NOT have changed to the overflowing values
    EXPECT_EQ(a.rows(), 2u);
    EXPECT_EQ(a.cols(), 2u);
    EXPECT_TRUE(a.hasArr2DErrors());
}

// -----------------------------------------------------------------
// row() access -- both non-const and const overloads.
// The const overload was previously declared but never defined
// (link error); this is a direct regression test for that fix.
// -----------------------------------------------------------------

TEST(Flat2DArray, RowReturnsPointerToRowStart) {
    flat2DArray a(2, 3);
    a(1, 0) = 10; a(1, 1) = 11; a(1, 2) = 12;
    Real* r = a.row(1);
    ASSERT_NE(r, nullptr);
    EXPECT_DOUBLE_EQ(r[0], 10);
    EXPECT_DOUBLE_EQ(r[1], 11);
    EXPECT_DOUBLE_EQ(r[2], 12);
}

TEST(Flat2DArray, ConstRowReturnsPointerToRowStart) {
    flat2DArray a(2, 3);
    a(0, 0) = 1; a(0, 1) = 2; a(0, 2) = 3;
    const flat2DArray& ca = a;
    const Real* r = ca.row(0);
    ASSERT_NE(r, nullptr);
    EXPECT_DOUBLE_EQ(r[0], 1);
    EXPECT_DOUBLE_EQ(r[1], 2);
    EXPECT_DOUBLE_EQ(r[2], 3);
}

TEST(Flat2DArray, RowOutOfBoundsReturnsNullptrAndLogsError) {
    flat2DArray a(2, 2);
    Real* r = a.row(99);
    EXPECT_EQ(r, nullptr);
    EXPECT_TRUE(a.hasArr2DErrors());
}

TEST(Flat2DArray, ConstRowOutOfBoundsReturnsNullptrAndLogsError) {
    flat2DArray a(2, 2);
    const flat2DArray& ca = a;
    const Real* r = ca.row(99);
    EXPECT_EQ(r, nullptr);
    EXPECT_TRUE(ca.hasArr2DErrors());
}

TEST(Flat2DArray, RowStrideAndLengthEqualCols) {
    flat2DArray a(4, 6);
    EXPECT_EQ(a.rowStride(), 6u);
    EXPECT_EQ(a.rowLength(), 6u);
}

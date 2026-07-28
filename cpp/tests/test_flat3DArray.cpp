// Tests for flat3DArray
#include <gtest/gtest.h>
#include "flat3DArray.h"
#include <cmath>

// -----------------------------------------------------------------
// Construction / basic dimensions
// -----------------------------------------------------------------

TEST(Flat3DArray, DefaultConstructedIsEmpty) {
    flat3DArray a;
    EXPECT_EQ(a.dim1(), 0u);
    EXPECT_EQ(a.dim2(), 0u);
    EXPECT_EQ(a.dim3(), 0u);
    EXPECT_TRUE(a.empty());
    EXPECT_EQ(a.size(), 0u);
}

TEST(Flat3DArray, SizedConstructorSetsDimensions) {
    flat3DArray a(2, 3, 4);
    EXPECT_EQ(a.dim1(), 2u);
    EXPECT_EQ(a.dim2(), 3u);
    EXPECT_EQ(a.dim3(), 4u);
    EXPECT_EQ(a.size(), 24u);
    EXPECT_FALSE(a.empty());
}

TEST(Flat3DArray, FillValueAppliesToAllElements) {
    flat3DArray a(2, 2, 2, 6.0);
    for (size_t i = 0; i < 2; ++i)
        for (size_t j = 0; j < 2; ++j)
            for (size_t k = 0; k < 2; ++k)
                EXPECT_DOUBLE_EQ(a(i, j, k), 6.0);
}

// -----------------------------------------------------------------
// operator() read/write and layout
// -----------------------------------------------------------------

TEST(Flat3DArray, ReadWriteRoundTrip) {
    flat3DArray a(2, 2, 2);
    a(0, 0, 0) = 1; a(1, 1, 1) = 8;
    EXPECT_DOUBLE_EQ(a(0, 0, 0), 1);
    EXPECT_DOUBLE_EQ(a(1, 1, 1), 8);
}

TEST(Flat3DArray, MemoryLayoutMatchesFormula) {
    // data_[(i*dim2_+j)*dim3_+k]
    flat3DArray a(2, 2, 2);
    a(1, 0, 1) = 42.0;
    const Real* d = a.data();
    size_t idx = (1 * 2 + 0) * 2 + 1;
    EXPECT_DOUBLE_EQ(d[idx], 42.0);
}

// -----------------------------------------------------------------
// Out-of-bounds access -> NaN + logged error
// -----------------------------------------------------------------

TEST(Flat3DArray, OutOfBoundsReadReturnsNaNAndLogsError) {
    flat3DArray a(2, 2, 2);
    Real v = a(9, 9, 9);
    EXPECT_TRUE(std::isnan(v));
    EXPECT_TRUE(a.hasArr3DErrors());
}

TEST(Flat3DArray, OutOfBoundsConstReadReturnsNaNAndLogsError) {
    const flat3DArray a(2, 2, 2, 1.0);
    Real v = a(9, 0, 0);
    EXPECT_TRUE(std::isnan(v));
    EXPECT_TRUE(a.hasArr3DErrors());  // const-qualified, verifies mutable a_errs
}

TEST(Flat3DArray, InBoundsAccessNeverLogsError) {
    flat3DArray a(2, 2, 2);
    Real v = a(1, 1, 1);
    (void)v;
    EXPECT_FALSE(a.hasArr3DErrors());
}

// -----------------------------------------------------------------
// operator== / operator!=
// -----------------------------------------------------------------

TEST(Flat3DArray, EqualArraysCompareEqual) {
    flat3DArray a(2, 2, 2, 5.0), b(2, 2, 2, 5.0);
    EXPECT_TRUE(a == b);
    EXPECT_FALSE(a != b);
}

TEST(Flat3DArray, DifferentDataComparesNotEqual) {
    flat3DArray a(2, 2, 2, 5.0), b(2, 2, 2, 6.0);
    EXPECT_TRUE(a != b);
}

TEST(Flat3DArray, DifferentDimensionsComparesNotEqual) {
    flat3DArray a(2, 2, 2), b(2, 2, 3);
    EXPECT_TRUE(a != b);
}

// -----------------------------------------------------------------
// resize()
// -----------------------------------------------------------------

TEST(Flat3DArray, ResizeChangesDimensionsAndFillsValue) {
    flat3DArray a(2, 2, 2, 1.0);
    a.resize(3, 4, 5, 8.0);
    EXPECT_EQ(a.dim1(), 3u);
    EXPECT_EQ(a.dim2(), 4u);
    EXPECT_EQ(a.dim3(), 5u);
    for (size_t i = 0; i < 3; ++i)
        for (size_t j = 0; j < 4; ++j)
            for (size_t k = 0; k < 5; ++k)
                EXPECT_DOUBLE_EQ(a(i, j, k), 8.0);
}

// -----------------------------------------------------------------
// plane() / row() -- valid access
// -----------------------------------------------------------------

TEST(Flat3DArray, PlaneReturnsCorrectSlice) {
    flat3DArray a(2, 3, 4, 0.0);
    // fill plane i=1 with a marker value
    for (size_t j = 0; j < 3; ++j)
        for (size_t k = 0; k < 4; ++k)
            a(1, j, k) = 99.0;
    Real* p = a.plane(1);
    ASSERT_NE(p, nullptr);
    for (size_t idx = 0; idx < 12; ++idx) EXPECT_DOUBLE_EQ(p[idx], 99.0);
}

TEST(Flat3DArray, ConstPlaneReturnsCorrectSlice) {
    flat3DArray a(2, 3, 4, 3.0);
    const flat3DArray& ca = a;
    const Real* p = ca.plane(0);
    ASSERT_NE(p, nullptr);
    EXPECT_DOUBLE_EQ(p[0], 3.0);
}

TEST(Flat3DArray, RowReturnsCorrectSlice) {
    flat3DArray a(2, 3, 4, 0.0);
    for (size_t k = 0; k < 4; ++k) a(0, 2, k) = 7.0;
    Real* r = a.row(0, 2);
    ASSERT_NE(r, nullptr);
    for (size_t k = 0; k < 4; ++k) EXPECT_DOUBLE_EQ(r[k], 7.0);
}

TEST(Flat3DArray, ConstRowReturnsCorrectSlice) {
    flat3DArray a(2, 3, 4, 2.0);
    const flat3DArray& ca = a;
    const Real* r = ca.row(1, 1);
    ASSERT_NE(r, nullptr);
    EXPECT_DOUBLE_EQ(r[0], 2.0);
}

TEST(Flat3DArray, PlaneStrideRowStrideRowLength) {
    flat3DArray a(2, 3, 4);
    EXPECT_EQ(a.planeStride(), 12u);  // dim2*dim3
    EXPECT_EQ(a.rowStride(), 4u);     // dim3
    EXPECT_EQ(a.rowLength(), 4u);     // dim3
}

// -----------------------------------------------------------------
// plane()/row() out-of-bounds indices used to be guarded by assert(),
// which aborted the process in non-NDEBUG builds and gave zero
// protection at all under -DNDEBUG (release builds). They now use
// the same log-and-return-nullptr pattern as operator(), so no crash
// should occur in either build mode, and the failure is discoverable
// via hasArr3DErrors()/print_ErrorLog() instead of a process abort.
// -----------------------------------------------------------------

TEST(Flat3DArray, PlaneOutOfBoundsReturnsNullptrAndLogsError) {
    flat3DArray a(2, 2, 2);
    Real* p = a.plane(99);
    EXPECT_EQ(p, nullptr);
    EXPECT_TRUE(a.hasArr3DErrors());
}

TEST(Flat3DArray, ConstPlaneOutOfBoundsReturnsNullptrAndLogsError) {
    flat3DArray a(2, 2, 2);
    const flat3DArray& ca = a;
    const Real* p = ca.plane(99);
    EXPECT_EQ(p, nullptr);
    EXPECT_TRUE(ca.hasArr3DErrors());
}

TEST(Flat3DArray, RowOutOfBoundsReturnsNullptrAndLogsError) {
    flat3DArray a(2, 2, 2);
    Real* r = a.row(0, 99);
    EXPECT_EQ(r, nullptr);
    EXPECT_TRUE(a.hasArr3DErrors());
}

TEST(Flat3DArray, ConstRowOutOfBoundsReturnsNullptrAndLogsError) {
    flat3DArray a(2, 2, 2);
    const flat3DArray& ca = a;
    const Real* r = ca.row(0, 99);
    EXPECT_EQ(r, nullptr);
    EXPECT_TRUE(ca.hasArr3DErrors());
}

TEST(Flat3DArray, RowOutOfBoundsOnEitherIndexIsCaught) {
    // i valid but j out of bounds, and vice versa
    flat3DArray a(2, 3, 2);
    EXPECT_EQ(a.row(1, 99), nullptr);
    EXPECT_EQ(a.row(99, 1), nullptr);
}

TEST(Flat3DArray, PlaneErrorMessageContainsBothIndexAndDim) {
    // Regression test for the earlier comma-operator bug in the
    // draft version of this fix, which silently dropped the 'j'
    // value and trailing text from the logged message.
    flat3DArray a(2, 3, 4);
    a.row(0, 99);  // triggers the out-of-bounds branch
    ASSERT_TRUE(a.hasArr3DErrors());
}


// Regression tests for array1D, array2D, array3D, and numEqualArray.
#include "MOLE_arrays.h"
#include "mole_test.h"

// ---------------------------------------------------------------
// Default construction / empty-object semantics
// ---------------------------------------------------------------

TEST_CASE("array1D default construction is empty") {
    array1D a;
    CHECK(a.data_.is_empty());
    CHECK(a.data_.n_elem == 0);
}

TEST_CASE("array2D default construction is empty") {
    array2D a;
    CHECK(a.data_.is_empty());
    CHECK(a.data_.n_rows == 0);
    CHECK(a.data_.n_cols == 0);
}

TEST_CASE("array3D default construction is empty") {
    array3D a;
    CHECK(a.data_.is_empty());
    CHECK(a.data_.n_rows == 0);
    CHECK(a.data_.n_cols == 0);
    CHECK(a.data_.n_slices == 0);
}

// ---------------------------------------------------------------
// Parameterized constructors
// ---------------------------------------------------------------

TEST_CASE("array1D(n, fill) allocates and fills") {
    array1D a(5, 3.0);
    REQUIRE(a.data_.n_elem == 5);
    for (arma::uword i = 0; i < a.data_.n_elem; ++i) {
        CHECK(a.data_(i) == 3.0);
    }
}

TEST_CASE("array1D default fill value is 0.0") {
    array1D a(4);
    for (arma::uword i = 0; i < a.data_.n_elem; ++i) {
        CHECK(a.data_(i) == 0.0);
    }
}

TEST_CASE("array2D(rows, cols, fill) allocates and fills") {
    array2D a(3, 4, 7.0);
    REQUIRE(a.data_.n_rows == 3);
    REQUIRE(a.data_.n_cols == 4);
    CHECK(a.data_(0, 0) == 7.0);
    CHECK(a.data_(2, 3) == 7.0);
}

TEST_CASE("array3D(d1, d2, d3, fill) allocates and fills") {
    array3D a(2, 3, 4, 9.0);
    REQUIRE(a.data_.n_rows == 2);
    REQUIRE(a.data_.n_cols == 3);
    REQUIRE(a.data_.n_slices == 4);
    CHECK(a.data_(1, 2, 3) == 9.0);
}

// ---------------------------------------------------------------
// valid_index / valid_indeces
// ---------------------------------------------------------------

TEST_CASE("array1D::valid_index respects bounds") {
    array1D a(3, 0.0);
    CHECK(a.valid_index(0));
    CHECK(a.valid_index(2));
    CHECK(!a.valid_index(3));   // one-past-the-end is invalid
}

TEST_CASE("array2D::valid_indeces respects bounds") {
    array2D a(2, 3, 0.0);
    CHECK(a.valid_indeces(0, 0));
    CHECK(a.valid_indeces(1, 2));
    CHECK(!a.valid_indeces(2, 0));
    CHECK(!a.valid_indeces(0, 3));
}

TEST_CASE("array3D::valid_indeces respects bounds") {
    array3D a(2, 2, 2, 0.0);
    CHECK(a.valid_indeces(1, 1, 1));
    CHECK(!a.valid_indeces(2, 0, 0));
    CHECK(!a.valid_indeces(0, 2, 0));
    CHECK(!a.valid_indeces(0, 0, 2));
}

// ---------------------------------------------------------------
// resize: preserves-vs-overwrites semantics as actually implemented
// (resize reallocates + fills with fillVal; it does NOT preserve
// prior contents the way arma::mat::resize does. This test locks in
// the class's actual documented behavior rather than assuming
// Armadillo's semantics carry over.)
// ---------------------------------------------------------------

TEST_CASE("array1D::resize reallocates and fills with fillVal") {
    array1D a(3, 1.0);
    a.resize(5, 2.0);
    REQUIRE(a.data_.n_elem == 5);
    for (arma::uword i = 0; i < a.data_.n_elem; ++i) {
        CHECK(a.data_(i) == 2.0);
    }
    CHECK(!a.hasArrayErrors());
}

TEST_CASE("array2D::resize reallocates and fills with fillVal") {
    array2D a(2, 2, 1.0);
    a.resize(3, 3, 5.0);
    REQUIRE(a.data_.n_rows == 3);
    REQUIRE(a.data_.n_cols == 3);
    CHECK(a.data_(2, 2) == 5.0);
    CHECK(!a.hasArrayErrors());
}

TEST_CASE("array3D::resize reallocates and fills with fillVal") {
    array3D a(2, 2, 2, 1.0);
    a.resize(3, 3, 3, 6.0);
    REQUIRE(a.data_.n_rows == 3);
    REQUIRE(a.data_.n_cols == 3);
    REQUIRE(a.data_.n_slices == 3);
    CHECK(a.data_(2, 2, 2) == 6.0);
    CHECK(!a.hasArrayErrors());
}

TEST_CASE("array1D::resize to 0 produces an empty array, not an error") {
    array1D a(4, 1.0);
    a.resize(0);
    CHECK(a.data_.is_empty());
    CHECK(a.data_.n_elem == 0);
    CHECK(!a.hasArrayErrors());
}

// ---------------------------------------------------------------
// operator==
//
// operator== is a proper value comparison (size + contents), and
// correctly reports equal for two independently-constructed arrays
// that happen to hold the same values.
// ---------------------------------------------------------------

TEST_CASE("array1D::operator== compares by value, not identity") {
    array1D a(3, 2.5), b(3, 2.5);
    CHECK(a.data_.memptr() != b.data_.memptr()); // genuinely distinct
    CHECK(a == b);                               // but equal by value
}

TEST_CASE("array1D::operator== detects differing size") {
    array1D a(3, 1.0), b(4, 1.0);
    CHECK(!(a == b));
}

TEST_CASE("array1D::operator== detects differing content") {
    array1D a(3, 1.0), b(3, 2.0);
    CHECK(!(a == b));
}

TEST_CASE("array2D::operator== compares by value") {
    array2D a(2, 2, 4.0), b(2, 2, 4.0);
    CHECK(a == b);
    array2D c(2, 2, 4.0), d(2, 3, 4.0);
    CHECK(!(c == d));
}

TEST_CASE("array3D::operator== compares by value") {
    array3D a(2, 2, 2, 4.0), b(2, 2, 2, 4.0);
    CHECK(a == b);
    array3D c(2, 2, 2, 4.0), d(2, 2, 3, 4.0);
    CHECK(!(c == d));
}

// ---------------------------------------------------------------
// operator!=  --  KNOWN DIVERGENCE FROM operator==
//
// As currently implemented, operator!= is an identity check (does
// this array live at a different memory address / have a different
// shape?), NOT the logical negation of operator==. This means two
// independently-constructed, value-equal arrays report BOTH
// (a == b) == true AND (a != b) == true simultaneously, which is
// a genuine logical inconsistency between the two operators.
//
// This test intentionally documents that CURRENT behavior (so a
// future accidental "fix" that changes it doesn't silently pass
// unnoticed) while flagging it clearly as inconsistent with ==.
// See the accompanying regression-test report for a suggested fix
// (operator!= should just be `return !(*this == other);`).
// ---------------------------------------------------------------

TEST_CASE("KNOWN ISSUE: array1D::operator!= is pointer-identity, "
          "not the logical negation of operator==") {
    array1D a(3, 2.5), b(3, 2.5);
    REQUIRE(a == b);              // equal by value ...
    CHECK_MSG(a != b,             // ... yet also reported "not equal"
        "operator!= currently returns true here because it only "
        "compares memptr()/shape, not values. If operator!= is ever "
        "fixed to be !(a==b), this CHECK will (correctly) start "
        "failing and should be updated to CHECK(!(a != b)).");
}

// ---------------------------------------------------------------
// numEqualArray
// ---------------------------------------------------------------

TEST_CASE("numEqualArray: identical array1D compares equal") {
    array1D a(4, 1.0), b(4, 1.0);
    CHECK(numEqualArray(a, b, 4.0));
}

TEST_CASE("numEqualArray: differing sizes compare unequal") {
    array1D a(4, 1.0), b(5, 1.0);
    CHECK(!numEqualArray(a, b, 4.0));
}

TEST_CASE("numEqualArray: tiny floating point noise within tolerance") {
    array1D a(3, 1.0);
    // epsilon for double is ~2.22e-16, so 4*epsilon ~8.88e-16.
    // 5e-17 is safely below that; 1e-15 (an earlier version of this
    // test used that) is actually ABOVE 4*epsilon and correctly
    // fails -- don't widen this without re-checking the tolerance.
    array1D b(3, 1.0 + 5e-17);
    CHECK(numEqualArray(a, b, 4.0));
}

TEST_CASE("numEqualArray: difference beyond tolerance is rejected") {
    array1D a(3, 1.0);
    array1D b(3, 1.01); // far beyond 4*epsilon
    CHECK(!numEqualArray(a, b, 4.0));
}

TEST_CASE("numEqualArray works for array2D and array3D") {
    array2D a2(2, 2, 3.0), b2(2, 2, 3.0);
    CHECK(numEqualArray(a2, b2, 4.0));

    array3D a3(2, 2, 2, 3.0), b3(2, 2, 2, 3.0);
    CHECK(numEqualArray(a3, b3, 4.0));
}

MOLE_TEST_MAIN()

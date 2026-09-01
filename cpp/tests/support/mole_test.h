/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * mole_test.h - a tiny, dependency-free unit test framework for the
 * MOLE regression suite.
 *
 * Why not Catch2/GoogleTest? MOLE's build has no other third-party
 * dependency besides Armadillo, and the test suite doesn't need
 * anything more than "run named test cases, report pass/fail,
 * non-zero exit on failure" to work well with CTest. Each test
 * executable is self-contained: include this header, write one or
 * more TEST_CASE blocks, and end the file with MOLE_TEST_MAIN().
 *
 * Usage:
 *
 *   #include "mole_test.h"
 *
 *   TEST_CASE("array1D default construction is empty") {
 *       array1D a;
 *       CHECK(a.data_.is_empty());
 *       CHECK(a.data_.n_elem == 0);
 *   }
 *
 *   MOLE_TEST_MAIN()
 *
 * CHECK(cond) records a failure and keeps running the rest of the
 * test case (use this for independent assertions you want full
 * visibility into). REQUIRE(cond) aborts the current test case
 * immediately on failure (use this when later checks in the same
 * case would be meaningless or crash after a failed precondition,
 * e.g. dereferencing something that might not exist).
 */
#ifndef MOLE_TEST_H
#define MOLE_TEST_H

#include <functional>
#include <iostream>
#include <sstream>
#include <string>
#include <vector>

namespace moletest {

struct AssertionFailure {
    std::string message;
};

struct TestCase {
    std::string name;
    std::function<void()> fn;
};

inline std::vector<TestCase>& registry() {
    static std::vector<TestCase> r;
    return r;
}

struct Registrar {
    Registrar(std::string name, std::function<void()> fn) {
        registry().push_back({std::move(name), std::move(fn)});
    }
};

// Per-test-case failure counter. Reset before each case runs.
inline int& failures_in_case() {
    static int n = 0;
    return n;
}

inline void report_failure(const char* kind, const char* condText,
                            const char* file, int line,
                            const std::string& extra = "") {
    ++failures_in_case();
    std::cerr << "    [" << kind << " failed] " << condText
               << "  (" << file << ":" << line << ")";
    if (!extra.empty()) std::cerr << "\n        " << extra;
    std::cerr << "\n";
}

} // namespace moletest

#define MOLE_TEST_CONCAT_(a, b) a##b
#define MOLE_TEST_CONCAT(a, b) MOLE_TEST_CONCAT_(a, b)

#define TEST_CASE(name)                                                    \
    static void MOLE_TEST_CONCAT(mole_test_fn_, __LINE__)();               \
    static ::moletest::Registrar MOLE_TEST_CONCAT(mole_test_reg_,          \
        __LINE__)(name, MOLE_TEST_CONCAT(mole_test_fn_, __LINE__));        \
    static void MOLE_TEST_CONCAT(mole_test_fn_, __LINE__)()

#define CHECK(cond)                                                        \
    do {                                                                   \
        if (!(cond)) {                                                     \
            ::moletest::report_failure("CHECK", #cond, __FILE__, __LINE__);\
        }                                                                  \
    } while (0)

// CHECK_MSG lets a failing check carry a dynamically-built message
// (e.g. the actual vs. expected values), which is often the
// difference between "test failed" and "test failed, here's why".
#define CHECK_MSG(cond, msg)                                               \
    do {                                                                   \
        if (!(cond)) {                                                     \
            std::ostringstream oss_; oss_ << msg;                          \
            ::moletest::report_failure("CHECK", #cond, __FILE__, __LINE__, \
                                        oss_.str());                       \
        }                                                                  \
    } while (0)

#define REQUIRE(cond)                                                      \
    do {                                                                   \
        if (!(cond)) {                                                     \
            ::moletest::report_failure("REQUIRE", #cond, __FILE__,         \
                                        __LINE__);                         \
            throw ::moletest::AssertionFailure{                           \
                std::string("REQUIRE failed: ") + #cond};                  \
        }                                                                  \
    } while (0)

inline int mole_run_all_tests() {
    using namespace moletest;
    int failed_cases = 0;
    const auto& tests = registry();
    std::cout << "Running " << tests.size() << " MOLE test case(s)\n";
    std::cout << "----------------------------------------------------\n";
    for (const auto& tc : tests) {
        failures_in_case() = 0;
        std::cout << "[ RUN      ] " << tc.name << "\n";
        try {
            tc.fn();
        } catch (const AssertionFailure&) {
            // Already reported by REQUIRE; just stop this case.
        } catch (const std::exception& e) {
            std::cerr << "    [uncaught std::exception] " << e.what()
                       << "\n";
            ++failures_in_case();
        } catch (...) {
            std::cerr << "    [uncaught unknown exception]\n";
            ++failures_in_case();
        }
        if (failures_in_case() == 0) {
            std::cout << "[       OK ] " << tc.name << "\n";
        } else {
            std::cout << "[  FAILED  ] " << tc.name << "\n";
            ++failed_cases;
        }
    }
    std::cout << "----------------------------------------------------\n";
    std::cout << tests.size() << " test case(s) run, "
               << (tests.size() - failed_cases) << " passed, "
               << failed_cases << " failed.\n";
    return failed_cases == 0 ? 0 : 1;
}

#define MOLE_TEST_MAIN()                                                   \
    int main() { return mole_run_all_tests(); }

#endif // MOLE_TEST_H

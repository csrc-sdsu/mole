/*
 * mini_test.h - a tiny, dependency-free test harness used for the
 * MOLE grid/array regression suite. No gtest/Catch2 required, so
 * these tests can be compiled anywhere a plain g++ is available.
 */
#ifndef MINI_TEST_H
#define MINI_TEST_H

#include <iostream>
#include <string>
#include <vector>
#include <functional>
#include <cmath>

struct TestCase {
    std::string name;
    std::function<void()> fn;
};

inline std::vector<TestCase>& registry() {
    static std::vector<TestCase> tests;
    return tests;
}

struct TestRegistrar {
    TestRegistrar(const std::string& name, std::function<void()> fn) {
        registry().push_back({name, fn});
    }
};

// Per-test pass/fail counters (reset before each test in RUN_ALL_TESTS)
inline int& g_checks_run()    { static int v = 0; return v; }
inline int& g_checks_failed() { static int v = 0; return v; }
inline bool& g_current_test_failed() { static bool v = false; return v; }

#define TEST(name) \
    void name(); \
    static TestRegistrar registrar_##name(#name, name); \
    void name()

#define CHECK(cond) \
    do { \
        g_checks_run()++; \
        if (!(cond)) { \
            g_checks_failed()++; \
            g_current_test_failed() = true; \
            std::cerr << "    [FAIL] " << __FILE__ << ":" << __LINE__ \
                      << "  CHECK(" #cond ")\n"; \
        } \
    } while (0)

#define CHECK_NEAR(a, b, tol) \
    CHECK(std::fabs((a) - (b)) <= (tol))

#define CHECK_EQ(a, b) CHECK((a) == (b))
#define CHECK_TRUE(a)  CHECK(static_cast<bool>(a))
#define CHECK_FALSE(a) CHECK(!static_cast<bool>(a))

inline int RUN_ALL_TESTS() {
    int total = 0, failed = 0;
    for (auto& t : registry()) {
        g_current_test_failed() = false;
        int before_run = g_checks_run();
        int before_fail = g_checks_failed();
        std::cout << "RUN  " << t.name << std::endl;
        try {
            t.fn();
        } catch (const std::exception& e) {
            g_current_test_failed() = true;
            std::cerr << "    [EXCEPTION] " << e.what() << std::endl;
        } catch (...) {
            g_current_test_failed() = true;
            std::cerr << "    [EXCEPTION] unknown exception thrown" << std::endl;
        }
        total++;
        bool this_test_failed = g_current_test_failed() ||
            (g_checks_failed() > before_fail);
        if (this_test_failed) {
            failed++;
            std::cout << "FAIL " << t.name << std::endl;
        } else {
            std::cout << "PASS " << t.name
                       << "  (" << (g_checks_run() - before_run) << " checks)"
                       << std::endl;
        }
    }
    std::cout << "----------------------------------------\n";
    std::cout << total << " tests run, " << (total - failed) << " passed, "
               << failed << " failed.\n";
    std::cout << g_checks_run() << " total assertions, "
               << g_checks_failed() << " failed.\n";
    return failed == 0 ? 0 : 1;
}

#endif // MINI_TEST_H

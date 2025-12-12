#include "mole.h"
#include <gtest/gtest.h>

void run_test(int k) {
    int m = 5;
    Real dx = 1.0;
    WeightsQ Q(k,m,dx);
}

TEST(WeightTests, Accuracy) {
    for (int k : {2}) {
        run_test(k);
    }
}
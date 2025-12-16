#include "mole.h"
#include <gtest/gtest.h>

void run_Qtest(int k) {
    Real dx = 1.0;
    int m = k*2 + 1;
    WeightsQ Q(k,m,dx);
}

void run_Ptest(int k) {
    Real dx = 1.0;
    int m = k*2 + 1;
    WeightsP P(k,m,dx);
}

TEST(WeightTests, Accuracy) {
    for (int k : {2}) {
        run_Qtest(k);
        run_Ptest(k);
    }
}

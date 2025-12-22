#include "mole.h"
#include <gtest/gtest.h>

vec Q_baseline[3];
vec P_baseline[3];
Real tolerance = 1.0e-08;

void run_Qtest(int k) {
    Real dx = 1.0;
    int m = k*2 + 1;
    int j = k/2 - 1;
    WeightsQ Q(k,m,dx);
    Real total_error = 0.0;

    for (int i = 0; i < m+2; ++i) {
        total_error += abs(Q[i] - Q_baseline[j][i]);
    }
    ASSERT_LE(total_error, tolerance);
}

void run_Ptest(int k) {
    Real dx = 1.0;
    int m = k*2 + 1;
    int j = k/2 - 1;
    Real total_error = 0.0;

    WeightsP P(k,m,dx);
    for (int i = 0; i < m; ++i) {
        total_error += abs(P[i] - P_baseline[j][i]);
    }
    ASSERT_LE(total_error, tolerance);

}

TEST(WeightTests, Accuracy) {

        // Baseline weights - Generated from MatLab/Octave
        Q_baseline[0] = { 1.000000000,1.000000000,1.000000000,1.000000000,1.000000000,1.000000000,1.000000000};
        Q_baseline[1] = { 1.000000000,1.125064293,0.751414447,1.162097097,0.962852897,0.997142531,0.962852897,
                        1.162097097,0.751414447,1.125064293,1.000000000 };
        Q_baseline[2] = { 1.000000000,1.188528786,0.464036031,1.670433241,0.529401810,1.170898848,0.978586058,
                        0.996230453,0.978586058,1.170898848,0.529401810,1.670433241,0.464036031,1.188528786,1.000000000 };

        P_baseline[0] = { 0.375000000,1.125000000,1.000000000,1.000000000,1.125000000,0.375000000 };
        P_baseline[1] = { 0.354134518,1.228459404,0.898117099,1.018547095,1.000741884,1.000741884,
                    1.018547095,0.898117099,1.228459404,0.354134518 };
        P_baseline[2] = { 0.315722926,1.390677390,0.629532984,1.234237262,0.919144328,1.009804636,
                    1.000880474,1.000880474,1.009804636,0.919144328,1.234237262,0.629532984,
                    1.390677390,0.315722926 };
      for (int k : {2,4,6}) {
        run_Qtest(k);
        run_Ptest(k);
    }
}

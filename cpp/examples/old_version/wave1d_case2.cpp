#include <iostream>
#include <fstream>
#include <sstream>
#include <cmath>
#include "mole.h"

using namespace std;

// Force function
arma::vec calculateForce(const Laplacian& L, const arma::vec& x, const double c_squared) {
    return c_squared * (L * x);
}

int main() {
    // Parameters
    constexpr int kAccuracyOrder = 4;
    constexpr int kNumCells = 101;
    constexpr double kLeftBoundary = 1.0;
    constexpr double kRightBoundary = 4.0;
    constexpr double kDx = (kRightBoundary - kLeftBoundary)/kNumCells;
    constexpr double kWaveSpeed = 100.0;
    constexpr double kWaveSpeedSquared = kWaveSpeed * kWaveSpeed;
    constexpr double kDt = kDx/(2*kWaveSpeed);
    constexpr double kTotalTime = 0.06;
    const int kNumSteps = static_cast<int>(std::round(kTotalTime/kDt));

    // Output filenames
    const string DATA_FILENAME = "wave1d_case2_solution.txt";
    const string GNUPLOT_SCRIPT = "plot_wave1d_case2.gnu";

    // Create staggered grid
    arma::vec xgrid = arma::linspace(kLeftBoundary, kRightBoundary, kNumCells+2);

    // Create Laplacian operator
    Laplacian L(kAccuracyOrder, kNumCells, kDx);

    // Initial conditions
    arma::vec u(kNumCells+2);
    for(int i = 0; i < kNumCells+2; i++) {
        double x = xgrid(i);
        u(i) = (x > 2.0 && x < 3.0) ? std::sin(M_PI * x) : 0.0;
    }
    arma::vec v = arma::zeros<arma::vec>(kNumCells+2);

    // Add before the time integration loop:
    constexpr double kSaveTimeInterval = 0.0012;  // Save every 0.0012 time units (50 frames over 0.06 time units)
    const int kSaveInterval = static_cast<int>(std::round(kSaveTimeInterval/kDt));
    ofstream data_file(DATA_FILENAME);
    if (!data_file) {
        cerr << "Error: Unable to open file for writing data.\n";
        return EXIT_FAILURE;
    }

    // Time integration loop
    for (int step = 0; step <= kNumSteps; step++) {
        // Position Verlet algorithm
        u += 0.5 * kDt * v;
        v += kDt * calculateForce(L, u, kWaveSpeedSquared);
        u += 0.5 * kDt * v;

        // Save solution at regular intervals
        if (step % kSaveInterval == 0) {
            data_file << "# t = " << step * kDt << "\n";
            for (int i = 0; i < kNumCells+2; i++) {
                data_file << xgrid(i) << " " << u(i) << "\n";
            }
            data_file << "\n\n";  // Double newline to separate timesteps
        }
    }
    data_file.close();

    // Generate GNUplot script
    ofstream plot_script(GNUPLOT_SCRIPT);
    if (!plot_script) {
        cerr << "Error: Failed to create GNUplot script.\n";
        return EXIT_FAILURE;
    }

    plot_script << "set title 'Wave Equation Solution (Case 2)'\n";
    plot_script << "set xlabel 'x'\n";
    plot_script << "set ylabel 'u(x)'\n";
    plot_script << "set grid\n";
    plot_script << "set yrange [-1.5:1.5]\n";
    plot_script << "set xrange [" << kLeftBoundary << ":" << kRightBoundary << "]\n";
    plot_script << "do for [i=0:" << kNumSteps/kSaveInterval << "] {\n";
    plot_script << "    plot '" << DATA_FILENAME << "' index i using 1:2 with lines title 'Wave Solution t = '.i\n";
    plot_script << "    pause 0.15\n";  // Adjust animation speed
    plot_script << "}\n";
    plot_script.close();

    // Execute GNUplot
    string gnuplot_command = "gnuplot -persist " + GNUPLOT_SCRIPT;
    if (system(gnuplot_command.c_str()) != 0) {
        cerr << "Error: Failed to execute GNUplot.\n";
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}

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
    constexpr int kAccuracyOrder = 2;     // Order of accuracy (spatial)
    constexpr int kNumCells = 50;         // Number of cells
    constexpr double kLeftBoundary = 0.0; // Left boundary
    constexpr double kRightBoundary = 1.0;// Right boundary
    constexpr double kDx = (kRightBoundary - kLeftBoundary)/kNumCells;  // Step length
    constexpr double kWaveSpeed = 2.0;    // Wave speed
    constexpr double kWaveSpeedSquared = kWaveSpeed * kWaveSpeed;  // Pre-compute c^2
    constexpr double kDt = kDx/(2*kWaveSpeed); // Time step (CFL condition)
    constexpr double kTotalTime = 1.0;    // Total simulation time
    const int kNumSteps = static_cast<int>(std::round(kTotalTime/kDt));

    // Output filenames
    const string DATA_FILENAME = "wave1d_solution.txt";
    const string GNUPLOT_SCRIPT = "plot_wave1d.gnu";

    // Create staggered grid
    arma::vec xgrid = arma::linspace(kLeftBoundary, kRightBoundary, kNumCells+2);

    // Create Laplacian operator
    Laplacian L(kAccuracyOrder, kNumCells, kDx);

    // Initial conditions
    arma::vec u = arma::sin(M_PI * xgrid);
    arma::vec v = arma::zeros<arma::vec>(kNumCells+2);

    // Add before the time integration loop:
    constexpr double kSaveTimeInterval = 0.02;  // Save every 0.02 time units (50 frames over 1.0 time units)
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

    plot_script << "set title 'Wave Equation Solution'\n";
    plot_script << "set xlabel 'x'\n";
    plot_script << "set ylabel 'u(x)'\n";
    plot_script << "set grid\n";
    plot_script << "set yrange [-1.5:1.5]\n";
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

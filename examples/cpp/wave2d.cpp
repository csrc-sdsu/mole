#include <iostream>
#include <fstream>
#include <sstream>
#include <cmath>
#include "mole.h"

using namespace std;

// Force calculation function
arma::vec calculateForce(const Laplacian& L, const arma::vec& u, const double c_squared) {
    return c_squared * (L * u);
}

int main() {
    // Parameters
    constexpr int kAccuracyOrder = 2;
    constexpr int kNumCells = 50;
    constexpr double kLeftBoundary = 0.0;
    constexpr double kRightBoundary = 1.0;
    constexpr double kBottomBoundary = 0.0;
    constexpr double kTopBoundary = 1.0;
    constexpr double kDx = (kRightBoundary - kLeftBoundary)/kNumCells;
    constexpr double kDy = (kTopBoundary - kBottomBoundary)/kNumCells;
    constexpr double kWaveSpeed = 1.0;
    constexpr double kWaveSpeedSquared = kWaveSpeed * kWaveSpeed;
    constexpr double kDt = kDx/(2*kWaveSpeed);
    constexpr double kTotalTime = 1.0;
    const int kNumSteps = static_cast<int>(std::round(kTotalTime/kDt));

    // Output filenames
    const string DATA_FILENAME = "wave2d_solution.txt";
    const string GNUPLOT_SCRIPT = "plot_wave2d.gnu";

    // Create 2D grid
    arma::vec xvals = arma::regspace(kLeftBoundary + kDx/2, kDx, kRightBoundary - kDx/2);
    xvals = arma::join_cols(arma::vec({kLeftBoundary}), arma::join_cols(xvals, arma::vec({kRightBoundary})));
    arma::vec yvals = arma::regspace(kBottomBoundary + kDy/2, kDy, kTopBoundary - kDy/2);
    yvals = arma::join_cols(arma::vec({kBottomBoundary}), arma::join_cols(yvals, arma::vec({kTopBoundary})));
    arma::mat X, Y;
    Utils Util_func;
    Util_func.meshgrid(xvals, yvals, X, Y);

    // Create operators
    Laplacian L(kAccuracyOrder, kNumCells, kNumCells, kDx, kDy);
    RobinBC BC(kAccuracyOrder, kNumCells, kDx, kNumCells, kDy, 1.0, 0.0);
    Interpol I(kNumCells, kNumCells, 0.5, 0.5);
    Interpol I2(true, kNumCells, kNumCells, 0.5, 0.5);

    // Combine operators
    auto combined = L + BC;
    auto I_scaled = kDt * I;
    auto I2_scaled = 0.5 * kDt * I2;

    // Initial conditions
    arma::mat U_init(kNumCells+2, kNumCells+2);
    for(size_t i = 0; i < kNumCells+2; ++i) {
        for(size_t j = 0; j < kNumCells+2; ++j) {
            U_init(i,j) = std::sin(M_PI * X(i,j)) * std::sin(M_PI * Y(i,j));
        }
    }
    arma::vec u = arma::vectorise(U_init);
    arma::vec v(I_scaled.n_rows, arma::fill::zeros);

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
        // Position Verlet with interpolation
        u += I2_scaled * v;
        v += I_scaled * calculateForce(L, u, kWaveSpeedSquared);
        u += I2_scaled * v;

        // Save solution at regular intervals
        if (step % kSaveInterval == 0) {
            arma::mat U_snapshot = arma::reshape(u, kNumCells+2, kNumCells+2);
            data_file << "# t = " << step * kDt << "\n";
            for (size_t i = 0; i < kNumCells+2; ++i) {
                for (size_t j = 0; j < kNumCells+2; ++j) {
                    data_file << X(i,j) << " " << Y(i,j) << " " << U_snapshot(i,j) << "\n";
                }
                data_file << "\n";
            }
            data_file << "\n";  // Extra newline to separate timesteps
        }
    }
    data_file.close();

    // Generate GNUplot script
    ofstream plot_script(GNUPLOT_SCRIPT);
    if (!plot_script) {
        cerr << "Error: Failed to create GNUplot script.\n";
        return EXIT_FAILURE;
    }

    plot_script << "set title 'Wave Equation Solution (2D)'\n";
    plot_script << "set xlabel 'x' offset 0,-1\n";
    plot_script << "set ylabel 'y' offset -2,0\n";
    plot_script << "set zlabel 'z' offset -2,0\n";
    plot_script << "set xrange [" << kLeftBoundary << ":" << kRightBoundary << "]\n";
    plot_script << "set yrange [" << kBottomBoundary << ":" << kTopBoundary << "]\n";
    plot_script << "set zrange [-1:1]\n";
    plot_script << "set view 60,30\n";
    plot_script << "set grid\n";
    plot_script << "set hidden3d\n";
    plot_script << "set pm3d\n";
    plot_script << "set style fill transparent solid 1.0\n";
    plot_script << "set tics out\n";
    plot_script << "set xtics 0.2\n";  // Adjusted for wave2d's domain
    plot_script << "set ytics 0.2\n";  // Adjusted for wave2d's domain
    plot_script << "set ztics 0.5\n";
    plot_script << "set palette defined (-1 'blue', 0 'white', 1 'red')\n";
    plot_script << "set cbrange [-1:1]\n";
    plot_script << "set border 31 lw 1\n";
    plot_script << "do for [i=0:" << kNumSteps/kSaveInterval << "] {\n";
    plot_script << "    splot '" << DATA_FILENAME << "' index i using 1:2:3 with pm3d title 'Wave Solution t = '.i\n";
    plot_script << "    pause 0.2\n";
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

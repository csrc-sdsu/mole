#include <iostream>
#include <fstream>
#include <sstream>
#include <cmath>
#include "mole.h"

using namespace std;

// Force calculation function
arma::vec calculateForce(const arma::sp_mat& combined, const arma::vec& u,
                        const double c_squared) {
    return c_squared * (combined * u);
}

// Create meshgrid helper function
void create_meshgrid(const arma::vec& x, const arma::vec& y, arma::mat& X, arma::mat& Y) {
    X = arma::repmat(x.t(), y.size(), 1);
    Y = arma::repmat(y, 1, x.size());
}

int main() {
    // Simulation parameters
    constexpr int kAccuracyOrder = 4;
    constexpr int kNumCellsX = 101;
    constexpr int kNumCellsY = 101;
    constexpr double kWestBoundary = -5.0;
    constexpr double kEastBoundary = 10.0;
    constexpr double kSouthBoundary = -5.0;
    constexpr double kNorthBoundary = 10.0;
    constexpr double kDx = (kEastBoundary - kWestBoundary) / kNumCellsX;
    constexpr double kDy = (kNorthBoundary - kSouthBoundary) / kNumCellsY;
    constexpr double kWaveSpeed = 100.0;
    constexpr double kWaveSpeedSquared = kWaveSpeed * kWaveSpeed;
    constexpr double kDt = kDx / (2 * kWaveSpeed);
    constexpr double kTotalTime = 0.3;
    const int kNumSteps = static_cast<int>(kTotalTime / kDt);

    // Output filenames
    const string DATA_FILENAME = "wave2d_case2_solution.txt";
    const string GNUPLOT_SCRIPT = "plot_wave2d_case2.gnu";

    // Create 2D grid
    arma::vec xgrid = arma::linspace(kWestBoundary, kEastBoundary, kNumCellsX + 2);
    arma::vec ygrid = arma::linspace(kSouthBoundary, kNorthBoundary, kNumCellsY + 2);
    arma::mat X, Y;
    Utils Util_func;
    Util_func.meshgrid(xgrid, ygrid, X, Y);

    // Create operators
    Laplacian L(kAccuracyOrder, kNumCellsX, kNumCellsY, kDx, kDy);
    RobinBC BC(kAccuracyOrder, kNumCellsX, kDx, kNumCellsY, kDy, 1.0, 0.0);
    Interpol I(kNumCellsX, kNumCellsY, 0.5, 0.5);
    Interpol I2(true, kNumCellsX, kNumCellsY, 0.5, 0.5);

    // Combine operators
    auto combined = L + BC;
    auto I_scaled = kDt * I;
    auto I2_scaled = 0.5 * kDt * I2;

    // Initial conditions
    arma::mat U_init(kNumCellsX + 2, kNumCellsY + 2);
    for (size_t i = 0; i < kNumCellsX + 2; ++i) {
        for (size_t j = 0; j < kNumCellsY + 2; ++j) {
            double x = X(i, j);
            double y = Y(i, j);
            U_init(i, j) = (x > 2.0 && x < 3.0 && y > 2.0 && y < 3.0)
                             ? std::sin(M_PI * x) * std::sin(M_PI * y)
                             : 0.0;
        }
    }
    arma::vec u = arma::vectorise(U_init);
    arma::vec v(I_scaled.n_rows, arma::fill::zeros);  // Use n_rows property

    // Add before the time integration loop:
    constexpr double kSaveTimeInterval = 0.006;  // Save every 0.006 time units (50 frames over 0.3 time units)
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
        v += I_scaled * calculateForce(combined, u, kWaveSpeedSquared);
        u += I2_scaled * v;

        // Save solution at regular intervals
        if (step % kSaveInterval == 0) {
            arma::mat U_snapshot = arma::reshape(u, kNumCellsX+2, kNumCellsY+2);
            data_file << "# t = " << step * kDt << "\n";
            for (size_t i = 0; i < kNumCellsX+2; ++i) {
                for (size_t j = 0; j < kNumCellsY+2; ++j) {
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

    plot_script << "set title 'Wave Equation Solution (2D Case 2)'\n";
    plot_script << "set xlabel 'x' offset 0,-1\n";
    plot_script << "set ylabel 'y' offset -2,0\n";
    plot_script << "set zlabel 'z' offset -2,0\n";
    plot_script << "set xrange [" << kWestBoundary << ":" << kEastBoundary << "]\n";
    plot_script << "set yrange [" << kSouthBoundary << ":" << kNorthBoundary << "]\n";
    plot_script << "set zrange [-1:1]\n";
    plot_script << "set view 60,30\n";
    plot_script << "set grid\n";
    plot_script << "set hidden3d\n";
    plot_script << "set pm3d\n";
    plot_script << "set style fill transparent solid 1.0\n";
    plot_script << "set tics out\n";
    plot_script << "set xtics 5\n";
    plot_script << "set ytics 5\n";
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

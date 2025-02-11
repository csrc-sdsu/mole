#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <cmath>
#include <chrono>
#include <thread>
#include <filesystem>
#include <gnuplot-iostream.h>
#include "laplacian.h"

// Force function (equivalent to MATLAB's F = @(x) (c^2)*L*x)
arma::vec calculateForce(const Laplacian& L, const arma::vec& x, const double c) {
    return (c * c) * (static_cast<const arma::sp_mat&>(L) * x);
}

int main() {
    // Parameters
    constexpr int kAccuracyOrder = 4;     // Order of accuracy (spatial)
    constexpr int kNumCells = 101;        // Number of cells
    constexpr double kLeftBoundary = 1.0; // Left boundary
    constexpr double kRightBoundary = 4.0;// Right boundary
    constexpr double kDx = (kRightBoundary - kLeftBoundary)/kNumCells;  // Step length
    constexpr double kWaveSpeed = 100.0;  // Wave speed (T/p) Tension over density
    constexpr double kDt = kDx/(2*kWaveSpeed); // Time step (CFL condition)
    constexpr double kTotalTime = 0.06;   // Total simulation time
    const int kNumSteps = static_cast<int>(std::floor(kTotalTime/kDt));
    constexpr bool kUseVerlet = true;     // If false, use Forest-Ruth algorithm
    const double kTheta = 1.0/(2.0-std::pow(2.0, 1.0/3.0)); // From Peter Young's paper

    // Create staggered grid (displacement nodes)
    arma::vec xgrid = arma::linspace(kLeftBoundary, kRightBoundary, kNumCells+2);

    // Create Laplacian operator (k=4 for 4th order accuracy)
    Laplacian L(kAccuracyOrder, kNumCells, kDx);

    // Initial conditions
    arma::vec u(kNumCells+2);
    for(int i = 0; i < kNumCells+2; i++) {
        double x = xgrid(i);
        u(i) = (x > 2.0 && x < 3.0) ? std::sin(M_PI * x) : 0.0;
    }
    arma::vec v = arma::zeros<arma::vec>(kNumCells+2);

    // Time integration loop
    for (int step = 0; step <= kNumSteps; step++) {
        if (kUseVerlet) {
            // Position Verlet algorithm
            u += 0.5 * kDt * v;
            v += kDt * calculateForce(L, u, kWaveSpeed);
            u += 0.5 * kDt * v;
        } else {
            // Forest-Ruth algorithm
            arma::vec unew = u + kTheta * 0.5 * kDt * v;
            arma::vec vnew = v + kTheta * kDt * calculateForce(L, unew, kWaveSpeed);
            
            unew = unew + (1.0-kTheta) * 0.5 * kDt * vnew;
            vnew = vnew + (1.0-2.0*kTheta) * kDt * calculateForce(L, unew, kWaveSpeed);
            
            unew = unew + (1.0-kTheta) * 0.5 * kDt * vnew;
            vnew = vnew + kTheta * kDt * calculateForce(L, unew, kWaveSpeed);
            
            unew = unew + kTheta * 0.5 * kDt * vnew;
            
            u = unew;
            v = vnew;
        }

        // Save data for plotting
        std::stringstream filename;
        filename << "solution_" << step << ".dat";
        std::ofstream outfile(filename.str());
        for (int i = 0; i < kNumCells+2; i++) {
            outfile << xgrid(i) << " " << u(i) << std::endl;
        }
        outfile.close();
    }

    // Plot using Gnuplot
    Gnuplot gp;
    gp << "set terminal qt title 'Wave Equation Simulation'\n";
    gp << "set xlabel 'x'\n";
    gp << "set ylabel 'u(x)'\n";
    gp << "set yrange [-1.5:1.5]\n";
    gp << "set grid\n";
    gp << "set style line 1 linewidth 2\n";
    
    // Animation loop
    for (int step = 0; step <= kNumSteps; step++) {
        gp << "set title '1D Wave equation t = " << step*kDt << "'\n";
        gp << "plot 'solution_" << step << ".dat' with lines linestyle 1 notitle\n";
        gp.flush();
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
    }

    std::cout << "Press Enter to exit and cleanup files..." << std::endl;
    std::cin.get();

    // Cleanup solution files using std::filesystem
    for (int step = 0; step <= kNumSteps; step++) {
        std::stringstream filename;
        filename << "solution_" << step << ".dat";
        std::error_code ec;
        std::filesystem::remove(filename.str(), ec);
        if (ec) {
            std::cerr << "Error deleting file " << filename.str() << ": " << ec.message() << std::endl;
        }
    }

    return 0;
}

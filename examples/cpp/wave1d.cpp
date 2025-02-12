#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <cmath>
#include <chrono>
#include <thread>
#include <filesystem>
#include "gnuplot-iostream.h"
#include "laplacian.h"

// Force function
arma::vec calculateForce(const Laplacian& L, const arma::vec& x, const double c_squared) {
    const arma::sp_mat& L_sp = static_cast<const arma::sp_mat&>(L);
    return c_squared * (L_sp * x);
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

    // Create staggered grid (displacement nodes)
    arma::vec xgrid = arma::linspace(kLeftBoundary, kRightBoundary, kNumCells+2);

    // Create Laplacian operator
    Laplacian L(kAccuracyOrder, kNumCells, kDx);

    // Initial conditions
    arma::vec u = arma::sin(M_PI * xgrid);
    arma::vec v = arma::zeros<arma::vec>(kNumCells+2);

    // Time integration loop
    for (int step = 0; step <= kNumSteps; step++) {
        // Save current state
        std::ofstream outfile("solution_" + std::to_string(step) + ".dat");
        for (int i = 0; i < kNumCells+2; i++) {
            outfile << xgrid(i) << " " << u(i) << std::endl;
        }
        outfile.close();

        // Position Verlet algorithm
        u += 0.5 * kDt * v;
        v += kDt * calculateForce(L, u, kWaveSpeedSquared);
        u += 0.5 * kDt * v;
    }

    // Plot using Gnuplot
    try {
        Gnuplot gp;
        gp << "set terminal qt title 'Wave Equation Simulation' size 800,600\n";
        gp << "set xlabel 'x'\n";
        gp << "set ylabel 'u(x)'\n";
        gp << "set xrange [" << kLeftBoundary << ":" << kRightBoundary << "]\n";
        gp << "set yrange [-1.5:1.5]\n";
        gp << "set grid\n";
        gp << "set style line 1 linewidth 2 lc rgb '#0060ad'\n";
        
        // Add multiple ways to exit
        gp << "bind 'q' 'exit gnuplot'\n";
        gp << "bind 'x' 'exit gnuplot'\n";
        gp << "bind 'ctrl-c' 'exit gnuplot'\n";
        
        std::cout << "Animation started. Press 'q' or 'x' to exit, or close the window.\n";
        
        volatile bool running = true;
        std::thread input_thread([&running]() {
            char c;
            while (running && std::cin.get(c)) {
                if (c == 'q' || c == 'x') {
                    running = false;
                    break;
                }
            }
        });
        input_thread.detach();

        for (int step = 0; step <= kNumSteps && running; step++) {
            gp << "set title '1D Wave equation t = " << std::fixed 
               << std::setprecision(3) << step*kDt << "'\n";
            gp << "plot 'solution_" << step 
               << ".dat' using 1:2 with lines linestyle 1 notitle\n";
            gp.flush();
            
            std::this_thread::sleep_for(std::chrono::milliseconds(50));
        }
    }
    catch (const std::exception& e) {
        std::cerr << "Error during plotting: " << e.what() << std::endl;
    }

    // Cleanup files
    for (int step = 0; step <= kNumSteps; step++) {
        std::filesystem::remove("solution_" + std::to_string(step) + ".dat");
    }

    return 0;
}

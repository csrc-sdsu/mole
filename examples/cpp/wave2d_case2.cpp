#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <cmath>
#include <chrono>
#include <thread>
#include <filesystem>
#include <iomanip>
#include "gnuplot-iostream.h"
#include "laplacian.h"
#include "robinbc.h"
#include "interpol.h"
#include <armadillo>

// Constants for color mapping
constexpr const char* kColorMapFile = "colormapwave2dcase2_rgb.txt";

// Helper function to convert RGB to hex color
std::string rgbToHex(double r, double g, double b) {
    std::stringstream ss;
    ss << "#" 
       << std::hex << std::setfill('0') << std::setw(2) << static_cast<int>(r * 255)
       << std::hex << std::setfill('0') << std::setw(2) << static_cast<int>(g * 255)
       << std::hex << std::setfill('0') << std::setw(2) << static_cast<int>(b * 255);
    return ss.str();
}

// Generate color palette definition
std::string generatePaletteDefinition() {
    std::ifstream file(kColorMapFile);
    std::stringstream palette;
    std::string line;
    int index = 0;
    
    palette << "set palette defined (";
    
    while (std::getline(file, line)) {
        std::stringstream line_stream(line);
        double r, g, b;
        char comma;
        line_stream >> r >> comma >> g >> comma >> b;
        
        if (index > 0) palette << ", ";
        palette << std::fixed << std::setprecision(6) 
                << (2.0 * (index/255.0) - 1.0) << " '" 
                << rgbToHex(r, g, b) << "'";
        index++;
    }
    
    palette << ")\n";
    return palette.str();
}

// Force calculation function
arma::vec calculateForce(const arma::sp_mat& combined, const arma::vec& u, const double c_squared) {
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

    // Create 2D grid
    arma::vec xgrid = arma::linspace(kWestBoundary, kEastBoundary, kNumCellsX + 2);
    arma::vec ygrid = arma::linspace(kSouthBoundary, kNorthBoundary, kNumCellsY + 2);
    arma::mat X, Y;
    create_meshgrid(xgrid, ygrid, X, Y);

    // Create operators
    Laplacian L(kAccuracyOrder, kNumCellsX, kNumCellsY, kDx, kDy);
    RobinBC BC(kAccuracyOrder, kNumCellsX, kDx, kNumCellsY, kDy, 1.0, 0.0);
    Interpol I(kNumCellsX, kNumCellsY, 0.5, 0.5);
    Interpol I2(true, kNumCellsX, kNumCellsY, 0.5, 0.5);

    // Cast and combine operators
    const arma::sp_mat& L_sp = static_cast<const arma::sp_mat&>(L);
    const arma::sp_mat& BC_sp = static_cast<const arma::sp_mat&>(BC);
    arma::sp_mat combined = L_sp + BC_sp;
    arma::sp_mat I_scaled = kDt * static_cast<arma::sp_mat>(I);
    arma::sp_mat I2_scaled = 0.5 * kDt * static_cast<arma::sp_mat>(I2);

    // Initial conditions
    arma::mat U_init(kNumCellsX + 2, kNumCellsY + 2);
    for(size_t i = 0; i < kNumCellsX + 2; ++i) {
        for(size_t j = 0; j < kNumCellsY + 2; ++j) {
            double x = X(i,j);
            double y = Y(i,j);
            U_init(i,j) = (x > 2.0 && x < 3.0 && y > 2.0 && y < 3.0) ?
                           std::sin(M_PI * x) * std::sin(M_PI * y) : 0.0;
        }
    }
    arma::vec u = arma::vectorise(U_init);
    arma::vec v = arma::zeros<arma::vec>(I_scaled.n_rows);
    
    // Time integration loop
    for (int step = 0; step <= kNumSteps; step++) {
        // Save current state
        arma::mat U_plot = arma::reshape(u, kNumCellsX + 2, kNumCellsY + 2);
        std::stringstream filename;
        filename << "solution2d_" << step << ".dat";
        std::ofstream outfile(filename.str());
        for (size_t i = 0; i < kNumCellsX + 2; ++i) {
            for (size_t j = 0; j < kNumCellsY + 2; ++j) {
                outfile << X(i,j) << " " << Y(i,j) << " " << U_plot(i,j) << std::endl;
            }
            outfile << std::endl;
        }
        outfile.close();

        // Position Verlet with interpolation
        u += I2_scaled * v;
        v += I_scaled * calculateForce(combined, u, kWaveSpeedSquared);
        u += I2_scaled * v;
    }
    // Plot using Gnuplot
    try {
        // freopen("/dev/null", "w", stderr);
        Gnuplot gp;
        gp << "set terminal qt title 'Wave2D Equation Simulation' size 800,600\n";
        gp << "set xlabel 'x' offset 0,-1\n";
        gp << "set ylabel 'y' offset -2,0\n";
        gp << "set zlabel 'z' offset -2,0\n";
        gp << "set xrange [" << kWestBoundary << ":" << kEastBoundary << "]\n";
        gp << "set yrange [" << kSouthBoundary << ":" << kNorthBoundary << "]\n";
        gp << "set zrange [-1:1]\n";
        gp << "set view 60,30\n";
        gp << "set style data lines\n";
        gp << "set hidden3d\n";
        gp << "set pm3d\n";
        gp << "set style fill transparent solid 1.0\n";
        gp << "set grid\n";
        gp << "set tics out\n";
        gp << "set xtics 5\n";
        gp << "set ytics 5\n";
        gp << "set ztics 0.5\n";
        gp << generatePaletteDefinition();
        gp << "set cbrange [-1:1]\n";
        gp << "set colorbox\n";
        gp << "set border 31 lw 1\n";
        gp << "set key off\n";
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
            gp << "set title '2D Wave equation t = " 
               << std::fixed << std::setprecision(3) << step*kDt << "'\n";
            gp << "splot 'solution2d_" << step 
               << ".dat' using 1:2:3 with pm3d at s title ''\n";
            gp.flush();
            std::this_thread::sleep_for(std::chrono::milliseconds(75));
        }
    }
    catch (const std::exception& e) {
        std::cerr << "Error during plotting: " << e.what() << std::endl;
    }

    // Cleanup files
    for (int step = 0; step <= kNumSteps; step++) {
        std::filesystem::remove("solution2d_" + std::to_string(step) + ".dat");
    }

    return 0;
}

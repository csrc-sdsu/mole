#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <cmath>
#include <chrono>
#include <thread>
#include <filesystem>
#include <iomanip>  // Add this for std::hex and std::setfill
#include "gnuplot-iostream.h"
#include "laplacian.h" 
#include "robinbc.h"
#include "interpol.h"
#include <armadillo>

// Add these new functions at the start, after the includes
std::string rgbToHex(double r, double g, double b) {
    int ri = static_cast<int>(r * 255);
    int gi = static_cast<int>(g * 255);
    int bi = static_cast<int>(b * 255);
    std::stringstream ss;
    ss << "#" 
       << std::hex << std::setfill('0') << std::setw(2) << ri
       << std::hex << std::setfill('0') << std::setw(2) << gi 
       << std::hex << std::setfill('0') << std::setw(2) << bi;
    return ss.str();
}

std::stringstream generatePaletteDefinition() {
    std::ifstream file("colormap_rgb.txt");
    std::string line;
    std::vector<std::string> colors;
    int index = 0;
    
    while (std::getline(file, line)) {
        std::stringstream ss(line);
        double r, g, b;
        char comma;
        ss >> r >> comma >> g >> comma >> b;
        colors.push_back(std::to_string(2.0 * (index/255.0) - 1.0) + " '" + rgbToHex(r, g, b) + "'");
        index++;
    }
    
    std::stringstream palette;
    palette << "set palette defined (";
    for (size_t i = 0; i < colors.size(); ++i) {
        palette << colors[i];
        if (i < colors.size() - 1) palette << ", ";
    }
    palette << ")\n";
    
    return palette;
}

void create_meshgrid(const arma::vec& x, const arma::vec& y, arma::mat& X, arma::mat& Y) {
    X = arma::repmat(x.t(), y.size(), 1);
    Y = arma::repmat(y, 1, x.size());
}

int main() {
    // Parameters
    constexpr int kAccuracyOrder = 2;     // Order of accuracy
    constexpr int kNumCells = 50;         // Number of cells
    constexpr double kLeftBoundary = 0.0; // West boundary
    constexpr double kRightBoundary = 1.0;// East boundary
    constexpr double kBottomBoundary = 0.0;// South boundary
    constexpr double kTopBoundary = 1.0;  // North boundary
    constexpr double kDx = (kRightBoundary - kLeftBoundary)/kNumCells; // Step length x
    constexpr double kDy = (kTopBoundary - kBottomBoundary)/kNumCells; // Step length y
    constexpr double kWaveSpeed = 1.0;    // Wave speed
    constexpr double kWaveSpeedSquared = kWaveSpeed * kWaveSpeed;  // Pre-compute c^2
    constexpr double kDt = kDx/(2*kWaveSpeed); // Time step (CFL condition)
    constexpr double kTotalTime = 1.0;    // Total simulation time
    const int kNumSteps = static_cast<int>(std::round(kTotalTime/kDt));

    // Create staggered grid
    arma::vec xvals = arma::regspace(kLeftBoundary + kDx/2, kDx, kRightBoundary - kDx/2);
    xvals = arma::join_cols(arma::vec({kLeftBoundary}), arma::join_cols(xvals, arma::vec({kRightBoundary})));
    arma::vec yvals = arma::regspace(kBottomBoundary + kDy/2, kDy, kTopBoundary - kDy/2);
    yvals = arma::join_cols(arma::vec({kBottomBoundary}), arma::join_cols(yvals, arma::vec({kTopBoundary})));
    arma::mat X, Y;
    create_meshgrid(xvals, yvals, X, Y);

    // Create operators
    Laplacian L(kAccuracyOrder, kNumCells, kNumCells, kDx, kDy);
    RobinBC BC(kAccuracyOrder, kNumCells, kDx, kNumCells, kDy, 1.0, 0.0);
    Interpol I(kNumCells, kNumCells, 0.5, 0.5);
    Interpol I2(true, kNumCells, kNumCells, 0.5, 0.5);

    // Cast and combine operators
    const arma::sp_mat& L_sp = static_cast<const arma::sp_mat&>(L);
    const arma::sp_mat& BC_sp = static_cast<const arma::sp_mat&>(BC);
    arma::sp_mat I_sp = static_cast<arma::sp_mat>(I);
    arma::sp_mat I2_sp = static_cast<arma::sp_mat>(I2);
    arma::sp_mat combined = L_sp + BC_sp;

    // Scale interpolation operators
    I_sp = kDt * I_sp;
    I2_sp = 0.5 * kDt * I2_sp;

    // Initial conditions
    arma::mat U_init(kNumCells+2, kNumCells+2);
    for(size_t i = 0; i < kNumCells+2; ++i) {
        for(size_t j = 0; j < kNumCells+2; ++j) {
            U_init(i,j) = std::sin(M_PI * X(i,j)) * std::sin(M_PI * Y(i,j));
        }
    }
    arma::vec u = arma::vectorise(U_init);
    arma::vec v = arma::zeros<arma::vec>(I_sp.n_rows);

    // Time integration loop
    for (int step = 0; step <= kNumSteps; step++) {
        // Save current state
        arma::mat U_plot = arma::reshape(u, kNumCells+2, kNumCells+2);
        std::stringstream filename;
        filename << "solution_" << step << ".dat";
        std::ofstream outfile(filename.str());
        for (size_t i = 0; i < kNumCells+2; ++i) {
            for (size_t j = 0; j < kNumCells+2; ++j) {
                outfile << X(i,j) << " " << Y(i,j) << " " << U_plot(i,j) << std::endl;
            }
            outfile << std::endl;
        }
        outfile.close();

        // Position Verlet with interpolation
        u += I2_sp * v;
        arma::vec Lu = combined * u;
        arma::vec F = kWaveSpeedSquared * Lu;
        v += I_sp * F;
        u += I2_sp * v;
    }

    // Plot using Gnuplot
    try {
        Gnuplot gp;
        gp << "set terminal qt title 'Wave Equation Simulation' size 800,600\n";
        gp << "set xlabel 'x'\n";
        gp << "set ylabel 'y'\n";
        gp << "set zlabel 'z'\n";
        gp << "set view 60,30\n";
        gp << generatePaletteDefinition().str();
        gp << "set zrange [-1:1]\n";
        gp << "set cbrange [-1:1]\n";
        gp << "set style data lines\n";
        gp << "unset hidden3d\n";  // Show all lines
        gp << "set grid noxtics noytics noztics\n";  // Disable default grid
        gp << "set xyplane 0\n";
        gp << "set style fill solid 0.7\n";
        gp << "bind 'q' 'exit gnuplot'\n";
        gp << "bind 'x' 'exit gnuplot'\n";
        
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
            gp << "set title 'Elastic membrane with position Verlet Time = " 
               << std::fixed << std::setprecision(2) << step*kDt << "'\n";
            gp << "splot 'solution_" << step 
               << ".dat' using 1:2:3 with lines lc palette lw 1.5 notitle, "
               << "'solution_" << step 
               << ".dat' using 1:2:3 with points pt 7 ps 0.1 lc rgb 'white' notitle\n";
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

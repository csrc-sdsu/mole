#include <iostream>
#include <fstream>
#include <vector>
#include <cmath>
#include <chrono>
#include <thread>
#include <gnuplot-iostream.h>
#include "./src/cpp/laplacian.h" 
#include "./src/cpp/robinbc.h"
#include "./src/cpp/interpol.h"
#include <armadillo>

void create_meshgrid(const arma::vec& x, const arma::vec& y, arma::mat& X, arma::mat& Y) {
    X = arma::repmat(x.t(), y.size(), 1);
    Y = arma::repmat(y, 1, x.size());
}

int main() {
    // Parameters
    const int k = 4;           // Order of accuracy
    const int m = 101;         // Spatial resolution
    const int n = m;           // Spatial resolution
    const double a = -5.0;     // West boundary
    const double b = 10.0;     // East boundary
    const double c = -5.0;     // South boundary
    const double d = 10.0;     // North boundary
    const double dx = (b-a)/m; // Step length along x-axis
    const double dy = (d-c)/n; // Step length along y-axis
    const double speed = 100.0;// Wave speed
    const double dt = dx/(2*speed); // Time step (CFL condition)
    const double T = 0.3;      // Total simulation time
    const int n_steps = static_cast<int>(T/dt);

    // Create 2D grid
    arma::vec xgrid = arma::linspace(a, b, m+2);
    arma::vec ygrid = arma::linspace(c, d, n+2);
    arma::mat X, Y;
    create_meshgrid(xgrid, ygrid, X, Y);

    // Calculate dimensions
    const int total_points = (m+2) * (n+2);
    const int interior_points = m * n;
    
    // Create operators
    Laplacian L(k, m, n, dx, dy);
    RobinBC BC(k, m, dx, n, dy, 1.0, 0.0);
    
    // Create interpolation operators
    Interpol I(m, n, 0.5, 0.5);          // Regular interpolation
    Interpol I2(true, m, n, 0.5, 0.5);   // Second type interpolation

    // Cast and combine operators
    const arma::sp_mat& L_sp = static_cast<const arma::sp_mat&>(L);
    const arma::sp_mat& BC_sp = static_cast<const arma::sp_mat&>(BC);
    arma::sp_mat I_sp = static_cast<arma::sp_mat>(I);
    arma::sp_mat I2_sp = static_cast<arma::sp_mat>(I2);
    arma::sp_mat combined = L_sp + BC_sp;

    // Scale interpolation operators
    arma::sp_mat I_scaled = dt * I_sp;
    arma::sp_mat I2_scaled = 0.5 * dt * I2_sp;

    // Initial conditions
    arma::mat U_init(m+2, n+2);
    for(size_t i = 0; i < m+2; ++i) {
        for(size_t j = 0; j < n+2; ++j) {
            double x = X(i,j);
            double y = Y(i,j);
            U_init(i,j) = (x > 2.0 && x < 3.0 && y > 2.0 && y < 3.0) ? 
                          std::sin(M_PI * x) * std::sin(M_PI * y) : 0.0;
        }
    }
    arma::vec u = arma::vectorise(U_init);
    
    // Initialize velocity vector with correct dimensions
    arma::vec v = arma::zeros<arma::vec>(I_sp.n_rows);

    // Print detailed dimensions for debugging
    std::cout << "Grid points: " << total_points << std::endl;
    std::cout << "Interior points: " << interior_points << std::endl;
    std::cout << "I matrix dimensions: " << I_sp.n_rows << "x" << I_sp.n_cols << std::endl;
    std::cout << "I2 matrix dimensions: " << I2_sp.n_rows << "x" << I2_sp.n_cols << std::endl;
    std::cout << "Combined operator dimensions: " << combined.n_rows << "x" << combined.n_cols << std::endl;
    std::cout << "Initial u vector size: " << u.n_elem << std::endl;
    std::cout << "Initial v vector size: " << v.n_elem << std::endl;
    
    // Verify matrix multiplication compatibility
    if (I2_sp.n_cols != v.n_elem) {
        std::cerr << "Error: Incompatible dimensions for I2 * v multiplication" << std::endl;
        std::cerr << "I2 cols: " << I2_sp.n_cols << ", v size: " << v.n_elem << std::endl;
        return 1;
    }
    if (combined.n_cols != u.n_elem) {
        std::cerr << "Error: Incompatible dimensions for combined * u multiplication" << std::endl;
        std::cerr << "Combined cols: " << combined.n_cols << ", u size: " << u.n_elem << std::endl;
        return 1;
    }
    if (I_sp.n_cols != u.n_elem) {
        std::cerr << "Error: Incompatible dimensions for I * F multiplication" << std::endl;
        std::cerr << "I cols: " << I_sp.n_cols << ", u size: " << u.n_elem << std::endl;
        return 1;
    }

    // Time integration (Position Verlet)
    for (int step = 0; step <= n_steps; step++) {
        // Position Verlet with interpolation
        u += I2_scaled * v;
        arma::vec Lu = combined * u;
        arma::vec F = speed * speed * Lu;
        v += I_scaled * F;
        u += I2_scaled * v;

        // Reshape for plotting
        arma::mat U_plot = arma::reshape(u, m+2, n+2);

        // Save data for plotting
        std::ofstream outfile("solution2d_" + std::to_string(step) + ".dat");
        for (size_t i = 0; i < m+2; ++i) {
            for (size_t j = 0; j < n+2; ++j) {
                outfile << X(i,j) << " " << Y(i,j) << " " << U_plot(i,j) << std::endl;
            }
            outfile << std::endl;
        }
    }

    // Plot using Gnuplot
    Gnuplot gp;
    gp << "set terminal qt size 1200,800 font 'Arial,12'\n";
    
    // Set axis labels and ranges
    gp << "set xlabel 'x' offset 0,-1\n";
    gp << "set ylabel 'y' offset -2,0\n";
    gp << "set zlabel 'z' offset -2,0\n";
    gp << "set xrange [-5:10]\n";
    gp << "set yrange [-5:10]\n";
    gp << "set zrange [-1:1]\n";
    
    // Set view and style
    gp << "set view 60,30\n";
    gp << "set style data lines\n";
    gp << "set hidden3d\n";
    gp << "set pm3d\n";
    gp << "set style fill transparent solid 0.8\n";
    
    // Configure grid and tics
    gp << "set grid\n";
    gp << "set tics out\n";
    gp << "set xtics 5\n";
    gp << "set ytics 5\n";
    gp << "set ztics 0.5\n";
    
    // Set color scheme similar to turbo colormap
    gp << "set palette defined (\\\n";
    gp << "    -0.08 '#000080',\\\n";  // Dark blue
    gp << "    -0.04 '#0000FF',\\\n";  // Blue
    gp << "    0.00  '#00FFFF',\\\n";  // Cyan
    gp << "    0.04  '#00FF00',\\\n";  // Green
    gp << "    0.08  '#FFFF00')\n";    // Yellow
    gp << "set cbrange [-0.08:0.08]\n";
    gp << "set colorbox\n";
    
    // Set border and background
    gp << "set border 31 lw 1\n";
    gp << "set key off\n";
    
    // Animation loop
    for (int step = 0; step <= n_steps; step++) {
        gp << "set title '2D Wave equation solved with MOLE, Time = " 
           << std::fixed << std::setprecision(2) << step*dt << "'\n";
        gp << "splot 'solution2d_" << step 
           << ".dat' using 1:2:3 with pm3d at s title ''\n";
        gp.flush();
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
    }

    return 0;
}

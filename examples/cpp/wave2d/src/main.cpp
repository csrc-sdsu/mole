#include "../include/Wave2DSolver.hpp"
#include "../include/Wave2DVisualizer.hpp"
#include <iostream>
#include <iomanip>
#include <filesystem>

int main() {
    // Create and initialize solver
    Wave2DSolver solver;
    solver.solve();

    // Get results
    const auto& solution_history = solver.getSolutionHistory();
    const auto& X = solver.getX();
    const auto& Y = solver.getY();
    
#ifdef ENABLE_VISUALIZATION
    // Create visualizer only if visualization is enabled
    Wave2DVisualizer visualizer;
    if (!visualizer.initialize()) {
        std::cerr << "Failed to initialize visualizer\n";
        return 1;
    }

    std::cout << "Animation started. Press 'q' or 'x' to exit, or close the window.\n";

    // Visualization loop
    for (size_t i = 0; i < solution_history.size(); ++i) {
        std::string filename = "solution2d_" + std::to_string(i) + ".dat";
        
        if (!visualizer.visualize(X, Y, solution_history[i], i * solver.getDt(), filename)) {
            std::cerr << "Visualization failed at step " << i << "\n";
            break;
        }
    }

    visualizer.cleanup();
#else
    // Create solutions directory with error checking
    std::string solutions_dir = "solutions";
    try {
        if (!std::filesystem::create_directory(solutions_dir)) {
            if (!std::filesystem::exists(solutions_dir)) {
                std::cerr << "Error: Could not create directory '" << solutions_dir << "'\n";
                return 1;
            }
        }
        std::cout << "\nCreated solutions directory: " << solutions_dir << "\n";
    } catch (const std::filesystem::filesystem_error& e) {
        std::cerr << "Error creating directory: " << e.what() << "\n";
        return 1;
    }

    // Print computation information
    std::cout << "Computation completed without visualization.\n";
    std::cout << "Number of time steps computed: " << solution_history.size() << "\n";
    std::cout << "Time step size (dt): " << solver.getDt() << "\n";
    std::cout << "Domain: x=[" << solver.getWestBoundary() << "," << solver.getEastBoundary() 
              << "], y=[" << solver.getSouthBoundary() << "," << solver.getNorthBoundary() << "]\n\n";

    // Save solutions with full path
    const int save_intervals = 5;
    for (size_t step = 0; step < solution_history.size(); step += save_intervals) {
        std::string filename = solutions_dir + "/solution_t" + 
                             std::to_string(step * solver.getDt()) + ".dat";
        
        std::ofstream outfile(filename);
        if (!outfile.is_open()) {
            std::cerr << "Error: Could not open file for writing: " << filename << "\n";
            continue;
        }

        outfile << "# Time = " << step * solver.getDt() << "\n";
        outfile << "# x y z\n";
        for (size_t i = 0; i < X.n_rows; ++i) {
            for (size_t j = 0; j < X.n_cols; ++j) {
                outfile << std::setprecision(6) << std::fixed
                       << X(i,j) << " " 
                       << Y(i,j) << " " 
                       << solution_history[step](i,j) << "\n";
            }
            outfile << "\n";  // Add blank line between rows for gnuplot
        }
        outfile.close();
        std::cout << "Saved solution file: " << filename << "\n";
    }

    // Save final solution with different statistics
    std::string final_filename = solutions_dir + "/final_solution.dat";
    std::ofstream final_outfile(final_filename);
    if (!final_outfile.is_open()) {
        std::cerr << "Error: Could not open final solution file: " << final_filename << "\n";
        return 1;
    }

    // Add header with statistics
    final_outfile << "# Final solution at time = " 
                 << (solution_history.size() - 1) * solver.getDt() << "\n";
    final_outfile << "# Domain: x=[" << solver.getWestBoundary() 
                 << "," << solver.getEastBoundary() << "] "
                 << "y=[" << solver.getSouthBoundary() 
                 << "," << solver.getNorthBoundary() << "]\n";
    final_outfile << "# x y z\n";

    // Calculate min and max values
    double min_val = solution_history.back().min();
    double max_val = solution_history.back().max();

    final_outfile << "# Min value: " << min_val << "\n";
    final_outfile << "# Max value: " << max_val << "\n\n";

    // Write the solution data
    for (size_t i = 0; i < X.n_rows; ++i) {
        for (size_t j = 0; j < X.n_cols; ++j) {
            final_outfile << std::setprecision(6) << std::fixed
                       << X(i,j) << " " 
                       << Y(i,j) << " " 
                       << solution_history.back()(i,j) << "\n";
        }
        final_outfile << "\n";
    }
    final_outfile.close();

    std::cout << "\nSolutions saved in 'solutions' directory:\n";
    std::cout << "- Intermediate solutions saved every " << save_intervals << " steps\n";
    std::cout << "- Final solution saved as 'final_solution.dat'\n";
    std::cout << "- Use 'gnuplot' to visualize the saved solutions\n\n";
    
    // Print gnuplot visualization instructions
    std::cout << "To visualize saved solutions using gnuplot:\n";
    std::cout << "1. Start gnuplot\n";
    std::cout << "2. Type the following commands:\n";
    std::cout << "   set pm3d\n";
    std::cout << "   set view 60,30\n";
    std::cout << "   splot 'solutions/final_solution.dat' using 1:2:3 with pm3d\n\n";
#endif

    return 0;
}
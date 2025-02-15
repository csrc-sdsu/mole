#include "../include/Wave2DVisualizer.hpp"
#include <fstream>
#include <sstream>
#include <iomanip>

Wave2DVisualizer::Wave2DVisualizer() {
#ifdef ENABLE_VISUALIZATION
    gp = nullptr;
#endif
}

bool Wave2DVisualizer::initialize() {
#ifdef ENABLE_VISUALIZATION
    try {
        gp = new Gnuplot();
        *gp << "set terminal qt title 'Wave2D Equation Simulation' size 800,600\n";
        *gp << "set xlabel 'x' offset 0,-1\n";
        *gp << "set ylabel 'y' offset -2,0\n";
        *gp << "set zlabel 'z' offset -2,0\n";
        *gp << "set zrange [-1:1]\n";
        *gp << "set cbrange [-1:1]\n";
        *gp << "set view 60,30\n";
        *gp << "set style data lines\n";
        *gp << "set hidden3d\n";
        *gp << "set pm3d\n";
        *gp << "set style fill transparent solid 1.0\n";
        *gp << "set grid\n";
        *gp << "set tics out\n";
        *gp << "set xtics 5\n";
        *gp << "set ytics 5\n";
        *gp << "set ztics 0.5\n";
        // Use the specific colormap file
        std::string colormap_file = "../src/colormap_rgb.txt";
        if (!std::filesystem::exists(colormap_file)) {
            std::cerr << "Warning: Colormap file not found at " << colormap_file << "\n";
            *gp << "set palette defined (-1 'blue', 0 'white', 1 'red')\n";
        } else {
            *gp << generatePaletteDefinition(colormap_file) << "\n";
            std::cout << "Successfully loaded colormap from: " << colormap_file << "\n";
        }
        *gp << "set colorbox\n";
        *gp << "set border 31 lw 1\n";
        *gp << "bind 'q' 'exit gnuplot'\n";
        *gp << "bind 'x' 'exit gnuplot'\n";
        return true;
    }
    catch (const std::exception& e) {
        std::cerr << "Error in initialization: " << e.what() << "\n";
        return false;
    }
#else
    return false;
#endif
}

bool Wave2DVisualizer::visualize(const arma::mat& X, const arma::mat& Y,
                               const arma::mat& solution,
                               double time,
                               const std::string& filename) {
#ifdef ENABLE_VISUALIZATION
    try {
        // Save data to temporary file
        std::ofstream outfile(filename);
        for (size_t i = 0; i < X.n_rows; ++i) {
            for (size_t j = 0; j < X.n_cols; ++j) {
                outfile << X(i,j) << " " << Y(i,j) << " " << solution(i,j) << std::endl;
            }
            outfile << std::endl;
        }
        outfile.close();

        // Plot the data
        std::stringstream title;
        title << "set title '2D Wave equation t = " 
              << std::fixed << std::setprecision(3) << time << "'\n";
        *gp << title.str();
        
        std::stringstream plot_cmd;
        plot_cmd << "splot '" << filename 
                << "' using 1:2:3 with pm3d at s title ''\n";
        *gp << plot_cmd.str();
        gp->flush();

        return true;
    }
    catch (const std::exception& e) {
        return false;
    }
#else
    return false;
#endif
}

void Wave2DVisualizer::cleanup() {
#ifdef ENABLE_VISUALIZATION
    delete gp;
    gp = nullptr;
#endif
}

#ifdef ENABLE_VISUALIZATION
std::string Wave2DVisualizer::rgbToHex(double r, double g, double b) {
    std::stringstream ss;
    ss << "#" 
       << std::hex << std::setfill('0') << std::setw(2) << static_cast<int>(r * 255)
       << std::hex << std::setfill('0') << std::setw(2) << static_cast<int>(g * 255)
       << std::hex << std::setfill('0') << std::setw(2) << static_cast<int>(b * 255);
    return ss.str();
}

std::string Wave2DVisualizer::generatePaletteDefinition(const std::string& colormap_file) {
    std::ifstream file(colormap_file);
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
    
    palette << ")";
    return palette.str();
}
#endif
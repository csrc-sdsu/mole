// Wave2DVisualizer.hpp
#ifndef WAVE2D_VISUALIZER_HPP
#define WAVE2D_VISUALIZER_HPP

#ifdef ENABLE_VISUALIZATION
#include "examples/cpp/gnuplot-iostream.h"
#endif
#include <string>
#include <armadillo>
#include <vector>

class Wave2DVisualizer {
public:
    Wave2DVisualizer();
    bool initialize();
    bool visualize(const arma::mat& X, const arma::mat& Y,
                  const arma::mat& solution,
                  double time,
                  const std::string& filename);
    void cleanup();

private:
#ifdef ENABLE_VISUALIZATION
    Gnuplot* gp;
    std::string generatePaletteDefinition(const std::string& colormap_file);
    std::string rgbToHex(double r, double g, double b);
#endif
};

#endif // WAVE2D_VISUALIZER_HPP
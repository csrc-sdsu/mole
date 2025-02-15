#ifndef WAVE2D_SOLVER_HPP
#define WAVE2D_SOLVER_HPP

#include <armadillo>
#include <vector>
#include <cmath>
#include "src/cpp/laplacian.h"
#include "src/cpp/robinbc.h"
#include "src/cpp/interpol.h"

class Wave2DSolver {
private:
    // Class constants
    static const int DEFAULT_ACCURACY_ORDER = 4;
    static const int DEFAULT_NUM_CELLS = 101;
    
    // Member variables
    const int accuracy_order;
    const int num_cells_x;
    const int num_cells_y;
    const double west_boundary;
    const double east_boundary;
    const double south_boundary;
    const double north_boundary;
    const double dx;
    const double dy;
    const double wave_speed;
    const double dt;
    const double total_time;
    const int num_steps;

    // Grid and solution data
    arma::mat X, Y;
    arma::vec u, v;
    std::vector<arma::mat> solution_history;

    // Operators
    arma::sp_mat combined;
    arma::sp_mat I_scaled;
    arma::sp_mat I2_scaled;

    void create_meshgrid(const arma::vec& x, const arma::vec& y, arma::mat& X, arma::mat& Y);
    arma::vec calculateForce(const arma::sp_mat& combined, const arma::vec& u, const double c_squared);

public:
    Wave2DSolver(int order = DEFAULT_ACCURACY_ORDER, 
                int cells = DEFAULT_NUM_CELLS);
    
    void initialize();
    void solve();

    // Accessor methods
    const std::vector<arma::mat>& getSolutionHistory() const;
    const arma::mat& getX() const;
    const arma::mat& getY() const;
    int getNumSteps() const;
    double getDt() const;
    double getWestBoundary() const;
    double getEastBoundary() const;
    double getSouthBoundary() const;
    double getNorthBoundary() const;
};

#endif // WAVE2D_SOLVER_HPP
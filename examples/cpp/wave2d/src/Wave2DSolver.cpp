#include "../include/Wave2DSolver.hpp"

Wave2DSolver::Wave2DSolver(int order, int cells)
    : accuracy_order(order),
      num_cells_x(cells),
      num_cells_y(cells),
      west_boundary(-5.0),
      east_boundary(10.0),
      south_boundary(-5.0),
      north_boundary(10.0),
      dx((east_boundary - west_boundary) / num_cells_x),
      dy((north_boundary - south_boundary) / num_cells_y),
      wave_speed(100.0),
      dt(dx / (2 * wave_speed)),
      total_time(0.3),
      num_steps(static_cast<int>(total_time / dt))
{
    initialize();
}

void Wave2DSolver::create_meshgrid(const arma::vec& x, const arma::vec& y, arma::mat& X, arma::mat& Y) {
    X = arma::repmat(x.t(), y.size(), 1);
    Y = arma::repmat(y, 1, x.size());
}

arma::vec Wave2DSolver::calculateForce(const arma::sp_mat& combined, const arma::vec& u, const double c_squared) {
    return c_squared * (combined * u);
}

void Wave2DSolver::initialize() {
    // Create 2D grid
    arma::vec xgrid = arma::linspace(west_boundary, east_boundary, num_cells_x + 2);
    arma::vec ygrid = arma::linspace(south_boundary, north_boundary, num_cells_y + 2);
    create_meshgrid(xgrid, ygrid, X, Y);

    // Create operators
    Laplacian L(accuracy_order, num_cells_x, num_cells_y, dx, dy);
    RobinBC BC(accuracy_order, num_cells_x, dx, num_cells_y, dy, 1.0, 0.0);
    Interpol I(num_cells_x, num_cells_y, 0.5, 0.5);
    Interpol I2(true, num_cells_x, num_cells_y, 0.5, 0.5);

    // Cast and combine operators
    const arma::sp_mat& L_sp = static_cast<const arma::sp_mat&>(L);
    const arma::sp_mat& BC_sp = static_cast<const arma::sp_mat&>(BC);
    combined = L_sp + BC_sp;
    I_scaled = dt * static_cast<arma::sp_mat>(I);
    I2_scaled = 0.5 * dt * static_cast<arma::sp_mat>(I2);

    // Set initial conditions
    arma::mat U_init(num_cells_x + 2, num_cells_y + 2);
    for(size_t i = 0; i < num_cells_x + 2; ++i) {
        for(size_t j = 0; j < num_cells_y + 2; ++j) {
            double x = X(i,j);
            double y = Y(i,j);
            U_init(i,j) = (x > 2.0 && x < 3.0 && y > 2.0 && y < 3.0) ?
                           std::sin(M_PI * x) * std::sin(M_PI * y) : 0.0;
        }
    }
    u = arma::vectorise(U_init);
    v = arma::zeros<arma::vec>(I_scaled.n_rows);
}

void Wave2DSolver::solve() {
    solution_history.clear();
    solution_history.reserve(num_steps + 1);

    for (int step = 0; step <= num_steps; step++) {
        // Save current state
        solution_history.push_back(arma::reshape(u, num_cells_x + 2, num_cells_y + 2));

        // Position Verlet with interpolation
        u += I2_scaled * v;
        v += I_scaled * calculateForce(combined, u, wave_speed * wave_speed);
        u += I2_scaled * v;
    }
}

// Accessor method implementations
const std::vector<arma::mat>& Wave2DSolver::getSolutionHistory() const { return solution_history; }
const arma::mat& Wave2DSolver::getX() const { return X; }
const arma::mat& Wave2DSolver::getY() const { return Y; }
int Wave2DSolver::getNumSteps() const { return num_steps; }
double Wave2DSolver::getDt() const { return dt; }
double Wave2DSolver::getWestBoundary() const { return west_boundary; }
double Wave2DSolver::getEastBoundary() const { return east_boundary; }
double Wave2DSolver::getSouthBoundary() const { return south_boundary; }
double Wave2DSolver::getNorthBoundary() const { return north_boundary; }
#include "MOLE_grids.h"
#include <iostream>

int main() {
    gridParams2D p;
    p.topology = 'u';
    p.m = 3; p.n = 3;
    p.dx = 1.0; p.dy = 1.0;

    grid2D g(p);
    if (!g.validGrid()) {
        g.print_ErrorLog();
        return 1;
    }
    std::cout << "grid2D built OK, nodes_X is "
              << g.grid.nodes_X.rows() << " x " << g.grid.nodes_X.cols()
              << "\n";
    return 0;
}

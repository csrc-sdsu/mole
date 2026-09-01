#include "MOLE_grids.h"
#include <iostream>

int main() {
    gridParams1D p;
    p.topology = 'u';
    p.m = 4;
    p.dx = 0.5;

    grid1D g(p);
    if (!g.validGrid()) {
        g.print_ErrorLog();
        return 1;
    }
    std::cout << "grid built OK, " << g.grid.nodes_X.data_.n_elem
              << " nodal points\n";
    return 0;
}

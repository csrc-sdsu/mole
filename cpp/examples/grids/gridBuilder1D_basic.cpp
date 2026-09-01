// Builds a uniform 1D grid through the gridBuilder utility.
//
// gridBuilder takes <attribute, value> pairs in any order and
// returns a gridVar. Compare with grid1D_basic.cpp, which fills a
// gridParams1D and calls the grid1D constructor directly.
#include "grid_builder.h"
#include <iostream>

int main() {
    gridVar g = gridBuilder("dim", 1, "m", 4, "dx", 0.5,
                            "topology", 'u');

    if (!isValidGrid(g)) {
        std::visit([](auto&& grid) { grid.print_ErrorLog(); }, g);
        return 1;
    }

    // dim was 1, so the variant holds a grid1D.
    grid1D& g1 = std::get<grid1D>(g);
    std::cout << "grid built OK, " << g1.grid.nodes_X.data_.n_elem
              << " nodal points\n";
    return 0;
}

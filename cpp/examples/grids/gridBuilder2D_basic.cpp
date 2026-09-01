// Builds a uniform 2D grid through gridBuilder, with periodicity
// declared on the x-axis only.
//
// isPeriodic is passed as the address of a vector holding one flag
// per dimension. The vector carries its own size, so gridBuilder
// checks it against dim; the pair may appear before "dim" in the
// argument list because both the check and the copy happen after
// parsing. The vector must outlive the gridBuilder call.
#include "grid_builder.h"
#include <iostream>
#include <vector>

int main() {
    const std::vector<bool> periodic = {true, false};

    gridVar g = gridBuilder("dim", 2,
                            "m", 3, "n", 3,
                            "dx", 1.0, "dy", 1.0,
                            "topology", 'u',
                            "isPeriodic", &periodic);

    if (!isValidGrid(g)) {
        std::visit([](auto&& grid) { grid.print_ErrorLog(); }, g);
        return 1;
    }

    grid2D& g2 = std::get<grid2D>(g);
    std::cout << "grid2D built OK, nodes_X is "
              << g2.grid.nodes_X.data_.n_rows << " x "
              << g2.grid.nodes_X.data_.n_cols << "\n";
    std::cout << "periodic in x: " << g2.grid.bc_isPeriodic[0]
              << ", periodic in y: " << g2.grid.bc_isPeriodic[1]
              << "\n";
    return 0;
}

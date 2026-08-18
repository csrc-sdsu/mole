// This example exercises gridBuilder's parse-time failures.
//
// gridBuilder collects every error it can find rather than stopping
// at the first, pushes MOLE_ERR_INVALID_GRID_ARGS on top of the
// stack, and returns a gridNull carrying the whole log. The caller
// checks isValidGrid and prints the log.
#include "grid_builder.h"
#include <iostream>
#include <vector>

// report prints the outcome of one gridBuilder call.
static void report(gridVar& g) {
    if (isValidGrid(g)) {
        std::visit([](auto&& grid) {
            std::cout << "grid built OK, dim = " << grid.dim << "\n";
        }, g);
        return;
    }
    std::cout << "holds gridNull: "
              << std::holds_alternative<gridNull>(g) << "\n";
    std::visit([](auto&& grid) { grid.print_ErrorLog(); }, g);
}

int main() {
    cout << "===================================================="
         << endl;
    cout << "GRID #1 (fails on an unknown attribute name) " << endl;
    cout << "===================================================="
         << endl;
    // Parsing stops at the first key that is not a grid attribute,
    // because the value type after an unknown key is unknown too.
    gridVar g1 = gridBuilder("dim", 1, "m", 5, "spacing", 0.2,
                             "topology", 'u');
    report(g1);

    cout << "===================================================="
         << endl;
    cout << "GRID #2 (fails on a missing dim attribute) " << endl;
    cout << "===================================================="
         << endl;
    // dim is required and is never inferred from m, n or o.
    gridVar g2 = gridBuilder("m", 5, "dx", 0.2, "topology", 'u');
    report(g2);

    cout << "===================================================="
         << endl;
    cout << "GRID #3 (accumulates four separate errors) " << endl;
    cout << "===================================================="
         << endl;
    // A 3D grid with no cell counts and a bad topology: three
    // missing counts plus the topology, all reported at once.
    gridVar g3 = gridBuilder("dim", 3, "topology", 'x');
    report(g3);

    cout << "===================================================="
         << endl;
    cout << "GRID #4 (fails on a count the dimension cannot use) "
         << endl;
    cout << "===================================================="
         << endl;
    // o belongs to a 3D grid only, so supplying it for a 2D grid
    // is a cell-count inconsistency.
    gridVar g4 = gridBuilder("dim", 2, "m", 5, "n", 5, "o", 5,
                             "dx", 0.2, "dy", 0.2, "topology", 'u');
    report(g4);

    cout << "===================================================="
         << endl;
    cout << "GRID #5 (fails on an isPeriodic size mismatch) "
         << endl;
    cout << "===================================================="
         << endl;
    // isPeriodic holds one flag per dimension. The vector reports
    // its own size, so a 3D grid given two flags is caught rather
    // than reading past the end of the vector.
    const std::vector<bool> tooFew = {true, false};
    gridVar g5 = gridBuilder("dim", 3, "m", 5, "n", 5, "o", 5,
                             "dx", 0.2, "dy", 0.2, "dz", 0.2,
                             "topology", 'u',
                             "isPeriodic", &tooFew);
    report(g5);

    cout << "===================================================="
         << endl;
    cout << "GRID #6 (success - grid instantiated!) " << endl;
    cout << "===================================================="
         << endl;
    gridVar g6 = gridBuilder("dim", 2, "m", 5, "n", 5,
                             "dx", 0.2, "dy", 0.2, "topology", 'u');
    report(g6);
    return 0;
}

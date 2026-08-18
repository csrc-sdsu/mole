// Attribute pairs may be given in any order.
//
// gridBuilder reads <name, value> pairs until the nullptr sentinel,
// dispatching on the name, so position carries no meaning. The three
// calls below describe the same 3x3 uniform grid and produce grids
// that compare equal field by field.
//
// The one attribute with an ordering subtlety is isPeriodic: it is
// a pointer to the caller's vector, and dim may not have been read
// yet when the pair is seen. The parser stashes the pointer, then
// checks its size against dim and copies the flags after parsing,
// so "isPeriodic" may still precede "dim".
#include "grid_builder.h"
#include <iostream>
#include <vector>

// sameGrid compares the parameters two 2D grids were built with.
static bool sameGrid(const grid2D& a, const grid2D& b) {
    return a.grid.topology == b.grid.topology
        && a.grid.m == b.grid.m
        && a.grid.n == b.grid.n
        && a.grid.dx == b.grid.dx
        && a.grid.dy == b.grid.dy
        && a.grid.nodes_X == b.grid.nodes_X
        && a.grid.nodes_Y == b.grid.nodes_Y
        && a.grid.centers_X == b.grid.centers_X
        && a.grid.centers_Y == b.grid.centers_Y
        && a.grid.bc_isPeriodic[0] == b.grid.bc_isPeriodic[0]
        && a.grid.bc_isPeriodic[1] == b.grid.bc_isPeriodic[1];
}

int main() {
    const std::vector<bool> periodic = {true, false};

    // Order A: dimensionality, counts, spacings, topology.
    gridVar a = gridBuilder("dim", 2,
                            "m", 3, "n", 3,
                            "dx", 1.0, "dy", 1.0,
                            "topology", 'u',
                            "isPeriodic", &periodic);

    // Order B: the same pairs, reversed.
    gridVar b = gridBuilder("isPeriodic", &periodic,
                            "topology", 'u',
                            "dy", 1.0, "dx", 1.0,
                            "n", 3, "m", 3,
                            "dim", 2);

    // Order C: pairs interleaved by axis rather than by kind.
    gridVar c = gridBuilder("topology", 'u',
                            "m", 3, "dx", 1.0,
                            "n", 3, "dy", 1.0,
                            "isPeriodic", &periodic,
                            "dim", 2);

    if (!isValidGrid(a) || !isValidGrid(b) || !isValidGrid(c)) {
        std::cout << "at least one grid failed to build\n";
        return 1;
    }

    grid2D& ga = std::get<grid2D>(a);
    grid2D& gb = std::get<grid2D>(b);
    grid2D& gc = std::get<grid2D>(c);

    std::cout << "order B matches order A: "
              << sameGrid(ga, gb) << "\n";
    std::cout << "order C matches order A: "
              << sameGrid(ga, gc) << "\n";
    return 0;
}

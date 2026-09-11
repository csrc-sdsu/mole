// This example generates some grid issues
#include "MOLE_grids.h"
#include <iostream>

int main() {
    gridParams2D p;
    p.topology = 'x';
    p.m = 3; p.n = 3;
    p.dx = 1.0; p.dy = 1.0;

    cout << "===================================================== " 
    << endl;
    cout << "Attempt to create GRID #1 (fails on invalid topology) "
    << endl;
    cout << "===================================================== " 
    << endl;
    // This grid has an invalid topology
    grid2D g(p);
    if (!g.validGrid()) {
        g.print_ErrorLog();
    } else {
        std::cout << "grid2D built OK, nodes_X is "
        << g.grid.nodes_X.data_.n_rows << " x " 
        << g.grid.nodes_X.data_.n_cols << "\n";
    }
    
    cout << "===================================================== " 
    << endl;
    cout << "Attempt to create GRID #2 (fails on invalid spacing) "
    << endl;
    cout << "===================================================== " 
    << endl;

    // This second grid has an invalid dx
    p.topology = 'u';
    p.dx = 0;
    grid2D g1(p);
     if (!g1.validGrid()) {
        g1.print_ErrorLog();
    } else {
        std::cout << "grid2D built OK, nodes_X is "
        << g1.grid.nodes_X.data_.n_rows << " x " 
        << g1.grid.nodes_X.data_.n_cols << "\n";
    } 
    
    cout << "======================================================= " 
    << endl;
    cout << "Attempt to create GRID #3 (success - grid instantiated!) "
    << endl;
    cout << "======================================================= " 
    << endl;
    // This third attempt the grid has valid parameters
    p.topology = 'u';
    p.dx = 1.0;
    grid2D g2(p);
     if (!g2.validGrid()) {
        g2.print_ErrorLog();
    } else {
        std::cout << "grid2D built OK, nodes_X is "
        << g2.grid.nodes_X.data_.n_rows << " x " 
        << g2.grid.nodes_X.data_.n_cols << "\n";
    } 

    return 0;
}

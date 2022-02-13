/**
 * Nullity test of Divergence operator
 */

#include <iostream>
#include "mole.h"

int main() {
    int k = 2;
    int m = 2*k+1;
    float dx = 1;
    float tol = 1e-16;
    
    Divergence D(k, m, dx);
    vec field(m+1, fill::ones);
    
    vec sol = D*field;
    
    norm(sol) < tol ? cout << "\033[1;32mTest PASSED!\033[0m\n" : cout << "\033[1;31mTest FAILED!\033[0m\n";
    
    return 0;
}

.. _GettingStarted:

Getting Started
**************************************

This section provides information on how to get started with the MOLE library.

Installation
======================================

To install MOLE, you can clone the repository and build it using CMake:

.. code-block:: bash

   git clone https://github.com/csrc-sdsu/mole.git
   cd mole
   mkdir build
   cd build
   cmake ..
   make
   make install

Basic Usage
======================================

Here's a simple example of how to use the MOLE library:

.. code-block:: cpp

   #include "mole.h"
   #include <iostream>

   int main() {
       // Create a 1D grid with 100 cells and spacing of 0.01
       u32 m = 100;
       Real dx = 0.01;
       
       // Create operators (4th order of accuracy)
       u16 k = 4;
       Gradient G(k, m, dx);
       Divergence D(k, m, dx);
       Laplacian L(k, m, dx);
       
       // Create vectors for input and output
       vec f(m);
       vec df(m);
       
       // Initialize input vector
       for (u32 i = 0; i < m; ++i) {
           Real x = i * dx;
           f(i) = sin(x);
       }
       
       // Apply operators
       df = G * f;        // Compute gradient
       df = D * f;        // Compute divergence
       df = L * f;        // Compute laplacian
       
       return 0;
   } 
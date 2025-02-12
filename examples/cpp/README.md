This folder houses a collection of examples that serve as excellent starting points for developing more sophisticated programs utilizing MOLE's C++ version.

# Examples:

### 1. wave1d.cpp: Implements the 1D wave equation solver using:
   - Second-order accurate spatial discretization
   - Position Verlet time integration scheme
   - Mimetic Laplacian operator
   - Visualization using Gnuplot

### 2. wave2d.cpp: Implements the 2D wave equation solver featuring:
   - Second-order accurate spatial discretization in both dimensions
   - Position Verlet time integration
   - 2D Mimetic Laplacian operator with Robin boundary conditions
   - Interactive 3D visualization using Gnuplot

## Key Features:
- Uses existing mimetic operators (Gradient, Divergence, Laplacian)
- Implements proper boundary conditions using RobinBC
- Provides real-time visualization of wave propagation
- Maintains consistency with existing codebase style and structure
- Updated Makefile to include new examples

## Dependencies
- Armadillo (Linear algebra library)
- Boost (For filesystem and gnuplot-iostream)
- Gnuplot (For visualization)
- OpenBLAS (Optional, for better performance)
- SuperLU (For sparse matrix operations)
- Incorporate C++20 for better filesystem handling

### Installation on different platforms:

#### macOS (using Homebrew):
```
brew install armadillo
brew install boost
brew install gnuplot
brew install openblas
```
#### Ubuntu/Debian:
```
sudo apt-get install libarmadillo-dev
sudo apt-get install libboost-all-dev
sudo apt-get install gnuplot
sudo apt-get install libopenblas-dev
sudo apt-get install libsuperlu-dev
```

### Structure of the directory
```plaintext
examples/cpp/
├── wave1d.cpp          # First case of 1D wave equation
├── wave1d_case2.cpp    # Second case of 1D wave equation
├── wave2d.cpp          # First case of 2D wave equation
├── wave2d_case2.cpp    # Second case of 2D wave equation
└── Makefile            # Build system for examples
```

## Testing
1. Build the examples:
```
cd examples/cpp
make wave1d wave1d_case2 wave2d wave2d_case2
```
2. Run individual examples
```
./wave1d
./wave1d_case2
./wave2d
./wave2d_case2
```

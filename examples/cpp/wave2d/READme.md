# Wave2D - 2D Wave Equation Solver

This project implements a numerical solver for the 2D wave equation using the MOLE (Method Of Lines Engine) library. It includes both computation and visualization capabilities.

## Directory Structure
```
mole/
├── examples/
│   └── cpp/
│       └── wave2d/                    # Wave2D project directory
│           ├── include/               # Header files
│           │   ├── Wave2DSolver.hpp
│           │   └── Wave2DVisualizer.hpp
│           ├── src/                   # Source files
│           │   ├── Wave2DSolver.cpp
│           │   ├── Wave2DVisualizer.cpp
│           │   ├── main.cpp
│           │   └── colormap_rgb.txt   # Colormap for visualization
│           └── CMakeLists.txt        # Build configuration
```

## Prerequisites
- C++17 or later
- CMake 3.10 or later
- Armadillo
- OpenBLAS
- Boost (for visualization)
- Gnuplot (for visualization)

## Building and Running

### With Visualization
```bash
cd build
rm -rf *
cmake .. -DENABLE_VISUALIZATION=ON
make
./wave2d
```
The program will display an interactive 3D visualization of the wave equation solution.

- Use 'q' or 'x' to exit
- Mouse to rotate view
- Arrow keys for different perspectives

### Without Visualization
```bash
cd build
rm -rf *
cmake .. -DENABLE_VISUALIZATION=OFF
make
./wave2d
```
The program will:
- Compute the solution
- Save results in a 'solutions' directory
- Generate both intermediate and final solution files

## Viewing Saved Results
After running without visualization, view results using gnuplot:
```bash
gnuplot
gnuplot> set pm3d
gnuplot> set view 60,30
gnuplot> splot 'solutions/final_solution.dat' using 1:2:3 with pm3d
```

## Implementation Details
- Position Verlet time integration
- 2D wave equation with Robin boundary conditions
- Spatial discretization using the MOLE library
- Optional real-time visualization using gnuplot-iostream
- Solution data saved in readable format

## Customization
Modify in source code:
- Grid size
- Time step
- Domain size
- Wave speed
- Boundary conditions

Visualization settings:
- Color scheme (via `colormap_rgb.txt`)
- View angles
- Output format

## License
This project is part of the MOLE library. See the main MOLE repository for license information.

## Authors
- **MOLE Framework**: MOLE Development Team
- **Wave2D Implementation**: Arshia Ilaty

## Acknowledgments
This implementation uses the MOLE (Method Of Lines Engine) library developed at San Diego State University.

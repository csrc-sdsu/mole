#include <iostream>
#include <vector>
#include <cmath>
#include <fstream>
#include <iomanip>

std::vector<std::vector<std::vector<double>>> init3DVector(int x, int y, int z, double value = 0.0) {
    return std::vector<std::vector<std::vector<double>>>(x, std::vector<std::vector<double>>(y, std::vector<double>(z, value)));
}

void saveFrameToFile(std::ofstream &file, const std::vector<std::vector<double>> &slice, int step) {
    file << "Step " << step << ":\n";
    for (const auto &row : slice) {
        for (const auto &val : row) {
            file << std::setw(8) << val << " ";
        }
        file << "\n";
    }
    file << "\n";
}

int main() {
    const int m = 101, n = 51, o = 101;
    const int iters = 240;

    double a = 0, b = 101, c = 0, d = 51, e = 0, f = 101;
    double dx = (b - a) / m;
    double dy = (d - c) / n;
    double dz = (f - e) / o;

    double bottom = 30, top = 35, seal = 40;
    double diff = 4.0;
    double porosity = 1.0;
    diff *= porosity;

    auto density = init3DVector(m + 2, n + 2, o + 2, 0.0);
    for (int j = bottom; j <= top; ++j) {
        density[m / 2][j][o / 2] = 1.0;
    }

    auto kField = init3DVector(m + 2, n + 2, o + 2, diff);
    for (int j = 0; j < o + 2; ++j) {
        for (int i = 0; i < m + 2; ++i) {
            kField[i][seal][j] = diff * 0.1;
            kField[i][seal + 5][j] = diff * 0.025;
        }
    }


    double dt = 0.1 * dx * dx / diff;

    std::ofstream outputFile("simulation_data.txt");
    if (!outputFile.is_open()) {
        std::cerr << "Error: Unable to open file for writing.\n";
        return 1;
    }

    for (int step = 0; step < iters * 3; ++step) {
        auto nextDensity = density;

        for (int x = 1; x < m + 1; ++x) {
            for (int y = 1; y < n + 1; ++y) {
                for (int z = 1; z < o + 1; ++z) {
                    nextDensity[x][y][z] = density[x][y][z] +
                        dt * (
                            (kField[x + 1][y][z] + kField[x][y][z]) * (density[x + 1][y][z] - density[x][y][z]) / (2 * dx * dx) -
                            (kField[x][y][z] + kField[x - 1][y][z]) * (density[x][y][z] - density[x - 1][y][z]) / (2 * dx * dx) +
                            (kField[x][y + 1][z] + kField[x][y][z]) * (density[x][y + 1][z] - density[x][y][z]) / (2 * dy * dy) -
                            (kField[x][y][z] + kField[x][y - 1][z]) * (density[x][y][z] - density[x][y - 1][z]) / (2 * dy * dy) +
                            (kField[x][y][z + 1] + kField[x][y][z]) * (density[x][y][z + 1] - density[x][y][z]) / (2 * dz * dz) -
                            (kField[x][y][z] + kField[x][y][z - 1]) * (density[x][y][z] - density[x][y][z - 1]) / (2 * dz * dz)
                        );
                }
            }
        }

        for (int x = 0; x < m + 2; ++x) {
            for (int y = 0; y < n + 2; ++y) {
                for (int z = 0; z < o + 2; ++z) {
                    nextDensity[x][y][z] = std::max(0.0, nextDensity[x][y][z]);
                }
            }
        }

        density = nextDensity;

        for (int j = bottom; j <= top; ++j) {
            density[m / 2][j][o / 2] = 1.0;
        }

        auto slice = density[seal];
        saveFrameToFile(outputFile, slice, step);
    }

    std::cout << "Simulation complete. Data saved to 'simulation_data.txt'.\n";
    outputFile.close();
    return 0;
}

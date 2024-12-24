/**
 * @file convection_diffusion_3D.cpp
 * @brief Solves a 3D Convection-Diffusion equation using Mimetic Operators for Linear Equations (MOLE).
 *
 * This program numerically solves the 3D convection-diffusion equation using MOLE techniques.
 * It simulates the distribution of CO2 concentration over time within a porous medium,
 * considering both diffusion and advection effects. 
 * 
 * If OUTPUT_FRAME_DATA is set to 1, slices (2D cross-sections) of the concentration field are extracted 
 * and saved to a text file for visualization.
 */

#include <iostream>
#include <fstream>
#include <mole.h>

#define OUTPUT_FRAME_DATA 0

// Helper for linear indexing in 3D arrays (0-based indexing)
inline size_t idx3D(size_t i, size_t j, size_t k, size_t m, size_t n, size_t o) {
    return i + (m+2)*j + (m+2)*(n+2)*k;
}

int main() {
    // Parameters
    unsigned short k = 2;
    unsigned int m = 101;
    unsigned int n = 51;
    unsigned int o = 101;

    double a = 0.0, b = 101.0;
    double c = 0.0, d = 51.0;
    double e = 0.0, f = 101.0;

    double dx = (b - a) / m;
    double dy = (d - c) / n;
    double dz = (f - e) / o;

    // Construct operators
    sp_mat D = Divergence(k, m, n, o, dx, dy, dz);
    sp_mat G = Gradient(k, m, n, o, dx, dy, dz);
    sp_mat I = Interpol(m, n, o, 1, 1, 1);

    size_t scalarSize = (m+2)*(n+2)*(o+2);
    size_t vectorSize = G.n_rows;

    // Allocate fields
    std::vector<double> V(vectorSize, 0.0);
    vec C(scalarSize, fill::zeros);

    // Initial conditions
    int bottom = 10; 
    int top = 15;   
    int seal = 40;  
    int seal_idx = seal - 1;
    int seal5_idx = (seal + 5) - 1;

    // Construct the velocity field
    size_t yCount = m*(n+1)*o;
    std::vector<double> y(yCount, 1.0);

    // Apply shale conditions on velocity field
    for (int i_ = 0; i_ < (int)m; i_++) {
        for (int k_ = 0; k_ < (int)o; k_++) {
            y[i_ + m*seal_idx + m*(n+1)*k_] = 0.0;
            y[i_ + m*seal5_idx + m*(n+1)*k_] = 0.0;
        }
    }

    // Assign y into V at the correct offset
    size_t offset = (m+1)*n*o; 
    for (size_t i_ = 0; i_ < yCount; ++i_) {
        if (offset + i_ < V.size()) {
            V[offset + i_] = y[i_];
        }
    }

    // Set initial density
    int mid_x = (int)std::ceil((m+2)/2.0) - 1; 
    int mid_z = (int)std::ceil((o+2)/2.0) - 1;
    for (int j = bottom - 1; j <= top - 1; j++) {
        size_t idx = idx3D(mid_x, j, mid_z, m, n, o);
        C(idx) = 1.0;
    }

    // Well indices where C=1
    std::vector<size_t> wellIndices;
    for (size_t i_ = 0; i_ < scalarSize; ++i_) {
        if (C(i_) == 1.0) {
            wellIndices.push_back(i_);
        }
    }

    // Diffusivity and porosity
    double diff = 1.0;
    double porosity = 1.0;
    diff *= porosity;

    // Build K
    std::vector<double> K(vectorSize, diff);
    std::vector<double> kk(yCount, diff);
    for (int i_ = 0; i_ < (int)m; i_++) {
        for (int k_ = 0; k_ < (int)o; k_++) {
            kk[i_ + m*seal_idx + m*(n+1)*k_] = diff/10.0;
            kk[i_ + m*seal5_idx + m*(n+1)*k_] = diff/40.0;
        }
    }
    for (size_t i_ = 0; i_ < yCount; ++i_) {
        if (offset + i_ < K.size()) {
            K[offset + i_] = kk[i_];
        }
    }

    // Time step calculation
    double dt1 = dx*dx/(3*diff)/3.0;
    double maxV = 0.0;
    for (auto val : V) {
        if (val > maxV) maxV = val;
    }
    double dt2 = (maxV > 0.0) ? (dx/maxV)/3.0 : 1e-3;
    double dt = std::min(dt1, dt2);
    int iters = 120;

    // Convert V and K to arma::vec
    arma::vec K_arma(K);
    arma::vec V_arma(V);

    arma::ivec offsets_vec(1);
    offsets_vec(0) = 0;

    sp_mat Kdiag = spdiags(K_arma, offsets_vec, K_arma.n_elem, K_arma.n_elem);
    sp_mat Vdiag = spdiags(V_arma, offsets_vec, V_arma.n_elem, V_arma.n_elem);

    SizeMat size_identity(D.n_rows, D.n_rows);
    sp_mat I_sp = speye(size_identity);

    // Operators: L and Dadv
    sp_mat L = dt * D * Kdiag * G + I_sp;
    sp_mat Dadv = dt * D * Vdiag * I;

    #if OUTPUT_FRAME_DATA
    // Open a single file to store selected frames
    std::ofstream frameFile("frames.txt");
    if(!frameFile) {
        std::cerr << "Error opening frames.txt for writing.\n";
        return 1;
    }
    #endif

    // Time-stepping loop
    for (int i_ = 1; i_ <= iters*3; ++i_) {
        // Diffusion step
        vec Cnew = L * C;
        for (auto w : wellIndices) {
            Cnew(w) = 1.0;
        }
        C = Cnew;

        // Advection step
        vec Cadv = Dadv * C;
        Cadv = C - Cadv;
        for (auto w : wellIndices) {
            Cadv(w) = 1.0;
        }
        C = Cadv;

        #if OUTPUT_FRAME_DATA
        // Write only selected frames to a single file
        frameFile << "FRAME " << i_ << "\n";
        for (int j = 0; j < (int)(n+2); j++) {
            for (int k_ = 0; k_ < (int)(o+2); k_++) {
                size_t idx = idx3D(seal_idx, j, k_, m, n, o);
                frameFile << C(idx);
                if (k_ < (int)(o+1)) frameFile << " ";
            }
            frameFile << "\n";
        }
        frameFile << "\n"; // Blank line between frames
        #endif
    }
    
    #if OUTPUT_FRAME_DATA
    frameFile.close();
    #endif

    // Display minimum and maximum concentration values
    std::cout << "Minimum CO2 concentration: " << C.min() << "\n";
    std::cout << "Maximum CO2 concentration: " << C.max() << "\n";

    return 0;
}

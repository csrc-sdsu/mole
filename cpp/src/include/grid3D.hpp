#ifndef GRID3D_HPP
#define GRID3D_HPP

#include <vector>
#include <stdexcept>

// Convenience typedefs for multi-dimensional double arrays stored as vectors
using Array1D = std::vector<double>;
using Array2D = std::vector<std::vector<double>>;
using Array3D = std::vector<std::vector<std::vector<double>>>;

class grid3D {
public:
    // ---- Core scalar attributes ----
    int dim;          // dimensionality flag
    char topology;    // 'u' (uniform) or 'c' (curvilinear/custom)
    int m;
    int n;
    int o;
    float dx;
    float dy;
    float dz;

    // ---- Nested data groups ----

    // Node coordinates
    struct Nodes {
        Array1D X;  // size: m+1
        Array2D Y;  // size: (m+1) x (n+1)
        Array3D Z;  // size: (m+1) x (n+1) x (o+1)
    } nodes;

    // Cell-center coordinates
    struct Centers {
        Array1D X;  // size: m+2
        Array2D Y;  // size: (m+2) x (n+2)
        Array3D Z;  // size: (m+2) x (n+2) x (o+2)
    } centers;

    // Face-related data
    struct Faces {
        Array1D X;  // size: m+1

        // Sub-group "u" for face quantities
        struct U {
            Array2D X;  // size: (m+1) x n
            Array2D Y;  // size: (m+1) x n
            Array3D Z;  // size: (m+1) x n x o
        } u;
    } faces;

    // ---- Constructor ----
    // Allocates all arrays to the correct sizes based on m, n, o.
    // Validates that topology is either 'u' or 'c'.
    grid3D(int dim_, char topology_, int m_, int n_, int o_,
           float dx_, float dy_, float dz_)
        : dim(dim_), topology(topology_), m(m_), n(n_), o(o_),
          dx(dx_), dy(dy_), dz(dz_)
    {
        if (topology != 'u' && topology != 'c') {
            throw std::invalid_argument("topology must be 'u' or 'c'");
        }

        // ---- nodes ----
        nodes.X.assign(m + 1, 0.0);
        nodes.Y.assign(m + 1, Array1D(n + 1, 0.0));
        nodes.Z.assign(m + 1, Array2D(n + 1, Array1D(o + 1, 0.0)));

        // ---- centers ----
        centers.X.assign(m + 2, 0.0);
        centers.Y.assign(m + 2, Array1D(n + 2, 0.0));
        centers.Z.assign(m + 2, Array2D(n + 2, Array1D(o + 2, 0.0)));

        // ---- faces ----
        faces.X.assign(m + 1, 0.0);
        faces.u.X.assign(m + 1, Array1D(n, 0.0));
        faces.u.Y.assign(m + 1, Array1D(n, 0.0));
        faces.u.Z.assign(m + 1, Array2D(n, Array1D(o, 0.0)));
    }
};

#endif // GRID3D_HPP

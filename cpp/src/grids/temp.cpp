

class Grid1D : public GridBase {
public:
    Grid1D(int nx) : nx_(nx) {}
    void doSomething() override { /* ... */ }
    int dimension() const override { return 1; }
private:
    int nx_;
};

class Grid2D : public GridBase {
public:
    Grid2D(int nx, int ny) : nx_(nx), ny_(ny) {}
    void doSomething() override { /* ... */ }
    int dimension() const override { return 2; }
private:
    int nx_, ny_;
};

class Grid3D : public GridBase {
public:
    Grid3D(int nx, int ny, int nz) : nx_(nx), ny_(ny), nz_(nz) {}
    void doSomething() override { /* ... */ }
    int dimension() const override { return 3; }
private:
    int nx_, ny_, nz_;
};



std::unique_ptr<GridBase> makeGrid(const GridParams& p) {
    switch (p.dim) {
        case 1: return std::make_unique<Grid1D>(p.nx);
        case 2: return std::make_unique<Grid2D>(p.nx, p.ny);
        case 3: return std::make_unique<Grid3D>(p.nx, p.ny, p.nz);
        default: throw std::invalid_argument("dim must be 1, 2, or 3");
    }
}


#include <memory>
#include <stdexcept>

// Shared interface
class GridBase {
    bool isValid = false; // Flag to indicate if the grid is valid
public:
    virtual ~GridBase() = default;
    virtual void doSomething() = 0;
    virtual int dimension() const = 0;
};

class Grid1D : public GridBase {
public:
    Grid1D(int nx) : nx_(nx) {}
    void doSomething() override { /* ... */ }
    int dimension() const override { return 1; }
private:
    int nx_;
};

class Grid2D : public GridBase {
public:
    Grid2D(int nx, int ny) : nx_(nx), ny_(ny) {}
    void doSomething() override { /* ... */ }
    int dimension() const override { return 2; }
private:
    int nx_, ny_;
};

class Grid3D : public GridBase {
public:
    Grid3D(int nx, int ny, int nz) : nx_(nx), ny_(ny), nz_(nz) {}
    void doSomething() override { /* ... */ }
    int dimension() const override { return 3; }
private:
    int nx_, ny_, nz_;
};


// ---- Grid3D Constructor ----
    // Allocates all arrays to the correct sizes based on m, n, o.
    // Validates that topology is either 'u' or 'c'.
    grid3(char topology_, int m_, int n_, int o_,
           Real dx_, Real dy_, Real dz_)
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

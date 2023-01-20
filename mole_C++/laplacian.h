#ifndef LAPLACIAN_H
#define LAPLACIAN_H

#include "divergence.h"
#include "gradient.h"

class Laplacian : public sp_mat
{

public:
    using sp_mat::operator=;

    // 1-D Constructor
    Laplacian(u16 k, u32 m, real dx);
    // 2-D Constructor
    Laplacian(u16 k, u32 m, u32 n, real dx, real dy);
    // 3-D Constructor
    Laplacian(u16 k, u32 m, u32 n, u32 o, real dx, real dy, real dz);
};

#endif // LAPLACIAN_H

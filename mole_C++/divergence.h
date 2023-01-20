#ifndef DIVERGENCE_H
#define DIVERGENCE_H

#include <cassert>
#include "utils.h"

class Divergence : public sp_mat
{

public:
    using sp_mat::operator=;

    // 1-D Constructor
    Divergence(u16 k, u32 m, real dx);
    // 2-D Constructor
    Divergence(u16 k, u32 m, u32 n, real dx, real dy);
    // 3-D Constructor
    Divergence(u16 k, u32 m, u32 n, u32 o, real dx, real dy, real dz);
    // Returns weights
    vec getQ();

private:
    vec Q;
};

#endif // DIVERGENCE_H

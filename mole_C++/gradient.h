#ifndef GRADIENT_H
#define GRADIENT_H

#include <cassert>
#include "utils.h"

class Gradient : public sp_mat
{

public:
    using sp_mat::operator=;

    // 1-D Constructor
    Gradient(u16 k, u32 m, real dx);
    // 2-D Constructor
    Gradient(u16 k, u32 m, u32 n, real dx, real dy);
    // 3-D Constructor
    Gradient(u16 k, u32 m, u32 n, u32 o, real dx, real dy, real dz);
    // Returns weights
    vec getP();

private:
    vec P;
};

#endif // GRADIENT_H

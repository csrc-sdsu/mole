#ifndef NODAL_H
#define NODAL_H

#include "utils.h"
#include <math.h>   
#include <armadillo>

class Nodal : public sp_mat
{

public:
    using sp_mat::operator=;

    // 1-D Constructor
    Nodal(u16 k, u32 m, double dx);
    // 2-D Constructor
    Nodal(u16 k, u32 m, u32 n, double dx, double dy);
    // 3-D Constructor
    Nodal(u16 k, u32 m, u32 n,  u32 o, double dx, double dy, double dz);

private:

};

#endif // NODAL_H

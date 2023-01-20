#ifndef ROBINBC_H
#define ROBINBC_H

#include "gradient.h"

class RobinBC : public sp_mat
{

public:
    using sp_mat::operator=;

    // 1-D Constructor
    RobinBC(u16 k, u32 m, real dx, real a, real b);
    // 2-D Constructor
    RobinBC(u16 k, u32 m, real dx, u32 n, real dy, real a, real b);
    // 3-D Constructor
    RobinBC(u16 k, u32 m, real dx, u32 n, real dy, u32 o, real dz, real a, real b);
};

#endif // ROBINBC_H

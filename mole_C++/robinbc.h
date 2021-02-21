#ifndef ROBINBC_H
#define ROBINBC_H

#include "gradient.h"

class RobinBC : public sp_mat
{

public:
    using sp_mat::operator=;

    // 1-D Constructor
    RobinBC(u16 k, u32 m, double dx, double a, double b);
    // 2-D Constructor
    RobinBC(u16 k, u32 m, double dx, u32 n, double dy, double a, double b);
    // 3-D Constructor
    RobinBC(u16 k, u32 m, double dx, u32 n, double dy, u32 o, double dz, double a, double b);
};

#endif // ROBINBC_H

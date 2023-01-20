#ifndef INTERPOL_H
#define INTERPOL_H

#include <cassert>
#include "utils.h"

class Interpol : public sp_mat
{

public:
    using sp_mat::operator=;

    // 1-D Constructor
    Interpol(u32 m, real c);
    // 2-D Constructor
    Interpol(u32 m, u32 n, real c1, real c2);
    // 3-D Constructor
    Interpol(u32 m, u32 n, u32 o, real c1, real c2, real c3);
};

#endif // INTERPOL_H

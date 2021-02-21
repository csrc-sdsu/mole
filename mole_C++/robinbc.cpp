#include "robinbc.h"

// 1-D Constructor
RobinBC::RobinBC(u16 k, u32 m, double dx, double a, double b)
{
    sp_mat A(m+2, m+2);
    sp_mat B(m+2, m+1);

    A.at(0, 0) = a;
    A.at(m+1, m+1) = a;

    B.at(0, 0) = -b;
    B.at(m+1, m) = b;

    Gradient grad(k, m, dx);

    *this = A + B*(sp_mat)grad;
}

// 2-D Constructor
RobinBC::RobinBC(u16 k, u32 m, double dx, u32 n, double dy, double a, double b)
{
    RobinBC Bm(k, m, dx, a, b);
    RobinBC Bn(k, n, dy, a, b);

    sp_mat Im = speye(m+2, m+2);
    sp_mat In = speye(n+2, n+2);

    In(0, 0) = 0;
    In(n+1, n+1) = 0;

    sp_mat BC1 = Utils::spkron(In, Bm);
    sp_mat BC2 = Utils::spkron(Bn, Im);

    *this = BC1 + BC2;
}

// 3-D Constructor
RobinBC::RobinBC(u16 k, u32 m, double dx, u32 n, double dy, u32 o, double dz, double a, double b)
{
    RobinBC Bm(k, m, dx, a, b);
    RobinBC Bn(k, n, dy, a, b);
    RobinBC Bo(k, o, dz, a, b);

    sp_mat Im = speye(m+2, m+2);
    sp_mat In = speye(n+2, n+2);
    sp_mat Io = speye(o+2, o+2);

    Io(0, 0) = 0;
    Io(o+1, o+1) = 0;

    sp_mat In2 = In;
    In2(0, 0) = 0;
    In2(n+1, n+1) = 0;

    sp_mat BC1 = Utils::spkron(Utils::spkron(Io, In2), Bm);
    sp_mat BC2 = Utils::spkron(Utils::spkron(Io, Bn), Im);
    sp_mat BC3 = Utils::spkron(Utils::spkron(Bo, In), Im);

    *this = BC1 + BC2 + BC3;
}

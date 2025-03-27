#ifndef JACOBIAN_H
#define JACOBIAN_H

// Curvilinear Operator Helpers

#include "utils.h"
#include "nodal.h"

using namespace arma;

class Jacob
{

public:
    vec Xe; vec Xn; vec Xc;
    vec Ye; vec Yn; vec Yc;
    vec Ze; vec Zn; vec Zc;

    vec Jacob_vec;
    // 2-D Jacobian Constructor
    void Jacobian(const u16 k, const mat &Xin, const mat &Yin);
    // 3-D Jacobian Constructor
    void Jacobian(const u16 k, const cube &Xin, const cube&Yin, const cube &Zin);

private:

};

#endif // JACOBIAN_H

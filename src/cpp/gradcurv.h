#ifndef GRADCURV_H
#define GRADCURV_H

// Gradient Curvilinear Operator

#include "interpolator.h"
#include "utils.h"
#include "jacobian.h"
#include "nodal.h"

using namespace arma;

class GradCurv
{

public:

    sp_mat GI_inter; // Interpolator like MATLAB

    void GI( u16 m, u16 n, u16 t);
    void GI( u16 m, u16 n, u16 o, u16 t);

    sp_mat grad3DCurv;
    void G3DCurv(const u16 k, const cube &X, const cube &Y, const cube &Z);

private:

};

#endif // GRADCURV_H
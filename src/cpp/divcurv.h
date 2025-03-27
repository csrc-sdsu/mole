#ifndef DIVCURV_H
#define DIVCURV_H

// Divergence Curvilinear Operator

#include "interpolator.h"
#include "jacobian.h"
#include "utils.h"
#include "nodal.h"

using namespace arma;

class DivCurv
{

public:

    sp_mat DI_inter; // Interpolator like MATLAB

    void DI( u16 m, u16 n, u16 t);
    void DI( u16 m, u16 n, u16 o, u16 t);

    sp_mat div3DCurv;
    void D3DCurv(const u16 k, const cube &X, const cube &Y, const cube &Z);


private:

};

#endif // DIVCURV_H
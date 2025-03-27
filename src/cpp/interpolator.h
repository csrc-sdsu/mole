#ifndef INTERPOLATOR_H
#define INTERPOLATOR_H

#include <cassert>
#include <math.h>   
#include "mole.h"

#define ARMA_DONT_PRINT_FAST_MATH_WARNING
#include <armadillo>

using namespace arma;

class Interpolator
{
public:
    // Interpolate from Centers to faces
    sp_mat Inter_CenterToFaces( u32 k, u32 m);
    sp_mat Inter_CenterToFaces( u32 k, u32 m, u32 n);
    sp_mat Inter_CenterToFaces( u32 k, u32 m, u32 n, u32 o);

    // Interpolate from Faces to Centers
    sp_mat Inter_FacesToCenters( u32 k, u32 m);
    sp_mat Inter_FacesToCenters( u32 k, u32 m, u32 n);
    sp_mat Inter_FacesToCenters( u32 k, u32 m, u32 n, u32 o);

    //Interpolate Nodes to centers
    sp_mat Inter_NodesToCenters( u32 k, u32 m);
    sp_mat Inter_NodesToCenters( u32 k, u32 m, u32 n);
    sp_mat Inter_NodesToCenters( u32 k, u32 m, u32 n, u32 o);

    // Interpolate Centers to Nodes
    sp_mat Inter_CentersToNodes( u32 k, u32 m);
    sp_mat Inter_CentersToNodes( u32 k, u32 m, u32 n);
    sp_mat Inter_CentersToNodes( u32 k, u32 m, u32 n, u32 o);

    // Interpolate Nodes to specific faces (Concatenation of interps)
    sp_mat Inter_NodeToU( u32 k, u32 m, u32 n );
    sp_mat Inter_NodeToU( u32 k, u32 m, u32 n, u32 o);
    sp_mat Inter_NodeToV( u32 k, u32 m, u32 n );
    sp_mat Inter_NodeToV( u32 k, u32 m, u32 n, u32 o);
    sp_mat Inter_NodeToW( u32 k, u32 m, u32 n, u32 o);
    
    sp_mat Inter_UtoNode( u32 k, u32 m, u32 n );
    sp_mat Inter_UtoNode( u32 k, u32 m, u32 n, u32 o);
    sp_mat Inter_VtoNode( u32 k, u32 m, u32 n );
    sp_mat Inter_VtoNode( u32 k, u32 m, u32 n, u32 o);
    sp_mat Inter_WtoNode( u32 k, u32 m, u32 n, u32 o);

    // Interpolate from Centers to specific faces.
    sp_mat Inter_CtoU( u32 k, u32 m, u32 n );
    sp_mat Inter_CtoV( u32 k, u32 m, u32 n );
    sp_mat Inter_UtoC( u32 k, u32 m, u32 n );
    sp_mat Inter_VtoC( u32 k, u32 m, u32 n );

    sp_mat Inter_CtoU( u32 k, u32 m, u32 n, u32 o );
    sp_mat Inter_CtoV( u32 k, u32 m, u32 n, u32 o );
    sp_mat Inter_CtoW( u32 k, u32 m, u32 n, u32 o );
    sp_mat Inter_UtoC( u32 k, u32 m, u32 n, u32 o );
    sp_mat Inter_VtoC( u32 k, u32 m, u32 n, u32 o );
    sp_mat Inter_WtoC( u32 k, u32 m, u32 n, u32 o );

    // Interpolate from faces to other faces
    sp_mat Inter_UtoV( u32 k, u32 m, u32 n );
    sp_mat Inter_VtoU( u32 k, u32 m, u32 n );

    sp_mat Inter_UtoV( u32 k, u32 m, u32 n, u32 o );
    sp_mat Inter_UtoW( u32 k, u32 m, u32 n, u32 o );
    sp_mat Inter_VtoU( u32 k, u32 m, u32 n, u32 o );
    sp_mat Inter_VtoW( u32 k, u32 m, u32 n, u32 o );
    sp_mat Inter_WtoU( u32 k, u32 m, u32 n, u32 o );
    sp_mat Inter_WtoV( u32 k, u32 m, u32 n, u32 o );

};
#endif
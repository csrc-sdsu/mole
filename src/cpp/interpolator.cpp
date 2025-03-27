#include "interpolator.h"

/*
   _   _   _   _   _   _   _     _   _     _   _   _   _   _  
  / \ / \ / \ / \ / \ / \ / \   / \ / \   / \ / \ / \ / \ / \ 
 ( C | e | n | t | e | r | s ) ( t | o ) ( f | a | c | e | s )
  \_/ \_/ \_/ \_/ \_/ \_/ \_/   \_/ \_/   \_/ \_/ \_/ \_/ \_/ 
*/
//Centers to Faces
// 1D interpolation from centers to faces.
// logical centers are [1 1.5 2.5 ... m-1.5 m-0.5 m]
// m is the number of cells in the logic x-axis
// BRZENSKI 1D confirmed for k=2 and k=4;
sp_mat Interpolator::Inter_CenterToFaces(u32 k, u32 m)
{
    // Make sure order of accuracy is correct
    assert(!(k%2));
    assert(k > 1 && k < 5);
    //assert(m >= 2*k);
    
    //CtoF = sp_mat(m+1, m+2);
    sp_mat CtoF(m+1,m+2);

    float denom;

    switch (k) {
        case 2:
            CtoF(0,0) = 2;
            CtoF(m,m+1) = 2;

            for (u32 i = 1; i <= m-1; i++) {
                CtoF(i,i)   = 1;
                CtoF(i,i+1) = 1;
            }

            denom = 2;
            break;

        case 4:
            CtoF(0,0) = 112;
            CtoF(m,m+1) = 112;

            vec A; // This is stored by default as a column
            A = {-16, 70, 70, -14, 2}; // This is stored as a column, by default
            CtoF(span(1,1),span(0,4)) = A.t(); // transpose to make it a row
            CtoF(span(m-1,m-1),span(m-3,m+1)) = fliplr( A.t() );
            for (u32 i = 2; i<m-1; i++) {
                CtoF(i,i-1) = -7;
                CtoF(i,i)   = 63;
                CtoF(i,i+1) = 63;
                CtoF(i,i+2) = -7;
            }
            denom = 112;
            break;
    
    } // switch end

    CtoF *= (1/denom);
    return CtoF;

} // end Inter_CentersToFaces


sp_mat Interpolator::Inter_CenterToFaces(u32 k, u32 m, u32 n)
{
    sp_mat Ix = Interpolator::Inter_CenterToFaces( k, m );
    sp_mat Iy = Interpolator::Inter_CenterToFaces( k, n );

    sp_mat Im( m+2, m );
    sp_mat In( n+2, n );

    Im(span(1,m), span(0,m-1)) = speye<sp_mat>(m,m);
    In(span(1,n), span(0,n-1)) = speye<sp_mat>(n,n);

    sp_mat Sx;
    Sx = kron( In.t(), Ix );
    sp_mat Sy; 
    Sy = kron( Iy,Im.t() );

    sp_mat I(n*(m+1)+(n+1)*m, 2*(n+2)*(m+2));

    I(span(0,n*(m+1)-1), span(0,(n+2)*(m+2)-1) ) = Sx;
    I(span(n*(m+1),n*(m+1)+(n+1)*m-1), span( (n+2)*(m+2),2*(n+2)*(m+2)-1 )) = Sy;

    return I;
}

sp_mat Interpolator::Inter_CenterToFaces(u32 k, u32 m, u32 n, u32 o)
{
    int cells = (o+2)*(n+2)*(m+2);

    sp_mat Ix = Interpolator::Inter_CenterToFaces( k, m );
    sp_mat Iy = Interpolator::Inter_CenterToFaces( k, n );
    sp_mat Iz = Interpolator::Inter_CenterToFaces( k, o );

    sp_mat Im( m+2, m );
    sp_mat In( n+2, n );
    sp_mat Io( o+2, o );

    Im(span(1,m), span(0,m-1)) = speye<sp_mat>(m,m);
    In(span(1,n), span(0,n-1)) = speye<sp_mat>(n,n);
    Io(span(1,o), span(0,o-1)) = speye<sp_mat>(o,o);

    sp_mat Sx;
    Sx = kron( kron(Io.t(),In.t()), Ix );
    sp_mat Sy; 
    Sy = kron( kron(Io.t(), Iy), Im.t() );
    sp_mat Sz;
    Sz = kron( kron(Iz, In.t()), Im.t() );

    int ix = o*n*(m+1);
    int iy = o*(n+1)*m;
    int iz = (o+1)*n*m;

    sp_mat I(ix+iy+iz, 3*cells);

    I( span(     0,       ix-1), span(      0,   cells-1) ) = Sx;
    I( span(    ix,    ix+iy-1), span(  cells, 2*cells-1) ) = Sy;
    I( span( ix+iy, ix+iy+iz-1), span(2*cells, 3*cells-1) ) = Sz;

    return I;
}

/***************************************************************
   _   _   _   _   _     _   _     _   _   _   _   _   _   _  
  / \ / \ / \ / \ / \   / \ / \   / \ / \ / \ / \ / \ / \ / \ 
 ( F ( a ( c ( e ( s ) ( t ( o ) ( C ( e ( n ( t ( e ( r ( s )
  \_/ \_/ \_/ \_/ \_/   \_/ \_/   \_/ \_/ \_/ \_/ \_/ \_/ \_/ 
***************************************************************/
/* 1D interpolation from faces to centers
   centers logical coordinates [1,1.5:m-0.5,m]
   m is the number of cells in the logical x-axis */

// BRZENSKI Checked k=2,4 both are correct
sp_mat Interpolator::Inter_FacesToCenters(u32 k, u32 m)
{
    // Make sure order of accuracy is correct
    assert(!(k%2));
    assert(k > 1 && k < 5);
    //assert(m >= 2*k);
    
    //FtoC = sp_mat(m+2, m+1);
    sp_mat FtoC(m+2,m+1);

    float denom;

    switch (k) {
        case 2:
            FtoC(0,0) = 2;
            FtoC(m+1,m) = 2;

            for (u32 i = 1; i <= m; i++) {
                FtoC(i,i-1) = 1;
                FtoC(i,i)   = 1;
            }
            denom = 2;
            break;

        case 4:
            FtoC(0,0)   = 128;
            FtoC(m+1,m) = 128;

            vec A; // This is stored by default as a column
            A = {35, 140, -70, 28, -5};
            FtoC(span(1,1),span(0,4)) = A.t(); // transpose to make it a row
            FtoC(span(m,m),span(m-4,m)) = fliplr( A.t() );
            for (u32 i = 2; i<m; i++) {
                FtoC(i,i-2) = -8;
                FtoC(i,i-1) = 72;
                FtoC(i,  i) = 72;
                FtoC(i,i+1) = -8;
            }
            denom = 128;
            break;
    
    } // switch end

    FtoC *= (1/denom);
    return FtoC;

} // end Inter_CentersToFaces 1D

sp_mat Interpolator::Inter_FacesToCenters(u32 k, u32 m, u32 n)
{

    sp_mat Ix = Interpolator::Inter_FacesToCenters( k, m );
    sp_mat Iy = Interpolator::Inter_FacesToCenters( k, n );

    sp_mat Im( m+2, m );
    sp_mat In( n+2, n );

    Im(span(1,m), span(0,m-1)) = speye<sp_mat>(m,m);
    In(span(1,n), span(0,n-1)) = speye<sp_mat>(n,n);

    sp_mat Sx;
    Sx = kron( In, Ix );
    sp_mat Sy; 
    Sy = kron( Iy,Im );

    sp_mat I( 2*(n+2)*(m+2), n*(m+1)+(n+1)*m );

    I(span(0,(n+2)*(m+2)-1), span(0,n*(m+1)-1) ) = Sx;
    I(span((n+2)*(m+2), 2*(n+2)*(m+2)-1 ), span( n*(m+1), n*(m+1)+(n+1)*m -1)) = Sy;

    return I;

} // end Inter_FacesToCenters 2D

sp_mat Interpolator::Inter_FacesToCenters(u32 k, u32 m, u32 n, u32 o)
{
    int cells = (o+2)*(n+2)*(m+2);

    sp_mat Ix = Interpolator::Inter_FacesToCenters( k, m );
    sp_mat Iy = Interpolator::Inter_FacesToCenters( k, n );
    sp_mat Iz = Interpolator::Inter_FacesToCenters( k, o );

    sp_mat Im( m+2, m );
    sp_mat In( n+2, n );
    sp_mat Io( o+2, o );

    Im(span(1,m), span(0,m-1)) = speye<sp_mat>(m,m);
    In(span(1,n), span(0,n-1)) = speye<sp_mat>(n,n);
    Io(span(1,o), span(0,o-1)) = speye<sp_mat>(o,o);

    sp_mat Sx;
    Sx = kron( kron(Io,In), Ix );
    sp_mat Sy; 
    Sy = kron( kron(Io,Iy), Im );
    sp_mat Sz;
    Sz = kron( kron(Iz,In), Im );

    int ix = o*n*(m+1);
    int iy = o*(n+1)*m;
    int iz = (o+1)*n*m;

    sp_mat I(3*cells, ix+iy+iz);

    I( span(0,cells-1), span(0,ix-1) ) = Sx;
    I( span(cells, 2*cells-1), span(ix, ix+iy-1) ) = Sy;
    I( span(2*cells, 3*cells-1), span(ix+iy, ix+iy+iz-1) ) = Sz;

    return I;

} // end fo Inter_FacesToCenters 3D



/***************************************************************
   _   _   _   _   _     _   _     _   _   _   _   _   _   _  
  / \ / \ / \ / \ / \   / \ / \   / \ / \ / \ / \ / \ / \ / \ 
 ( N ( o ( d ( e ( s ) ( t ( o ) ( C ( e ( n ( t ( e ( r ( s )
  \_/ \_/ \_/ \_/ \_/   \_/ \_/   \_/ \_/ \_/ \_/ \_/ \_/ \_/ 
***************************************************************/

/* interpolation operator from nodal coordinates to staggered centers
   m is the number of cells in the logical x-axis
   nodal logical coordinates are [1:1:m]
   centers logical coordinates [1,1.5:m-0.5,m] */
sp_mat Interpolator::Inter_NodesToCenters( u32 k, u32 m)
{
    return Interpolator::Inter_FacesToCenters( k, m );
}


sp_mat Interpolator::Inter_NodesToCenters( u32 k, u32 m, u32 n)
{
    sp_mat I1 = Interpolator::Inter_FacesToCenters( k, m );
    sp_mat I2 = Interpolator::Inter_FacesToCenters( k, n );

    return kron(I2,I1);
}


sp_mat Interpolator::Inter_NodesToCenters( u32 k, u32 m, u32 n, u32 o)
{
    sp_mat I1 = Interpolator::Inter_FacesToCenters( k, m );
    sp_mat I2 = Interpolator::Inter_FacesToCenters( k, n );
    sp_mat I3 = Interpolator::Inter_FacesToCenters( k, o );

    return kron( I3, kron(I2,I1) );
}

/***************************************************************
   _   _   _   _   _   _   _     _   _     _   _   _   _   _  
  / \ / \ / \ / \ / \ / \ / \   / \ / \   / \ / \ / \ / \ / \ 
 ( C ( e ( n ( t ( e ( r ( s ) ( t ( o ) ( N ( o ( d ( e ( s )
  \_/ \_/ \_/ \_/ \_/ \_/ \_/   \_/ \_/   \_/ \_/ \_/ \_/ \_/  
****************************************************************/

sp_mat Interpolator::Inter_CentersToNodes( u32 k, u32 m)
{
    return Interpolator::Inter_CenterToFaces( k, m );
}


sp_mat Interpolator::Inter_CentersToNodes( u32 k, u32 m, u32 n)
{
    sp_mat I1 = Interpolator::Inter_CenterToFaces( k, m );
    sp_mat I2 = Interpolator::Inter_CenterToFaces( k, n );

    return kron(I2, I1);
}


sp_mat Interpolator::Inter_CentersToNodes( u32 k, u32 m, u32 n, u32 o) 
{
    sp_mat I1 = Interpolator::Inter_CenterToFaces( k, m );
    sp_mat I2 = Interpolator::Inter_CenterToFaces( k, n );
    sp_mat I3 = Interpolator::Inter_CenterToFaces( k, o );

    return kron( I3, kron(I2,I1) );
}



/***************************************************************
   _   _   _   _   _     _   _     _   _   _   _     _   _   _   _   _  
  / \ / \ / \ / \ / \   / \ / \   / \ / \ / \ / \   / \ / \ / \ / \ / \ 
 ( N | o | d | e | s ) ( t | o ) ( I | n | d | . ) ( F | a | c | e | s )
  \_/ \_/ \_/ \_/ \_/   \_/ \_/   \_/ \_/ \_/ \_/   \_/ \_/ \_/ \_/ \_/ 
****************************************************************/
// NOTES JARED
// Interpolating in X gives the lcoations at the V locations
// similarly, interpolating in Y gives the values at the U points.
// Derivative in Z is still at the Z coordinate.
// Dont mess that up
// I( span(     0,       ix-1), span(      0,   cells-1) ) = Sx;
// I( span(    ix,    ix+iy-1), span(  cells, 2*cells-1) ) = Sy;
// I( span( ix+iy, ix+iy+iz-1), span(2*cells, 3*cells-1) ) = Sz;

sp_mat Interpolator::Inter_NodeToU( u32 k, u32 m, u32 n )
{
    sp_mat NtoC  = Interpolator::Inter_NodesToCenters( k,m,n );
    sp_mat CtoF  = Interpolator::Inter_CenterToFaces(  k,m,n );

    int cells = (n+2)*(m+2);
    int    ix = (m+1)*n;
    // Using X derivative component
    sp_mat CtoFV = CtoF(span(0,ix-1), span(0,cells-1) );
    return CtoFV * NtoC;
}

sp_mat Interpolator::Inter_NodeToU( u32 k, u32 m, u32 n, u32 o)
{
    sp_mat NtoC  = Interpolator::Inter_NodesToCenters( k,m,n,o );
    sp_mat CtoF  = Interpolator::Inter_CenterToFaces(  k,m,n,o );
    
    int cells = (o+2)*(n+2)*(m+2);
    int ix = o*n*(m+1);
    // Using X derivative component
    sp_mat CtoFV = CtoF(span( 0,ix-1), span( 0,cells-1 ) );
    return CtoFV * NtoC;
}

sp_mat Interpolator::Inter_NodeToV( u32 k, u32 m, u32 n )
{
    sp_mat NtoC  = Interpolator::Inter_NodesToCenters( k,m,n );
    sp_mat CtoF  = Interpolator::Inter_CenterToFaces(  k,m,n );

    int cells = (n+2)*(m+2);
    int    ix = (m+1)*n;
    int    iy = m*(n+1);

    // Using Y derivative component
    sp_mat CtoFU = CtoF(span(ix,iy+ix-1), span( cells,2*cells-1 ));
    return CtoFU * NtoC;
}

sp_mat Interpolator::Inter_NodeToV( u32 k, u32 m, u32 n, u32 o)
{
    sp_mat NtoC  = Interpolator::Inter_NodesToCenters( k,m,n,o );
    sp_mat CtoF  = Interpolator::Inter_CenterToFaces(  k,m,n,o );

    int cells = (o+2)*(n+2)*(m+2);
    int ix = o*n*(m+1);
    int iy = o*(n+1)*m;
    // Using Y derivative component
    sp_mat CtoFU = CtoF(span( ix, ix+iy-1), span(cells, 2*cells-1 ) );
    return CtoFU * NtoC;
}

// NODE TO W
sp_mat Interpolator::Inter_NodeToW( u32 k, u32 m, u32 n, u32 o)
{
    sp_mat NtoC  = Interpolator::Inter_NodesToCenters( k,m,n,o );
    sp_mat CtoF  = Interpolator::Inter_CenterToFaces(  k,m,n,o );

    int cells = (o+2)*(n+2)*(m+2);
    int ix = o*n*(m+1);
    int iy = o*(n+1)*m;
    int iz = (o+1)*n*m;
    
    sp_mat CtoFW = CtoF(span(ix+iy, ix+iy+iz-1), span( 2*cells, 3*cells-1 ) );
    return CtoFW * NtoC;
}


/***************************************************************
   _   _   _   _     _   _   _   _   _     _   _     _   _   _   _   _  
  / \ / \ / \ / \   / \ / \ / \ / \ / \   / \ / \   / \ / \ / \ / \ / \ 
 ( I | n | d | . ) ( F | a | c | e | s ) ( t | o ) ( N | o | d | e | s )
  \_/ \_/ \_/ \_/   \_/ \_/ \_/ \_/ \_/   \_/ \_/   \_/ \_/ \_/ \_/ \_/ 
****************************************************************/
// U TO NODE
sp_mat Interpolator::Inter_UtoNode( u32 k, u32 m, u32 n )
{
    sp_mat FtoC  = Interpolator::Inter_FacesToCenters( k,m,n );
    sp_mat CtoN  = Interpolator::Inter_CentersToNodes(  k,m,n );
    
    int ix = n*(m+1); // Numebr of U
    int iy = (n+1)*m; // Number of V
    int cells = (n+2)*(m+2);

    sp_mat FUtoC = FtoC(span( cells, 2*cells-1 ), span( iy, ix+iy -1)) ;
    return CtoN * FUtoC;
}
 
sp_mat Interpolator::Inter_UtoNode( u32 k, u32 m, u32 n, u32 o)
{
    sp_mat FtoC  = Interpolator::Inter_FacesToCenters( k,m,n,o );
    sp_mat CtoN  = Interpolator::Inter_CentersToNodes( k,m,n,o );

    int ix = o*n*(m+1); // Numebr of X
    int iy = o*(n+1)*m; // Number of Y
    int iz = (o+1)*n*m; // Number of Z
    int cells = (o+2)*(n+2)*(m+2);  

    sp_mat FUtoC = FtoC( span(cells, 2*cells-1), span(ix, ix+iy-1) ) ;
    return CtoN * FUtoC;
}

// V TO NODE
sp_mat Interpolator::Inter_VtoNode( u32 k, u32 m, u32 n )
{
    sp_mat FtoC  = Interpolator::Inter_FacesToCenters( k,m,n );
    sp_mat CtoN  = Interpolator::Inter_CentersToNodes( k,m,n );

    int ix = n*(m+1); // Numebr of U
    int iy = (n+1)*m; // Number of V
    int cells = (n+2)*(m+2); 

    sp_mat FVtoC = FtoC(span(0,cells-1), span(0,iy-1) );
    return CtoN * FVtoC;
}

sp_mat Interpolator::Inter_VtoNode( u32 k, u32 m, u32 n, u32 o)
{
    sp_mat FtoC  = Interpolator::Inter_FacesToCenters( k,m,n,o );
    sp_mat CtoN  = Interpolator::Inter_CentersToNodes( k,m,n,o );
    
    int ix = o*n*(m+1); // Numebr of X
    int iy = o*(n+1)*m; // Number of Y
    int iz = (o+1)*n*m; // Number of Z
    int cells = (o+2)*(n+2)*(m+2);  

    sp_mat FVtoC = FtoC( span(0,cells-1), span(0,ix-1) );
    return CtoN * FVtoC;
}

sp_mat Interpolator::Inter_WtoNode( u32 k, u32 m, u32 n, u32 o)
{
    sp_mat FtoC  = Interpolator::Inter_FacesToCenters( k,m,n,o );
    sp_mat CtoN  = Interpolator::Inter_CentersToNodes( k,m,n,o );
    
    int ix = o*n*(m+1); // Numebr of X
    int iy = o*(n+1)*m; // Number of Y
    int iz = (o+1)*n*m; // Number of Z
    int cells = (o+2)*(n+2)*(m+2);  
    
    sp_mat FWtoC = FtoC( span(2*cells, 3*cells-1), span(ix+iy, ix+iy+iz-1) );
    return CtoN * FWtoC;

}


/***************************************************************
   ____           _                  _          _   ___     ____        __
  / ___|___ _ __ | |_ ___ _ __ ___  | |_ ___   | | | \ \   / /\ \      / /
 | |   / _ \ '_ \| __/ _ \ '__/ __| | __/ _ \  | | | |\ \ / /  \ \ /\ / / 
 | |__|  __/ | | | ||  __/ |  \__ \ | || (_) | | |_| | \ V /    \ V  V /  
  \____\___|_| |_|\__\___|_|  |___/  \__\___/   \___/   \_/      \_/\_/                                                                           
****************************************************************/

sp_mat Interpolator::Inter_CtoU( u32 k, u32 m, u32 n )
{
    int ix = n*(m+1); // Numebr of X
    int iy = (n+1)*m; // Number of Y
    int cells = (n+2)*(m+2);
    //
    sp_mat CtoF = Interpolator::Inter_CenterToFaces(k, m, n);
    //
    return CtoF( span(0,ix-1), span(0,cells-1) );

}

sp_mat Interpolator::Inter_CtoV( u32 k, u32 m, u32 n )
{
    int ix = n*(m+1); // Numebr of X
    int iy = (n+1)*m; // Number of Y
    int cells = (n+2)*(m+2);
    //
    sp_mat CtoF = Interpolator::Inter_CenterToFaces(k, m, n);
    //
    return CtoF( span(ix,ix+iy-1), span(cells,2*cells-1) );

}

sp_mat Interpolator::Inter_UtoC( u32 k, u32 m, u32 n )
{
    int ix = n*(m+1); // Numebr of X
    int iy = (n+1)*m; // Number of Y
    int cells = (n+2)*(m+2);

    sp_mat FtoC = Interpolator::Inter_FacesToCenters( k,m,n );
    sp_mat UtoC = FtoC( span(0, cells-1), span(0, ix-1 ) );
    return UtoC;
}

sp_mat Interpolator::Inter_VtoC( u32 k, u32 m, u32 n )
{
    int ix = n*(m+1); // Numebr of X
    int iy = (n+1)*m; // Number of Y
    int cells = (n+2)*(m+2);

    sp_mat FtoC = Interpolator::Inter_FacesToCenters( k,m,n );
    sp_mat VtoC = FtoC( span(cells, 2*cells-1), span(ix, ix+iy-1 ) );

    return VtoC;
}

// 3D interpolations
sp_mat Interpolator::Inter_CtoU( u32 k, u32 m, u32 n, u32 o )
{
    int ix = o*n*(m+1); // Numebr of X
    int iy = o*(n+1)*m; // Number of Y
    int iz = (o+1)*n*m; // Number of Z
    int cells = (o+2)*(n+2)*(m+2);

    sp_mat CtoF = Interpolator::Inter_CenterToFaces(k, m, n, o);
    //
    return CtoF( span(0,ix-1), span(0,cells-1) );

}

sp_mat Interpolator::Inter_CtoV( u32 k, u32 m, u32 n, u32 o )
{
    int ix = o*n*(m+1); // Numebr of X
    int iy = o*(n+1)*m; // Number of Y
    int iz = (o+1)*n*m; // Number of Z
    int cells = (o+2)*(n+2)*(m+2);

    sp_mat CtoF = Interpolator::Inter_CenterToFaces(k, m, n, o);
    //
    return CtoF( span(ix,ix+iy-1), span(cells,2*cells-1) );

}

sp_mat Interpolator::Inter_CtoW( u32 k, u32 m, u32 n, u32 o )
{
    int ix = o*n*(m+1); // Numebr of X
    int iy = o*(n+1)*m; // Number of Y
    int iz = (o+1)*n*m; // Number of Z
    int cells = (o+2)*(n+2)*(m+2);

    sp_mat CtoF = Interpolator::Inter_CenterToFaces(k, m, n, o);
    //
    return CtoF( span(ix+iy,ix+iy+iz-1), span(2*cells,3*cells-1) );

}

sp_mat Interpolator::Inter_UtoC( u32 k, u32 m, u32 n, u32 o )
{
    int ix = o*n*(m+1); // Numebr of X
    int iy = o*(n+1)*m; // Number of Y
    int iz = (o+1)*n*m; // Number of Z
    int cells = (o+2)*(n+2)*(m+2);

    sp_mat FtoC = Interpolator::Inter_FacesToCenters( k,m,n,o );
    sp_mat UtoC = FtoC( span(0, cells-1), span(0, ix-1 ) );
    return UtoC;
}

sp_mat Interpolator::Inter_VtoC( u32 k, u32 m, u32 n, u32 o )
{
    int ix = o*n*(m+1); // Numebr of X
    int iy = o*(n+1)*m; // Number of Y
    int iz = (o+1)*n*m; // Number of Z
    int cells = (o+2)*(n+2)*(m+2);

    sp_mat FtoC = Interpolator::Inter_FacesToCenters( k,m,n,o );
    sp_mat VtoC = FtoC( span(cells, 2*cells-1), span(ix, ix+iy-1 ) );

    return VtoC;
}

sp_mat Interpolator::Inter_WtoC( u32 k, u32 m, u32 n, u32 o )
{
    int ix = o*n*(m+1); // Numebr of X
    int iy = o*(n+1)*m; // Number of Y
    int iz = (o+1)*n*m; // Number of Z
    int cells = (o+2)*(n+2)*(m+2);

    sp_mat FtoC = Interpolator::Inter_FacesToCenters( k,m,n,o );
    sp_mat WtoC = FtoC( span(2*cells, 3*cells-1), span(ix+iy, ix+iy+iz-1 ) );

    return WtoC;
}
/***************************************************************
  _   ___     ____        __  _          _   ___     ____        __
 | | | \ \   / /\ \      / / | |_ ___   | | | \ \   / /\ \      / /
 | | | |\ \ / /  \ \ /\ / /  | __/ _ \  | | | |\ \ / /  \ \ /\ / / 
 | |_| | \ V /    \ V  V /   | || (_) | | |_| | \ V /    \ V  V /  
  \___/   \_/      \_/\_/     \__\___/   \___/   \_/      \_/\_/ 
***************************************************************/

// 2D Operations
sp_mat Interpolator::Inter_UtoV( u32 k, u32 m, u32 n )
{
    sp_mat UtoC = Interpolator::Inter_UtoC( k,m,n );
    sp_mat CtoV = Interpolator::Inter_CtoV( k, m, n );
    //
    return CtoV * UtoC;
}

sp_mat Interpolator::Inter_VtoU( u32 k, u32 m, u32 n )
{
    sp_mat VtoC = Interpolator::Inter_VtoC( k,m,n );
    sp_mat CtoU = Interpolator::Inter_CtoU( k, m, n );
    //
    return CtoU * VtoC;
}


// 3D Operations
sp_mat Interpolator::Inter_UtoV( u32 k, u32 m, u32 n, u32 o )
{
    sp_mat UtoC = Interpolator::Inter_UtoC( k,m,n,o );
    sp_mat CtoV = Interpolator::Inter_CtoV( k,m,n,o );
    //
    return CtoV * UtoC;
}

sp_mat Interpolator::Inter_UtoW( u32 k, u32 m, u32 n, u32 o )
{
    sp_mat UtoC = Interpolator::Inter_UtoC( k,m,n,o );
    sp_mat CtoW = Interpolator::Inter_CtoW( k,m,n,o );
    //
    return CtoW * UtoC;
}

sp_mat Interpolator::Inter_VtoU( u32 k, u32 m, u32 n, u32 o )
{
    sp_mat VtoC = Interpolator::Inter_VtoC( k,m,n,o );
    sp_mat CtoU = Interpolator::Inter_CtoU( k,m,n,o );
    //
    return CtoU * VtoC;
}
sp_mat Interpolator::Inter_VtoW( u32 k, u32 m, u32 n, u32 o )
{
    sp_mat VtoC = Interpolator::Inter_VtoC( k,m,n,o );
    sp_mat CtoW = Interpolator::Inter_CtoW( k,m,n,o );
    //
    return CtoW * VtoC;
}

sp_mat Interpolator::Inter_WtoU( u32 k, u32 m, u32 n, u32 o )
{
    sp_mat WtoC = Interpolator::Inter_WtoC( k,m,n,o );
    sp_mat CtoU = Interpolator::Inter_CtoU( k,m,n,o );
    //
    return CtoU * WtoC;
}
sp_mat Interpolator::Inter_WtoV( u32 k, u32 m, u32 n, u32 o )
{
    sp_mat WtoC = Interpolator::Inter_WtoC( k,m,n,o );
    sp_mat CtoV = Interpolator::Inter_CtoV( k,m,n,o );
    //
    return CtoV * WtoC;
}
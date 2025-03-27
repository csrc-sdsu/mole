#include "nodal.h"

// 1-D Constructor
Nodal::Nodal(u16 k, u32 m, double dx) : sp_mat(m, m)
{
    DBGMSG("Nodal 1D starting.");

    assert(k == 2 || k == 4);
    assert(m >= 2*k);

    switch (k) {
        case 2:
            // A
            at(0, 0) = -1.5;
            at(0, 1) =  2.0;
            at(0, 2) = -0.5;
            // A'
            at(m-1, m-1)   =  1.5;
            at(m-1, m-2) = -2.0;
            at(m-1, m-3) =  0.5;
            // Middle
            for (u32 i = 1; i < m-1; i++) {
                at(i, i-1) = -0.5;
                at(i, i+1) =  0.5;
            }
            // Weights
            break;
        
        case 4:
            //A
            // Coefficients:
            // -25/12, 4, -3, 4/3, -1/4
            // -1/4, -5/6, 3/2, -1/2, 1/12
            at( 0, 0 ) = -25.0/12.0;
            at( 0, 1 ) =        4.0;
            at( 0, 2 ) =       -3.0;
            at( 0, 3 ) =    4.0/3.0;
            at( 0, 4 ) =      -0.25;
            
            at( 1, 0 ) =     -0.25;
            at( 1, 1 ) =  -5.0/6.0;
            at( 1, 2 ) =       1.5;
            at( 1, 3 ) =      -0.5;
            at( 1, 4 ) =  1.0/12.0;

            //A'
            // Coefficients
            // -1/12, 1/2, -3/2, 5/6, 1/4
            // 1/4, -4/3, 3, -4, 25/12
            at( m-2, m-5 ) = -1.0/12.0;
            at( m-2, m-4 ) =   0.5;
            at( m-2, m-3 ) =  -1.5;
            at( m-2, m-2 ) =   5.0/6.0;
            at( m-2, m-1 ) =  0.25;

            at( m-1, m-5 ) =  0.25;
            at( m-1, m-4 ) =  -4.0/3.0;
            at( m-1, m-3 ) =     3;
            at( m-1, m-2 ) =    -4;
            at( m-1, m-1 ) = 25.0/12.0;

            for ( u32 i = 2; i < m-2; i++ ) {
                at( i, i-2 ) =  1.0/12.0;
                at( i, i-1 ) =  -2.0/3.0;
                at( i, i+1 ) =   2.0/3.0;
                at( i, i+2 ) = -1.0/12.0;
            }
            break;
    }

    // Scaling
    *this /= dx;
}

// 2-D Constructor
Nodal::Nodal(u16 k, u32 m, u32 n, double dx,  double dy)
{
    DBGMSG("Nodal 2D starting.");
    
    Nodal Nx( k, m, dx ); // m
    Nodal Ny( k, n, dy ); // n

    sp_mat Im = speye(m, m);
    sp_mat In = speye(n, n);

    sp_mat G1 = Utils::spkron(In, Nx);
    sp_mat G2 = Utils::spkron(Ny, Im);

    // Dimensions = 2*m*n+m+n, (m+2)*(n+2)
    if (m != n)
        *this = join_vert(G1, G2);    
        //*this = Utils::spjoin_cols(G1, G2);
    else {
        cout  <<" Doing something..." << endl;
        sp_mat A1(2, 1);
        sp_mat A2(2, 1);
        cout <<"A1 A2 done"<<endl;
        A1(0, 0) = A2(1, 0) = 1.0;
        cout <<"A1 A2 st to 1"<<endl;
        *this = Utils::spkron(A1, G1) + Utils::spkron(A2, G2);
        cout <<"Add spkrons"<<endl;

    }

}

// 3-D Constructor
Nodal::Nodal(u16 k, u32 m, u32 n, u32 o,double dx, double dy, double dz)
{
    DBGMSG("Nodal 3D Starting.");
    
    Nodal Nx(k, m, dx);
    Nodal Ny(k, n, dy);
    Nodal Nz(k, o, dz);

    sp_mat Im = speye(m, m);
    sp_mat In = speye(n, n);
    sp_mat Io = speye(o, o);

    sp_mat G1 = Utils::spkron(Utils::spkron(Io, In), Nx);
    sp_mat G2 = Utils::spkron(Utils::spkron(Io, Ny), Im);
    sp_mat G3 = Utils::spkron(Utils::spkron(Nz, In), Im);

    // Dimensions = 3*m*n*o+m*n+m*o+n*o, (m+2)*(n+2)*(o+2)
    if ((m != n) || (n != o))
        *this = Utils::spjoin_cols(Utils::spjoin_cols(G1, G2), G3);
    else {
        sp_mat A1(3, 1);
        sp_mat A2(3, 1);
        sp_mat A3(3, 1);
        A1(0, 0) = A2(1, 0) = A3(2, 0) = 1.0;
        *this = Utils::spkron(A1, G1) + Utils::spkron(A2, G2) + Utils::spkron(A3, G3);
    }
}

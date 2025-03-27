#include "jacobian.h"

void Jacob::Jacobian(const u16 k, const mat &Xin, const mat &Yin)
{
    // Returns:
    //                J : Determinant of the Jacobian (XeYn - XnYe)
    //               Xe : dx/de metric
    //               Xn : dx/dn metric
    //               Ye : dy/de metric
    //               Yn : dy/dn metric
    //
    // Parameters:
    //                k : Order of accuracy
    //                X : x-coordinates (physical) of meshgrid
    //                Y : y-coordinates (physical) of meshgrid
    u32 m = 0;
    u32 n = 0;

    m = Xin.n_cols;
    n = Xin.n_rows;
    
    vec X = vectorise(Xin.t(),0);
    vec Y = vectorise(Yin.t(),0);

    //X = reshape(X', [], 1);
    //Y = reshape(Y', [], 1);
    
    sp_mat N;
    N = Nodal(k, m, n, 1, 1);
    
    X = N*X;
    Y = N*Y;
    
    int mn = m*n;
    int end = X.n_elem -1;

    Xe = X.subvec(0,mn-1);
    Xn = X.subvec(mn,end);
    Ye = Y.subvec(0,mn-1);
    Yn = Y.subvec(mn,end);
    
    Jacob_vec = Xe%Yn-Xn%Ye;

    cout << "Finished 2D Jacobian" << endl;

}


void Jacob::Jacobian(const u16 k, const cube &Xin, const cube &Yin, const cube &Zin)
{
    // Returns:
    //                J : Determinant of the Jacobian (XeYn - XnYe)
    //               Xe : dx/de metric
    //               Xn : dx/dn metric
    //               Ye : dy/de metric
    //               Yn : dy/dn metric
    //
    // Parameters:
    //                k : Order of accuracy
    //                X : x-coordinates (physical) of meshgrid
    //                Y : y-coordinates (physical) of meshgrid
    DBGMSG("Starting Jacobian.");

    u32 m = 0;
    u32 n = 0;
    u32 o = 0;

    m = Xin.n_rows;
    n = Xin.n_cols;
    o = Xin.n_slices;

    vec X = vectorise(Xin);
    vec Y = vectorise(Yin);
    vec Z = vectorise(Zin);

    //X = reshape(X', [], 1);
    //Y = reshape(Y', [], 1);
    
    sp_mat N;
    N = Nodal(k, m, n, o, 1, 1, 1);
    
    X = N*X;
    Y = N*Y;
    Z = N*Z;

    sp_mat Xs(X);
    sp_mat Ys(Y);
    sp_mat Zs(Z);

    int mno = m*n*o;
    int end = X.n_elem -1;

    Xe = X.subvec(0,mno-1);
    Xn = X.subvec(mno,2*mno-1);
    Xc = X.subvec(2*mno,end);
    Ye = Y.subvec(0,mno-1);
    Yn = Y.subvec(mno,2*mno-1);
    Yc = Y.subvec(2*mno,end);
    Ze = Z.subvec(0,mno-1);
    Zn = Z.subvec(mno,2*mno-1);
    Zc = Z.subvec(2*mno,end);
    
    DBGMSG("Building Jacobian vector.");
    
    Jacob_vec = Xe%(Yn%Zc-Yc%Zn)-Ye%(Xn%Zc-Xc%Zn)+Ze%(Xn%Yc-Xc%Yn);

}

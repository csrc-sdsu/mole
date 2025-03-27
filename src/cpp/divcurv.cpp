#include "divcurv.h"
#include <chrono>


void DivCurv::D3DCurv(const u16 k, const cube &X, const cube &Y, const cube &Z)
{
    DBGMSG("Starting D3DCurv.");
    //auto jstart = std::chrono::high_resolution_clock::now();

    Jacob J;
    // [J, Xe, Xn, Xc, Ye, Yn, Yc, Ze, Zn, Zc] //
    J.Jacobian(k,X,Y,Z);
    //auto jend = std::chrono::high_resolution_clock::now();
    //const std::chrono::duration<double, std::milli> jduration = jend - jstart;
    //std::cout << "The Jacobian took " << jduration.count()/1e3 << " seconds to execute." << std::endl;

    int m = X.n_rows;
    int n = X.n_cols;
    int o = X.n_slices;

    int size_u = (m)*(n-1)*(o-1);
    int size_v = (m-1)*(n)*(o-1);
    int size_w = (m-1)*(n-1)*(o);
    int size_c = (m+1)*(n+1)*(o+1);
    int size_n = (m)*(n)*(o);

    // Newest Interpolators
    Interpolator In;
    
    //auto istart = std::chrono::high_resolution_clock::now();
    // Pretty sure the m,n,o are taken care of in the function
    sp_mat NtoC = In.Inter_NodesToCenters(k,m-1,n-1,o-1);
    // iend = std::chrono::high_resolution_clock::now();
    //const std::chrono::duration<double, std::milli> iduration = ( iend - istart );
    //std::cout << "The Interpolator took " << iduration.count()/1e3 << " seconds to execute." << std::endl;

    DBGMSG("Mulitplying by inverse Jacobians");
    //auto vstart = std::chrono::high_resolution_clock::now();
    // Jacobian has returned all vectors
    vec A = J.Yn%J.Zc-J.Zn%J.Yc;
    vec B = J.Zn%J.Xc-J.Xn%J.Zc;
    vec C = J.Xn%J.Yc-J.Yn%J.Xc;
    vec D = J.Ze%J.Yc-J.Ye%J.Zc;
    vec E = J.Xe%J.Zc-J.Ze%J.Xc;
    vec F = J.Ye%J.Xc-J.Xe%J.Yc;
    vec G = J.Ye%J.Zn-J.Ze%J.Yn;
    vec H = J.Ze%J.Xn-J.Xe%J.Zn;
    vec I = J.Xe%J.Yn-J.Ye%J.Xn;

    //Interpolate the vectors to centers
    vec Jc = NtoC * J.Jacob_vec;
    Jc = 1.0 / Jc; // BRZENSKI Added 11/23/23
    A  = NtoC * A; 
    B  = NtoC * B;
    C  = NtoC * C;
    D  = NtoC * D;
    E  = NtoC * E;
    F  = NtoC * F;
    G  = NtoC * G;
    H  = NtoC * H;
    I  = NtoC * I;
    // auto vend = std::chrono::high_resolution_clock::now();
    // const std::chrono::duration<double, std::milli> vduration = vend - vstart;
    // std::cout << "The Vector mult interpolator took " << vduration.count()/1e3 << " seconds to execute." << std::endl;

    // Transform them into sparse diagonalized matrices
    // auto sstart = std::chrono::high_resolution_clock::now();
    sp_mat As(A.n_elem,  A.n_elem);     As.diag(0) = A;
    sp_mat Bs(B.n_elem,  B.n_elem);     Bs.diag(0) = B;
    sp_mat Cs(C.n_elem,  C.n_elem);     Cs.diag(0) = C;
    sp_mat Ds(D.n_elem,  D.n_elem);     Ds.diag(0) = D;
    sp_mat Es(E.n_elem,  E.n_elem);     Es.diag(0) = E;
    sp_mat Fs(F.n_elem,  F.n_elem);     Fs.diag(0) = F;
    sp_mat Gs(G.n_elem,  G.n_elem);     Gs.diag(0) = G;
    sp_mat Hs(H.n_elem,  H.n_elem);     Hs.diag(0) = H;
    sp_mat Is(I.n_elem,  I.n_elem);     Is.diag(0) = I;
    sp_mat Js(Jc.n_elem, Jc.n_elem);    Js.diag(0) = Jc;
    // auto send = std::chrono::high_resolution_clock::now();
    // const std::chrono::duration<double, std::milli> sduration = send - sstart;
    // std::cout << "The Sparse maker mult nterpolator took " << sduration.count()/1e3 << " seconds to execute." << std::endl;

    
    Divergence Div(k, m-1, n-1, o-1, 1, 1, 1);     // Gradient

    sp_mat De = Div.cols(0,size_u-1);
    sp_mat Dn = Div.cols(size_u,size_u+size_v-1);
    sp_mat Dc = Div.cols(size_u+size_v, size_u+size_v+size_w-1);

    // Apply Transformation
    /* Case 't' can repressent any of the following:
    1 - Dn
    2 - De
    3 - Dc
    4 - Dcc
    5 - Dee
    6 - Dnn  */

    // These are stored in DI_inter

    DI(m-1, n-1, o-1, 1);   //Dn
    sp_mat IDs = DI_inter;

    DI(m-1,n-1,o-1,3);      //Dc
    sp_mat IDc = DI_inter;

    // auto d1start = std::chrono::high_resolution_clock::now();
    sp_mat Dx = Js*( (As*De) + (Ds*IDs) + (Gs*IDc) );
    // auto d1end = std::chrono::high_resolution_clock::now();
    // const std::chrono::duration<double, std::milli> d1duration = d1end - d1start;
    // std::cout << "The Dx maker mult interpolator took " << d1duration.count()/1e3 << " seconds to execute." << std::endl;

    DI(m-1, n-1, o-1, 2); //De
    sp_mat IDe = DI_inter;
    DI(m-1, n-1, o-1, 4); //Dcc
    IDc = DI_inter;
    // auto d2start = std::chrono::high_resolution_clock::now();

    sp_mat Dy = Js*( (Bs*IDe) + (Es*Dn) + (Hs*IDc) );
    // auto d2end = std::chrono::high_resolution_clock::now();
    // const std::chrono::duration<double, std::milli> d2duration = d2end - d2start;
    // std::cout << "The Dy maker mult interpolator took " << d2duration.count()/1e3 << " seconds to execute." << std::endl;

    DI(m-1, n-1, o-1, 5); //Dee
    IDe = DI_inter;
    DI(m-1, n-1, o-1, 6); //Dnn
    sp_mat IDn = DI_inter;
    // cout << "Size of IDe is " << arma::size(IDe) << "and number of nnz=" << IDe.n_nonzero << endl;
    // cout << "Size of IDn is " << arma::size(IDn) << "with nnz=" << IDn.n_nonzero << endl;
    // cout << "Size of Is is " << arma::size(Is) << " with nnz=" << Is.n_nonzero << endl;
    // cout << "Size of Cs is " << arma::size(Cs) << " with nnz=" << Cs.n_nonzero << endl;
    // cout << "Size of Fs is " << arma::size(Fs) << " with nnz=" << Fs.n_nonzero << endl;
    // cout << "Size of Dc is " << arma::size(Dc) << " with nnz=" << Dc.n_nonzero << endl;

    auto d3start = std::chrono::high_resolution_clock::now();
    sp_mat Dz( arma::size(IDe) );
    sp_mat temp1 = Cs * IDe;
    sp_mat temp2 = Fs * IDn;
    sp_mat temp3 = Is * Dc;
    Dz = temp1 + temp2 + temp3;
    //Dz = (Cs*IDe) + (Fs*IDn) + (Is*Dc);
    auto d3end = std::chrono::high_resolution_clock::now();
    const std::chrono::duration<double, std::milli> d3duration = d3end - d3start;
    std::cout << "The Dz maker first mult interpolator took " << d3duration.count()/1e3 << " seconds to execute." << std::endl;
    
    auto d4start = std::chrono::high_resolution_clock::now();
    Dz = Js*Dz;
    //sp_mat Dz = Js*( (Cs*IDe) + (Fs*IDn) + (Is*Dc) );
    auto d4end = std::chrono::high_resolution_clock::now();
    const std::chrono::duration<double, std::milli> d4duration = d4end - d4start;
    std::cout << "The Dz final partmaker mult interpolator took " << d4duration.count()/1e3 << " seconds to execute." << std::endl;
    // cout << "Size of Dz is " << arma::size(Dz) << endl;

    DBGMSG("Joining three Ds.");
    // auto dmakestart = std::chrono::high_resolution_clock::now();
    div3DCurv = join_horiz(Dx, Dy, Dz);
    // auto dmakeend = std::chrono::high_resolution_clock::now();
    // const std::chrono::duration<double, std::milli> dmakeduration = dmakeend - dmakestart;
    // std::cout << "The D joiner maker mult interpolator took " << dmakeduration.count()/1e3 << " seconds to execute." << std::endl;

    // Clean out smaller values not needed !!!
    div3DCurv.clean(datum::eps);

    // % Apply transformation
    // Gx = Ju*(A*Ge+D*GI13(Gn, m-1, n-1, o-1, 'Gn')+G*GI13(Gc, m-1, n-1, o-1, 'Gc'));
    // Gy = Jv*(B*GI13(Ge, m-1, n-1, o-1, 'Ge')+E*Gn+H*GI13(Gc, m-1, n-1, o-1, 'Gcy'));
    // Gz = Jw*(C*GI13(Ge, m-1, n-1, o-1, 'Gee')+F*GI13(Gn, m-1, n-1, o-1, 'Gnn')+I*Gc);
    
    // % Final 3D curvilinear mimetic gradient operator (d/dx, d/dy, d/dz)
    // G = [Gx; Gy; Gz];
}


void DivCurv::DI( const u16 m, const u16 n, const u16 t)
{
    /* Case 't' can repressent any of the following:
    1 - Dn
    2 - De
    3 - Dc
    4 - Dcc
    5 - Dee
    6 - Dnn  */
    assert(t > 0 && t < 3);
    
    switch(t) {

        case(1):{
            // Dn
            // Boundary Block
            vec e;
            e.ones(m);
            sp_mat bdry(m, ((m+1)*n) );
            bdry.diag(0) = -0.5*e;
            bdry.diag(1) = -0.5*e; 
            bdry.diag(m+1) = 0.5*e;
            bdry.diag(m+2) = 0.5*e;

            // Main Block
            sp_mat block(m+2,m+1);
            vec e2;
            e2 = e2.ones(m+1)*0.25;
            e2(m-1) = 0.25;
            e2(m) = 0;
            block.diag(0) = e2;
            e2(m-1) = 0.25;
            e2.resize(m);
            block.diag(1) = e2;

            // Pattern Block
            sp_mat pattern(n-2,n);
            e.ones(n-2);
            pattern.diag(0) = -e;
            pattern.diag(2) =  e;

            // Middle Block
            sp_mat middle;
            middle = Utils::spkron(pattern, block);

            // Final Dn
            sp_mat Top(m+3,    (m+1)*n );
            sp_mat Middle(2,   (m+1)*n );
            sp_mat Bottom(m+3, (m+1)*n );

            // Cannot shift a sparse matrix??
            //mat bdry_dense(bdry);
            sp_mat bdry_shift;
            //bdry_shift = arma::shift(bdry_dense, (m+1)*(n-2), 1);
            bdry_shift = Utils::circshift(bdry, (m+1)*(n-2), 1);

            // Will not join sparse matrices mroe than 2 at a time;
            sp_mat I;
            I = arma::join_vert(Top, bdry);
            I = arma::join_vert(I,Middle);
            I = arma::join_vert(I,middle);
            I = arma::join_vert(I,bdry_shift);
            I = arma::join_vert(I,Bottom);
            
            DI_inter = std::move(I);
            break;
        }

        case(2):{
            // De
            // Main Block
            sp_mat block(m+2,m);
            vec e;
            e = e.ones(m)*(-0.25);
            e(m-1) = 0;
            block.diag(-1) = e;
            block.diag(1).fill(0.25);

            block(0,0) = -0.5;
            block(0,1) = 0.5;
            block(m-1,m-2) = -0.5;
            block(m-1,m-1) = 0.5;

            // Pattern Block
            sp_mat pattern(n,n+1);
            pattern.diag(0).fill(1);
            pattern.diag(1).fill(1);

            // Middle Block
            sp_mat middle;
            middle = Utils::spkron(pattern, block);
            
            // Final De
            sp_mat Top(m+3,    (n+1)*m );
            sp_mat Bottom(m+1, (n+1)*m );

            // Will not join sparse matrices mroe than 2 at a time;
            sp_mat I;

            I = arma::join_vert(Top, middle);
            I = arma::join_vert(I,Bottom);
            
            DI_inter = std::move(I);
            break;
        }
    }
}

void DivCurv::DI( const u16 m, const u16 n, const u16 o, const u16 t)
{
    /* Case 't' can repressent any of the following:
    1 - Dn
    2 - De
    3 - Dc
    4 - Dcc
    5 - Dee
    6 - Dnn  */
    assert(t > 0 && t < 7);
    
    DBGVMSG("DI starting for case", t);
    
    switch(t) {

        case(1):{
            // Dn
            //cout << "DI3 -- Case 1" << endl;
            
            // Boundary Block
            vec e;
            e.ones(m);
            sp_mat bdry(m, ((m+1)*n) );
            bdry.diag(0) = -0.5*e;
            bdry.diag(1) = -0.5*e; 
            bdry.diag(m+1) = 0.5*e;
            bdry.diag(m+2) = 0.5*e;

            // Main Block
            sp_mat block(m+2,m+1);
            vec e2;
            e2 = e2.ones(m+1)*0.25;
            e2(m-1) = 0.25;
            e2(m) = 0;
            block.diag(0) = e2;
            e2(m-1) = 0.25;
            e2.resize(m);
            block.diag(1) = e2;

            // Pattern Block
            sp_mat pattern(n-2,n);
            e.ones(n-2);
            pattern.diag(0) = -e;
            pattern.diag(2) =  e;

            // Middle Block
            sp_mat middle;
            middle = Utils::spkron(pattern, block);

            // Final Dn
            sp_mat Top(m+3,    (m+1)*n );
            sp_mat Middle(2,   (m+1)*n );
            sp_mat Bottom(m+3, (m+1)*n );

            // Cannot shift a sparse matrix??
            //mat bdry_dense(bdry);
            sp_mat bdry_shift;
            //bdry_shift = arma::shift(bdry_dense, (m+1)*(n-2), 1);
            bdry_shift = Utils::circshift(bdry, (m+1)*(n-2), 1);

            // Will not join sparse matrices mroe than 2 at a time;
            sp_mat I;

            I = arma::join_vert(Top, bdry);
            I = arma::join_vert(I,Middle);
            I = arma::join_vert(I,middle);
            I = arma::join_vert(I,bdry_shift);
            I = arma::join_vert(I,Bottom);
            
            // Additional Kronecker for 3D
            sp_mat temp_sparse = arma::speye<sp_mat>(o,o);
            I = Utils::spkron(temp_sparse, I);

            // Make holder matrices for last commadbn in 'Dn'
            sp_mat TopEnd((m+2)*(n+2), I.n_cols );
            sp_mat BottomEnd( (m+2)*(n+2), I.n_cols );

            I = arma::join_vert(TopEnd, I);
            I = arma::join_vert(I, BottomEnd);

            // Transfer Solution to holder matrix
            DI_inter = std::move(I);
            break;
        }

        case(2):{
            // De
            //cout << "DI3 -- Case 2" << endl;
            
            // Main Block
            sp_mat block(m+2,m);
            vec e;
            e = e.ones(m)*(-0.25);
            e(m-1) = 0;
            block.diag(-1) = e;
            block.diag(1).fill(0.25);

            block(0,0) = -0.5;
            block(0,1) = 0.5;
            block(m-1,m-2) = -0.5;
            block(m-1,m-1) = 0.5;

            // Pattern Block
            sp_mat pattern(n,n+1);
            pattern.diag(0).fill(1);
            pattern.diag(1).fill(1);

            // Middle Block
            sp_mat middle;
            middle = Utils::spkron(pattern, block);
            
            // Final De
            sp_mat Top(m+3,    (n+1)*m );
            sp_mat Bottom(m+1, (n+1)*m );

            // Will not join sparse matrices mroe than 2 at a time;
            sp_mat I;

            I = arma::join_vert(Top, middle);
            I = arma::join_vert(I,Bottom);
            
            // I = kron(speye(o), I); /* from MATLAB */
            // Additional Kronecker for 3D
            sp_mat temp_sparse = arma::speye<sp_mat>(o,o);
            I = Utils::spkron(temp_sparse, I);

            // I = [spalloc((m+2)*(n+2), size(I, 2), 0); I; spalloc((m+2)*(n+2), size(I, 2), 0)];
            // Make holder matrices for last commadbn in 'Dn'
            sp_mat TopEnd((m+2)*(n+2), I.n_cols );
            sp_mat BottomEnd( (m+2)*(n+2), I.n_cols );
            I = arma::join_vert(TopEnd, I);
            I = arma::join_vert(I, BottomEnd);

            // Transfer Solution to holder matrix
            DI_inter = std::move(I);
            break;
        }
        case(3): {
            // Dc
            //cout << "DI3 -- Case 3" << endl;
            // Boundary Block
            // e = ones(m, 1);
            // bdry = spdiags([0.5*e 0.5*e], [0 1], m, m+1);
            sp_mat bdry(m, m+1);
            bdry.diag(0).fill(0.5); // = 0.5*e;
            bdry.diag(1).fill(0.5); // = 0.5*e;

            // bdry = [bdry; spalloc(2, m+1, 0)];
            sp_mat two(2, m+1);
            bdry = arma::join_vert(bdry, two);

            // bdry = kron(speye(n), bdry);
            sp_mat temp_sparse = arma::speye<sp_mat>(n,n);
            bdry = Utils::spkron(temp_sparse, bdry);

            // middle = kron(0.25*speye(o-2), [bdry; spalloc(2*(m+2), size(bdry, 2), 0)]);
            sp_mat first = arma::speye<sp_mat>(o-2,o-2);
            first = 0.25 * first;

            sp_mat last(2*(m+2), bdry.n_cols);
            sp_mat middle;
            middle = arma::join_vert(bdry, last);
            middle = Utils::spkron(first, middle);


            // middle = [spalloc(2*(m+2), size(middle, 2), 0); middle];
            sp_mat temp_sparse2(2*(m+2), middle.n_cols );

            middle = arma::join_cols(temp_sparse2, middle);

            // middle = [middle spalloc(size(middle, 1), (m+1)*n*o-size(middle, 2), 0)];
            sp_mat temp_sparse3(middle.n_rows, (m+1)*n*o - middle.n_cols);

            middle = arma::join_rows(middle, temp_sparse3);

            // middle = -middle + Utils::circshift(middle, 2*(m+1)*n, 2);
            //mat middle_dense(middle);
            sp_mat bdry_shift;
            //bdry_shift = arma::shift(middle_dense, 2*(m+1)*n, 1);
            bdry_shift = Utils::circshift(middle, 2*(m+1)*n, 1);
            middle = -middle + bdry_shift;

            // bdry = [-bdry bdry spalloc(size(bdry, 1), (m+1)*n*o-2*size(bdry, 2), 0)];
            sp_mat temp3(bdry.n_rows, (m+1)*n*o - 2*bdry.n_cols);
            bdry = arma::join_rows(-bdry, bdry);
            bdry = arma::join_rows(bdry, temp3);

            // I = [spalloc((m+2)*(n+2)+m+3, size(bdry, 2), 0); bdry];
            sp_mat I((m+2)*(n+2)+m+3, bdry.n_cols);
            I = arma::join_vert(I, bdry);

            // I = [I; middle; Utils::circshift(bdry, (m+1)*n*(o-2), 2); spalloc((m+2)*(n+2)+m+1, size(bdry, 2), 0)];
            I = arma::join_vert(I, middle);
            //mat bdry_dense(bdry);
            //sp_mat bdry_shift;
            //bdry_shift = arma::shift( bdry_dense, (m+1)*n*(o-2),1 );
            bdry_shift = Utils::circshift( bdry, (m+1)*n*(o-2),1 );
            I = arma::join_vert(I,bdry_shift);
            sp_mat temp4((m+2)*(n+2)+m+1, bdry.n_cols);
            I = arma::join_vert(I, temp4);

            // Transfer Solution to holder matrix
            DI_inter = std::move(I);
            break;
        }

        case(4):{
            // case Dcc
            //cout << "DI3 -- Case 4" << endl;
            
            // e = ones(m, 1);
            // bdry = spdiags(0.5*e, 0, m, m);
            // bdry = [bdry; spalloc(2, m, 0)];
            sp_mat bdry(m, m);
            bdry.diag(0).fill(0.5); //  = 0.5*e;
            sp_mat temp0(2,m);
            bdry = arma::join_cols(bdry, temp0);

            // I = spdiags([ones(n, 1) ones(n, 1)], [0 1], n, n+1);
            sp_mat I(n,n+1);
            I.diag(0).fill(1.0);
            I.diag(1).fill(1.0);

            // middle = kron(0.25*I, bdry);
            I = 0.25 * I;
            sp_mat middle;
            middle = Utils::spkron(I, bdry);

            //middle = [middle; spalloc(2*(m+2), size(middle, 2), 0)];
            sp_mat temp1(2*(m+2), middle.n_cols);
            middle = arma::join_cols(middle, temp1);

            // middle = kron(spdiags([-ones(o-2, 1) ones(o-2, 1)], [0 2], o-2, o), middle);
            sp_mat temp2(o-2,o);
            temp2.diag(2).fill(1.0);
            temp2.diag(0).fill(-1.0);
            middle = Utils::spkron(temp2, middle);

            // bdry = kron(I, bdry);
            I = 4 * I; // make back into ones.
            bdry = Utils::spkron(I, bdry);

            // bdry = [-bdry bdry spalloc(size(bdry, 1), m*(n+1)*o-2*size(bdry, 2), 0)];
            sp_mat temp3( bdry.n_rows, (m*(n+1)*o)-(2*bdry.n_cols) );
            bdry = arma::join_rows(-bdry, bdry);
            bdry = arma::join_rows(bdry, temp3);

            /* I = [spalloc((m+2)*(n+2)+m+3, size(bdry, 2), 0);   // temp4
                                                          bdry;
                            spalloc(2*(m+2), size(bdry, 2), 0);   // temp5
                                                        middle; 
                             Utils::circshift(bdry, m*(n+1)*(o-2), 2);   // bdry_shift
                     spalloc((m+2)*(n+2)+m+1, size(bdry, 2), 0)]; // temp6    */

            sp_mat temp4( (m+2)*(n+2)+m+3, bdry.n_cols );            
            sp_mat temp5( 2*(m+2), bdry.n_cols );
            sp_mat temp6( (m+2)*(n+2)+m+1, bdry.n_cols );
            //mat bdry_dense(bdry);
            sp_mat bdry_shift;
            //bdry_shift = arma::shift( bdry_dense, m*(n+1)*(o-2),1 );
            bdry_shift = Utils::circshift(bdry,m*(n+1)*(o-2), 1 );

            I = arma::join_cols(temp4, bdry);
            I = arma::join_cols(I, temp5);
            I = arma::join_cols(I,middle);
            I = arma::join_cols(I,bdry_shift);
            I = arma::join_cols(I,temp6);

            // Transfer Solution to holder matrix
            DI_inter = std::move(I);
            break;
        }

        case(5):{
            // case Dee
            //e = ones(m-2, 1);
            //cout << "DI3 -- Case 5" << endl;
            
            //block = spdiags([[-0.25*e; -0.25; 0] [0; 0.25*e; 0.25]], [-1 1], m+2, m);
            //block(1, 1) = -0.5;
            //block(1, 2) = 0.5;
            //block(m, m-1) = -0.5;
            //block(m, m) = 0.5;
            
            sp_mat block(m+2,m);
            vec e;
            e = e.ones(m)*(-0.25);
            e(m-1) = 0;
            block.diag(-1) = e;
            block.diag(1).fill(0.25);

            block(0,0) = -0.5;
            block(0,1) = 0.5;
            block(m-1,m-2) = -0.5;
            block(m-1,m-1) = 0.5;

            // middle = kron(speye(n), block);
            sp_mat temp1 = arma::speye<sp_mat>(n,n);
            sp_mat middle;
            middle = Utils::spkron(temp1, block);

            // middle = [middle; spalloc(2*(m+2), size(middle, 2), 0)];
            sp_mat temp2(2*(m+2), middle.n_cols);
            middle = arma::join_cols(middle, temp2);

            // I = kron(spdiags([ones(o, 1) ones(o, 1)], [0 1], o, o+1), middle);
            sp_mat temp3(o,o+1);
            temp3.diag(0).fill(1.0); // = 1.0;
            temp3.diag(1).fill(1.0); // = 1.0;

            sp_mat I;
            I = Utils::spkron(temp3, middle);

            //I = [spalloc((m+2)*(n+2)+m+3, size(I, 2), 0); I; spalloc((m+2)*n+m+1, size(I, 2), 0)];
            sp_mat temp4( (m+2)*(n+2)+m+3, I.n_cols );
            sp_mat temp5( (m+2)*n+m+1, I.n_cols );
            I = arma::join_cols(temp4, I);
            I = arma::join_cols(I, temp5);

            // Transfer Solution to holder matrix
            DI_inter = std::move(I);
            break;
        }

        case(6):{
            // case Dnn
            // e = ones(m, 1);
            // bdry = spdiags([-0.5*e 0.5*e -0.5*e 0.5*e], [0 m m*n m*n+m], m, 2*m*n);
            //cout << "DI3 -- Case 6" << endl;

            sp_mat bdry(m, 2*m*n );
            bdry.diag(0).fill(-0.5);
            bdry.diag(m).fill(0.5);     // = 0.5; 
            bdry.diag(m*n).fill(-0.5);  // = -0.5;
            bdry.diag(m*n+m).fill(0.5); // = 0.5;

            // middle = 0.25*speye(m);
            sp_mat middle;
            middle = 0.25 * arma::speye<sp_mat>(m,m);

            // middle = [middle; spalloc(2, m, 0)];
            sp_mat temp1(2,m);
            middle = arma::join_cols(middle, temp1);

            // middle = kron(spdiags([-ones(n-2, 1) ones(n-2, 1)], [0 2], n-2, n), middle);
            sp_mat temp2(n-2,n);
            temp2.diag(0).fill(-1.0);  // = -1.0;
            temp2.diag(2).fill(1.0);   //  =  1.0;
            middle = Utils::spkron(temp2, middle);


            // middle = [middle middle];
            middle = arma::join_rows(middle, middle);

            // I = [bdry; spalloc(2, size(bdry, 2), 0); middle; Utils::circshift(bdry, m*(n-2), 2)];
            sp_mat I;
            sp_mat temp3(2,bdry.n_cols);
            I = arma::join_cols(bdry, temp3);
            I = arma::join_cols(I, middle);

            // Cannot shift a sparse matrix??
            //mat bdry_dense(bdry);
            sp_mat bdry_shift;
            //bdry_shift = arma::shift(bdry_dense, (m)*(n-2), 1);
            bdry_shift = Utils::circshift(bdry,(m)*(n-2), 1 );
            I = arma::join_cols(I, bdry_shift);

            I = I.cols(0,m*n - 1);

            // I = [I; spalloc(2*(m+2)+2, size(I, 2), 0)];
            sp_mat temp4(2*(m+2)+2, I.n_cols);
            I = arma::join_cols(I, temp4);

            // I = kron(spdiags([ones(o, 1) ones(o, 1)], [0 1], o, o+1), I);
            sp_mat temp5(o,o+1);
            temp5.diag(0).fill(1.0); // = 1.0;
            temp5.diag(1).fill(1.0); // = 1.0;
            I = Utils::spkron(temp5, I);

            // I = [spalloc((m+2)*(n+2)+m+3, size(I, 2), 0); I; spalloc((m+2)*n+m+1, size(I, 2), 0)];
            sp_mat temp6( ((m+2)*(n+2)+m+3), I.n_cols);
            sp_mat temp7( (m+2)*n + m+1, I.n_cols);
            I = arma::join_cols(temp6, I);
            I = arma::join_cols(I, temp7);

            // Transfer Solution to holder matrix
            DI_inter = std::move(I);
            break;
        }
    }
}


      // // axes indicates direction of shift
      // // 0  == up(shift+) or down(shift-)
      // // 1  == left(shift-) or right(shift+)
      // int c = Q.n_cols;

      // sp_mat P(c,c);
      // sp_mat T(c,c);
      // vec d(c-1, fill::ones);
      // cout << "Doing circshift in DI3 " << abs(shift) << " times!!" << endl;
      // cout << "P and T size has " << c*c << "elements" << endl;

      // if ( shift < 0 ){
      //       P.diag(-1) = d;
      //       T(0,c-1) = 1;            
      // }
      // else{
      //       P.diag(1) = d;
      //       T(c-1,0) = 1;         
      // }

      // sp_mat LS(Q);

      // if ( axes == 1)  for(int i=0; i<abs(shift); ++i) LS = (LS*T) + (LS*P);
      // else             for(int i=0; i<abs(shift); ++i) LS = (T*LS) + (P*LS);

      // return LS;  

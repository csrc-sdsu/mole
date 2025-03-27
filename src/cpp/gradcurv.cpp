#include "gradcurv.h"
#include <chrono>

void GradCurv::G3DCurv(const u16 k, const cube &X, const cube &Y, const cube &Z)
{
    DBGMSG("Starting G3DCurv.");

    Jacob J;
    // [J, Xe, Xn, Xc, Ye, Yn, Yc, Ze, Zn, Zc] //
    J.Jacobian(k,X,Y,Z);

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

    // Pretty sure the m,n,o are taken care of in the function
    //cout << "ALERT:: NodeToU and NodeToV are backwards!!!!" << endl << endl;
    // FIXED :: BRZENSKI 12/12/23
    sp_mat NtoU = In.Inter_NodeToU(k,m-1,n-1,o-1);
    sp_mat NtoV = In.Inter_NodeToV(k,m-1,n-1,o-1);
    sp_mat NtoW = In.Inter_NodeToW(k,m-1,n-1,o-1);

    vec A = J.Yn%J.Zc-J.Zn%J.Yc;
    vec B = J.Zn%J.Xc-J.Xn%J.Zc;
    vec C = J.Xn%J.Yc-J.Yn%J.Xc;
    vec D = J.Ze%J.Yc-J.Ye%J.Zc;
    vec E = J.Xe%J.Zc-J.Ze%J.Xc;
    vec F = J.Ye%J.Xc-J.Xe%J.Yc;
    vec G = J.Ye%J.Zn-J.Ze%J.Yn;
    vec H = J.Ze%J.Xn-J.Xe%J.Zn;
    vec I = J.Xe%J.Yn-J.Ye%J.Xn;
    
    vec Ju = NtoU * J.Jacob_vec; 
    A  = NtoU * A; 
    D  = NtoU * D;
    G  = NtoU * G;

    vec Jv = NtoV * J.Jacob_vec;
    B  = NtoV * B;
    E  = NtoV * E;
    H  = NtoV * H;

    vec Jw = NtoW * J.Jacob_vec;
    C  = NtoW * C;
    F  = NtoW * F;
    I  = NtoW * I;

    DBGMSG("Building diagonal matrix elements As,Bs...");
    // Transform them into sparse diagonalized matrices
    sp_mat As(A.n_elem, A.n_elem);    As.diag(0)  = A;
    sp_mat Bs(B.n_elem, B.n_elem);    Bs.diag(0)  = B;
    sp_mat Cs(C.n_elem, C.n_elem);    Cs.diag(0)  = C;
    sp_mat Ds(D.n_elem, D.n_elem);    Ds.diag(0)  = D;
    sp_mat Es(E.n_elem, E.n_elem);    Es.diag(0)  = E;
    sp_mat Fs(F.n_elem, F.n_elem);    Fs.diag(0)  = F;
    sp_mat Gs(G.n_elem, G.n_elem);    Gs.diag(0)  = G;
    sp_mat Hs(H.n_elem, H.n_elem);    Hs.diag(0)  = H;
    sp_mat Is(I.n_elem, I.n_elem);    Is.diag(0)  = I;
    sp_mat Jus(Ju.n_elem, Ju.n_elem); Jus.diag(0) = 1.0/Ju; // BRZENSKI Was this always here????
    sp_mat Jvs(Jv.n_elem, Jv.n_elem); Jvs.diag(0) = 1.0/Jv;
    sp_mat Jws(Jw.n_elem, Jw.n_elem); Jws.diag(0) = 1.0/Jw;

    Gradient Grad(k, m-1, n-1, o-1, 1, 1, 1);     // Gradient

    sp_mat Ge = Grad.rows(0,size_u-1);
    sp_mat Gn = Grad.rows(size_u,size_u+size_v-1);
    sp_mat Gc = Grad.rows(size_u+size_v, size_u+size_v+size_w-1);

    // Apply Transformation
    /* Case 't' can repressent any of the following:
    1 - Gn
    2 - Ge
    3 - Gc
    4 - Gcc
    5 - Gee
    6 - Gnn  */
    // These are stored in GI_inter

    GI(m-1, n-1, o-1, 1);   //Gn
    sp_mat IGn = GI_inter*Gn;
    GI(m-1,n-1,o-1,3);      //Gc
    sp_mat IGc = GI_inter*Gc;
    // auto g1start = std::chrono::high_resolution_clock::now();
    sp_mat Gx = Jus*( (As*Ge) + (Ds*IGn) + (Gs*IGc) );
    // auto g1end = std::chrono::high_resolution_clock::now();
    // const std::chrono::duration<double, std::milli> g1duration = g1end - g1start;
    // std::cout << "The Gx maker mult nterpolator took " << g1duration.count()/1e3 << " seconds to execute." << std::endl;

    GI(m-1, n-1, o-1, 2); //Ge
    sp_mat IGe = GI_inter * Ge;
    GI(m-1, n-1, o-1, 4); //Gcc
    IGc = GI_inter * Gc;
    // auto g2start = std::chrono::high_resolution_clock::now();
    sp_mat Gy = Jvs*( (Bs*IGe) + (Es*Gn) + (Hs*IGc) );
    // auto g2end = std::chrono::high_resolution_clock::now();
    // const std::chrono::duration<double, std::milli> g2duration = g2end - g2start;
    // std::cout << "The Gy maker mult nterpolator took " << g2duration.count()/1e3 << " seconds to execute." << std::endl;

 
    GI(m-1, n-1, o-1, 5); //Gee
    IGe = GI_inter * Ge;
    GI(m-1, n-1, o-1, 6); //Gnn
    IGn = GI_inter * Gn;
    // auto g3start = std::chrono::high_resolution_clock::now();
    sp_mat Gz = ( (Cs*IGe) + (Fs*IGn) + (Is*Gc) );
    Gz = Jws * Gz;
    //sp_mat Gz = Jws*( (Cs*IGe) + (Fs*IGn) + (Is*Gc) );
    // auto g3end = std::chrono::high_resolution_clock::now();
    // const std::chrono::duration<double, std::milli> g3duration = g3end - g3start;
    // std::cout << "The Gz maker mult nterpolator took " << g3duration.count()/1e3 << " seconds to execute." << std::endl;

    // auto gjstart = std::chrono::high_resolution_clock::now();

    grad3DCurv = join_vert(Gx, Gy, Gz);
    //grad3DCurv = join_vert(grad3DCurv, Gz);
    // auto gjend = std::chrono::high_resolution_clock::now();
    // const std::chrono::duration<double, std::milli> gjduration = gjend - gjstart;
    // std::cout << "The Final G join vert maker mult nterpolator took " << gjduration.count()/1e3 << " seconds to execute." << std::endl;

    // Clean out smaller values!!
    
    grad3DCurv.clean(datum::eps);

    // % Apply transformation
    // Gx = Ju*(A*Ge+D*GI13(Gn, m-1, n-1, o-1, 'Gn')+G*GI13(Gc, m-1, n-1, o-1, 'Gc'));
    // Gy = Jv*(B*GI13(Ge, m-1, n-1, o-1, 'Ge')+E*Gn+H*GI13(Gc, m-1, n-1, o-1, 'Gcy'));
    // Gz = Jw*(C*GI13(Ge, m-1, n-1, o-1, 'Gee')+F*GI13(Gn, m-1, n-1, o-1, 'Gnn')+I*Gc);
    
    // % Final 3D curvilinear mimetic gradient operator (d/dx, d/dy, d/dz)
    // G = [Gx; Gy; Gz];
}



void GradCurv::GI( const u16 m, const u16 n, const u16 t)
{
    /* Case 't' can repressent any of the following:
    1 - Gn
    2 - Ge
    3 - Gc
    4 - Gnn
    5 - Gee
    6 - Gcc  */
    assert(t > 0 && t < 3);

    DBGVMSG("In GI for case ", t);

    int i = 0;
    int j = 0;
    int k = 0;
    //cout << "G init" << endl;
    switch(t) {
        case(1): // Gn
        {
            vec I(4*n*(m-1)+(12*n), fill::zeros);
            vec J(4*n*(m-1)+(12*n), fill::zeros);
            vec V(4*n*(m-1)+(12*n), fill::zeros);
            k = 0; // This is the starting index for C++
            int kt = 4*(m-1)-1;

            vec temp1;
            vec temp2;
            vec temp3;
            vec temp4;

            for (int idx = 0; idx < n; ++idx)
            {
                i = idx * (m+1);
                j = idx * m;

                temp1 = regspace(i+2, i+m);
                temp2 = join_cols(temp1, temp1);
                I.rows(k,k+kt) = join_cols(temp2, temp2);
                /* May need k,kt-1??? */

                temp1 = regspace(j+1, j+m-1);
                temp2 = regspace(j+2, j+m);
                temp3 = regspace(j+m+1, j+(2*m)-1);
                temp4 = regspace(j+m+2, j+(2*m));

                temp1 = join_cols(temp1, temp2);
                temp1 = join_cols(temp1, temp3);
                temp1 = join_cols(temp1, temp4);
                J.rows(k, k+kt) = temp1;

                temp1.resize(kt + 1);

                temp1.ones();
                V.rows(k, k+kt) = 0.25 * temp1;

                k = k+kt+1;
            }

            for (int idx = 0; idx < n; ++idx)
            {
                /* These are cast as doubles, to prevent warning of int -> double */
                double ii = idx * (m+1); 
                double jj = idx * m;   

                temp1 = {ii+1, ii+1, ii+1, ii+1, ii+1, ii+1};
                I.rows(k,k+5) = temp1;

                temp1 = {jj+1, jj+2, jj+3, jj+m+1, jj+m+2, jj+m+3};
                J.rows(k,k+5) = temp1;

                temp1 = {-0.25, 0.25, 0.5, -0.25, 0.25, 0.5};
                V.rows(k,k+5) = temp1;

                k=k+6;

                temp1 = {ii+m+1, ii+m+1, ii+m+1, ii+m+1, ii+m+1, ii+m+1};
                I.rows(k,k+5) = temp1;

                temp1 = {jj+m-2, jj+m-1, jj+m, jj+(2*m)-2, jj+(2*m)-1, jj+(2*m)};
                J.rows(k,k+5) = temp1;

                temp1 = {-0.25, 0.25, 0.5, -0.25, 0.25, 0.5};
                V.rows(k,k+5) = temp1;

                k=k+6;
            }

            // Building the sparse matrix, equivalent to
            // matlab sparse(I,J,V), where values V are put
            // at locations I,J. 
            // I and J need to be integer locations, but previous
            // operations needed doubles. Here convert them to uvecs, 
            // and concatanate to make the locations matrix.
            umat locations;
            uvec locx = conv_to<uvec>::from(I);
            uvec locy = conv_to<uvec>::from(J);
            locations = join_cols(locx.t(), locy.t());

            sp_mat II(locations, V);
            GI_inter = std::move(II);
            break;
            //GI_inter = II;
            //M = II*M;
        } // End Case 1

        case(2): // Ge
        {

            //cout << "G case 2" << endl;
            vec I(4*m*(n-1)+(12*m), fill::zeros);
            vec J(4*m*(n-1)+(12*m), fill::zeros);
            vec V(4*m*(n-1)+(12*m), fill::zeros);

            vec E(m,fill::ones);

            vec temp1;
            vec temp2;
            vec temp3;
            vec temp4;
            vec temp5;
            vec temp6;

            k = 0;          // This is the starting index for C++

            int kt = 4*m-1; // c++ one less
            
            int jb = 0;     // j begin at 0
            int jt = 0;     // should be one less
            int jm = 0;
            
            int ib = 0;     // i begin at 0
            int it = m - 1; // index is one lwoer in c++

            for (int idx = 0; idx < n-1; ++idx)
            {
                
                ib = it+1;
                it = ib+m-1;
                jb = jt;
                jt = jb+m+1;

                temp1 = regspace(ib, it);                // 1 col
                temp2 = join_cols(temp1, temp1);         // 2 cols
                temp3 = join_cols(temp2, temp2);         // 4 cols
                I.rows(k,kt) = temp3;

                temp1 = regspace(   jb, jt-2);
                temp2 = regspace( jb+1, jt-1);
                temp3 = regspace(   jt, jt+m-1);
                temp4 = regspace( jt+1, jt+m);

                temp1 = join_cols(temp1, temp2);
                temp1 = join_cols(temp1, temp3);
                temp1 = join_cols(temp1, temp4);

                J.rows(k, kt) = temp1;

                temp1.resize(kt-k+1);

                temp1.ones();

                V.rows(k, kt) = 0.25 * temp1;

                k = kt+1;
                kt = kt+(4*m);
            }

            // Part 2
            ib = 1-1;
            it = m-1;
            kt = k+6*m-1;
            jb = 1-1;     // -1 for c++
            jm = m+2-1;   // - 1 for c++
            jt = 2*m+3-1; // -1 for c++

            temp1 = regspace(ib, it);               // 1 col
            temp2 = join_cols(temp1, temp1);        // 2 cols
            temp3 = join_cols(temp2, temp2);        // 4 cols
            temp4 = join_cols(temp3, temp2);        // 6 cols
            I.rows(k,kt) = temp4;

            temp1 = regspace(   jb, jm-2);
            temp2 = regspace( jb+1, jm-1);
            temp3 = regspace(   jm, jt-2);
            temp4 = regspace( jm+1, jt-1);
            temp5 = regspace(   jt, jt+m-1);
            temp6 = regspace(  jt+1, jt+m);

            temp1 = join_cols(temp1, temp2);
            temp1 = join_cols(temp1, temp3);
            temp1 = join_cols(temp1, temp4);
            temp1 = join_cols(temp1, temp5);
            temp1 = join_cols(temp1, temp6);
            J.rows(k, kt) = temp1;

            temp1 = 0.5*E;
            temp2 = 0.25*E;
            temp3 = -0.25*E;
            temp4 = join_cols(temp1,temp1);
            temp4 = join_cols(temp4,temp2);
            temp4 = join_cols(temp4,temp2);
            temp4 = join_cols(temp4,temp3);
            temp4 = join_cols(temp4,temp3);
            V.rows(k, kt) = temp4;

            // Part 3

            ib = n*m+1-1;
            it = ib+m-1;
            jb = (n-3)*(m+1)+1-1;
            jm = jb+m+1;
            jt = jm+m+1;
            k  = kt+1;
            kt = k+(6*m)-1;

            temp1 = regspace(ib, it);               // 1 col
            temp2 = join_cols(temp1, temp1);        // 2 cols
            temp3 = join_cols(temp2, temp2);        // 4 cols
            I.rows(k,kt) = join_cols(temp3, temp2); // 6 cols

            temp1 = regspace(   jb, jm-2);
            temp2 = regspace( jb+1, jm-1);
            temp3 = regspace(   jm, jt-2);
            temp4 = regspace( jm+1, jt-1);
            temp5 = regspace(   jt, jt+m-1);
            temp6 = regspace(  jt+1, jt+m);

            temp1 = join_cols(temp1, temp2);
            temp1 = join_cols(temp1, temp3);
            temp1 = join_cols(temp1, temp4);
            temp1 = join_cols(temp1, temp5);
            temp1 = join_cols(temp1, temp6);
            J.rows(k, kt) = temp1;

            temp1 = 0.5*E;
            temp2 = 0.25*E;
            temp3 = -0.25*E;
            temp4 = join_cols(temp3,temp3);
            temp4 = join_cols(temp4,temp2);
            temp4 = join_cols(temp4,temp2);
            temp4 = join_cols(temp4,temp1);
            temp4 = join_cols(temp4,temp1);
            V.rows(k, kt) = temp4;


            // Building the sparse matrix, equivalent to
            // matlab sparse(I,J,V), where values V are put
            // at locations I,J. 
            // I and J need to be integer locations, but previous
            // operations needed doubles. Here convert them to uvecs, 
            // and concatanate to make the locations matrix.
            umat locations;
            uvec locx = conv_to<uvec>::from(I);
            uvec locy = conv_to<uvec>::from(J);
            locations = join_cols(locx.t(), locy.t());

            sp_mat II(locations, V);
            GI_inter = std::move(II);
            break;
            //II.print();
            //Curve.GI_inter = II;
            //cout << "G Sparse Built" << endl;
            //Curve.GI_inter.print();

            //M = II*M;
            //sp_mat GI_inter(locations,V);
        }

    }

}

void GradCurv::GI( const u16 m, const u16 n,  const u16 o, const u16 t)
{
    /* Case 't' can repressent any of the following:
    1 - Gn
    2 - Ge
    3 - Gc
    4 - Gnn
    5 - Gee
    6 - Gcc  */
    assert(t > 0 && t < 7);

    DBGVMSG("In GI for case ", t);
    int i = 0;
    int j = 0;
    int k = 0;
    //cout << "G3 init" << endl;
    switch(t) {
        case(1): // Gn
        {
            sp_mat I  = arma::speye<sp_mat>(n*o,n*o);
            sp_mat I1 = arma::speye<sp_mat>(m+1,m);
            I1(m,m-1) = 1;
            I = Utils::spkron(I, I1);
            sp_mat temp1(I.n_rows, m*o);
            I = arma::join_rows(I, temp1);
            GI_inter = std::move(I);
            break;
        }

        case(2): // Ge
        {
            sp_mat I  = arma::speye<sp_mat>(n+1,n);
            sp_mat I1 = arma::speye<sp_mat>(m,m+1);
            I(n,n-1) = 1;
            I = Utils::spkron(I, I1);
            sp_mat temp1 = arma::speye<sp_mat>(o, o);
            I = Utils::spkron(temp1, I);
            GI_inter = std::move(I);
            break;
        }

        case(3): // Gc
        {
            sp_mat I  = arma::speye<sp_mat>(n*o,n*o);
            sp_mat I1 = arma::speye<sp_mat>(m+1,m);
            I1(m,m-1) = 1;
            I = Utils::spkron(I, I1);
            sp_mat temp1(I.n_rows, m*n);
            I = arma::join_rows(I,temp1);
            GI_inter = std::move(I);
            break;
        }
        
        case(4): // Gcy
        {
            sp_mat I  = arma::speye<sp_mat>(m*o,m*o);
            sp_mat I1 = arma::speye<sp_mat>(n+1,n);
            I1(n,n-1) = 1;
            I = Utils::spkron(I, I1);
            sp_mat temp1(I.n_rows, m*n);
            I = arma::join_rows(I, temp1);
            GI_inter = std::move(I);
            break;
        }
                
        case(5): // Gee
        {
            sp_mat I  = arma::speye<sp_mat>(o+1,o);
            sp_mat I1 = arma::speye<sp_mat>(m,m+1);
            I(o,o-1) = 1;
            I = Utils::spkron(I, I1);
            sp_mat temp1 = arma::speye<sp_mat>(n,n);
            I = Utils::spkron(temp1, I);
            GI_inter = std::move(I);
            break;
        }

        case(6): // Gnn
        {
            sp_mat I  = arma::speye<sp_mat>(m*n,m*n);
            sp_mat I1 = arma::speye<sp_mat>(o+1,o);
            I1(o,o-1) = 1;
            I = Utils::spkron(I, I1);
            sp_mat temp1(I.n_rows, m*o);
            I = arma::join_rows(I, temp1);
            GI_inter = std::move(I);
            break;
        }

    }
}

/**
 * 
 */

#include "mole.h"

int main(void)
{

    u16 k;
    u32 m, n, o;

    ivec pdc1 = {0, 0};
    ivec nc1 = {0, 0};
    ivec ndc1 = {1, 1};

    ivec pdc2 = {0, 0, 0, 0};
    ivec nc2 = {0, 0, 0, 0};
    ivec ndc2 = {1, 1, 1, 1};

    ivec pdc3 = {0, 0, 0, 0, 0, 0};
    ivec nc3 = {0, 0, 0, 0, 0, 0};
    ivec ndc3 = {1, 1, 1, 1, 1, 1};

    for (k = 2; k < 3; k += 2)
    {
        m = 2 * k + 1;
        n = m + 1;
        o = n + 1;

        /****************
        1-D Interpolators
        ****************/

        // Periodic
        InterpolCtoF picf1(k, m, pdc1, nc1);
        InterpolCtoN picn1(k, m, pdc1, nc1);
        InterpolFtoC pifc1(k, m, pdc1, nc1);
        InterpolNtoC pinc1(k, m, pdc1, nc1);

        picf1.save("picf1D.csv", arma::csv_ascii);
        picn1.save("picn1D.csv", arma::csv_ascii);
        pifc1.save("pifc1D.csv", arma::csv_ascii);
        pinc1.save("pinc1D.csv", arma::csv_ascii);

        // Nonperiodic
        InterpolCtoF nicf1(k, m, ndc1, nc1);
        InterpolCtoN nicn1(k, m, ndc1, nc1);
        InterpolFtoC nifc1(k, m, ndc1, nc1);
        InterpolNtoC ninc1(k, m, ndc1, nc1);

        nicf1.save("nicf1D.csv", arma::csv_ascii);
        nicn1.save("nicn1D.csv", arma::csv_ascii);
        nifc1.save("nifc1D.csv", arma::csv_ascii);
        ninc1.save("ninc1D.csv", arma::csv_ascii);

        /****************
        2-D Interpolators
        ****************/

        // Periodic
        InterpolCtoF picf2(k, m, n, pdc2, nc2);
        InterpolCtoN picn2(k, m, n, pdc2, nc2);
        InterpolFtoC pifc2(k, m, n, pdc2, nc2);
        InterpolNtoC pinc2(k, m, n, pdc2, nc2);

        picf2.save("picf2D.csv", arma::csv_ascii);
        picn2.save("picn2D.csv", arma::csv_ascii);
        pifc2.save("pifc2D.csv", arma::csv_ascii);
        pinc2.save("pinc2D.csv", arma::csv_ascii);

        // Nonperiodic
        InterpolCtoF nicf2(k, m, n, ndc2, nc2);
        InterpolCtoN nicn2(k, m, n, ndc2, nc2);
        InterpolFtoC nifc2(k, m, n, ndc2, nc2);
        InterpolNtoC ninc2(k, m, n, ndc2, nc2);

        nicf2.save("nicf2D.csv", arma::csv_ascii);
        nicn2.save("nicn2D.csv", arma::csv_ascii);
        nifc2.save("nifc2D.csv", arma::csv_ascii);
        ninc2.save("ninc2D.csv", arma::csv_ascii);

        /****************
        3-D Interpolators
        ****************/

        // Periodic
        InterpolCtoF picf3(k, m, n, o, pdc3, nc3);
        InterpolCtoN picn3(k, m, n, o, pdc3, nc3);
        InterpolFtoC pifc3(k, m, n, o, pdc3, nc3);
        InterpolNtoC pinc3(k, m, n, o, pdc3, nc3);

        picf3.save("picf3D.csv", arma::csv_ascii);
        picn3.save("picn3D.csv", arma::csv_ascii);
        pifc3.save("pifc3D.csv", arma::csv_ascii);
        pinc3.save("pinc3D.csv", arma::csv_ascii);

        // Nonperiodic
        InterpolCtoF nicf3(k, m, n, o, ndc3, nc3);
        InterpolCtoN nicn3(k, m, n, o, ndc3, nc3);
        InterpolFtoC nifc3(k, m, n, o, ndc3, nc3);
        InterpolNtoC ninc3(k, m, n, o, ndc3, nc3);

        nicf3.save("nicf3D.csv", arma::csv_ascii);
        nicn3.save("nicn3D.csv", arma::csv_ascii);
        nifc3.save("nifc3D.csv", arma::csv_ascii);
        ninc3.save("ninc3D.csv", arma::csv_ascii);
    }

    return 0;
}
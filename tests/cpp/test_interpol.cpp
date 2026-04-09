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

    char buff[64];

    for (k = 2; k < 9; k += 2)
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

        sprintf(buff, "picf1Dk%d.csv", k);
        picf1.save(buff, arma::csv_ascii);
        sprintf(buff, "picn1Dk%d.csv", k);
        picn1.save(buff, arma::csv_ascii);
        sprintf(buff, "pifc1Dk%d.csv", k);
        pifc1.save(buff, arma::csv_ascii);
        sprintf(buff, "pinc1Dk%d.csv", k);
        pinc1.save(buff, arma::csv_ascii);

        // Nonperiodic
        InterpolCtoF nicf1(k, m, ndc1, nc1);
        InterpolCtoN nicn1(k, m, ndc1, nc1);
        InterpolFtoC nifc1(k, m, ndc1, nc1);
        InterpolNtoC ninc1(k, m, ndc1, nc1);

        sprintf(buff, "nicf1Dk%d.csv", k);
        nicf1.save(buff, arma::csv_ascii);
        sprintf(buff, "nicn1Dk%d.csv", k);
        nicn1.save(buff, arma::csv_ascii);
        sprintf(buff, "nifc1Dk%d.csv", k);
        nifc1.save(buff, arma::csv_ascii);
        sprintf(buff, "ninc1Dk%d.csv", k);
        ninc1.save(buff, arma::csv_ascii);

        /****************
        2-D Interpolators
        ****************/

        // Periodic
        InterpolCtoF picf2(k, m, n, pdc2, nc2);
        InterpolCtoN picn2(k, m, n, pdc2, nc2);
        InterpolFtoC pifc2(k, m, n, pdc2, nc2);
        InterpolNtoC pinc2(k, m, n, pdc2, nc2);

        sprintf(buff, "picf2Dk%d.csv", k);
        picf2.save(buff, arma::csv_ascii);
        sprintf(buff, "picn2Dk%d.csv", k);
        picn2.save(buff, arma::csv_ascii);
        sprintf(buff, "pifc2Dk%d.csv", k);
        pifc2.save(buff, arma::csv_ascii);
        sprintf(buff, "pinc2Dk%d.csv", k);
        pinc2.save(buff, arma::csv_ascii);

        // Nonperiodic
        InterpolCtoF nicf2(k, m, n, ndc2, nc2);
        InterpolCtoN nicn2(k, m, n, ndc2, nc2);
        InterpolFtoC nifc2(k, m, n, ndc2, nc2);
        InterpolNtoC ninc2(k, m, n, ndc2, nc2);

        sprintf(buff, "nicf2Dk%d.csv", k);
        nicf2.save(buff, arma::csv_ascii);
        sprintf(buff, "nicn2Dk%d.csv", k);
        nicn2.save(buff, arma::csv_ascii);
        sprintf(buff, "nifc2Dk%d.csv", k);
        nifc2.save(buff, arma::csv_ascii);
        sprintf(buff, "ninc2Dk%d.csv", k);
        ninc2.save(buff, arma::csv_ascii);

        /****************
        3-D Interpolators
        ****************/

        // Periodic
        InterpolCtoF picf3(k, m, n, o, pdc3, nc3);
        InterpolCtoN picn3(k, m, n, o, pdc3, nc3);
        InterpolFtoC pifc3(k, m, n, o, pdc3, nc3);
        InterpolNtoC pinc3(k, m, n, o, pdc3, nc3);

        sprintf(buff, "picf3Dk%d.csv", k);
        picf3.save(buff, arma::csv_ascii);
        sprintf(buff, "picn3Dk%d.csv", k);
        picn3.save(buff, arma::csv_ascii);
        sprintf(buff, "pifc3Dk%d.csv", k);
        pifc3.save(buff, arma::csv_ascii);
        sprintf(buff, "pinc3Dk%d.csv", k);
        pinc3.save(buff, arma::csv_ascii);

        // Nonperiodic
        InterpolCtoF nicf3(k, m, n, o, ndc3, nc3);
        InterpolCtoN nicn3(k, m, n, o, ndc3, nc3);
        InterpolFtoC nifc3(k, m, n, o, ndc3, nc3);
        InterpolNtoC ninc3(k, m, n, o, ndc3, nc3);

        sprintf(buff, "nicf3Dk%d.csv", k);
        nicf3.save(buff, arma::csv_ascii);
        sprintf(buff, "nicn3Dk%d.csv", k);
        nicn3.save(buff, arma::csv_ascii);
        sprintf(buff, "nifc3Dk%d.csv", k);
        nifc3.save(buff, arma::csv_ascii);
        sprintf(buff, "ninc3Dk%d.csv", k);
        ninc3.save(buff, arma::csv_ascii);
    }

    return 0;
}
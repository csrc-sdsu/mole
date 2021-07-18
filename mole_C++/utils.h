#ifndef UTILS_H
#define UTILS_H

#include <armadillo>

using namespace arma;

class Utils
{

public:
    static sp_mat spkron(const sp_mat &A, const sp_mat &B);
    static sp_mat spjoin_rows(const sp_mat &A, const sp_mat &B);
    static sp_mat spjoin_cols(const sp_mat &A, const sp_mat &B);
};

#endif // UTILS_H

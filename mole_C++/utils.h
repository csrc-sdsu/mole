#ifndef UTILS_H
#define UTILS_H

#include <armadillo>

using namespace arma;

class Utils
{

public:
    static sp_mat spkron(sp_mat A, sp_mat B);
    static sp_mat spjoin_rows(sp_mat A, sp_mat B);
    static sp_mat spjoin_cols(sp_mat A, sp_mat B);
};

#endif // UTILS_H

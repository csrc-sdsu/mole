#pragma once

#ifndef UTILS_H
#define UTILS_H

#include <armadillo>
#define Real double

using namespace arma;

class Utils
{
public:
    static sp_mat spkron(const sp_mat &A, const sp_mat &B);
    static sp_mat spjoin_rows(const sp_mat &A, const sp_mat &B);
    static sp_mat spjoin_cols(const sp_mat &A, const sp_mat &B);
    static vec spsolve_eigen(const sp_mat &A, const vec &b);
};

#endif // UTILS_H

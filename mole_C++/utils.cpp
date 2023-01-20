#include "utils.h"

#ifdef EIGEN
#include <eigen3/Eigen/SparseLU>
vec Utils::spsolve_eigen(const sp_mat &A, const vec &b)
{
	Eigen::SparseMatrix<real> eigen_A(A.n_rows, A.n_cols);
	std::vector<Eigen::Triplet<real>> triplets;
	Eigen::SparseLU<Eigen::SparseMatrix<real>, Eigen::COLAMDOrdering<int>> solver;

	Eigen::VectorXd eigen_x(A.n_rows);
	triplets.reserve(5*A.n_rows);

	auto it = A.begin();
	while(it != A.end()) {
		triplets.push_back(Eigen::Triplet<real>(it.row(), it.col(), *it));
		++it;
	}

	eigen_A.setFromTriplets(triplets.begin(), triplets.end());
	triplets.clear();

	auto b_ = conv_to<std::vector<real> >::from(b);
	Eigen::Map<Eigen::VectorXd> eigen_b(b_.data(), b_.size());

	solver.analyzePattern(eigen_A);
	solver.factorize(eigen_A);
	eigen_x = solver.solve(eigen_b);

	return vec(eigen_x.data(), eigen_x.size());
}
#endif

// Basic implementation of Kronecker product
/*
sp_mat Utils::spkron(const sp_mat &A, const sp_mat &B)
{
    sp_mat result;

    for (u32 i = 0; i < A.n_rows; i++) {
        sp_mat BLOCK;
        for (u32 j = 0; j < A.n_cols; j++) {
            BLOCK = join_rows(BLOCK, A(i, j)*B);
        }
        result = join_cols(result, BLOCK);
    }

    return result;
}
*/

sp_mat Utils::spkron(const sp_mat &A, const sp_mat &B)
{
    sp_mat::const_iterator itA  = A.begin();
    sp_mat::const_iterator endA = A.end();
    sp_mat::const_iterator itB  = B.begin();
    sp_mat::const_iterator endB = B.end();
    u32 j = 0;

    vec a = nonzeros(A);
    vec b = nonzeros(B);

    umat locations(2, a.n_elem*b.n_elem);
    vec values(a.n_elem*b.n_elem);

    while(itA != endA) {
        while(itB != endB) {
            locations(0, j) = itA.row()*B.n_rows + itB.row();
            locations(1, j) = itA.col()*B.n_cols + itB.col();
            values(j) = (*itA)*(*itB);
            ++j;
            ++itB;
        }

        ++itA;
        itB = B.begin();
    }

    sp_mat result(locations, values, A.n_rows*B.n_rows, A.n_cols*B.n_cols, true);

    return result;
}

sp_mat Utils::spjoin_rows(const sp_mat &A, const sp_mat &B)
{
    sp_mat::const_iterator itA  = A.begin();
    sp_mat::const_iterator endA = A.end();
    sp_mat::const_iterator itB  = B.begin();
    sp_mat::const_iterator endB = B.end();
    u32 j = 0;

    vec a = nonzeros(A);
    vec b = nonzeros(B);

    umat locations(2, a.n_elem + b.n_elem);
    vec values(a.n_elem + b.n_elem);

    while(itA != endA) {
        locations(0, j) = itA.row();
        locations(1, j) = itA.col();
        values(j) = (*itA);
        ++itA;
        ++j;
    }

    while(itB != endB) {
        locations(0, j) = itB.row();
        locations(1, j) = itB.col() + A.n_cols;
        values(j) = (*itB);
        ++itB;
        ++j;
    }

    sp_mat result(locations, values, A.n_rows, A.n_cols+B.n_cols, true);

    return result;
}

sp_mat Utils::spjoin_cols(const sp_mat &A, const sp_mat &B)
{
    sp_mat::const_iterator itA  = A.begin();
    sp_mat::const_iterator endA = A.end();
    sp_mat::const_iterator itB  = B.begin();
    sp_mat::const_iterator endB = B.end();
    u32 j = 0;

    vec a = nonzeros(A);
    vec b = nonzeros(B);

    umat locations(2, a.n_elem + b.n_elem);
    vec values(a.n_elem + b.n_elem);

    while(itA != endA) {
        locations(0, j) = itA.row();
        locations(1, j) = itA.col();
        values(j) = (*itA);
        ++itA;
        ++j;
    }

    while(itB != endB) {
        locations(0, j) = itB.row() + A.n_rows;
        locations(1, j) = itB.col();
        values(j) = (*itB);
        ++itB;
        ++j;
    }

    sp_mat result(locations, values, A.n_rows+B.n_rows, A.n_cols, true);

    return result;
}

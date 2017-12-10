#include "utils.h"

// Basic implementation
/*
sp_mat Utils::spkron(sp_mat A, sp_mat B)
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

sp_mat Utils::spkron(sp_mat A, sp_mat B)
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

sp_mat Utils::spjoin_rows(sp_mat A, sp_mat B)
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

sp_mat Utils::spjoin_cols(sp_mat A, sp_mat B)
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

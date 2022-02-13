/*
This isolated example illustrates how to solve a linear system where 'A' 
is of type sp_mat and 'b' is of type vec (Armadillo's types) using sparse QR 
factorization provided by cuSOLVER.

cuSOLVER doesn't provide a routine for sparse LU factorization on the GPU! The 
best alternative is QR factorization (based on the qualities of the mimetic Laplacian) 
even though it is twice as expensive.

Compile:
nvcc spsolve_cuda.cu -o spsolve_cuda -O3 -I./armadillo-10.2.1/include -lcusparse -lcusolver
*/

#include <cusolverSp.h>
#define ARMA_ALLOW_FAKE_GCC
#include <armadillo>

using namespace arma;

double* cuda_qr(const double* values,
        const long long unsigned int a_nnz,
        const long long unsigned int rows,
        const long long unsigned int cols,
        const long long unsigned int* row_ind,
        const long long unsigned int* col_ptrs,
        double* b,
        double* x) {

  int nnz = (int)a_nnz;
  int* h_csccol_pts;
  int* h_cscRowInd;
  double* h_cscVal;

  h_csccol_pts = (int*)malloc(sizeof(int) * (cols + 1));
  for (int i = 0; i < cols + 1; ++i)
    h_csccol_pts[i] = (int)col_ptrs[i];

  h_cscRowInd = (int*)malloc(sizeof(int) * nnz);
  for (int i = 0; i < nnz; ++i)
    h_cscRowInd[i] = (int)row_ind[i];

  h_cscVal = (double*)malloc(sizeof(double) * nnz);
  memcpy(h_cscVal, values, sizeof(double) * nnz);

  size_t h_buffer = 0;
  double* d_buffer = nullptr;

  int* d_csccol_pts = nullptr;
  int* d_cscRowInd = nullptr;
  int* d_csrRowPtr = nullptr;
  int* d_csrColInd = nullptr;
  double* d_csrvalues = nullptr;
  double* d_cscVal = nullptr;

  cusparseHandle_t sphandle = nullptr;
  cusparseCreate(&sphandle);

  cudaMalloc((void**)&d_cscVal, sizeof(double) * nnz);
  cudaMalloc((void**)&d_csccol_pts, sizeof(int) * (cols + 1));
  cudaMalloc((void**)&d_cscRowInd, sizeof(int) * nnz);
  cudaMalloc((void**)&d_csrvalues, sizeof(double) * nnz);
  cudaMalloc((void**)&d_csrRowPtr, sizeof(int) * (rows + 1));
  cudaMalloc((void**)&d_csrColInd, sizeof(int) * nnz);

  cusparseIndexBase_t idxBase = CUSPARSE_INDEX_BASE_ZERO;
  cusparseAction_t copyValues = CUSPARSE_ACTION_NUMERIC;
  cusparseCsr2CscAlg_t alg = CUSPARSE_CSR2CSC_ALG2;
  cudaDataType valType = CUDA_R_64F;

  cudaMemcpy(d_cscVal, h_cscVal, sizeof(double) * nnz, cudaMemcpyHostToDevice);
  cudaMemcpy(d_csccol_pts, h_csccol_pts, sizeof(int) * (cols + 1), cudaMemcpyHostToDevice);
  cudaMemcpy(d_cscRowInd, h_cscRowInd, sizeof(int) * nnz, cudaMemcpyHostToDevice);

  cusparseMatDescr_t descrA = nullptr;
  cusparseCreateMatDescr(&descrA);
  cusparseSetMatType(descrA, CUSPARSE_MATRIX_TYPE_GENERAL);
  cusparseSetMatIndexBase(descrA, CUSPARSE_INDEX_BASE_ZERO);

  cusparseCsr2cscEx2_bufferSize(sphandle,
                                cols,
                                rows,
                                nnz,
                                d_cscVal,
                                d_csccol_pts,
                                d_cscRowInd,
                                d_csrvalues,
                                d_csrRowPtr,
                                d_csrColInd,
                                valType,
                                copyValues,
                                idxBase,
                                alg,
                                &h_buffer);

  cudaMalloc((void**)&d_buffer, sizeof(double) * h_buffer);

  cusparseCsr2cscEx2(sphandle,
                     cols,
                     rows,
                     nnz,
                     d_cscVal,
                     d_csccol_pts,
                     d_cscRowInd,
                     d_csrvalues,
                     d_csrRowPtr,
                     d_csrColInd,
                     valType,
                     copyValues,
                     idxBase,
                     alg,
                     d_buffer);

  cusolverSpHandle_t solhandle = nullptr;
  cusolverSpCreate(&solhandle);

  double* d_b = nullptr;
  cudaMalloc((void**)&d_b, sizeof(double) * rows);

  double tol = 1e-12;
  const int reorder = 1;
  int singularity = 0;

  double* d_x = nullptr;
  cudaMalloc((void**)&d_x, sizeof(double) * cols);

  cudaMemcpy(d_b, b, sizeof(double) * rows, cudaMemcpyHostToDevice);

  cusolverSpDcsrlsvqr(solhandle,
                      cols,
                      nnz,
                      descrA,
                      d_csrvalues,
                      d_csrRowPtr,
                      d_csrColInd,
                      d_b,
                      tol,
                      reorder,
                      d_x,
                      &singularity);

  if (0 <= singularity)
        cout << "Matrix is singular\n";

  x = (double*)malloc(sizeof(double) * cols);

  cudaMemcpy(x, d_x, sizeof(double) * cols, cudaMemcpyDeviceToHost);

  cusolverSpDestroy(solhandle);
  cusparseDestroy(sphandle);
  cusparseDestroyMatDescr(descrA);
  free(h_cscVal);
  free(h_csccol_pts);
  free(h_cscRowInd);
  cudaFree(d_cscVal);
  cudaFree(d_csccol_pts);
  cudaFree(d_cscRowInd);
  cudaFree(d_csrvalues);
  cudaFree(d_csrRowPtr);
  cudaFree(d_csrColInd);
  cudaFree(d_buffer);
  cudaFree(d_x);
  cudaFree(d_b);

  return x;
}

vec spsolve_cuda(sp_mat A, vec b) {
  const double* values = A.values;
  const long long unsigned int nnz = A.n_nonzero;
  const long long unsigned int rows = A.n_rows;
  const long long unsigned int cols = A.n_cols;
  const long long unsigned int* row_indices = A.row_indices;
  const long long unsigned int* col_ptrs = A.col_ptrs;

  double* b_ = b.memptr();
  double* x = nullptr;

  return vec(cuda_qr(values, nnz, rows, cols, row_indices, col_ptrs, b_, x), A.n_cols);
}

int main() {
  int size = 1000;
  sp_mat A = sprandn<sp_mat>(size, size, 0.05); // 5% density
  vec b(size, fill::randu);

  vec x = spsolve_cuda(A, b);

  return 0;
}

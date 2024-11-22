/**
 * @file laplacian.h
 * 
 * @brief Mimetic Laplacian Class and Constructors
 * 
 * @date 2024/10/15
 * 
 */

#ifndef LAPLACIAN_H
#define LAPLACIAN_H

#include "divergence.h"
#include "gradient.h"

/**
 * @brief Mimetic Laplacian operator
 *
 */
class Laplacian : public sp_mat {

public:
  using sp_mat::operator=;

  /**
   * @brief 1-D Mimetic Laplacian Constructor
   *
   * @param k Order of accuracy
   * @param m Number of cells
   * @param dx Spacing between cells
   */  
  Laplacian(u16 k, u32 m, Real dx);
  
  /**
   * @brief 2-D Mimetic Laplacian Constructor
   *
   * @param k Order of accuracy
   * @param m Number of cells in x-direction
   * @param n Number of cells in y-direction
   * @param dx Spacing between cells in x-direction
   * @param dy Spacing between cells in y-direction
   */  
  Laplacian(u16 k, u32 m, u32 n, Real dx, Real dy);
  

  /**
   * @brief 3-D Mimetic Laplacian Constructor
   *
   * @param k Order of accuracy
   * @param m Number of cells in x-direction
   * @param n Number of cells in y-direction
   * @param o Number of cells in z-direction
   * @param dx Spacing between cells in x-direction
   * @param dy Spacing between cells in y-direction
   * @param dz Spacing between cells in z-direction
   */  
  Laplacian(u16 k, u32 m, u32 n, u32 o, Real dx, Real dy, Real dz);
};

#endif // LAPLACIAN_H

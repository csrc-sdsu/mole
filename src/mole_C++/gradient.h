/**
 * @file gradient.h
 * 
 * @brief Mimetic Gradient Operators
 * 
 * @date 2024/10/15
 * 
 */

#ifndef GRADIENT_H
#define GRADIENT_H

#include "utils.h"
#include <cassert>

/**
 * @brief Mimetic Gradient operator
 *
 */
class Gradient : public sp_mat {

public:
  using sp_mat::operator=;

  /**
   * @brief 1-D Mimetic Gradient Constructor
   *
   * @param k Order of accuracy
   * @param m Number of cells
   * @param dx Spacing between cells
   */  
  Gradient(u16 k, u32 m, Real dx);
  
  /**
   * @brief 2-D Mimetic Gradient Constructor
   *
   * @param k Order of accuracy
   * @param m Number of cells in x-direction
   * @param n Number of cells in y-direction
   * @param dx Spacing between cells in x-direction
   * @param dy Spacing between cells in y-direction
   */  
  Gradient(u16 k, u32 m, u32 n, Real dx, Real dy);
  
  /**
   * @brief 3-D Mimetic Gradient Constructor
   *
   * @param k Order of accuracy
   * @param m Number of cells in x-direction
   * @param n Number of cells in y-direction
   * @param o Number of cells in z-direction
   * @param dx Spacing between cells in x-direction
   * @param dy Spacing between cells in y-direction
   * @param dz Spacing between cells in z-direction
   */  
  Gradient(u16 k, u32 m, u32 n, u32 o, Real dx, Real dy, Real dz);


  /**
   * @brief Returns the weights used in the Mimeitc Gradient Operators.
   *
   * @note for informational purposes only, can be used in constructing new operators.
   */  
  vec getP();

private:
  vec P;
};

#endif // GRADIENT_H

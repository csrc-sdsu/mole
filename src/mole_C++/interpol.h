/**
 * @file interpol.h
 * 
 * @brief Mimetic Interpolators
 * 
 * @date 2024/10/15
 * 
 */

 #ifndef INTERPOL_H
#define INTERPOL_H

#include "utils.h"
#include <cassert>

/**
 * @brief Mimetic Interpolator operator
 *
 */
class Interpol : public sp_mat {

public:
  using sp_mat::operator=;

  /**
   * @brief 1-D Mimetic Interpolator Constructor
   *
   * @param m Number of cells
   * @param c Weight for ends, can be any value from 0.0<=c<=1.0
   */  
  Interpol(u32 m, Real c);
  
  /**
   * @brief 2-D Mimetic Interpolator Constructor
   *
   * @param m Number of cells in x-direction
   * @param n Number of cells in y-direction
   * @param c1 Weight for ends in x-direction, can be any value from 0.0<=c<=1.0
   * @param c2 Weight for ends in y-direction, can be any value from 0.0<=c<=1.0
   */  
  Interpol(u32 m, u32 n, Real c1, Real c2);
  
  /**
   * @brief 3-D Mimetic Interpolator Constructor
   *
   * @param m Number of cells in x-direction
   * @param n Number of cells in y-direction
   * @param o Number of cells in z-direction
   * @param c1 Weight for ends in x-direction, can be any value from 0.0<=c<=1.0
   * @param c2 Weight for ends in y-direction, can be any value from 0.0<=c<=1.0
   * @param c3 Weight for ends in z-direction, can be any value from 0.0<=c<=1.0
   */   
  Interpol(u32 m, u32 n, u32 o, Real c1, Real c2, Real c3);
  
  /**
   * @brief 1-D Mimetic Interpolator Constructor
   *
   * @param type Dummy holder to trigger overloaded function
   * @param m Number of cells
   * @param c Weight for ends, can be any value from 0.0<=c<=1.0
   */    
  Interpol(bool type, u32 m, Real c);
  
  /**
   * @brief 2-D Mimetic Interpolator Constructor
   *
   * @param type Dummy holder to trigger overloaded function
   * @param m Number of cells in x-direction
   * @param n Number of cells in y-direction
   * @param c1 Weight for ends in x-direction, can be any value from 0.0<=c<=1.0
   * @param c2 Weight for ends in y-direction, can be any value from 0.0<=c<=1.0
   */  
  Interpol(bool type, u32 m, u32 n, Real c1, Real c2);

  /**
   * @brief 3-D Mimetic Interpolator Constructor
   *
   * @param type Dummy holder to trigger overloaded function
   * @param m Number of cells in x-direction
   * @param n Number of cells in y-direction
   * @param o Number of cells in z-direction
   * @param c1 Weight for ends in x-direction, can be any value from 0.0<=c<=1.0
   * @param c2 Weight for ends in y-direction, can be any value from 0.0<=c<=1.0
   * @param c3 Weight for ends in z-direction, can be any value from 0.0<=c<=1.0
   */     
  Interpol(bool type, u32 m, u32 n, u32 o, Real c1, Real c2, Real c3);
};

#endif // INTERPOL_H

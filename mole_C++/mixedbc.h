/**
 * @file mixedbc.h
 * @author Johnny Corbino (johnnycorbino@gmail.com)
 * @brief Header file for the Mixed Boundary Condition operator
 * @version 0.1
 * @date 2024-08-03
 *
 * @copyright Copyright (c) 2024
 *
 */

#ifndef MIXEDBC_H
#define MIXEDBC_H

#include "gradient.h"

/**
 * @brief Mimetic Mixed BC operator
 *
 */
class MixedBC : public sp_mat {

public:
  using sp_mat::operator=;

  /**
   * @brief 1-D Constructor
   *
   * @param k Order of accuracy
   * @param m Number of cells
   * @param dx Spacing between cells
   * @param left Type of boundary condition at the left boundary ('Dirichlet',
   * 'Neumann', 'Robin')
   * @param coeffs_left Coefficients for the left boundary condition
   * @param right Type of boundary condition at the right boundary ('Dirichlet',
   * 'Neumann', 'Robin')
   * @param coeffs_right Coefficients for the right boundary condition
   */
  MixedBC(u16 k, u32 m, Real dx, const std::string &left,
          const std::vector<Real> &coeffs_left, const std::string &right,
          const std::vector<Real> &coeffs_right);

  /**
   * @brief 2-D Constructor
   *
   * @param k Order of accuracy
   * @param m Number of cells along x-axis
   * @param dx Spacing between cells along x-axis
   * @param n Number of cells along y-axis
   * @param dy Spacing between cells along y-axis
   * @param left Type of boundary condition at the left boundary ('Dirichlet',
   * 'Neumann', 'Robin')
   * @param coeffs_left Coefficients for the left boundary condition
   * @param right Type of boundary condition at the right boundary ('Dirichlet',
   * 'Neumann', 'Robin')
   * @param coeffs_right Coefficients for the right boundary condition
   * @param bottom Type of boundary condition at the bottom boundary
   * ('Dirichlet', 'Neumann', 'Robin')
   * @param coeffs_bottom Coefficients for the bottom boundary condition
   * @param top Type of boundary condition at the top boundary ('Dirichlet',
   * 'Neumann', 'Robin')
   * @param coeffs_top Coefficients for the top boundary condition
   */
  MixedBC(u16 k, u32 m, Real dx, u32 n, Real dy, const std::string &left,
          const std::vector<Real> &coeffs_left, const std::string &right,
          const std::vector<Real> &coeffs_right, const std::string &bottom,
          const std::vector<Real> &coeffs_bottom, const std::string &top,
          const std::vector<Real> &coeffs_top);

  /**
   * @brief 3-D Constructor
   *
   * @param k Order of accuracy
   * @param m Number of cells along x-axis
   * @param dx Spacing between cells along x-axis
   * @param n Number of cells along y-axis
   * @param dy Spacing between cells along y-axis
   * @param o Number of cells along z-axis
   * @param dz Spacing between cells along z-axis
   * @param left Type of boundary condition at the left boundary ('Dirichlet',
   * 'Neumann', 'Robin')
   * @param coeffs_left Coefficients for the left boundary condition
   * @param right Type of boundary condition at the right boundary ('Dirichlet',
   * 'Neumann', 'Robin')
   * @param coeffs_right Coefficients for the right boundary condition
   * @param bottom Type of boundary condition at the bottom boundary
   * ('Dirichlet', 'Neumann', 'Robin')
   * @param coeffs_bottom Coefficients for the bottom boundary condition
   * @param top Type of boundary condition at the top boundary ('Dirichlet',
   * 'Neumann', 'Robin')
   * @param coeffs_top Coefficients for the top boundary condition
   * @param front Type of boundary condition at the front boundary ('Dirichlet',
   * 'Neumann', 'Robin')
   * @param coeffs_front Coefficients for the front boundary condition
   * @param back Type of boundary condition at the back boundary ('Dirichlet',
   * 'Neumann', 'Robin')
   * @param coeffs_back Coefficients for the back boundary condition
   */
  MixedBC(u16 k, u32 m, Real dx, u32 n, Real dy, u32 o, Real dz,
          const std::string &left, const std::vector<Real> &coeffs_left,
          const std::string &right, const std::vector<Real> &coeffs_right,
          const std::string &bottom, const std::vector<Real> &coeffs_bottom,
          const std::string &top, const std::vector<Real> &coeffs_top,
          const std::string &front, const std::vector<Real> &coeffs_front,
          const std::string &back, const std::vector<Real> &coeffs_back);
};

#endif // MIXEDBC_H

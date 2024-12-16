#include "mixedbc.h"

// 1-D Constructor
MixedBC::MixedBC(u16 k, u32 m, Real dx, const std::string &left,
                 const std::vector<Real> &coeffs_left, const std::string &right,
                 const std::vector<Real> &coeffs_right) {
  sp_mat A(m + 2, m + 2);
  sp_mat BG(m + 2, m + 2);

  Gradient *grad = nullptr;

  // Handle the left boundary condition
  if (left == "Dirichlet") {
    A.at(0, 0) = coeffs_left[0];
  } else if (left == "Neumann") {
    grad = new Gradient(k, m, dx);
    BG.row(0) = -coeffs_left[0] * grad->row(0);
  } else if (left == "Robin") {
    A.at(0, 0) = coeffs_left[0];
    grad = new Gradient(k, m, dx);
    BG.row(0) = -coeffs_left[1] * grad->row(0);
  } else {
    throw std::invalid_argument("Unknown boundary condition type");
  }

  // Handle the right boundary condition
  if (right == "Dirichlet") {
    A.at(m + 1, m + 1) = coeffs_right[0];
  } else if (right == "Neumann") {
    if (!grad)
      grad = new Gradient(k, m, dx);
    BG.row(m + 1) = coeffs_right[0] * grad->row(m);
  } else if (right == "Robin") {
    A.at(m + 1, m + 1) = coeffs_right[0];
    if (!grad)
      grad = new Gradient(k, m, dx);
    BG.row(m + 1) = coeffs_right[1] * grad->row(m);
  } else {
    throw std::invalid_argument("Unknown boundary condition type");
  }

  *this = A + BG;

  delete grad;
}

// 2-D Constructor
MixedBC::MixedBC(u16 k, u32 m, Real dx, u32 n, Real dy, const std::string &left,
                 const std::vector<Real> &coeffs_left, const std::string &right,
                 const std::vector<Real> &coeffs_right,
                 const std::string &bottom,
                 const std::vector<Real> &coeffs_bottom, const std::string &top,
                 const std::vector<Real> &coeffs_top) {
  MixedBC Bm(k, m, dx, left, coeffs_left, right, coeffs_right);
  MixedBC Bn(k, n, dy, bottom, coeffs_bottom, top, coeffs_top);

  sp_mat Im = speye(m + 2, m + 2);
  sp_mat In = speye(n + 2, n + 2);

  In.at(0, 0) = 0;
  In.at(n + 1, n + 1) = 0;

  sp_mat BC1 = Utils::spkron(In, Bm);
  sp_mat BC2 = Utils::spkron(Bn, Im);

  *this = BC1 + BC2;
}

// 3-D Constructor
MixedBC::MixedBC(u16 k, u32 m, Real dx, u32 n, Real dy, u32 o, Real dz,
                 const std::string &left, const std::vector<Real> &coeffs_left,
                 const std::string &right,
                 const std::vector<Real> &coeffs_right,
                 const std::string &bottom,
                 const std::vector<Real> &coeffs_bottom, const std::string &top,
                 const std::vector<Real> &coeffs_top, const std::string &front,
                 const std::vector<Real> &coeffs_front, const std::string &back,
                 const std::vector<Real> &coeffs_back) {
  MixedBC Bm(k, m, dx, left, coeffs_left, right, coeffs_right);
  MixedBC Bn(k, n, dy, bottom, coeffs_bottom, top, coeffs_top);
  MixedBC Bo(k, o, dz, front, coeffs_front, back, coeffs_back);

  sp_mat Im = speye(m + 2, m + 2);
  sp_mat In = speye(n + 2, n + 2);
  sp_mat Io = speye(o + 2, o + 2);

  Io.at(0, 0) = 0;
  Io.at(o + 1, o + 1) = 0;

  sp_mat In2 = In;
  In2.at(0, 0) = 0;
  In2.at(n + 1, n + 1) = 0;

  sp_mat BC1 = Utils::spkron(Utils::spkron(Io, In2), Bm);
  sp_mat BC2 = Utils::spkron(Utils::spkron(Io, Bn), Im);
  sp_mat BC3 = Utils::spkron(Utils::spkron(Bo, In), Im);

  *this = BC1 + BC2 + BC3;
}

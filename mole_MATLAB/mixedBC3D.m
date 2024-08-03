function BC = mixedBC3D(k, m, dx, n, dy, o, dz, left, coeffs_left, right, coeffs_right, bottom, coeffs_bottom, top, coeffs_top, front, coeffs_front, back, coeffs_back)
% Constructs a 3D mimetic mixed boundary conditions operator
%
% Parameters:
%    k               : Order of accuracy
%    m               : Number of cells in x-direction
%    dx              : Step size in x-direction
%    n               : Number of cells in y-direction
%    dy              : Step size in y-direction
%    o               : Number of cells in z-direction
%    dz              : Step size in z-direction
%    left            : Type of boundary condition at the left boundary ('Dirichlet', 'Neumann', 'Robin')
%    coeffs_left     : Coefficients for the left boundary condition (a, b for Robin, otherwise coeff. for Dirichlet or Neumann)
%    right           : Type of boundary condition at the right boundary ('Dirichlet', 'Neumann', 'Robin')
%    coeffs_right    : Coefficients for the right boundary condition (a, b for Robin, otherwise coeff. for Dirichlet or Neumann)
%    bottom          : Type of boundary condition at the bottom boundary ('Dirichlet', 'Neumann', 'Robin')
%    coeffs_bottom   : Coefficients for the bottom boundary condition (a, b for Robin, otherwise coeff. for Dirichlet or Neumann)
%    top             : Type of boundary condition at the top boundary ('Dirichlet', 'Neumann', 'Robin')
%    coeffs_top      : Coefficients for the top boundary condition (a, b for Robin, otherwise coeff. for Dirichlet or Neumann)
%    front           : Type of boundary condition at the front boundary ('Dirichlet', 'Neumann', 'Robin')
%    coeffs_front    : Coefficients for the front boundary condition (a, b for Robin, otherwise coeff. for Dirichlet or Neumann)
%    back            : Type of boundary condition at the back boundary ('Dirichlet', 'Neumann', 'Robin')
%    coeffs_back     : Coefficients for the back boundary condition (a, b for Robin, otherwise coeff. for Dirichlet or Neumann)

    % 1-D boundary operators
    Bx = mixedBC(k, m, dx, left, coeffs_left, right, coeffs_right);
    By = mixedBC(k, n, dy, bottom, coeffs_bottom, top, coeffs_top);
    Bz = mixedBC(k, o, dz, front, coeffs_front, back, coeffs_back);
    
    Im = speye(m+2);
    In = speye(n+2);
    Io = speye(o+2);
    
    In(1, 1) = 0;
    In(end, end) = 0;
    Io(1, 1) = 0;
    Io(end, end) = 0;

    BC1 = kron(kron(Io, In), Bx);
    BC2 = kron(kron(Io, By), Im);
    BC3 = kron(kron(Bz, In), Im);
    
    BC = BC1 + BC2 + BC3;
end

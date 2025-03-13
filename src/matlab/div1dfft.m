function [du]=div1dfft(u,k,dx)
    m=size(u)
    m=m(1)
    A=extensionOperatorDivergence(k,m-1);
    deriv=calculateInteriorRow(k)'; %size is k-1
  
    uExt=A*u; %size is m+k-2
    du=-ifft(fft(deriv,m+2*k-4) .* fft(uExt,m+2*k-4))/dx;
    du=du(k:(k+m-2))
    du=[0;du;0]
end
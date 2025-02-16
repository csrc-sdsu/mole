function D=divergencehelper(k,m)
%Calculates the mimetic divergence operator of order k,
%   barring dividing by dx. 
%   k=order of accuracy
%
    r=calculateInteriorRow(k);
    A=sparse(m+2,m+k-1); %This matrix is just using the interior scheme.Since we've extended our vector field
    %beyond the boundaries it'd normally have, we don't need to use
    %seperate power series expansions for the stencils near the boundary. 
    for i=2:(m+1)
        A(i,(i-1):(i+k-2))=r;
    end
    D=A*extensionOperatorDivergence(k,m);
end
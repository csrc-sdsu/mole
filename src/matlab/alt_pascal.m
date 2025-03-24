function [ A ] = alt_pascal( n )
%   Calculates the alternating pascal triangle up to n rows.
%   This is the change of basis matrix from the basis {i in {0,1,...,n-1}:(e^(h*D)-1)^i} to 
%   the standard basis. {i in {0,1,...,n-1}:(e^(i*h*D))}
    A=eye(n);
    A(:,1)=2*rem(1:n,2) - 1; %Alternating vector [1,-1,1,-1,...]
    for i=2:n
        A(i,2:end)=A(i-1,1:end-1)-A(i-1,2:end);
    end
    


end
function [ A ] = alt_pascal( n )
%   Calculates the alternating pascal triangle.
%   Will give exact values for n<56
    if(n>1030); error('Argument should be less than 1031'); end
    A=eye(n);
    A(:,1)=1;
    for i=2:n
        A(i,2:end)=A(i-1,1:end-1)+A(i-1,2:end);
    end
    for i=1:n
        for j=1:i
            A(i,j)=A(i,j)*(-1)^(i+j);
        end
    end


end
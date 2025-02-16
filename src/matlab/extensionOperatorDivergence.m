function E=extensionOperatorDivergence(k,m)
% Returns a m+k-1 by m+1 one matrix. Which pads an m+1` point vector field
% With k/2-1 additional points on each side. These points are
% approximations of what happens if you extrapolate 
% 
% 
% Parameters:
%                k : Order of accuracy
%                m : Number of cells

    E=sparse(m+k-1,m+1);
    r=idivide(k,int32(2));
    for i=r:m+r
        E(i,i+1-r)=1;
    end
    R=zeros(r-1,k+1);%calculates the matrix R_{i,j}=binom(i-k/2,j) 
    %Used in the fact that e^(-jh)=∑_{i=0}^(k)binom(-j,i)(exp(h*d/dx)-I)^i+O(h^(k+1)).
    % This is how you approximate  f(-jh) as a linear combo of
    %f(0),f(h),...,f(kh) with O(h^(k+1)).  
    R(:,1)=ones([r-1,1]);
    currentTerm=(-1);
    for i=2:(k+1)
        R(r-1,i)=currentTerm;
        currentTerm=currentTerm*(-1);
    end
    for i=(r-2):(-1):1
        for j=2:(k+1)
            R(i,j)=R(i+1,j)-R(i,j-1);
        end
    end

    % A=[(-1)^(i+j)*binomial(i,j) for i=0:k,j=0:k]
    R=R*alt_pascal(k+1)
    for i=1:(r-1)
        for j=1:(k+1)
            E(i,j)=R(i,j);
            E(m+k-i,m+2-j)=R(i,j);
        end
    end
   




end
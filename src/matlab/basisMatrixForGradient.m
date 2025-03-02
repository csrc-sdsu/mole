function [A]=basisMatrixForGradient(k)
% Returns a k+1 by k+1 triangular matrix.
% This is the change of basis matrix from the basis {1}U{f_0(x),f_1(x),...,f_k(x)} 
% to {1,x,x^3,...,x^(2k+1)}.Where f_i(x)=∫_1^x (t^2-1)^idt. 
% This is the corresponding change of basis matrix for
% extensionOperatorGradient like altPascal was for extensionOperatorDivergence.

    A=zeros(k+1);
    A(1,1)=1;
    currentRow=zeros([1,k+1]);
    %This is f_i(x), 
    %Initial row set to f_0(x) which is just x-1
    currentRow(1)=-1;
    currentRow(2)=1;
    alternatingBinom=zeros([1,k+1]); %this list represents x*(x^2-1)^i, which if expanded out
    % has coordinate vector [0,(-1)^(i),(-1)^(i-1)binom(i,1),...,1]
    alternatingBinom(2)=-1;
    alternatingBinom(3)=1;
    alternatingBinomCopy=zeros([1,k+1]);
    i=1;
    leftBoundaryBinom=1; %(-1)^(i), the first term of our alternatingBinom
    while 1
        A(i+1,:)=currentRow;
        if (i==k)
            break
        end
        currentRow=(1/(2*i+1)*(alternatingBinom+currentRow)-currentRow);
        %f_i(x)=(x(x^2-1)^i)/(2i+1)-(2i)/(2i+1)f_{i-1}(x)
        alternatingBinomCopy(2)=leftBoundaryBinom;
        for j=3:(i+2)
            alternatingBinomCopy(j)=alternatingBinom(j-1)-alternatingBinom(j);
        end
        alternatingBinomCopy(i+3)=1;
        for j=2:(i+3)
            alternatingBinom(j)=alternatingBinomCopy(j);
        end
        leftBoundaryBinom=-leftBoundaryBinom;
        i=i+1;
    end
    


end
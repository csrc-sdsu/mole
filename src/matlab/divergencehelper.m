function D=divergencehelper(k,m)
%Calculates the mimetic divergence operator of order k,
%   barring dividing by dx. 
%   k :order of accuracy.
%   m :number of cells. 
    interior=calculateInteriorRow(k); %The interior row of our matrix 
    numNonZeros=m*k; % The number of nonZeroElements in the interior stencil matrix
    rowList=zeros([1,numNonZeros]);
    columnList=zeros([1,numNonZeros]);
    valueList=zeros([1,numNonZeros]);
    elementsInserted=1;
    for i=2:(m+1)
        for j=1:(k)
            rowList(elementsInserted)=i;
            columnList(elementsInserted)=i+j-2;
            valueList(elementsInserted)=interior(j);
            elementsInserted=elementsInserted+1;
        end
    end
    interiorScheme=sparse(rowList,columnList,valueList,m+2,m+k-1);
    % This matrix is just using the interior scheme.
    % Since we've extended our vector field beyond the boundaries it'd normally have, we don't need to use
    % seperate power series expansions for the stencils near the boundary. 
    D=interiorScheme*extensionOperatorDivergence(k,m);
end
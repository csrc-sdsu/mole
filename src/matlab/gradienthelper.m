function G=gradienthelper(k,m)
    interior=calculateInteriorRow(k);
    numNonZeros=(m+1)*k;
    rowList=zeros([1,numNonZeros]);
    columnList=zeros([1,numNonZeros]);
    valueList=zeros([1,numNonZeros]);
    elementsInserted=1;
    for i=1:(m+1)
        for j=1:(k)
            rowList(elementsInserted)=i;
            columnList(elementsInserted)=i+j-1;
            valueList(elementsInserted)=interior(j);
            elementsInserted=elementsInserted+1;
        end
    end
    interiorScheme=sparse(rowList,columnList,valueList);
    G=interiorScheme*extensionOperatorGradient(k,m);

end
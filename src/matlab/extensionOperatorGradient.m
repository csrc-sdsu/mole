function E=extensionOperatorGradient(k,m)
    % Returns a m+k by m+2 matrix, 
    % Which turns the list [f(0),f(h/2),f(3h/2),...,f(1-h/2),f(1)]
    % Into
    % [f(-(k/2-1/2)h),f(-(k/2-3/2)h),...,f(-h/2),
    % f(h/2),...f(1-h/2),f(1+h/2),...f(1+(k/2-1/2)*h)]
    numOfRows=m+k;
    numOfColumns=m+2;
    r=idivide(k,int32(2));
    numNonZeros=m+k*(k+1); 
    % The number of nonZeroElements in the interior stencil matrix
    rowList=zeros([1,numNonZeros]);
    columnList=zeros([1,numNonZeros]);
    valueList=zeros([1,numNonZeros]);
    elementsInserted=1;
    R=zeros([r,k+1]);
    R(:,2)=ones(r);
    R(r,2:end)=2*rem(1:k,2) - 1;
    for i=(r-1):(-1):1
        for j=3:(k+1)
            R(i,j)=R(i+1,j)-R(i,j-1);
        end
    end

    Scalefactor=diag(-(k-1):2:-1);
    R=Scalefactor*R;
    R(:,1)=ones(r);
    R=R*basisMatrixForGradient(k);
    for i=1:r
        for j=1:(k+1)
            rowList(elementsInserted)=i;
            columnList(elementsInserted)=j;
            valueList(elementsInserted)=R(i,j);
            rowList(elementsInserted+1)=m+k+1-i;
            columnList(elementsInserted+1)=m+3-j;
            valueList(elementsInserted+1)=R(i,j);
            elementsInserted=elementsInserted+2;
        end
    end
    for j=2:(m+1)
        rowList(elementsInserted)=r+j-1;
        columnList(elementsInserted)=j;
        valueList(elementsInserted)=1;
        elementsInserted=elementsInserted+1;
    end
    E=sparse(rowList,columnList,valueList,numOfRows,numOfColumns);

end
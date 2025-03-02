function E=extensionOperatorDivergence(k,m)
% Returns a m+k-1 by m+1 one matrix. Which pads an m+1` point vector field
% With k/2-1 additional points on each side. These points are
% approximations of
% f(-(k/2-1)h),f(-(k/2-2)h),....,f(-h),f(1+h),f(1+2h),...,f(1+(k/2-1)h),
% with O(h^(k+1)) error on each of the approximations. 
% 
% 
% Parameters:
%                k : Order of accuracy
%                m : Number of cells
    numOfRows=m+k-1;
    numOfColumns=m+1;
    numNonZeros=(k-2)*(k+1)+m+1;%The number of nonzero elements in E.
    rowList=zeros([1,numNonZeros]);%Row indices for non zero elements
    columnList=zeros([1,numNonZeros]); %Column indices for non zero elements
    valueList=zeros([1,numNonZeros]); %Values of non zero elements
    elementsInserted=1; %Number of elements inserted into rowList,ColumnList
    %and ValueList
    r=idivide(k,int32(2));
    R=zeros(r-1,k+1);% Calculates the matrix R_{i,j}=binom(i-k/2,j-1) 
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
    R=R*alt_pascal(k+1); %Converts R into the standard basis 
    for i=1:(r-1) %
        for j=1:(k+1)
            rowList(elementsInserted)=i;
            columnList(elementsInserted)=j;
            valueList(elementsInserted)=R(i,j);
            rowList(elementsInserted+1)=m+k-i;
            columnList(elementsInserted+1)=m+2-j;
            valueList(elementsInserted+1)=R(i,j);
            elementsInserted=elementsInserted+2;
        end
    end
    for i=r:m+r
        rowList(elementsInserted)=i;
        columnList(elementsInserted)=i+1-r;
        valueList(elementsInserted)=1;
        elementsInserted=elementsInserted+1;
    end
    E=sparse(rowList,columnList,valueList,numOfRows,numOfColumns);

end
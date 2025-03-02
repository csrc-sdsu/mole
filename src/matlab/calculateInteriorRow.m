function output=calculateInteriorRow(k)
% Returns the interior row for the kth order mimetic divergence or gradient.
%
% Parameters:
%                k : Order of accuracy
    output=zeros([1,k]); 
    % Represents ∑_{i=0}^{k/2-1}
    % (∏_{j=1}^{i}(0.125/j-0.25))/(2i+1))(e^(h/2*d/dx)-e^(-h/2*d/dx))^(2i+1).
    % Our answer. 
    r=idivide(k,int32(2));
    output(r)=-1.0;
    output(r+1)=1.0; %our starting value for this series is (e^(h/2*d/dx)-e^(-h/2*d/dx))
    if (k>2)
        nextTerm=zeros([1,k]);% NextTerm in the series.
        %Initially set to (e^(h/2*d/dx)-e^(-h/2*d/dx))^(3)
        nextTermCopy=zeros([1,k]); 
        nextTerm(r-1)=-1.0;
        nextTerm(r)=3.0;
        nextTerm(r+1)=-3.0;
        nextTerm(r+2)=1.0;
        scalefactor=1; %this number is ∏_{j=1}^{i}(0.125/j-0.25).
        i=1;
        while 1
            scalefactor=scalefactor*(0.125/i-0.25);
            output=output+scalefactor/(2.0*i+1.0)*nextTerm;
            if (i==r-1)
                break
            end
            nextTermCopy(r-i-1)=-1.0; %Updates next term from (e^(h/2*d/dx)-e^(-h/2*d/dx))^(2i+1)
             %to (e^(h/2*d/dx)-e^(-h/2*d/dx))^(2i+3)
            nextTermCopy(r-i)=1.0*(2.0*i+3.0);
            nextTermCopy(r+i+1)=-1.0*(2.0*i+3.0);
            nextTermCopy(r+i+2)=1.0;
            for j=(r-i+1):(r+i)
                nextTermCopy(j)=nextTerm(j+1)-2*nextTerm(j)+nextTerm(j-1);
            end
            for j=(r-i-1):(r+i+2)
                nextTerm(j)=nextTermCopy(j);
            end
            i=i+1;

        
        end
    end
end
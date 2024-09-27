function Q = weightsQ(k, m, dx)
% Returns the m+2 weights of Q
%
% Parameters:
%                k : Order of accuracy
%                m : Number of cells
%               dx : Step size

    D = div(k, m, dx);
    
    b = [-1; zeros(m-1, 1); 1]; % RHS
    
    Q = [1; D(2:end-1, :)'\b; 1];
end

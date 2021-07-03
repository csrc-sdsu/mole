function Y = hmean(X)
% Returns the harmonic mean for every two pairs of a column vector
% And, Y(1) = X(1), Y(end) = X(end)
%
% Parameters:
%                X : Column vector

    Y = [X(1); 2*X(1:end-1).*X(2:end)./(X(1:end-1)+X(2:end)); X(end)];
end

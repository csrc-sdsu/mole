% MOLE is distributed under a GNU General Public License; please refer to the LICENSE file for more details.

function Y = amean(X)
% Returns the arithmetic mean for every two pairs in a column vector
% And, Y(1) = X(1), Y(end) = X(end)
%
% Parameters:
%                X : Column vector

 

    Y = [X(1); (X(1:end-1)+X(2:end))/2; X(end)];
end

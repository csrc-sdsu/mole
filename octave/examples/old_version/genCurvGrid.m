function [X, Y] = genCurvGrid(m, n)
    X = zeros(m, n);
    Y = zeros(m, n);
    for j = 1 : n
        for i = 1 : m
            X(i, j) = j-pi+2*sin((j-pi)/5)*cos((i-pi)/5);
            Y(i, j) = i-pi+2*sin((j-pi)/5)*cos((i-pi)/5);
        end
    end
end

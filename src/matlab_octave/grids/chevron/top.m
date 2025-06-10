function XY = top(s)
    X = s;
    if s <= 0.5
        Y = 1-s;
    elseif s > 0.5
        Y = s;
    end
    XY = [X Y];
end
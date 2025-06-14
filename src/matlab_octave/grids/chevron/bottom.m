function XY = bottom(s)
    X = s;
    if s <= 0.5
        Y = -s;
    elseif s > 0.5
        Y = s-1;
    end
    XY = [X Y];
end
function d2 = distanceFunction(XI,XJ)
   

for i = 1:size(XJ,1)
    d2(i,1) = sum(abs(XI(1:24) - XJ(i,1:24)) + abs(XI(73:96) - XJ(i,73:96))) ...
        + sum(abs(XI(25:48) - XJ(i,25:48)) + abs(XI(97:120) - XJ(i,97:120))).*5 ...
        + sum(abs(XI(49:72) - XJ(i,49:72)) + abs(XI(121:144) - XJ(i,121:144))).*10;
end

end


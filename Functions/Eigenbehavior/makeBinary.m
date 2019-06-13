function binaryLabels = makeBinary(tempLabel, nClass)

binaryLabels=[];
for class = 1:nClass
    temp_bin = tempLabel;
    temp_bin(temp_bin ~= class) = 0;
    temp_bin(temp_bin ~= 0) = 1;
    binaryLabels = [binaryLabels temp_bin];
end
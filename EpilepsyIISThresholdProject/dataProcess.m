function [y, localBaseline] = dataProcess(x, baselines)
%for now...
y = x;
baselineSize = 250; %How many values used to create a local baseline
localBaseline = zeros(size(x));
for i = 1: size(x, 2) %each channel
    avg = mean(x(1:baselineSize, i)); %first avg
    for j = 1: size(x, 1)
        if j <= baselineSize
            localBaseline(j, i) = avg;
        elseif j > size(x, 1) - baselineSize
            localBaseline(j, i) = avg;
        else %update localavg when necessary
            avg = avg + x(j, i)/baselineSize - x(j - baselineSize, i)/baselineSize;
            localBaseline(j, i) = avg;
        end
    end        
end
end
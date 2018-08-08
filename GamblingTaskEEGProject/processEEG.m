%Processes Raw EEG data
function processed = processEEG(rawEEG)
    %%
%     %standardization
%     normFactor = 1.0/4000; %correlates variation with the percentile to use
%     normMax = 10; %don't want bounds to shrink too much
     baselineVals = 100; %normalizing across 1 second
%     %%
    %relabeling from ~-1 to 1
    newEEG = zeros(size(rawEEG));
    for channel = 1: size(rawEEG, 2)
        %dev = var(rawEEG(:, channel));
        %normValue = dev * normFactor;
        %if (normValue > normMax) 
        %    normValue = normMax;
        %end
        min = prctile(rawEEG(:, channel), .0001);
        max = prctile(rawEEG(:, channel), 100 - .0001);
        rawEEG(:, channel) = rawEEG(:, channel) - min;
        rawEEG(:, channel) = rawEEG(: , channel)./ (max-min);
        rawEEG = rawEEG * 2  - 1;
        %baseline = mean(rawEEG(:, channel));
        %rawEEG(:, channel) = rawEEG(:, channel).*2 - baseline;
    %%   
    %moving baseline
        movingavg = movmean(rawEEG(:, channel), baselineVals);
        newEEG(:, channel) = rawEEG(:, channel) - movingavg;
    end
    processed = newEEG;
end

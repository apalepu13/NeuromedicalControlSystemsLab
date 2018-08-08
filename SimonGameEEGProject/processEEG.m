%Processes Raw EEG data
function processed = processEEG(rawEEG)
    %%
    %standardization
    normFactor = 1.0/1532; %correlates variation with the percentile to use
    normMax = 10; %don't want bounds to shrink too much
    baselineVals = 10000; %normalizing across 1 second
    %%
    %relabeling from ~-1 to 1
    newEEG = zeros(size(rawEEG));
    for channel = 1: size(rawEEG, 2)
        %dev = var(rawEEG(:, channel));
        %normValue = dev * normFactor;
        %if (normValue > normMax) 
        %    normValue = normMax;
        %end
        %min = prctile(rawEEG(:, channel), normValue);
        %max = prctile(rawEEG(:, channel), 100 - normValue);
        %rawEEG(:, channel) = rawEEG(:, channel) - min;
        %rawEEG(:, channel) = rawEEG(: , channel)./ (max-min);
        %%baseline = mean(rawEEG(:, channel));
        %%rawEEG(:, channel) = rawEEG(:, channel).*2 - baseline;
    %%   
    %moving baseline
        movingavg = 0;
        
        for time = 1: size(rawEEG, 1)
            if (time > baselineVals/2 && time < size(rawEEG, 1) - baselineVals/2 && rem(time,baselineVals) == 1)
                dev = var(rawEEG((time-baselineVals/2):(time + baselineVals/2), channel));
                normValue = dev * normFactor;
                if (normValue > normMax) 
                    normValue = normMax;
                end
                min = prctile(rawEEG(:, channel), normValue);
                max = prctile(rawEEG(:, channel), 100 - normValue);
                rawEEG((time-baselineVals/2):(time + baselineVals/2), channel) = rawEEG((time-baselineVals/2):(time + baselineVals/2), channel) - min;
                rawEEG((time-baselineVals/2):(time + baselineVals/2), channel) = rawEEG((time-baselineVals/2):(time + baselineVals/2), channel)./ (max-min);
            end
            
            if (time <= baselineVals/2) 
                movingavg = mean(rawEEG(1:time*2, channel));
            elseif (time >= size(rawEEG, 1) - baselineVals/2)
                movingavg = mean(rawEEG(time*2:end, channel));
            else
                movingavg = movingavg - rawEEG(time - baselineVals/2, channel)/baselineVals;
                movingavg = movingavg + rawEEG(time + baselineVals/2, channel)/baselineVals;
            end
            newEEG(time, channel) = rawEEG(time, channel) - movingavg;
        end  
    processed = newEEG;
end

%check if detected spikes matches up with 'real' spikes: false positive, true
%positive, false negative, true negative...
function [evaluation, evalStats] = evalSpikes(approximatedTimes, spikeTimes, numSpikes, timeLeniency)
    %Ensures evaluation holds a different value in each scenario.
    evaluation = (2*spikeTimes) + approximatedTimes; 
    %Initializes 'evalStats' holding frequency of true positive, false
    %positive...
    evalStats = zeros(1, 4);
    %This boolean is used to avoid counting a single spike multiple times.
    spikefound = false;
    for i = 1: size(evaluation, 2)
        spikeCount = 0;
        for j = 1: size(evaluation, 1)
            if evaluation(j, i) == 3
                if ~spikefound
                    evalStats(1, 1) = evalStats(1, 1) + 1; %True positive
                    spikefound = true;
                end
                if spikeCount > 11
                    spikeCount = 0;
                    spikefound = false;
                end
                spikeCount = spikeCount + 1;
            elseif evaluation(j, i) == 2
                evalStats(1, 2) = evalStats(1, 2) + 1; %False positive
                spikefound = false;
                spikeCount = 0;
            elseif evaluation(j, i) == 0
                spikefound = false;
                spikeCount = 0;
            elseif evaluation(j, i) == 1
                if spikeCount > 11
                    spikeCount = 0;
                    spikefound = false;
                end
                spikeCount = spikeCount + 1;
            end
        end
    end
    %Do this to ensure we are only getting one false negative per spike.
    evalStats(1, 3) = numSpikes - evalStats(1, 1); %False negative
    evalStats(1, 4) = numel(spikeTimes) - evalStats(1, 2) - numSpikes; %True negative   
end
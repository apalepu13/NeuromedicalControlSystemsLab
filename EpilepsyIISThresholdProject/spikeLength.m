%Used for analyzing the real spikes - not part of algorithm
function [Counters,avgVal] = spikeLength(EEG, approximatedTimes, spikeTimes)
Counters = zeros(200,1);
vals = [];
for i = 1 : size(approximatedTimes, 2)
    for j = 1: size(approximatedTimes, 1)
        if approximatedTimes(j, i) == 1 && approximatedTimes(j-5, i) == 1 && approximatedTimes(j+5, i) == 1
            vals(end+1) = max(abs(EEG(j-5:j+5,i)));
            for h = j-5: j+5
            if spikeTimes(h, i) == 1
                count = 1;
                for k = h : -1 : h-50
                    if spikeTimes(k, i) == 0
                         %break;
                    else
                        count = count + 1;
                    end
                end
                for k = h: h+50
                    if spikeTimes(k, i) == 0
                         %break;
                    else
                        count = count + 1;
                    end
                end
                Counters(count,1) = Counters(count) + 1;
            end
            end
        end
    end
end
%figure;
%histogram(vals);
avgVal = mean(vals);
end
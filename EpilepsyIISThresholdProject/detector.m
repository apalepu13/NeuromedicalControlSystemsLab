function spike_times = detector(EEG, threshold, thresholdLimit, baselines)
    if ~exist('baselines', 'var')
        baselines = zeros(size(EEG));
    end
    % Initializes all channel/time pairs to false.
    spike_times = false(size(EEG));
    % Sets values channel/time pairs exceeding the threshold to true.
    spike_times = (EEG-baselines < -1*threshold) & (EEG-baselines > -1*thresholdLimit); % spike
    %Removes spikes not between 3-5 time units long
%       for label = 1: size(spike_times, 2)
%            for time = 1: size(spike_times, 1)
%                if spike_times(time, label) == 1
%                   %Number of data points in interval
%                   myCount = 0;
%                   startTime = time -49;
%                   if startTime < 1
%                       startTime = 1;
%                   end
%                   endTime = time + 49;
%                   if endTime > size(spike_times, 1)
%                       endTime = size(spike_times, 1);
%                   end
%                   for t = startTime: endTime
%                       if spike_times(t, label) == 1
%                           myCount = myCount + 1;
%                       end
%                   end
%                   if myCount < 10 || myCount > 100
%                       spike_times(startTime:endTime, label) = 0;
%                   end                               
                 
%                   %Consecutive data points
%                 spikeStart = time;
%                 while spike_times(spikeStart, label)
%                     spikeStart = spikeStart - 1;
%                     if spikeStart == 0
%                         break;
%                     end
%                 end
%                 spikeEnd = time;
%                 while spike_times(spikeEnd, label)
%                     spikeEnd = spikeEnd + 1;
%                     if spikeEnd == size(spike_times, 1) + 1
%                         break;
%                     end
%                 end
%                 spikeLen = spikeEnd - spikeStart -1;
%                 if spikeLen < 3 || spikeLen > 49
%                     spike_times(spikeStart+1: spikeEnd -1, label) = 0;
%                 end
% 
%                end     
%            end
%       end
end
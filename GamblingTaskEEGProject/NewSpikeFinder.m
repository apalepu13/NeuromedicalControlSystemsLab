% %%
% %Analyze EEG Data for IIS
% %Uncomment to reload EEG data.
% 
% clearvars;
% load('EFRIO6EEGFilt.mat');
% myThreshold = .9; %this threshold is based on 7 previous data sets
% boxSize = 100; %1 second epochs, 2000 readings/second
% spikeRatioThreshold = .005; %what ratio of spike crossing 
%                           required to say a spike has occured 
% 
% 
% UNCOMMENT if you change the preprocessing algo
% EEG2 = processEEG(EEG); 
% %%
% 
% UNCOMMENT if you change the threshold for spike detection
% spikeTimes = zeros(size(EEG2));
% for channel = 1: size(EEG2, 2)
%   for time = 1: size(EEG2, 1)
%        spikeTimes(time, channel) = computeSpikes(EEG2(time, channel), myThreshold);
%    end
% end 
%  
% %%  
%   %How many threshold crossing occur in each epoch, or time unit. 
%   %Current epoch = 1 second or 2000 readings
%   
%  %Uncomment if epoch, AKA boxSize changes, or if anything before changes
%  EEGboxes = zeros(ceil(size(EEG2, 1)/boxSize), size(EEG2, 2));
%  for channel = 1: size(EEG2, 2)
%     for time = boxSize:boxSize: boxSize* size(EEGboxes, 1)
%         if (channel == size(EEG2, 2))
%            EEGboxes(time/boxSize, channel) = sum(spikeTimes(time - boxSize + 1: end, channel));
%         else
%             EEGboxes(time/boxSize, channel) = sum(spikeTimes(time-boxSize + 1: time, channel));
%         end
%      end
%  end
% 
% %
% 
% UNCOMMENT if you change the ratio of threshold crossings 
% in each epoch needed to decide a spike is occuring
% or if anything before is uncommented.
%  finalSpikeDecision = zeros(size(EEGboxes)); % correspond a time and channel w/ spikedecision
%  for channel = 1: size(EEGboxes, 2)
%     for boxnum = 1: size(EEGboxes, 1)
%         if (EEGboxes(boxnum, channel)/boxSize > spikeRatioThreshold)
%             finalSpikeDecision(boxnum, channel) = 1;
%         else
%         end
%     end
%  end
%  totalSpikes = sum(sum(finalSpikeDecision));
%  
%  %
%  
%  %UNCOMMENT IF YOU WANT TO PLOT SPIKES
%  %plot the "Spikes" found
%  %The title informs what channel/time the spike occurs at.
%  %Can use EDF browser to look at said channel/time to confirm if its a
%  %spike. 1925 spikes total found initially, not all are going to be real spikes. 
%  figure();
% 
%  for channel = 1: size(finalSpikeDecision, 2) 
%      for time = 1: size(finalSpikeDecision, 1)
%          if (finalSpikeDecision(time, channel) == 1)
%              if (channel ~= size(finalSpikeDecision, 2))
%                 plot(1:boxSize, (EEG2((time-1)*boxSize + 1: time*boxSize, channel))); 
%                 title("Channel/second" + " " + channel + "/" + time);
%                 pause;
%              else
%                 plot((time-1)*boxSize + 1: size(EEG2, 2), (EEG2((time-1)*boxSize + 1: end, channel)));
%                 title("Channel/second" + " " + channel + "/" + time);
%                 pause;
%              end
%          end
%      end
%  end
% 
% 
% 
% % % % % % % EACH SPIKE IS A COLUMN
% % % % % % % CHANNEL, TIME in all seconds, 
% % % % % % % MINUTES portion of time, SECONDS portion of time
% spikeListings = zeros(4, totalSpikes);
% spikeNum = 1;
% for channel = 1: size(finalSpikeDecision, 2)
%     for time = 1: size(finalSpikeDecision, 1)
%         if (finalSpikeDecision(time, channel) == 1)
%             spikeListings(1:4, spikeNum) = [channel time floor(time/60) time - 60*(floor(time/60))];
%             spikeNum = spikeNum + 1;
%         end
%     end
% end
% 
% save('IISResults.mat', 'spikeListings', 'totalSpikes', 'finalSpikeDecision');

clear all;
load('IISResults.mat');
load('data/EFRI06_WAR_SES1_Setup.mat');
trialMat = zeros(size(trial_times, 1), 2);
errorFindingTrial = zeros(size(trial_times, 1), 1);
%hmm not all are long enough and contain correct numbers, need to actually
%check manually ig....
for i = 1: size(trialMat, 1)
    startInd = find(trial_words{i} == 9, 1);
    lastInd = find(trial_words{i} == 51, 1);
    if(isempty(startInd)) 
        startInd = 1;
        errorFindingTrial(i, 1) = 1;
    end
    if(isempty(lastInd)) 
        lastInd = size(trial_words{i}, 1);
        errorFindingTrial(i, 1) = 1;
    end
    trialMat(i, 1) = floor(trial_times{i}(startInd, 1));
    trialMat(i, 2) = ceil(trial_times{i}(lastInd, 1));
end

spike_events_showcard = zeros(size(trialMat, 1), size(finalSpikeDecision, 2));
for i = 1 : size(trialMat, 1)
    for j = 1: size(finalSpikeDecision, 2)
        spike_events_showcard(i, j) = sum(finalSpikeDecision(trialMat(i, 1): trialMat(i, 2), j));
    end
end

save('IISResultsByTrialAndChannel.mat', 'spike_events_showcard', 'errorFindingTrial', 'finalSpikeDecision')

    
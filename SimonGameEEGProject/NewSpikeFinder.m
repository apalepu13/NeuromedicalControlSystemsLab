%%
% %Analyze EEG Data for IIS
% %Uncomment to reload EEG data.
% 
clearvars;
load('EEG.mat');
myThreshold = .46; %this threshold is based on 7 previous data sets
boxSize = 10000; %1 second epochs, 1000 readings/second
spikeRatioThreshold = .005; %what ratio of spike crossing 
%                           required to say a spike has occured 
%
% 
%% UNCOMMENT if you change the preprocessing algo
 EEG2 = processEEG(EEG); 
%%
% 
%UNCOMMENT if you change the threshold for spike detection
spikeTimes = zeros(size(EEG2));
for channel = 1: size(EEG2, 2)
  for time = 1: size(EEG2, 1)
       spikeTimes(time, channel) = computeSpikes(EEG2(time, channel), myThreshold);
   end
end 
 
%%  
  %How many threshold crossing occur in each epoch, or data unit. 
  %Current epoch = 1 second or 1000 readings
  
 %Uncomment if epoch, AKA boxSize changes, or if anything before changes
 EEGboxes = zeros(ceil(size(EEG2, 1)/boxSize), size(EEG2, 2));
 for channel = 1: size(EEG2, 2)
    for time = boxSize:boxSize: boxSize* size(EEGboxes, 1)
        if (time == boxSize* size(EEGboxes, 1))
           EEGboxes(time/boxSize, channel) = sum(spikeTimes(time - boxSize + 1: end, channel));
        else
            EEGboxes(time/boxSize, channel) = sum(spikeTimes(time-boxSize + 1: time, channel));
        end
     end
 end

%%

% UNCOMMENT if you change the ratio of threshold crossings 
% in each epoch needed to decide a spike is occuring
% or if anything before is uncommented.
 finalSpikeDecision = zeros(size(EEGboxes)); % correspond a time and channel w/ spikedecision
 for channel = 1: size(EEGboxes, 2)
    for boxnum = 1: size(EEGboxes, 1)
        if (EEGboxes(boxnum, channel)/boxSize > spikeRatioThreshold)
            finalSpikeDecision(boxnum, channel) = 1;
        else
        end
    end
 end
 totalSpikes = sum(sum(finalSpikeDecision));
 
 %%
 
 %%UNCOMMENT IF YOU WANT TO PLOT SPIKES
 %%plot the "Spikes" found
 %%The title informs what channel/time the spike occurs at.
 %%Can use EDF browser to look at said channel/time to confirm if its a
 %%spike. 1925 spikes total found initially, not all are going to be real spikes. 
 figure(1);

 for channel = 1: size(finalSpikeDecision, 2) 
     for time = 1: size(finalSpikeDecision, 1)
         if (finalSpikeDecision(time, channel) == 1)
             if (channel ~= size(finalSpikeDecision, 2))
                plot(1:boxSize, (EEG2((time-1)*boxSize + 1: time*boxSize, channel))); 
                title("Channel/second" + " " + channel + "/" + time);
                pause;
             else
                plot((time-1)*boxSize + 1: size(EEG2, 2), (EEG2((time-1)*boxSize + 1: end, channel)));
                title("Channel/second" + " " + channel + "/" + time);
                pause;
             end
         end
     end
 end

 %%
%

%EACH SPIKE IS A COLUMN
%CHANNEL, TIME in all seconds, 
%MINUTES portion of time, SECONDS portion of time
spikeListings = zeros(4, totalSpikes);
spikeNum = 1;
for channel = 1: size(finalSpikeDecision, 2)
    for time = 1: size(finalSpikeDecision, 1)
        if (finalSpikeDecision(time, channel) == 1)
            spikeListings(1:4, spikeNum) = [channel time floor(time/60) time - 60*(floor(time/60))];
            spikeNum = spikeNum + 1;
        end
    end
end

save('IISResults.mat', 'spikeListings', 'totalSpikes', 'finalSpikeDecision');
            
         
            
        
        
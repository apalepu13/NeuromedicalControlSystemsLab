%%% to set font size:
%%% - axes = gca; % set a variable to the current axes
%%% - axes.FontSize = FONTSIZE; 
clearvars;
%% INITIALIZING DATA
%Load in data for this patient
load('EEG19.mat');
%Set parameters for which thresholds are being tested
initThreshold = .3;
thresholdStep = 0.02;
thresholdFinal = .7;
thresholdLimit = 20;
%Alters raw data from EEG, if applicable
[EEG, localBaseline] = dataProcess(EEG, baselines);
%Removes bad channels and times from EEG - uses mean of beginning and final
%thresholds to find bad channels/times.
%[EEG, approximatedTimes, localBaseline] = eliminate(EEG, detector(EEG, ...
%  mean([initThreshold thresholdFinal]), thresholdLimit), approximatedTimes, localBaseline);


%% PROCESSING DATA
num = 1;
format long;
% Main computational loop - cycling through algorithm for each threshold
% being tested.
for i = initThreshold: thresholdStep: thresholdFinal
myThreshold(num) = i; % Keeps track of which threshold is being tested.
spike_times = detector(EEG, i, thresholdLimit, localBaseline);
%Used for research purposes, not part of detector 
[counter{num, 1}, avgVal] = spikeLength(EEG, approximatedTimes, spike_times);
[evaluation, evalStats] = evalSpikes(approximatedTimes, spike_times, numSpikes, timeLeniency);
[FPR(num), TPR(num)] = generateROC(evalStats);
num = num + 1;
end
[optimalDistance, optimalThresholdIndex] = optimizeROC(FPR, TPR); 

%% PLOTTING DATA
%Plotting FPR/TPR on a graph for each tested threshold
figure()
plot(FPR, TPR, '-bs')
% plot(FPR(optimalThresholdIndex), TPR(optimalThresholdIndex), '-rs')
axis([0 1 0 1])
title('TPR vs FPR using local baselines');
xlabel('FPR');
ylabel('TPR');
%Labeling each data point
for i = 1 : size(myThreshold, 2)
    hold on;
    if myThreshold(i) < 1
        txt{i} = horzcat(' ',num2str(myThreshold(i)), '\rightarrow');
    else
        txt{i} = strcat(num2str(myThreshold(i)), '\rightarrow');
    end
    %So that not every text is plotted (every 5th is plotted)
    if rem(i, 4) == 1
        text(FPR(i), TPR(i), txt{i}, 'HorizontalAlignment', 'right')
    end
end
optimalThreshold = initThreshold + optimalThresholdIndex*thresholdStep;
%save('M40ROC.mat','numSpikes', 'TPR','timeLeniency', 'FPR', 'optimalDistance', 'optimalThresholdIndex', 'optimalThreshold');

%% FUNCTIONS
%Alter EEG data to be in whatever format we desire.
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

%Our detection algorithm to detect spikes
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

%Cleaning up data - removes both channels and times that are falsely
%reporting spikes. %GOTTA FIX THIS, DOESNT WORK AS INTENDED
function [fixedData, fixedReal, fixedBaseline]  = eliminate(EEG, spikeTimes, realTimes, baselines)
badChannels = [];
badTimes = [];
s = sum(spikeTimes, 1);
%Deletes channels that are always reporting spikes
for i = size(spikeTimes, 2) : -1:  1
    %if 40 percent of the channel is spikes
    if s(i) > (size(spikeTimes, 1) * .5)
        badChannels(end + 1) = i;
    end
end
s = sum(spikeTimes, 2);
%Deletes times showing an abundance of spikes
for i = size(spikeTimes, 1) : -1: 1
    %if there are spikes on 40 percent of the 'good' channels at a time
    if s(i) > (size(spikeTimes, 2) * .3)
        badTimes(end + 1) = i;
    end
end
fixedData = EEG;
fixedReal = realTimes;
fixedBaseline = baselines;
fixedData(:, badChannels) = [];
fixedReal(:, badChannels) = [];
fixedBaseline(:, badChannels) = [];
fixedData(badTimes, :) = [];
fixedReal(badTimes, :) = [];
fixedBaseline(badTimes, :) = [];
end
       


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

%Determines the FPR and TPR based on number of true/false positive/negative
function [FPRout, TPRout] = generateROC(evalStats) 
FPRout = evalStats(1, 2) / (evalStats(1, 2) + evalStats(1, 4));
TPRout = evalStats(1, 1) / (evalStats(1,1) + evalStats(1,3));
end

% Finds threshold with min distance from 1 TPR and 0 FPR.
function [dist, index] = optimizeROC(FPR, TPR)
FPRdist = FPR.^2;
TPRdist = (1 - TPR).^2;
distance = sqrt(FPRdist + TPRdist);
[dist, index] = min(distance);
end

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


                
    


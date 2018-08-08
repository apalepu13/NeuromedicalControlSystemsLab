clearvars;
patients = {'m40_eeg', 'm36_eeg','m32_eeg','m26_eeg', 'm30_eeg', 'm23_eeg', 'm19_eeg', 'm10_eeg'}

for i = 3:3
patient = patients{i}
patient_id = strcat(patient, '.mat');
save_id = strcat('EEG', patient, 'final.mat');
patient_spike_times = strcat(patient(1:3), 'mv.txt'); 
dataDir = 'data/';
    
    patDir = fullfile(dataDir, patient_id);   
    rawdata = load(patDir);    
    EEG = rawdata.data;    
    EEGTimes = EEG(:, 1) - EEG(1, 1);   
    EEG = EEG(:, 2 : end -1);     
    EEGOriginal = EEG;     
    
    %Manual channel removal. NEEDS TO CHANGE FOR EACH PATIENT.
    %removedChannels = [116:128]; %m23 
    %EEG(:, removedChannels) = [];
    %labels = strsplit(rawdata.elec_labels{:}, ',');
    %labels = labels (2 : end-1);
    labels = {};
    index = 1;
    for i = 1 : length(rawdata.elec_labels)
        myArray = strsplit(rawdata.elec_labels{i}, ',');
        for j = 1 : length(myArray)
            labels{1, index} = myArray{j};
            index = index + 1;
        end
    end   
    labels = labels (2: end-1);
    labels2 = labels;
    %labels(:, removedChannels) = [];
    
    %Reads in text file - converts to an array of spike times.
    timesDir = fullfile(dataDir, patient_spike_times);
    content = fileread(timesDir);
    timesArray = textscan(content, '%s %s');
    for i = 1: size(timesArray{1,2})
        channels{i} = upper(timesArray{2}{i});
        convert = strsplit(timesArray{1}{i}, ':');
        convert = str2double(convert);
        times{i} = convert(3) + (convert(2)*60) + (convert(1) * 3600);
    end
    realTimes = cell(1, size(labels, 2));
    for i = 1 : size(times, 2)
        ch = channels{i};
        for j = 1: size(labels, 2)
            if strcmp(strcat(ch,'-REF'),labels{j})
                realTimes{j}{end + 1} = times{i};
                break
            end
        end
    end
    
    % Convert actual times into an array sorted by channel and time
    % with approximate times (with spikes marked at all times within
    % .02)
    timeLeniency = 1; %How close for a detected spike to be valid //.3
    interval = timeLeniency/.004; % A measurement every .004 seconds
    approximatedTimes1 = false(size(EEG));
    %Need to adjust for aligned spikes
    a = 0;
    for i = 1: size(realTimes, 2)
        lastTime = timeLeniency * -2;
        for j = 1: size(realTimes{i}, 2)
            if realTimes{i}{j} - lastTime >= timeLeniency*2
                a = a + 1;
                realSpike{a} = [round((realTimes{i}{j}*250)), i];
                approximatedTimes1(round((realTimes{i}{j}*250)), i) = 1;
                lastTime = realTimes{i}{j};
            end
        end
    end
    numSpikes = size(realSpike, 2);
    
    %List of spikes and respective values
    for i = 1 : size(EEG, 2)
        [min1, in1] = min(EEG(1000:1500, i));
        [min2, in2] = min(EEG(2000:2500, i));
        periodicitylen = in2 - in1 + 1000;
        repsignal = EEG(1:periodicitylen, i);
        len = size(EEG, 1);
        extended = [repmat(repsignal, floor(len / numel(repsignal)), 1); ...
             repsignal(1:mod(len, numel(repsignal)))];
            
        EEG(:, i) = EEG(:, i) - extended;
        dev(i) = var(EEG(:, i));
    end
    devAvg = mean(dev(1:end)); %Used to affect normalization - more deviation = higher normalization factor
    normalizationFactor = devAvg * 3/2700000 + 1;
    normMax = 10;
    if normalizationFactor > normMax
        normalizationFactor = normMax;
    end
   
    %Computes avg value for each channel.
    for i = 1 : size(EEG, 2)
        minimum(i) = prctile(EEG(:, i), normalizationFactor);
        maximum(i) = prctile(EEG(:, i), 100-normalizationFactor);
    end
    minimums = repelem(minimum, size(EEG, 1), 1);
    maximums = repelem(maximum, size(EEG, 1), 1);
    %Normalizes EEG values across channels
    EEG = EEG - minimums;
    EEG = EEG./(maximums-minimums);
    for i = 1 : size(EEG, 2)
        baseline(i) = mean(EEG(:, i));
    end
    baselines = repelem(baseline, size(EEG, 1), 1);
    EEG = EEG - baselines;
    for i = 1: size(EEGOriginal, 2)
        minimumOrig(i) = prctile(EEGOriginal(:, i), normalizationFactor);
        maximumOrig(i) = prctile(EEGOriginal(:, i), normalizationFactor);
    end
    minOrigs = repelem(minimumOrig, size(EEGOriginal, 1), 1);
    maxOrigs = repelem(maximumOrig, size(EEGOriginal, 1), 1);
    EEGOriginal = EEGOriginal - minOrigs;
    EEGOriginal = EEGOriginal./(maxOrigs-minOrigs);
    
    
    baselineLen = 50;
    EEGMovingBaseline = movmean(EEG, baselineLen);
    for i = 1: size(EEGMovingBaseline, 2)
        minmb(i) = prctile(EEGMovingBaseline(:, i), normalizationFactor);
        maxmb(i) = prctile(EEGMovingBaseline(:, i), normalizationFactor);
    end
    maxmbs = repelem(maxmb, size(EEGMovingBaseline, 1), 1);
    minmbs = repelem(minmb, size(EEGMovingBaseline, 1), 1);
    EEGMovingBaseline = EEGMovingBaseline - minmbs;
    EEGMovingBaseline = EEGMovingBaseline./(maxmbs-minmbs);
%     for j = 1:size(EEG, 2)
%         for i = 1: size(EEG, 1)
%             EEGMovingBaseline(i, j) = mean(max(1, i - baselineLen/2): min(i+baselineLen/2, size(EEG, 1)));
%         end
%     end
    
    
    
   
    approximatedTimes = false(size(EEG));
    approximatedTimes2 = false(size(EEG));
    for i = 1: size(approximatedTimes1, 2)
        j = 1;
        
        while (j < size(approximatedTimes1, 1))
            if approximatedTimes1(j, i) == 1
                [minimum, cent] = min(EEG(j-timeLeniency*250:j+timeLeniency*250,i)); %abs for max abs value
                %m(end+1, :) = EEG(j-timeLeniency*250+cent-320:j-timeLeniency*250+cent+320, i)';
                %approximatedTimes(j-timeLeniency*250+cent-5:j-timeLeniency*250+cent+5, i) = 1;
                approximatedTimes2(j-timeLeniency*250 + cent, i) = 1;
                j = j + 1;
            else
                j = j + 1;
            end
        end
    end
    %spikes = m(:, 240:400);
    save(save_id, 'patient', 'EEG', 'baselines', 'numSpikes', 'EEGOriginal', 'EEGMovingBaseline', 'labels2', 'approximatedTimes2');
    %save('EEG.mat', 'patient','m','spikes', 'approximatedTimes','timeLeniency', 'EEG', 'baselines', 'labels', 'numSpikes', 'EEGOriginal', 'labels2', 'approximatedTimes1');
end
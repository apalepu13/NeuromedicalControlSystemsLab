clearvars;
patient = 'ECoG';
labelid = 'Labels';
patient_id = strcat(patient, '.mat');
patient_id2 = strcat(labelid, '.mat');
dataDir = 'data/';

    patDataDir = fullfile(dataDir, patient_id);   
    patInfoDir = fullfile(dataDir, patient_id2);
    
    rawdata = load(patDataDir);    
    EEG = rawdata.ECoG';  
    label = load(patInfoDir);
    labels = label.Labels';
    
    
    
    timeLeniency = 1; %How close for a detected spike to be valid //.3
    interval = timeLeniency/.004; % A measurement every .004 seconds
    %save('newEEGset.mat', 'patient','m','spikes', 'approximatedTimes','timeLeniency', 'EEG', 'baselines', 'labels', 'numSpikes', 'EEG2', 'labels2', 'approximatedTimes2');
    save('EEG.mat', 'patient', 'EEG', 'labels', '-v7.3');
% end
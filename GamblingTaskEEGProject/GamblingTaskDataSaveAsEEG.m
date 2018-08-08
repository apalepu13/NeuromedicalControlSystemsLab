clearvars;
patient = 'EFRI06_WAR_SES1';
dataText = '_Filt';
setupText = '_Setup';
patient_id = strcat(patient, dataText, '.mat');
patient_id2 = strcat(patient, setupText, '.mat');
dataDir = 'data/';

    patDataDir = fullfile(dataDir, patient_id);   
    patInfoDir = fullfile(dataDir, patient_id2);
    
    rawdata = load(patDataDir);    
    EEG = rawdata.lfpdata;   
    labels = rawdata.infos.channels.name;

    %save('newEEGset.mat', 'patient','m','spikes', 'approximatedTimes','timeLeniency', 'EEG', 'baselines', 'labels', 'numSpikes', 'EEG2', 'labels2', 'approximatedTimes2');
    save('EFRIO6EEGFilt.mat', 'patient', 'EEG', 'labels', '-v7.3');
% end
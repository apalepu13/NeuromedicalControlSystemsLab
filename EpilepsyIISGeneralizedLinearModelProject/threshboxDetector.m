%Translate EEG into possible spikes, and then get windows around these
%spikes
%%
clear all;
eegFiles = {'EEGm10_eegfinal.mat', 'EEGm19_eegfinal.mat', 'EEGm23_eegfinal.mat','EEGm26_eegfinal.mat', 'EEGm30_eegfinal.mat', 'EEGm32_eegfinal.mat', 'EEGm36_eegfinal.mat', 'EEGm40_eegfinal.mat'};
datFiles = {'calculatedallm10_eeg.mat','calculatedallm19_eeg.mat','calculatedallm23_eeg.mat','calculatedallm26_eeg.mat','calculatedallm30_eeg.mat','calculatedallm32_eeg.mat','calculatedallm36_eeg.mat','calculatedallm40_eeg.mat'};
boxlen = 500;
use = [1 2 3  5  7 8];
fs = 250; wo = 60/(fs/2);  bw = 3/(fs/2);
[num,den] = iirpeak(wo,bw);
tfactor = 0;

for file = 1: size(use, 2)
    clear c b AllSpikes passThresh labelz labelz2 labels spikemat myEEG count B x y a approx AUC AUCthresh FitInfo threshlabels trainlabels trainspikemat x y threthresh;
    load(eegFiles{use(file)})
    filename = strcat('calculatedall', patient, '.mat');
    firstcount = 0;
    myEEG = EEG;
    for i = 1:boxlen:size(EEG, 1)-boxlen
        firstcount = firstcount + 1;
    end
    
    trial = 1;
    for myThresh = -.34:-.04:-.9
    for j = 1: size(EEGMovingBaseline, 2)
        for i = 1:firstcount
            b(i, j, trial) = sum(myEEG((i-1)*boxlen+1:boxlen*i,j) < myThresh) >= 1;
            approx(i, j) = sum(approximatedTimes2((i-1)*boxlen+1:boxlen*i, j) == 1) >= 1;
        end  

    end
    trial = trial + 1;
    end
    for j = 1:size(b, 2)
        for i = 1: size(b, 1)
            c(i, j) = mean(b(i, j, :));
        end
    end
            b = c;
            b = double(b(:));

%%

%%

%%%%%%%%%%% using glmfit
% [B,FitInfo] = glmfit(spikemat, labels, 'binomial');
% B = [0; B];
% prob=glmval(B, spikemat, 'logit');
% [X, Y, thre, AUC]=perfcurve(labels, prob,1);
% plot(X,Y)
% hold on
%%%%%%%%% 
%%%%%%%%% using elNet

%now lets calc total sens and spec...

count = 1;
for j = 1: size(approx, 2)

        for i = 1:size(approx, 1)
                labelz{1, count} = approx(i, j);
                count = count + 1;
            
        end
end
count = 1;
for j = 1: size(approx, 2)

        for i = 2:size(approx, 1)-1
                labelz2{1, count} = approx(i, j);
                count = count + 1;
            
        end
end
threshlabels = transpose(cell2mat(labelz));
labels = transpose(cell2mat(labelz2));

[Xthresh, Ythresh, threthresh, AUCthresh]=perfcurve(threshlabels, b(:),1);
figure();
plot(Xthresh,Ythresh)
load(datFiles{use(file)}, 'AUC', 'x', 'y', 'trainlabels', 'trainspikemat', 'spikemat', 'boxlen', 'B', 'FitInfo')
save(filename, 'threshlabels','b','AUC', 'AUCthresh','Xthresh', 'Ythresh', 'threthresh','x', 'y', 'trainlabels', 'trainspikemat','labels', 'spikemat','boxlen', 'B', 'FitInfo')
end
%         
function result = minus_avg(eeg, baselineSize)
    avg = movmean(eeg, baselineSize);
    result = eeg - avg;
end
% 
% 

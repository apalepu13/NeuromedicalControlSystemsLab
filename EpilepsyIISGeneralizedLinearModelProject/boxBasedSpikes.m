%Translate EEG into possible spikes, and then get windows around these
%spikes
%%
clear all;
eegFiles = {'EEGm10_eegfinal.mat', 'EEGm19_eegfinal.mat', 'EEGm23_eegfinal.mat','EEGm26_eegfinal.mat', 'EEGm30_eegfinal.mat', 'EEGm32_eegfinal.mat', 'EEGm36_eegfinal.mat', 'EEGm40_eegfinal.mat'};
boxlen = 500;
use = [1 2 3 4 5 6 7 8];
fs = 250; wo = 60/(fs/2);  bw = 3/(fs/2);
[num,den] = iirpeak(wo,bw);
tfactor = 0;
for file = 1: size(use, 2)
    clear b AllSpikes passThresh labelz labels spikemat myEEG count B x y a approx;
    load(eegFiles{use(file)})
    filename = strcat('calculatedall', patient, '.mat');
    count = 0;
    myEEG = EEG;
    for i = 1:boxlen:size(EEG, 1)-boxlen
        count = count + 1;
    end
    for j = 1: size(EEGMovingBaseline, 2)
        for i = 1:count
            b(i, j) = sum(myEEG((i-1)*boxlen+1:boxlen*i,j) < -.45) >= 1;
            
            a(i, j) = sum(myEEG((i-1)*boxlen+1:boxlen*i,j) < -.45) >= 3;
            approx(i, j) = sum(approximatedTimes2((i-1)*boxlen+1:boxlen*i, j) == 1) >= 1;
        end  

    end
            b = b(2:size(b, 1)-1, :);
            b = double(b(:));
count = 1;
mySize = 15;
myStep = 1;

for j = 1: size(a, 2)
    if (sum(approx(:, j)) >=1) 
        for i = 2:size(a, 1)-1
            if (approx(i, j) == 1 || rem(i, 42) == 0) %42
                labelz{1, count} = approx(i, j);
                passThresh{1, count} = a(i, j);
                [minimum, index] = min(myEEG((i-1)*boxlen + 1: boxlen * i, j));
                center = (i-1)*boxlen + index + 1;
                AllSpikes{1,count} = myEEG(center-mySize: myStep: center + mySize, j);
                count = count + 1;
            end
        end
    end
end
tpass = transpose(cell2mat(passThresh));
spikemat = transpose(cell2mat(AllSpikes));
trainspikemat = spikemat;
labels = transpose(cell2mat(labelz));
trainlabels = labels;
%%
FitInfo = 1;

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
[B, FitInfo] = lassoglm(spikemat, labels, 'binomial', 'CV', 10, 'Alpha', .1, 'Standardize', false);
maxAUC = .5;
opIndex = 50;
for curindex = 1:100
    myB = B(:, curindex);
    myB = [FitInfo.Intercept(1, curindex); myB];
    prob=glmval(myB, spikemat, 'logit') + tpass * tfactor;
    [X, Y, thre, AUC]=perfcurve(labels, prob,1);
    if (AUC > maxAUC) 
        maxAUC = AUC;
        opIndex = curindex;
    end
end
curindex = opIndex;
myB = B(:, curindex);
myB = [FitInfo.Intercept(1, curindex); myB];
prob=glmval(myB, spikemat, 'logit') + tpass * tfactor;
[X, Y, thre, AUC]=perfcurve(labels, prob,1);

%now lets calc total sens and spec...

count = 1;
clear labelz AllSpikes spikemat labels passThresh
for j = 1: size(a, 2)

        for i = 2:size(a, 1)-1
                passThresh{1, count} = a(i, j);
                labelz{1, count} = approx(i, j);
                [minimum, index] = min(EEG((i-1)*boxlen + 1: boxlen * i, j));
                center = (i-1)*boxlen + index + 1;
                AllSpikes{1,count} = myEEG(center-mySize: myStep : center + mySize, j);
                count = count + 1;
            
        end
end
tpass = transpose(cell2mat(passThresh));
spikemat = transpose(cell2mat(AllSpikes));
labels = transpose(cell2mat(labelz));

prob=glmval(myB, spikemat, 'logit') + tpass* tfactor;
[X, Y, thre, AUC]=perfcurve(labels, prob,1);
[Xthresh, Ythresh, threthresh, AUCthresh]=perfcurve(labels, b(:),1);
figure();
plot(X,Y)
x = X;
y = Y;
save(filename, 'b','AUC', 'AUCthresh','Xthresh', 'Ythresh', 'b', 'threthresh','x', 'y', 'trainlabels', 'trainspikemat','labels', 'spikemat','boxlen', 'B', 'FitInfo')
end
%         
function result = minus_avg(eeg, baselineSize)
    avg = movmean(eeg, baselineSize);
    result = eeg - avg;
end
% 
% 

 clearvars;
 a = load('calculatedallm10_eeg.mat');
 b = load('calculatedallm19_eeg.mat');
 c = load('calculatedallm23_eeg.mat');
 %d = load('calculatednewm26_eeg.mat');
 e = load('calculatedallm30_eeg.mat');
 %f = load('calculatednewm32_eeg.mat');
 g = load('calculatedallm36_eeg.mat');
 h = load('calculatedallm40_eeg.mat');
newfiles = {a, b, c, e, g, h};

%  aa = load('calculatedthreshm10_eeg.mat');
%  bb = load('calculatedthreshm19_eeg.mat');
%  cc = load('calculatedthreshm23_eeg.mat');
%  %dd = load('calculatedthreshm26_eeg.mat');
%  ee = load('calculatedthreshm30_eeg.mat');
%  ff = load('calculatedthreshm32_eeg.mat');
%  gg = load('calculatedthreshm36_eeg.mat');
%  hh = load('calculatedthreshm40_eeg.mat');
 %threshfiles = {aa, bb, cc, dd ,ee, ff, gg, hh};
%spikemats = nfiles;
tspike = a.trainspikemat;
tlabel = a.trainlabels;
aspike = a.spikemat;
alabel = a.labels;
for i = 2: 6
    tspike = [tspike; newfiles{i}.trainspikemat];
    tlabel = [tlabel; newfiles{i}.trainlabels];
    aspike = [aspike; newfiles{i}.spikemat];
    alabel = [alabel; newfiles{i}.labels];
end


[B, FitInfo] = lassoglm(tspike, tlabel, 'binomial', 'CV', 10, 'Alpha', .1, 'Standardize', false);
maxAUC = .5;
opIndex = 50;
for curindex = 1:100
    myB = B(:, curindex);
    myB = [FitInfo.Intercept(1, curindex); myB];
    prob=glmval(myB, tspike, 'logit');
    [X, Y, thre, AUC]=perfcurve(tlabel, prob,1);
    if (AUC > maxAUC) 
        maxAUC = AUC;
        opIndex = curindex;
    end
end
curindex = 74;
myB = B(:, curindex);
myB = [FitInfo.Intercept(1, curindex); myB];

prob=glmval(myB, aspike, 'logit');
[X, Y, thre, AUC]=perfcurve(alabel, prob,1);
modl = myB;

myB = a.b;
threshlabel = a.threshlabels;
for i = 2: 6
    myB = [myB; newfiles{i}.b];
    threshlabel = [threshlabel; newfiles{i}.threshlabels];
end
[Xthresh, Ythresh, threthresh, AUCthresh]=perfcurve(threshlabel, myB(:),1);
figure();
for i = 1:6
    plot(newfiles{i}.x, newfiles{i}.y, 'b- ');
    hold on
    plot(newfiles{i}.Xthresh, newfiles{i}.Ythresh, 'r- ');
    hold on
end
plot(X, Y, 'b-', 'LineWidth', 3);
plot(Xthresh, Ythresh, 'r-', 'LineWidth', 3);
xlabel("1-Specificity")
ylabel("Sensitivity")
title("Regularized ROC Results vs Threshold")
dist = zeros(size(X));
for i = 1: size(X, 1)
    dist(i, 1) = sqrt((X(i, 1))^2 + (1- Y(i, 1))^2);
end
[smallval, opIndex] = min(dist);
opThresh = thre(opIndex, 1);
sensitivity = Y(opIndex, 1)
specificity = 1- X(opIndex, 1)
    
tdist = zeros(size(Xthresh));
for i = 1: size(Xthresh, 1)
    tdist(i, 1) = sqrt((Xthresh(i, 1))^2 + (1- Ythresh(i, 1))^2);
end
[tsmallval, topIndex] = min(tdist);
topThresh = threthresh(topIndex, 1);
tsensitivity = Ythresh(topIndex, 1)
tspecificity = 1- Xthresh(topIndex, 1)
    

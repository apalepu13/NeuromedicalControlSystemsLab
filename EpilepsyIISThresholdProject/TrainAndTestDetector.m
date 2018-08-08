clearvars;
tic

files = {'EEG10.mat', 'EEG19.mat', 'EEG23.mat'  ...
    ,'EEG30.mat', 'EEG32.mat', 'EEG36.mat', 'EEG40.mat'};
for dataFile = 1: size(files, 2) %For each data file
    myData1 = load(files{dataFile}); 
    spikeNumbers(dataFile) = myData1.numSpikes;
    
    for myIndex = 1: 5 %Run 10 iterations
        timeLeniency = 1;
        sizeofTimes = size(myData1.EEG, 1);
        a = randperm(sizeofTimes, sizeofTimes);
        a = [1:sizeofTimes];
        unusedOrdered = a(1:floor(sizeofTimes/2));
        usedOrdered = a(ceil(sizeofTimes/2): end);
        EEG2 = myData1.EEG;
        EEG = myData1.EEG;
        approximatedTimes2 = myData1.approximatedTimes2;
        baselines = myData1.baselines;
        EEG(unusedOrdered, :) = [];
        baselines(unusedOrdered, :) = [];
        approximatedTimes3 = myData1.approximatedTimes2;
        approximatedTimes2(unusedOrdered, :) = [];
        numSpikes = sum(approximatedTimes2);
        numSpikes = sum(numSpikes); 
        clearvars -except nonSpikeNumbers spikeNumbers avgFPR avgTPR avgDistance dataFile files FPRs EEG TPRs optimalDistances myIndex EEG2 myData1 timeLeniency usedOrdered approximatedTimes3 numSpikes EEG1 approximatedTimes2 baselines numSpikes; 
        SpikeDetector; %This will run first half of data and calculate opt.
        %training   

         EEG2(usedOrdered, :) = [];
         approximatedTimes3(usedOrdered, :) = [];
         approximatedTimes2 = approximatedTimes3;
         numSpikes = sum(approximatedTimes2);
         numSpikes = sum(numSpikes);
         clearvars -except nonSpikeNumbers spikeNumbers avgFPR avgTPR avgDistance dataFile files approximatedTimes2 baselines FPRs TPRs EEG2 optimalThreshold optimalDistances myData1 timeLeniency optimalDistance numSpikes myIndex;
         SpecificDetector; %This will use op. threshold on other half of data
         %testing

         FPRs(myIndex) = myFPR;
         TPRs(myIndex) = myTPR;
         optimalDistances(myIndex) = myoptimalDistance; 
         %evaluate performance...
    end
    avgFPR(dataFile) = mean(FPRs);
    avgTPR(dataFile) = mean(TPRs);
    avgDistance(dataFile) = mean(optimalDistances);
    clearvars -except nonSpikeNumbers avgFPR avgTPR avgDistance dataFile files spikeNumbers
end

spikeNumbers = spikeNumbers / sum(spikeNumbers);
%nonSpikeNumbers = nonSpikeNumbers/ sum(nonSpikeNumbers);
%Weighting by number of spikes in a data file
totalFPR = mean(avgFPR);
%totalFPR = dot(avgFPR, nonSpikeNumbers)/ size(dataFile, 1); %normalized based on number of non-spike values in each data set
totalTPR = dot(avgTPR, spikeNumbers)/ size(dataFile, 1); %normalized based on on number of spikes in each set.
totalDistanceAverage = mean(avgDistance);
toc
figure
scatter(avgFPR, avgTPR)

save('FullResults.mat', 'totalFPR', 'totalTPR', 'totalDistanceAverage', 'spikeNumbers', 'avgFPR', 'avgTPR', 'avgDistance');
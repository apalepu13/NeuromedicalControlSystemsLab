function isSpike = computeSpikes(EEGVal, threshold)
if(EEGVal < -1 * threshold)
    isSpike = 1;
else
    isSpike = 0;
end
end

% Finds threshold with min distance from 1 TPR and 0 FPR.
function [dist, index] = optimizeROC(FPR, TPR)
FPRdist = FPR.^2;
TPRdist = (1 - TPR).^2;
distance = sqrt(FPRdist + TPRdist);
[dist, index] = min(distance);
end
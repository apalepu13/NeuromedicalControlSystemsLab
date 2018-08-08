%Determines the FPR and TPR based on number of true/false positive/negative
function [FPRout, TPRout] = generateROC(evalStats) 
FPRout = evalStats(1, 2) / (evalStats(1, 2) + evalStats(1, 4));
TPRout = evalStats(1, 1) / (evalStats(1,1) + evalStats(1,3));
end
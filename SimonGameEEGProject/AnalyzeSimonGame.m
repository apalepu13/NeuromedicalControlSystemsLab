clearvars();
load('Data/times.mat');
load('Data/resp.mat');
load('Data/trigger.mat');
load('IISResults.mat');

%Look at all responses
%times make sense now: 7, 5, 7, 5, 7, 5, 7, delay, recall, delay, recall,
%delay, baseline,... 
%need to understand how "resp" fits in. 
%check if response is occuring near a spike
%1 by 4 array
%1, 1 = not near spike, wrong response
%1, 2 = not near spike, right response
%1, 3 = near spike, wrong respones
%1, 4 = near spike, right response
%compare these!
%Things to figure out: what does "near spike" mean.
%How to compare. Just the ratios? is there better test to see if results
%are stat. significant
ResponseResults = zeros(size(resp));
for i = 1: size(resp, 2)
    count = 0;
    if (resp(1, i) == 1)
        count = count + 1;
    end
    respTime = times(12*i-1, 1);
    add = 0;
    for spike =  1: size(spikeListings, 2)
        if (abs(respTime - spikeListings(2, spike)*1000)) < 5000
            add = 2;
        end
    end
    count = count + add;
    ResponseResults(1, i) = count;
end
            
     
        
        
    
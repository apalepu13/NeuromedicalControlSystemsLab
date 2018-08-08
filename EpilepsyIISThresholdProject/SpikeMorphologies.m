clearvars;
load('EEG.mat');
figure(3);
for i = 1: size(m, 1)
    for j = 1: size(m, 2) - 10
        m2(i, j) = mean(m(i, j:j+10));
    end
end
for i = 1: size(m, 1)
    plot([1:641], (m(i, :))); 
    pause;
end

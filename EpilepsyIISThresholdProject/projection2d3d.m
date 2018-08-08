%this script takes in a matrix of data and plots in 2D and 3D PC space
 
%inputs: M = matrix of data. Rows are each data vector (observation) and
%columns are features of each data vector.
clearvars;
load('EEG.mat');
m = spikes;
[coeff,score,latent] = pca(m);
M3D = m*coeff(:,1:3);
bad = [];
for i = 1: size(m, 1)
    for j = 1: 3
        if abs(M3D(i, j)) > 50
            bad(end+1) = i;
            break;
        end
    end
end
m(bad, :) = [];
[coeff,score,latent] = pca(m);

            
%2D projection
M2D = m*coeff(:,1:2);
figure(1)
clf
scatterplot(M2D)
 
%2D projection
M3D = m*coeff(:,1:3);
figure(2)
clf
scatter3(M3D(:, 1), M3D(:, 2), M3D(:, 3))
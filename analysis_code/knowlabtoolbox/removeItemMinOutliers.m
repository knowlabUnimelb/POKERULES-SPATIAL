function [data, n] = removeItemMinOutliers(data, cols, n, minrt)

% Remove trials less than min RT
minRTidx = find(data(:,strcmp(cols, 'rt')) <= minrt);
n.minRTs = numel(minRTidx);
data(minRTidx, :) = [];



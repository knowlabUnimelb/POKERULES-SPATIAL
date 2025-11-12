function [data, n] = removeLastPercentileRTs(data, cols, cutoffPercentiles, n)

% cutoffPercentiles - Throw out anything greater than this prctile 
% (if 100 then don't throw out anything)
% This is useful for getting rid of extremely long RTs if the P, 
% for instance, took a phonecall or fell asleep

idxTooLong = find(data(:,strcmp(cols, 'rt')) > prctile(data(:,strcmp(cols, 'rt')), cutoffPercentiles));
data(idxTooLong, :) = []; % Delete long RTs
n.RemovedLongRTs = numel(idxTooLong);

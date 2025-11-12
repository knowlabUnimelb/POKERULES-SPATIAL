function [data, n] = removeTimeouts(data, cols, n)

idx9 = find(data(:,strcmp('acc', cols)) == 9); % Remove timeouts
data(idx9,:) = []; % Delete timeouts

n.Timeouts = numel(idx9);

n.nanRTs = sum(isnan(data(:,strcmp('rt', cols))));
data(isnan(data(:,strcmp('rt', cols))), :) = []; % Delete nans

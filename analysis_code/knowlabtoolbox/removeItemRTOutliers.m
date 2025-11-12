function [data, n] = removeItemRTOutliers(data, cols, n, removeOutliers)

% Remove trials greater than three times the std + mean for correct trials
itemMeans = aggregate(data(data(:,strcmp(cols, 'acc')) == 1, :),...
    find(strcmp(cols, 'itm')), find(strcmp(cols, 'rt')), @mean, 1);

itemStd = aggregate(data(data(:,strcmp(cols, 'acc')) == 1, :),...
    find(strcmp(cols, 'itm')), find(strcmp(cols, 'rt')), @std, 1);

outlierRTs = itemMeans + 3 * itemStd;  
outlierVec = outlierRTs(data(:,strcmp(cols, 'itm')));
outlierIdx = find(data(:,strcmp(cols, 'rt')) > outlierVec & data(:,strcmp(cols, 'acc')) == 1);
outlierTags = zeros(size(data, 1), 1);
outlierTags(outlierIdx) = 1;

if removeOutliers

    n.outlierRTsRemovedPerItem = aggregate([data(:,strcmp(cols, 'itm')), outlierTags], 1, 2, @sum, 1)';
    n.totalOutlierRTs = sum(n.outlierRTsRemovedPerItem);

    data(outlierIdx) = [];

else
    n.outlierRTsRemovedPerItem = zeros(1, numel(unique(data(:,strcmp(cols, 'itm')))));
    n.totalOutlierRTs = sum(n.outlierRTsRemovedPerItem);
end
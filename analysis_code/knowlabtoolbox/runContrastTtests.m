function ttests = runContrastTtests(data, cols, channelCodes, anovaTable)

anovadata = data(:, [find(strcmp('sub', cols)), find(strcmp('ses', cols)), find(strcmp('itm', cols)), find(strcmp('rt', cols))]);
anovadata(:,5:6) = channelCodes(data(:,strcmp(cols, 'itm')), :);

itemComparisons = [5 6; 7 8; 5 9; 6 9; 7 9; 8 9];
for icIdx = 1:size(itemComparisons, 1)
    item1 = anovadata(ismember(anovadata(:,3), itemComparisons(icIdx,1)), 4);
    item2 = anovadata(ismember(anovadata(:,3), itemComparisons(icIdx,2)), 4);
    [h, ttestp, ci, stats]= ttest2(item1, item2);
    if strcmp(anovaTable, 'on')
        fprintf('Contrast category comparison - item %d vs item %d: t(%d) = %6.2f, p = %3.3f\n',  itemComparisons(icIdx, 1), itemComparisons(icIdx, 2), stats.df, stats.tstat, ttestp);
    end
    ttests{icIdx, 1} = sprintf('Contrast category comparison - item %d vs item %d: t(%d) = %6.2f, p = %3.3f',  itemComparisons(icIdx, 1), itemComparisons(icIdx, 2), stats.df, stats.tstat, ttestp);
end
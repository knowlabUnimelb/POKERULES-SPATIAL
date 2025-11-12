function [data, cols, n] = addBlockColumn(data, cols, n)


nTrialsPerBlock = n.TrialsPerBlock * ones(1, n.BlocksPerSession);
nTrialsPerBlock(1) = nTrialsPerBlock(1) + n.PracticeTrials; 

nTrialsPerBlock = repmat(nTrialsPerBlock, 1, n.Sessions); % Duplicate number of trials per block across sessions

blocks = 1:((size(data, 1)/n.Sessions - n.PracticeTrials)/45); % Number the blocks
blocks = repmat(blocks, 1, n.Sessions);                   % Replicate blocks across sessions

% Add in block column to data file
sessionblocks = [];
for i = 1:numel(blocks)
    sessionblocks = [sessionblocks; ones(nTrialsPerBlock(i), 1) * blocks(i)];
end
data   = [data(:,1:4), sessionblocks,  data(:, 5:end)];
cols = [cols(1:4), 'blk', cols(5:end)]; % Add to col names
function outdata = removeFirstNTrials(data, cols, n)

% Remove first 9 trials regardless of whether they are experimental or
% practice trials
nTrialsToRemove = 9;

% set up removal vector
sessions = unique(data(:,strcmp(cols, 'ses')));
outdata = [];
for i = 1:n.Sessions
    tempdata = data(data(:,strcmp(cols, 'ses')) == sessions(i), :);
    outdata = [outdata; tempdata((nTrialsToRemove+1):end, :)];
end
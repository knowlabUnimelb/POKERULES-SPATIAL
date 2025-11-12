function data = readSubjectSessionData(datalocation, dataformat, dataPrefix, conNumber, subjectNumber, sessionNumbers)

% Read data
data = [];
for i = 1:numel(sessionNumbers)
    data = [data; 
        dlmread(fullfile(datalocation, sprintf(dataformat, dataPrefix, conNumber, subjectNumber, sessionNumbers(i))))];
end
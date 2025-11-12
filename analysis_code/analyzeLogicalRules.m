% Main logical rules analysis folder, interfaces with knowlab toolbox
%   Pokerules: does not remove outliers for each item based on long rts
%

%% Set up
clear all
clc
close all force hidden
addpath(genpath(fullfile(pwd, 'knowlabtoolbox')))

%% Check each of these settings before you run the analysis
projectFolder = fileparts(pwd);
datafolder = fullfile(projectFolder, 'data');

conditionFolders = {'exp1_adjacent', 'exp1_overlapped', 'exp1_separated', 'exp2_separated1', 'exp2_overlapped_shorter_line', 'exp2_separated8'};
dataPrefix   = '2015_PokeRules_v1';                                        % String at the beginning of data file
dataformat   = '%s_%d_%03d_%d.dat';                                        % Format for datafile name; first string is dataPrefix
RanalysisFolder = fullfile(pwd, 'RanalysisFiles');                         % Folder to create Ranalysis files in
dimensions = {'Ori', 'Sat'};                                             % Specify descriptive names for your dimensions

cols = {'sub', 'con', 'rot', 'ses', 'tri', 'itm', 'ori', 'sat', 'rsp', 'cat', 'acc', 'rt'}; % Data file column names (some columns are necessary: 'sub', 'itm', 'acc', 'rt' 

%% Subject specific information
% List each subject number separately in subjectNumbers, with corresponding
% condition and session numbers in 'conditionNumbers' and 'sessions'
% Change the variable called sidx (subject index) to change which subject
% is analysed

% Subject index
si = 25; % which subject to analyse? [Must correspond to the entry in subjectNumber variable]

subjectNumbers   = [103, 104, 106, 107, 108,...     % 1-5 Adjacent
                    203, 204, 208, 209, 210,...     % 6-10 Overlapped
                    303, 304, 305, 306, 307,...     % 11-15 Separated (1, bar)
                    402, 403, 407, 408, 409,...     % 16-20 Separated A ( 1, no bar)
                    501, 502, 503, 504, 505,...     % 21-25 Overlapped shorter line (originally 501, 503, 504, 505, 506 but 506 has SD violations) 
                    604, 606, 608, 609, 610];       % 26-30 Separated B(8, no bar) List of subject numbers

conditionNumbers = [1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6];   % List of condition nubmers corresponding to subjects

sessions         = {2:9, 2:9, 2:9, 2:9, 2:9,...
                    2:9, 2:9, 2:9, 2:9, 2:9,...
                    2:9, 2:9, 2:9, 2:9, 2:9,...
                    2:9, 2:9, 2:9, 2:9, 2:9,...
                    2:9, 2:9, 2:9, 2:9, 2:9,...
                    2:9, 2:9, 2:9, 2:9, 2:9}; % List of sessions for each subject. You can set this to more than one session by stating: 2:5

datalocation = fullfile(datafolder, conditionFolders{conditionNumbers(si)}); % Location folder of datafiles
modelingFileFolder = fullfile(projectFolder, 'modelling_code', 'data');                          % Folder to create modeling files in 

%% Experiment specific information
n.PracticeTrials   = 9;
n.TrialsPerBlock   = 45;
n.BlocksPerSession = 10;

%% Other settings
minrt = 200;   % Minimum RT cutoff 200ms 
maxrt = 3000;  % Maximum RT cutoff

ploton      = true;  % Set to true to display plots
runStats    = true;  % Set to true to run ANOVA and t-tests for target and contrast, respectively
anovaTable  = 'off';  % Set to true display the ANOVA table
addBlockCol = true;  % Set to true if a block column is not already part of the data file
isRTinMsec  = false; % Set to true if RTs are stored in msecs 
newfig      = false; % Set to true to plot each figure in a separate window (false will plot all to a single window)
generateDataForRsftPackage = false; % generate a data file that can be loaded into R for analysis using the sft package

stype = 'empirical'; % Survivor function type
% set to 'kaplan' to use censored survivor functions, set to 'empirical' to use empirical histograms
% In most cases, particularly when the error for *each item* is low, we
% want to use the emprical survivor functions. Under some circumstances,
% when error rates are high, it may be useful to use the kaplan-meyer censored survivor
% functions. The properties of the censored functions are not
% well-understood in how they relate to SFT yet

channelCodes = [2 2; 2 1; 1 2; 1 1; 2 -1; 1 -1; -1 2; -1 1; -1 -1; -2 -2; -2 -3; -3 -2; -3 -3];
%               HH;  HL;  LH;  LL;  Ex;  Ix;    Ey;   Iy;   R;    other
% These correspond to items 1:9 (or 1:13 in the case of opplum)

%% RUN THE ANALYSIS - DO NOT CHANGE ANYTHING BELOW THIS LINE %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Select from lists
subjectNumber = subjectNumbers(si); 
conNumber     = conditionNumbers(si);
sessionNumbers = sessions{si};

%% Read the data from each session file
data = readSubjectSessionData(datalocation, dataformat, dataPrefix, conNumber, subjectNumber, sessionNumbers);
n.totalTrials = size(data, 1); 

%% Set up block column
n.Sessions = numel(sessionNumbers);
if addBlockCol; [data, cols, n] = addBlockColumn(data, cols, n); end

%% Remove practice trials
data = removeFirstNTrials(data, cols, n);
n.totalTrials = size(data, 1); 

%% Remove timeouts
[data, n] = removeTimeouts(data, cols, n);

%% Remove long RTs
% [data, n] = removeLongRTs(data, cols, maxrt, n);
[data, n] = removeLastPercentileRTs(data, cols, 99.9, n);

%% Remove short RTs - this is done later in the removeItemMinOutliers call
% [data, n] = removeShortRTs(data, cols, minrt, n);

%% Convert RTs to msecs if not already in secs
if ~isRTinMsec; data(:,strcmp(cols, 'rt')) = data(:,strcmp(cols, 'rt')) * 1000; end

%% Remove outliers for each item
[data, n] = removeItemMinOutliers(data, cols, n, minrt);
% Note: remember that we are NOT removing RTs greater than 3 x std for each
% item. This is preferable since we're modelling the data using contaminant
% models. 

removeOutliers = false; 
[data, n] = removeItemRTOutliers(data, cols, n, removeOutliers);

%% Build output matrix (used from Fific2010 to Little2013)
% fprintf('Mean Correct RTs, Mean Error RTs, and Error Rates\n')
output = generateOutputMatrix(data, cols, n);

%% Save modelling data file (ce = correct and error data) to modelling folder
cedata = sortrows(data, find(strcmp(cols, 'itm'))); % The experiment code will be looking for cedata
ceDatafileName = fullfile(modelingFileFolder, sprintf('s%d_cedata.mat', subjectNumber));
if exist(ceDatafileName, 'file') ~= 2
    save(ceDatafileName, 'cedata') % Save matfile for model fitting
end
% clear cedata

%% Set up code for [R] analysis
if generateDataForRsftPackage
    rdata = generateRanalysisDataFile(data, cols, channelCodes);
    dlmwrite(fullfile(RanalysisFolder, sprintf('R_analysis_%s_%d.dat', dataPrefix, subjectNumbers(si))), rdata, 'delimiter', '\t')
end

%% Run ANOVA
if runStats
    anova = runANOVA(data, cols, channelCodes, dimensions, anovaTable);
end

%% Run ANOVA
if runStats
    ttests = runContrastTtests(data, cols, channelCodes, anovaTable);
end

%% Estimate CDFs for all items
mint = min([min(data(:,strcmp(cols, 'rt'))), 5]);
maxt = max(max(data(:,strcmp(cols, 'rt')))) + 300;
t = mint:10:maxt; % #### set t, time vector in msec (MIN : bin size : MAX)

[S, d, acc, ~] = computeSurvivors(data(:,mstrfind(cols, {'itm', 'acc', 'rt'})), stype, t);

%% Compute SICs
HH = d{1};   HL = d{2};   LH    = d{3};   LL    = d{4};
HHacc = acc{1}; HLacc = acc{2}; LHacc = acc{3}; LLacc = acc{4};
MIC = mean(LL) - mean(LH) - mean(HL) + mean(HH);
[sic, tcdf, tsf, tsic, sichi, siclo] = computeSIC(LL, LH, HL, HH, LLacc, LHacc, HLacc, HHacc, mint, maxt, [], stype);

%% Compute CCF
AH    = d{5};   AL    = d{6};   BH    = d{7};   BL    = d{8};
AHacc = acc{5}; ALacc = acc{6}; BHacc = acc{7}; BLacc = acc{8};
[ccf, ccf_H, tccf, ccfhi, ccflo] = computeCCF(AH, AL, BH, BL, AHacc, ALacc, BHacc, BLacc, mint, maxt);
ccfMean = nansum(exp(ccf_H));
Mccf = (ccfMean(1) - ccfMean(2)) + (ccfMean(3) - ccfMean(4));

%% Plot Target Category MICs
if ploton
    if newfig 
        plotMeans(d, dimensions, newfig, 1, 2, 1)
    else
        figure('WindowStyle', 'docked')
        plotMeans(d, dimensions, newfig, 3, 2, 1)
    end
    plotSurvivors(tsic, tsf, mint, maxt, newfig, 3, 2, 3)
    plotSIC(tsic, sic, sichi, siclo, mint, maxt, MIC, newfig, 3, 2, 5)

    plotConflictSurvivors(tccf, exp(ccf_H), mint, maxt, newfig, 3, 2, 4);
    plotCCF(tccf, ccf, ccfhi, ccflo, mint, maxt, Mccf, newfig, 3, 2, 6);
end

%% Plot for paper
figure('WindowStyle', 'docked')
set(gcf, 'Position', [1            1       1022.4          304])
plotMeans(d, dimensions, newfig, 1, 2, 1);

h = get(gcf, 'Children');
cla(h(4))
plotSIC(tsic, sic, sichi, siclo, mint, maxt, MIC, newfig, 1, 2, 1)        
delete(h(3))
delete(findall(findall(h(2),'Type','axe'),'Type','text'))
% set(get(h(4), 'Title'), 'Position', [1319.1 -0.27009 0])
ylims = get(gca,'YLim');
set(get(h(4), 'Title'), 'Position', [maxt-550, ylims(1)+.05, 0])

xl = [0, round(maxt/100)*100];
set(h(4), 'XLim', [xl(1), xl(2)], 'XTick', linspace(xl(1), xl(2), 5), 'XTickLabel', round(linspace(xl(1), xl(2), 5)))
xlabel(h(2), 'Contrast Category Item')
ylabel(h(2), 'Mean RT (msec)')

%% Recreate the SFT toolbox in Matlab
siDom_result = siDominance(HH, HL, LH, LL); % First 4 should be significant, last 4 nonsignificant
sic_result = sictest(HH, HL, LH, LL, sic);

%% Set up data for JASP analysis
jaspFileLocation = fullfile(pwd, 'jaspFiles');
jaspTtestFileName = fullfile(jaspFileLocation, sprintf('subject%03d_ttest_%d.csv', subjectNumber, conNumber));
jaspANOVAFileName = fullfile(jaspFileLocation, sprintf('subject%03d_ANOVA.csv', subjectNumber));
jaspCEmeanFileName = fullfile(jaspFileLocation, sprintf('subject%03d_meanceRT.csv', subjectNumber));

jaspData = data;
jaspData(jaspData(:,strcmp(cols, 'acc')) == 0, strcmp(cols, 'rt')) = NaN; % Replaces all error RTs with NaNs to maintain vector size

% % Transform data so that RTs for all items are now in columns
maxcount = max(aggregate(jaspData, find(strcmp(cols, 'itm')), find(strcmp(cols, 'itm')), @count, 1)); 

jHH = jaspData(jaspData(:,strcmp(cols, 'itm'))==1, strcmp(cols, 'rt')); % Extracts the RTs for all items with the item code 1 (i.e., the HH item)
jHL = jaspData(jaspData(:,strcmp(cols, 'itm'))==2, strcmp(cols, 'rt'));
jLH = jaspData(jaspData(:,strcmp(cols, 'itm'))==3, strcmp(cols, 'rt'));
jLL = jaspData(jaspData(:,strcmp(cols, 'itm'))==4, strcmp(cols, 'rt'));
jEx = jaspData(jaspData(:,strcmp(cols, 'itm'))==5, strcmp(cols, 'rt')); 
jIx = jaspData(jaspData(:,strcmp(cols, 'itm'))==6, strcmp(cols, 'rt'));
jEy = jaspData(jaspData(:,strcmp(cols, 'itm'))==7, strcmp(cols, 'rt'));
jIy = jaspData(jaspData(:,strcmp(cols, 'itm'))==8, strcmp(cols, 'rt'));

% pad with nan
itemRTs = [[jHH; nan(maxcount-numel(jHH), 1)],...
           [jHL; nan(maxcount-numel(jHL), 1)],...
           [jLH; nan(maxcount-numel(jLH), 1)],...
           [jLL; nan(maxcount-numel(jLL), 1)],...
           [jEx; nan(maxcount-numel(jEx), 1)],...
           [jIx; nan(maxcount-numel(jIx), 1)],...
           [jEy; nan(maxcount-numel(jEy), 1)],...
           [jIy; nan(maxcount-numel(jIy), 1)]];

itemRTs = [itemRTs, itemRTs(:, 5) - itemRTs(:,6), itemRTs(:, 7) - itemRTs(:,8)];

% Add item name headings to the RT data for Bayesian t tests and write to a .csv file
tTesttable = array2table(itemRTs); % Converts array of item RTs to a tabular format
tTesttable.Properties.VariableNames = {'HH', 'HL', 'LH', 'LL', 'Ex', 'Ix', 'Ey', 'Iy', 'Ex-Ix', 'Ey-Iy'}; % Adds column headings to the tables


% Extract all rows from the full dataset that correspond to target category items for the Bayesian ANOVA
% ANOVAdata = jaspData(jaspData(:,strcmp(cols, 'itm')) <= 4, :);
ANOVAdata = jaspData(jaspData(:,strcmp(cols, 'itm')) <= 4 & jaspData(:,strcmp(cols, 'acc')) == 1, :);

% Dummy code ori (310, 330) and sat (10, 14)
orivals = unique(ANOVAdata(:,strcmp(cols, 'ori')));
satvals = unique(ANOVAdata(:,strcmp(cols, 'sat')));

ANOVAdata(ANOVAdata(:,strcmp(cols, 'ori')) == orivals(1), strcmp(cols, 'ori')) = 0;
ANOVAdata(ANOVAdata(:,strcmp(cols, 'ori')) == orivals(2), strcmp(cols, 'ori')) = 1;
ANOVAdata(ANOVAdata(:,strcmp(cols, 'sat')) == satvals(1), strcmp(cols, 'sat')) = 0;
ANOVAdata(ANOVAdata(:,strcmp(cols, 'sat')) == satvals(2), strcmp(cols, 'sat')) = 1;

% Add headings to the columns in the target category dataset for Bayesian ANOVA and write to .csv file
ANOVAtable = array2table(ANOVAdata);
ANOVAtable.Properties.VariableNames = cols; %Contains a duplicated block column because of the way the toolbox analyses were programmed

if exist(jaspTtestFileName, 'file') ~= 2
    writetable(tTesttable, jaspTtestFileName); % Writes table as a .csv that can be opened in JASP/Jamovi
end
if exist(jaspANOVAFileName, 'file') ~= 2
    writetable(ANOVAtable, jaspANOVAFileName); % Writes table as a .csv that can be opened in Jamovi
end

%% Report results
items = 1:9;
acc = 1-aggregate(cedata, mstrfind(cols, {'itm'}), mstrfind(cols, {'acc'}), @(x)(round(nanmean(x), 2)), 1);
crt = fillMissingCounts(aggregate(cedata(cedata(:,strcmp(cols, 'acc')) == 1, :), mstrfind(cols, {'itm'}), mstrfind(cols, {'rt'}), @(x)(round(nanmean(x))), 0), 1:9);
ert = fillMissingCounts(aggregate(cedata(cedata(:,strcmp(cols, 'acc')) == 0, :), mstrfind(cols, {'itm'}), mstrfind(cols, {'rt'}), @(x)(round(nanmean(x))), 0), 1:9);
meanResults = [items; crt(:,2)'; ert(:,2)'; acc']

anova.t2

ttests

sic_result

siDom_result.p

% Uncomment to save files to load into jasp
% edit(fullfile(pwd, 'jaspFiles', sprintf('subject%03d_results_output.txt', subjectNumber)))

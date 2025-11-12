% 2014 Nov: Categorization experiment with using half-circles varying in
% saturation and line or orientation
%
% There are two categories defined as follows:
%
% d23||	  x7 |	x3	   x1
%    ||      |      A
% d22||	  x8 |	x4	   x2
%    ||       ---------------
% d21||	  x9	x6	   x5
%    || B
%     =========================
% 	     d11	d12	   d13
%
% d1 = orientation (low, medium, high)
% d2 = saturation  (high, medium, low)
% Stimulus numbering is based on the Fific, Little & Nosofsky paper
%
% Testing is over 8 sessions. The first session is solely used to increase
% accuracy to the correct level. In sessions 2-8, RT is recorded and
% participants are instructed to maintain high accuracy but to respond as
% soon as they know the answer.
%
% 150426 - Random number seed check: prior to this date seeded as: rand('state', seed + subject * 2)
%        - set session to 0 to recover sessions prior to this date

%% Set up testing

clear all % Clear workspace
clc       % Clear the screen

xup = -50; xleft = -18;                      % Center of screen offsets for showtext
bgcolor = [200 200 200];                     % User specified background color
multisamples = [];

addpath(genpath(fullfile(pwd, 'USTCRTBox_002')))

%% Experimental Variables
seed = 60872; % Seed for random number generator

feedback = {'...Wrong...', '...Correct...'}; % Feedback for an incorrect (0) and correct (1) response

timeout   = 5;   % Max response time
textsize  = 60;  % Text size
stimsize  = 100; % Stimulus size (height and width of circumscribing rectangle)
fixsize   = 50;  % Height and width of fixation cross (in pixels)
lineWidth = 5;   % Pixel width

fixationDuration = 1.5;   % Fixation cross presentation length (1.5 secs)
fbkDuration      = 2;     % Feedback presentation length
iti              = 1.5;   % Intertrial interval

stimuli = [3 3; 3 2; 2 3; 2 2; 3 1; 2 1; 1 3; 1 2; 1 1]; % matrix of x and y indexes (in the canonical numbering order)
nstimuli = size(stimuli, 1);

switch debug % Reduce the number of trials for debugging
    case true
        nPracTrials = 0;                      % Number of practice trials = 0 (9 stimuli x 0)
        nExpTrials  = 27;                     % Number of experimental trials = 9 stimuli x 1 reps * 3 blocks = 27
        nBlocks = 3;                          % Number of blocks = 3
        nTrialsPerBlock = nExpTrials/nBlocks; % Number of trials per block = 9
    case false
        nPracTrials = 9;                      % Number of practice trials = 9 (9 stimuli x 1)
        nExpTrials  = 450;                    % Number of experimental trials = 9 stimuli x 5 reps x 10 blocks = 450
        nBlocks = 10;                         % Number of blocks = 10
        nTrialsPerBlock = nExpTrials/nBlocks; % Number of trials per block = 45
end

%% OPEN EXPERIMENTAL WINDOW
% Present subject information screen until correct information is entered
subject     = input('Enter Subject Number [101-603]:');
session     = input('Enter Session Number [1-9]:');
condition   = input('Enter Condition Number [1 = adjacent, 2 = overlapped, 3 = separated, 4 = sep no bar, 5 = overlap short line, 6 = sep nb wide gap]:');

rotation  = 1; % boundary rotation (i.e., from the canonical location) {'0', '90', '180', '270'} - currently does nothing
outputfile = sprintf('2015_PokeRules_v1_%d_%03d_%d.dat', condition, subject, session);
rng(seed + subject * 2 + session, 'twister')

screenparms = prepexp(0, bgcolor, [], multisamples); % Open onscreen window at given background color

%% STIMULUS VARIABLES
switch condition 
	case 1
		featureSeparation = 0; % Pixel separation between top and bottom arcs (set to -1 to overlap features at top)
	case 2
		featureSeparation = -1; % Pixel separation between top and bottom arcs (set to -1 to overlap features at top)
	case 3
		featureSeparation = 45; % Pixel separation between top and bottom arcs (set to -1 to overlap features at top)
    case 4
		featureSeparation = 45; % Pixel separation between top and bottom arcs (set to -1 to overlap features at top)
    case 5
		featureSeparation = -1; % Pixel separation between top and bottom arcs (set to -1 to overlap features at top)
    case 6
		featureSeparation = 350; % Pixel separation between top and bottom arcs (set to -1 to overlap features at top)
end

orientation = [300 310 330]';  % levels of orientation (for output file)
% ptbOrientation   = mod(360 - orientation + 90, 360); % PTB measures in clockwise from vertical so transform the angles

saturation = [16 14 10]';        % levels of saturation (for output file)

colors = nan(numel(saturation), 3); % Preallocate matrix
for i = 1:numel(saturation)
    colors(i,:) =  munsell2rgb('5R', 5, saturation(i)); % RGB values for hue 5R, brightness 5, saturation defined above
end

feedbackprobs(:,1) = [1 1 1 1 0 0 0 0 0]'; % P(A|stimulus i)
feedbackprobs(:,2) = [0 0 0 0 1 1 1 1 1]'; % P(B|stimulus i)

%% LOAD STIMULI INTO TEXTURES
ProgBar = DrawProgressBar(screenparms, nstimuli, 'Generating Stimuli');  % Initialize progress bar on screen
Screen('Flip', screenparms.window);                                              % Flip screen

stimRect = [0 0 stimsize stimsize];
[stimTopRectLoc, ~, ~] = CenterRect(stimRect, screenparms.rect);
[stimBotRectLoc, ~, ~] = CenterRect(stimRect, screenparms.rect);

% Separate rectangles by featureSeparation amount
stimTopRectLoc = stimTopRectLoc - [0 featureSeparation*(featureSeparation > 0) 0 featureSeparation*(featureSeparation > 0)]./2;
stimBotRectLoc = stimBotRectLoc + [0 featureSeparation*(featureSeparation > 0) 0 featureSeparation*(featureSeparation > 0)]./2;

stimTopRectLoc = round(stimTopRectLoc);
stimBotRectLoc = round(stimBotRectLoc);

stimTopRectVerticalMidpoint = stimTopRectLoc(RectTop) + RectHeight(stimTopRectLoc)/2;
stimBotRectVerticalMidpoint = stimBotRectLoc(RectTop) + RectHeight(stimBotRectLoc)/2;

% Find coordinates of line on circle
if ismember(condition, [5])
    r = stimsize/3;                   % Radius of circle
else 
    r = stimsize/2;
end
    
[a, b] = RectCenter(stimTopRectLoc); % Center coordinates of circle
x = nan(numel(orientation), 1);
y = nan(numel(orientation), 1);
for i = 1:numel(orientation)
    theta = radians(orientation(i));
    x(i) = a + r * cos(theta);
    y(i) = b + r * sin(theta);
end

stimTexture     = cell(nstimuli,1);                                        % Initialize stimulus texture matrix]
stimmat         = cell(nstimuli, 1);
for i = 1:nstimuli                                                         % Cycle through stimuli
    [offScreenWindow, ~] = Screen('OpenOffscreenWindow', screenparms.window, screenparms.color, screenparms.rect); % Open an offscreen window to create the stimuli

    if featureSeparation < 0
        Screen('FillArc', offScreenWindow, colors(stimuli(i,2),:), stimTopRectLoc, 270, 180)         % Draw an arc in the appropriate saturation color at the bottom of the circle
    else
        Screen('FillArc', offScreenWindow, colors(stimuli(i,2),:), stimBotRectLoc, 90, 180)         % Draw an arc in the appropriate saturation color at the bottom of the circle
    end
    Screen('FrameArc', offScreenWindow, screenparms.black, stimBotRectLoc, 90, 180, lineWidth, lineWidth) % Frame an arc in black at the bottom of the circle    
    
    
    Screen('DrawLine', offScreenWindow, screenparms.black, stimBotRectLoc(RectLeft), stimBotRectVerticalMidpoint, stimBotRectLoc(RectRight), stimBotRectVerticalMidpoint, lineWidth) % Draw midpoint line for bottom arc
   
    
    if ~ismember(condition, [1 2 4 6])
        Screen('DrawLine', offScreenWindow, screenparms.black,...
        stimTopRectLoc(RectLeft) + RectWidth(stimTopRectLoc)/2, stimTopRectVerticalMidpoint,...
        stimTopRectLoc(RectLeft) + RectWidth(stimTopRectLoc)/2, stimBotRectVerticalMidpoint, lineWidth);
    end
    
    Screen('BlendFunction', offScreenWindow , GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('DrawLines', offScreenWindow, [a, x(stimuli(i,1)); b y(stimuli(i,1))], lineWidth, screenparms.black, [], 1) % Draw an oriented line
    Screen('FrameArc', offScreenWindow, screenparms.black, stimTopRectLoc, 270, 180, lineWidth, lineWidth) % Frame an arc in black at the top of the circle              
    Screen('DrawLine', offScreenWindow, screenparms.black, stimTopRectLoc(RectLeft), stimTopRectVerticalMidpoint, stimTopRectLoc(RectRight), stimTopRectVerticalMidpoint, lineWidth) % Draw midpoint line for top arc

    
    stimmat{i} = Screen('GetImage', offScreenWindow, screenparms.rect);       % Get the image matrix from the offscreen window
    stimTexture{i} = Screen('MakeTexture', screenparms.window, stimmat{i});   % Make a texture with the current image
    Screen('Close', offScreenWindow);
    
    FillScreen(screenparms)
    ProgBar(i); Screen('Flip', screenparms.window); % Update the progress bar
end

fixcrossH = CenterRect([0 0 fixsize 1], screenparms.rect);
fixcrossV = CenterRect([0 0 1 fixsize], screenparms.rect);

%% PRESENT INSTRUCTIONS
% Instructions need to be created in powerpoint and then the relevant
% slides saved as bmp's with the names corresponding to the names below
instructionFolder    = 'Instructions';
trainingInstructions = {'PokeRules_Instructions.bmp', sprintf('PokeRules_Instructions%d.bmp', condition)};
showInstructions(screenparms, fullfile(pwd, instructionFolder, trainingInstructions{1}), 'RTBox')
showInstructions(screenparms, fullfile(pwd, instructionFolder, trainingInstructions{2}), 'RTBox')

breakImage = (fullfile(pwd, instructionFolder, 'Break.bmp'));
endImage = (fullfile(pwd, instructionFolder, 'Thanks.bmp'));

%% Run Experiment
priorityLevel = MaxPriority(screenparms.window,'WaitBlanking');        % Maximum priority available (always 1 for Linux)
breaktrials = nTrialsPerBlock * (1:nBlocks-1) + nPracTrials;
overallcorrect = []; % Preallocate 

for bblocks = 1:nBlocks % Loop through each block
    if bblocks > 1; nPracTrials = 0; end % On blocks subsequent to block 1, set the number of practice trials to 0
    nTpB = (nPracTrials + nTrialsPerBlock);
    
    % Preload random stimulus order
    pstimInOrder = repmat((1:nstimuli)', nPracTrials/nstimuli, 1);         % Create a vector of indices for each practice stimulus
    pcurrentStimulus = pstimInOrder(randperm(numel(pstimInOrder)));        % Randomize the order of the practice stimuli
    
    estimInOrder = repmat((1:nstimuli)', nTrialsPerBlock/nstimuli, 1);     % Create a vector of indices for each experimental stimulus (repeated the appropriate number of times)
    ecurrentStimulus = estimInOrder(randperm(numel(estimInOrder)));        % Randomize the experimental stimuli
    currentStimulus = [pcurrentStimulus; ecurrentStimulus];                % Combine the practice trial order than the experimental trial order
    
    % Preallocate variables for recording responses 
    response = nan(ceil(nPracTrials + nTrialsPerBlock),1);                 % vector to record responses on each trial 
    rt       = nan(ceil(nPracTrials + nTrialsPerBlock),1);                 % vector to record RTs on each trial
    categoryFlag = (feedbackprobs(currentStimulus,1) == 0) + 1;            % vector recording correct response on each trial
    correctFlag  = nan(ceil(nPracTrials + nTrialsPerBlock),1);             % vector to record accuracy on each trial
    
    % Cycle through trials
    trialcnt = 1; % Current trial for this block
    for i = 1:(nPracTrials + nTrialsPerBlock)
        
        % Display fixation cross
        Screen('DrawLine', screenparms.window, screenparms.black, fixcrossH(1), fixcrossH(2), fixcrossH(3), fixcrossH(4), lineWidth)
        Screen('DrawLine', screenparms.window, screenparms.black, fixcrossV(1), fixcrossV(2), fixcrossV(3), fixcrossV(4), lineWidth)
        Screen('Flip', screenparms.window); % Flip the fixation cross to the front buffer
        WaitSecs(fixationDuration); % Wait
        
        Priority(priorityLevel); % Set the priority level
        
        % Present stimulus until response
        Screen('DrawTexture', screenparms.window, stimTexture{currentStimulus(i,1)});
        
        % Present instructions (last two inputs manipulate location: first
        % is vertical offset (negative is above midline, positive is below
        % midline), second is horizontal offset (negative is left of
        % midline, positive is right of midline)
        
        showtext(screenparms, textsize/3, '(CATEGORY A)',                                     1, 350, -screenparms.rect(4)/4);
        showtext(screenparms, textsize/3, '(CATEGORY B)',                                    1, 350,  screenparms.rect(4)/4);
        
        RTBox('clear'); % clear RT box buffer and sync clocks before stimulus onset
        vbl = Screen('Flip', screenparms.window); % Flip the stimulus and instructions to the front buffer (track time)
        
        % Record response when a button is pressed (or timeout)
        [cpuTime, buttonPress] = RTBox(timeout);  % computer time of button response

        % Clear the screen
        FillScreen(screenparms); 
        Screen('Flip', screenparms.window); 
        
        % Save response
        if ~isempty(cpuTime) % If a response has been made
            cpuTime = cpuTime(1);
            rt(i, 1)   = (cpuTime - vbl); % The RT is cpuTime - vbl (in seconds)
        end
        
        % Save response
        if ismember(buttonPress, {'1', '2'})
            response(i, 1) = 1;
        elseif ismember(buttonPress, {'3', '4'})
            response(i, 1) = 2;
        end
        
        % Display feedback
        if response(i,1) == categoryFlag(i,1) && rt(i,1) < timeout         % If the response is correct and it's not a timeout
            correctFlag(i,1) = 1;                                          % ... save it

            % Clear the screen
            FillScreen(screenparms); 
            Screen('Flip', screenparms.window); 

        elseif response(i,1) ~= categoryFlag(i,1) && rt(i,1) < timeout     % If the response is incorrect and it's not a timeout
            correctFlag(i,1) = 0;                                          % ... save it
            showtext(screenparms, textsize, feedback{1}, 1, 0, 0);         % ... show some feedback
            
            % Flip the feedback to the front buffer
            Screen('Flip', screenparms.window); 
            WaitSecs(fbkDuration);
            
            % Clear the screen            
            FillScreen(screenparms); 
            Screen('Flip', screenparms.window); 
        else                                                               % Otherwise, it's a timeout
            correctFlag(i,1) = 9;                                          % Tag the response as a timeout
            showtext(screenparms, textsize, 'Too Slow!', 1, 0, 0);         % ... show some feedback
            
            % Flip the feedback to the front buffer
            Screen('Flip', screenparms.window); 
            WaitSecs(fbkDuration);
            
            % Clear the screen
            FillScreen(screenparms); 
            Screen('Flip', screenparms.window); 
        end
        WaitSecs(iti);
        Priority(0);                                                       % Reset the priority
        
        %% Take a break
        if ismember(trialcnt, nPracTrials)                                 % When there is a practice trial
            
            showtext(screenparms, 20, 'Press any button to start experimental trials', 1, 0, 0); % Show some instructions to advance after the break
            Screen('Flip', screenparms.window);                                                  % Flip these to the front buffer
            
            RTBox('clear');                                                % clear buffer and sync clocks before stimulus onset
            while ~any(RTBox('ButtonDown')); WaitSecs(0.01); end           % Wait for any button press
            
            Screen('Flip', screenparms.window);                            % Clear the screen after a button press
            
        elseif ismember(trialcnt, nTpB)                         % Or if it's a breaktrial
            showtext(screenparms, 20, 'Take a short break. Press any button to continue', 1, 0, 0); % Show some instructions to advance after the break
            
            % Compute accuracy on current block
            if bblocks == 1; blkcorrect = correctFlag(nPracTrials+1:end,1); else blkcorrect = correctFlag; end % Ignore any practice trials
%             nblk = numel(blkcorrect);
            blkcorrect(isnan(blkcorrect),:) = [];                          % Remove any nan's
            blkcorrect(blkcorrect == 9,:)   = [];                          % Remove any timeouts
            nblk = numel(blkcorrect);
            blkpercent = 100 * sum(blkcorrect)/nblk;                       % Compute accuracy percentage
            
            showtext(screenparms, 20, sprintf('Accuracy = %4.2f percent correct in last block', blkpercent), 1, 100, 0); % Show the accuracy percentage
            Screen('Flip', screenparms.window); 
            
            RTBox('clear');                                                % Clear buffer and sync clocks before stimulus onset
            while ~any(RTBox('ButtonDown')); WaitSecs(0.01); end           % Wait for any button press
            
            Screen('Flip', screenparms.window);                            % Clear the screen after a button press
        end
        
        trialcnt = trialcnt + 1; % Keep track of the current trial
    end
    overallcorrect = [overallcorrect; blkcorrect]; % Append the block data 

    %% Save output
    output = [...                                       % Output columns:   
        repmat(subject, trialcnt-1,1),...               % Subject number
        repmat(condition, trialcnt-1, 1),...            % Condition number
        repmat(rotation, trialcnt-1, 1),...             % Rotation number        
        repmat(session, trialcnt-1,1),...               % Session number
        (1:trialcnt-1)',...                             % Trial number
        currentStimulus,...                             % Stimulus Index number
        orientation(stimuli(currentStimulus,1)),...     % Orientation level
        saturation(stimuli(currentStimulus,2)),...      % Saturation level
        response,...                                    % Response
        categoryFlag,...                                % Actual Category
        correctFlag,...                                 % Accuracy 
        rt];                                            % RT
    
    %% Save data on each block
    dlmwrite(outputfile, output, '-append');
end
showInstructions(screenparms, endImage, 'RTBox');                          % Show end of experiment instructions
closeexp(screenparms)                                                      % Close experiment

%% Check for bonus at the end of the experiment
overallAcc = sum(overallcorrect)./numel(overallcorrect);
fprintf('Overall Accuracy = %4.2f\n', overallAcc)
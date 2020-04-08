%% Define parameters
%
% Project: Emotion Discrimination Task, part of CWT
%
% Sets key parameters, called by main.m
%
% Niia Nikolova
% Last edit: 08/04/2020


%% Experimental design
% Design
vars.NLevels = 10;                                           % N stimulus levels (face morph)
vars.NTrials =  7;                                           % per morph level
vars.StimIDs = {'f06', 'f24', 'm08', 'm31'};                 % IDs of individuals in stimulus set
vars.NIndividuals = length(vars.StimIDs);                    % individuals
vars.NTrialsTotal = vars.NTrials * vars.NLevels * vars.NIndividuals;        % N total trials

% Task timing
vars.StimT = 1;      % sec
vars.RespT = 2;      % sec
vars.ConfT = 5;      % sec
vars.ITI_min = 1;    % variable ITI (1-2s)
vars.ITI_max = 2; 
vars.ITI = randInRange(vars.ITI_min, vars.ITI_max, [vars.NTrialsTotal,1]);

% Instructions
vars.InstructionTask = 'Decide if the face presented on each trial is angry or happy. \n \n ANGRY - Left arrow key                         HAPPY - Right arrow key \n \n \n \n Then, rate how confident you are in your choice using the number keys. \n \n Unsure (1), Sure (2), and Very sure (3). \n \n Press ''Space'' to start...';
vars.InstructionQ = 'Angry (L)     or     Happy (R)';
vars.InstructionConf = 'Rate your confidence \n \n Unsure (1)     Sure (2)     Very sure (3)';
vars.InstructionPause = 'Take a short break... \n \n When you are ready to continue, press ''Space''...';
vars.InstructionEnd = 'You have completed the session. Thank you!';
% N.B. Text colour and size are set after Screen('Open') call


%% Stimuli
% Stimuli
vars.TaskPath = fullfile('.', 'code', 'task');          % from \EmotionDiscriminationTask\
vars.StimFolder = fullfile('.', 'stimuli', filesep);
vars.StimSize = 7;                                      % DVA                                      
vars.StimsInDir = dir([vars.StimFolder, '*.tif']);      % list contents of 'stimuli' folder      
% check if NFiles/Individual is the same
for thisIndiv = 1 : vars.NIndividuals                
    NStimsCheck(thisIndiv) = length(dir([vars.StimFolder, '*', vars.StimIDs{thisIndiv}, '*']));  end
if (range(NStimsCheck) ~= 0) || any(( NStimsCheck(:) ~= vars.NLevels))
    disp('Error!! Unequal number of stimulus files per individual, or expected number of files does not match NLevels. Download stimulus folder again. '); 
    return
end
% Generate repeating list - string array with filenames
vars.StimList = strings(length(vars.StimsInDir),1);
for thisStim = 1:length(vars.StimsInDir)
    vars.StimList(thisStim) = getfield(vars.StimsInDir(thisStim), 'name');
end
StimTrialList = repmat(vars.StimList,vars.NTrials,1);
% Randomize order of stimuli & move sequential duplicates                     
ntrials = length(StimTrialList);
randomorder = Shuffle(length(StimTrialList), 'index');   % Shuffle is faster than randperm
vars.StimTrialList = StimTrialList(randomorder);
for thisStim = 1:ntrials-1
    nextStim = thisStim+1;
    Stim_1 = vars.StimTrialList(thisStim);
    Stim_2 = vars.StimTrialList(nextStim);
    % if two stim names are identical, move Stim_2 down and remove row
    if strcmp(Stim_1,Stim_2)    
        vars.StimTrialList = [vars.StimTrialList; Stim_2];
        vars.StimTrialList(nextStim)=[];
    end
end

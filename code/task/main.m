function main(vars, scr)
%function main(vars, scr)
%
% Project: Emotion Discrimination Task, part of CWT
% Main experimental script
%
% Input: 
%   vars        struct with key parameters (most are deifne in loadParams.m)
%   scr         struct with screen / display settings
% 
% Niia Nikolova
% Last edit: 08/04/2020


% Load the parameters
loadParams;

% Results struct
DummyDouble = ones(vars.NTrialsTotal,1).*NaN;
DummyString = strings(vars.NTrialsTotal,1);
Results = struct('trialN',{DummyDouble},'EmoResp',{DummyDouble}, 'ConfResp', {DummyDouble},...
    'EmoRT',{DummyDouble}, 'ConfRT', {DummyDouble},'trialSuccess', {DummyDouble}, 'StimFile', {DummyString},...
    'MorphLevel', {DummyDouble}, 'Indiv', {DummyString}, 'SubID', {DummyDouble});
% col_trialN = 1;
% col_EmoResp = 2;
% col_ConfResp = 3;
% col_EmoRT = 4;
% col_ConfRT = 5;
% col_trialSuccess = 6;
% col_StimFile = 7;
% col_MorphLevel = 8;
% col_Indiv = 9;
% col_subID = 10;


% Diplay configuration
[scr] = displayConfig(scr);

% Keyboard & keys configuration
[keys] = keyConfig();

% Reseed the random-number generator
SetupRand;


%% Prepare to start
AssertOpenGL;       % OpenGL? Else, abort
HideCursor;

try
    %% Open screen window
    [scr.win, scr.winRect] = PsychImaging('OpenWindow', scr.screenID, scr.BackgroundGray);
    PsychColorCorrection('SetEncodingGamma', scr.win, 1/scr.GammaGuess);
    Screen('TextSize', scr.win, scr.TextSize);
    
    % Set priority for script execution to realtime priority:
    scr.priorityLevel = MaxPriority(scr.win);
    Priority(scr.priorityLevel);
    
    % Determine stim size in pixels
    scr.dist = scr.ViewDist;
    scr.width  = scr.MonitorWidth;
    scr.resolution = scr.winRect(3);        % number of pixels of display in horizontal direction
    StimSizePix = angle2pix(scr, vars.StimSize);
    
    % Dummy calls to prevent delays
    ValidTrial = zeros(1,2);
    vars.RunSuccessfull = 0;
    WaitSecs(0.1);
    GetSecs;
    Resp = 888;
    ConfRating = 888;
    WaitSecs(0.500);
    [~, ~, KeyCode] = KbCheck;
    
    
    
    %% Show task istructions
    Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
    DrawFormattedText(scr.win, [vars.InstructionTask], 'center', 'center', scr.TextColour);
    [~, ~] = Screen('Flip', scr.win);
    
    while KeyCode(keys.Space) == 0
        [~, ~, KeyCode] = KbCheck;
        WaitSecs(0.001);
    end
    
    
    %% Run through trials
    
    % check that ntrials = expected Ntrials
    if ntrials == vars.NTrialsTotal
    else
        disp('#### Mismatch between expected number of trials and number of stimuli in text file!!! Download stimulus folder again... ####');
    end
    
    WaitSecs(0.500);            % pause before experiment start

    for thisTrial = 1:vars.NTrialsTotal
        
        %% Read in this image, adjust size and show stimulus
        % read stim image for this trial into matrix 'imdata':
        StimFilePath = strcat(vars.StimFolder,char(vars.StimTrialList(thisTrial)));
        ImDataOrig = imread(char(StimFilePath));
        StimFileName = char(vars.StimTrialList(thisTrial));
        ImData = imresize(ImDataOrig, [StimSizePix NaN]);           % Adjust image size to StimSize dva in Y dir
        
        % Update Results mat
        Results.trialN(thisTrial) = thisTrial;
        Results.StimFile(thisTrial) = StimFileName;
        Results.SubID(thisTrial) = vars.subNo;
        Results.Indiv(thisTrial) = StimFileName(8:10);
        Results.MorphLevel(thisTrial) = str2double(StimFileName(12:14));
        
        % Make texture image out of image matrix 'imdata'
        ImTex = Screen('MakeTexture', scr.win, ImData);
        
        % Draw texture image to backbuffer
        Screen('DrawTexture', scr.win, ImTex);
        [~, StimOn] = Screen('Flip', scr.win);
        
        % While loop to show stimulus until StimT seconds elapsed.
        while (GetSecs - StimOn) <= vars.StimT
            
            % KbCheck for Esc key
            if KeyCode(keys.Escape)==1
                % Save, mark the run
                vars.RunSuccessfull = 0;
                vars.DataFileName = ['Aborted_', vars.DataFileName];
                experimentEnd(vars, scr, keys, Results);
                return
            end
            
            [~, ~, KeyCode] = KbCheck;
            WaitSecs(0.001);
            
        end
        
        [~, ~] = Screen('Flip', scr.win);            % clear screen
        
        
        %% Show emotion prompt screen
        
        % Angry (L arrow) or Happy (R arrow)?
        Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
        DrawFormattedText(scr.win, [vars.InstructionQ], 'center', 'center', scr.TextColour);
        
        [~, StartRT] = Screen('Flip', scr.win);
        
        % loop until valid key is pressed or RespT is reached
        while ((GetSecs - StartRT) <= vars.RespT)
            
            % KbCheck for response
            if KeyCode(keys.Left)==1         % Angry
                % update results
                Resp = 0;
                ValidTrial(1) = 1;
            elseif KeyCode(keys.Right)==1    % Happy
                % update results
                Resp = 1;
                ValidTrial(1) = 1;
            elseif KeyCode(keys.Escape)==1
                % Save, mark the run
                Resp = 9;
                vars.RunSuccessfull = 0;
                vars.DataFileName = ['Aborted_', vars.DataFileName];
                experimentEnd(vars, scr, keys, Results);
                return
            else
                % ? DrawText: Please press a valid key...          
            end
            
            [~, EndRT, KeyCode] = KbCheck;
            WaitSecs(0.001);
            
            if(ValidTrial(1)), WaitSecs(0.2); break; end
        end
        
        % Compute response time
        RT = (EndRT - StartRT);                                 
        
        % Write trial result to file
        Results.EmoResp(thisTrial) = Resp;
        Results.EmoRT(thisTrial) = RT;
        
        %% Confidence rating
        % Rate your confidence: 1 Unsure, 2 Sure, 3 Very sure
        
        Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
        DrawFormattedText(scr.win, [vars.InstructionConf], 'center', 'center', scr.TextColour);
        [~, StartConf] = Screen('Flip', scr.win);
        
        % loop until valid key is pressed or ConfT is reached
        while (GetSecs - StartConf) <= vars.ConfT
            
            % KbCheck for response
            if KeyCode(keys.One)==1
                % update results
                ConfRating = 1;
                ValidTrial(2) = 1;
            elseif KeyCode(keys.Two)==1
                % update results
                ConfRating = 2;
                ValidTrial(2) = 1;
            elseif KeyCode(keys.Three)==1
                % update results
                ConfRating = 3;
                ValidTrial(2) = 1;
            elseif KeyCode(keys.Escape)==1
                % Save, mark the run                               
                ConfRating = 9;
                vars.RunSuccessfull = 0;
                vars.DataFileName = ['Aborted_', vars.DataFileName];
                experimentEnd(vars, scr, keys, Results);
                return
            else
                % DrawText: Please press a valid key...           
            end
            
            [~, EndConf, KeyCode] = KbCheck;
            WaitSecs(0.001);
            
            % If this trial was successfull, move on...
            if(ValidTrial(2)), WaitSecs(0.2); break; end
        end
        
        % Compute response time
        ConfRatingT = (EndConf - StartConf);                    
        
        % Write trial result to file
        Results.ConfResp(thisTrial) = ConfRating;
        Results.ConfRT(thisTrial) = ConfRatingT;
        
        % Was this a successfull trial? (both emotion and confidence rating valid)
        % 1-success, 0-fail
        Results.trialSuccess(thisTrial) = logical(sum(ValidTrial) == 2);
        
        
        %% ITI / prepare for next trial
        Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
        [~, StartITI] = Screen('Flip', scr.win);
        
        % Present the gray screen for ITI duration
        while (GetSecs - StartITI) <= vars.ITI(thisTrial)
            
            if KeyCode(keys.Escape)==1
                % Save, mark the run
                vars.RunSuccessfull = 0;
                vars.DataFileName = ['Aborted_', vars.DataFileName];
                experimentEnd(vars, scr, keys, Results);
                return
            end
        end
        
        [~, ~, KeyCode] = KbCheck;
        WaitSecs(0.001);
        
        % Reset Texture, ValidTrial, Resp
        ValidTrial = zeros(1,2);
        Resp = NaN;
        ConfRating = NaN;
        Screen('Close', ImTex);
        
        %% Break every ~5min (50 trials)
        if ~rem(thisTrial,50)
            % Gray screen - Take a short break and press 'space' to
            % continue
            Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
            DrawFormattedText(scr.win, vars.InstructionPause, 'center', 'center', scr.TextColour);
            [~, ~] = Screen('Flip', scr.win);
            
            while KeyCode(keys.Space) == 0
                [~, ~, KeyCode] = KbCheck;
                WaitSecs(0.001);
            end
            
        end
        
        
    end%thisTrial
    
    
    %% Show end screen and clean up
    Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
    DrawFormattedText(scr.win, vars.InstructionEnd, 'center', 'center', scr.TextColour);
    [~, ~] = Screen('Flip', scr.win);
    WaitSecs(3);
    
    vars.RunSuccessfull = 1;
    
    % Save the data
    eval(['save ', strcat(vars.OutputFolder, vars.DataFileName), 'Results', 'vars', 'scr', 'keys' ]);
    disp(['Run complete. Results were saved as: ', vars.DataFileName]);
    
    % Cleanup at end of experiment - Close window, show mouse cursor, close
    % result file, switch back to priority 0
    sca;
    ShowCursor;
    fclose('all');
    Priority(0);
    
catch
    % Error. Clean up...
    sca;
    ShowCursor;
    fclose('all');
    Priority(0);
    
    % Save the data
    vars.RunSuccessfull = 0;
    vars.DataFileName = ['Error_',vars.DataFileName];
    save(strcat(vars.OutputFolder, vars.DataFileName),  'Results', 'vars', 'scr', 'keys' );
    disp(['Run crashed. Results were saved as: ', vars.DataFileName]);
    disp(' ** Error!! ***')
    
    % Output the error message that describes the error:
    psychrethrow(psychlasterror);
    
end

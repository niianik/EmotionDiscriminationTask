function experimentEnd(vars, scr, keys, Results)
%function experimentEnd(vars, scr, keys, Results)

% Save, mark the run
vars.RunSuccessfull = 0;
save(strcat(vars.OutputFolder, vars.DataFileName),  'Results', 'vars', 'scr', 'keys' );
disp(['Run was aborted. Results were saved as: ', vars.DataFileName]);
% Abort screen
Screen('FillRect', scr.win, scr.BackgroundGray, scr.winRect);
DrawFormattedText(scr.win, 'Experiment was aborted!', 'center', 'center', scr.TextColour);
[~, ~] = Screen('Flip', scr.win);
WaitSecs(0.5);
ShowCursor;
sca;
disp('Experiment aborted by user!');
return;
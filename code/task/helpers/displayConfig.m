function [scr] = displayConfig(scr)
%function [scr] = displayConfig()


% Set-up screen
if length(Screen('Screens')) > 1
    scr.ExternalMonitor = 1;% set to 1 for secondary monitor
    % N.B. It's not optimal to use external monitor for newer Win systems
    % (Windows 7+) due to timing issues
else
    scr.ExternalMonitor = 0;
end

if scr.ExternalMonitor
    if ~isfield(scr,'MonitorHeight') || isempty(scr.MonitorHeight)
        scr.MonitorHeight = 30; end     % in cm 
    if ~isfield(scr,'MonitorWidth') || isempty(scr.MonitorWidth)
        scr.MonitorWidth = 53; end
    if ~isfield(scr,'ViewDist') || isempty(scr.ViewDist)
        scr.ViewDist = 75; end
    scr.GammaGuess = 2.3;
else % Laptop
    if ~isfield(scr,'MonitorHeight') || isempty(scr.MonitorHeight)
        scr.MonitorHeight = 16.5; end
    if ~isfield(scr,'MonitorWidth') || isempty(scr.MonitorWidth)
        scr.MonitorWidth = 23.5; end
    if ~isfield(scr,'ViewDist') || isempty(scr.ViewDist)
        scr.ViewDist = 40; end
    scr.GammaGuess = 2.6;
end

% Not yet sure if we'll need colour correction
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma');

scr.screenID = max(Screen('Screens'));

%% Colours and text params
scr.BackgroundGray = GrayIndex(scr.screenID);
White = WhiteIndex(scr.screenID);
Black = BlackIndex(scr.screenID);
scr.TextColour = Black;
scr.TextSize = 64;


end
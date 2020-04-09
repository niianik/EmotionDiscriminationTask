function experimentLauncher()
%function experimentLauncher()
%
% Project: Emotion Discrimination Task, part of CWT
% Queries participant info, sets paths, and calls main.m
%
% -------------- PRESS ESC TO EXIT ---------------------
%
% Niia Nikolova
% Last edit: 08/04/2020


%% Initial settings
% Close existing workspace
close all;clc;

vars.exptName = 'EmotDiscrim';

%% Do system checks
if ispc
    % Windows: Skip internal synch checks, suppress warnings  
    oldLevel = Screen('Preference', 'Verbosity', 0);
    Screen('Preference', 'SkipSyncTests', 1);
elseif ismac || isunix
    % Mac/Unix    ## Not tested ###                  
    Screen('Preference', 'SkipSyncTests', 0);    
end

% check working directory
vars.workingDir = fullfile('EmotionDiscriminationTask');
currentFolder = pwd;
correctFolder = contains(currentFolder, vars.workingDir);
if ~correctFolder                   % if we're not in the correct working directory, prompt to change
    disp(['Incorrect working directory. Please start from ', vars.workingDir]);return;
end

%% Ask for subID, age, gender, and display details
vars.subNo = input('What is your subject number (given by the experimenter, e.g. 05)?   ');
vars.subAge = input('What is your age (# in years, e.g. 35)?   ');
vars.subGen = input('What is your gender (f or m)?   ', 's');

if ~isfield(vars,'subNo') || isempty(vars.subNo)
    vars.subNo = 999;               % test
end

scr.MonitorHeight = input('Input your monitor height (cm): ');
scr.MonitorWidth = input('Input your monitor width (cm): ');
scr.ViewDist = input('Input your viewing distance (cm). This is usually around 40cm for laptops, and 75cm for desktop displays: ');


%% Output
vars.OutputFolder = fullfile('.', 'data', filesep);
vars.DataFileName = strcat(vars.exptName, '_',num2str(vars.subNo), '_', date);   % name of data file to write to
if isfile(strcat(vars.OutputFolder, vars.DataFileName, '.mat'))
    % File already exists in Outputdir
    if vars.subNo ~= 999
        disp('A datafile already exists for this subject ID. Please enter a different ID.')
        return
    end
end

%% Start experiment
main(vars, scr);

% Restore PTB verbosity
Screen('Preference', 'Verbosity', oldLevel);
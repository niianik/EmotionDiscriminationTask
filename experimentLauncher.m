function experimentLauncher()
%function experimentLauncher()
%
% Project: Emotion Discrimination Task, part of CWT
% Queries participant info, sets paths, and calls main.m
%
% ======================================================
%
% Run from EmotionDiscriminationTask directory
% -------------- PRESS ESC TO EXIT ---------------------
%
% ======================================================
%
% Niia Nikolova
% Last edit: 29/04/2020


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

% check working directory & change if necessary
vars.workingDir = fullfile('EmotionDiscriminationTask');
currentFolder = pwd;
correctFolder = contains(currentFolder, vars.workingDir);
if ~correctFolder                   % if we're not in the correct working directory, prompt to change
    disp(['Incorrect working directory. Please start from ', vars.workingDir]); return;
end


% setup path
addpath(genpath('code'));
addpath(genpath('data'));
addpath(genpath('stimuli'));

%% Ask for subID, age, gender, and display details
vars.subNo = input('What is your subject number (given by the experimenter, e.g. 001)?   ');
vars.subAge = input('What is your age (# in years, e.g. 35)?   ');
vars.subGen = input('What is your gender (f or m)?   ', 's');

if ~isfield(vars,'subNo') || isempty(vars.subNo)
    vars.subNo = 999;               % test
end

disp('=====================================================================================');
disp('Now please enter your screen dimensions and viewing distance.');
disp('If left blank, these will default to 16.5 x 23.5cm, 40cm viewing distance, which is approximate for a 13" laptop.');
disp('Press ENTER to continue...');
disp('=====================================================================================');
pause
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
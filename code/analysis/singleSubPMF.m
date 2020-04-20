% simple PF fitting to emotion discrimination data (single subject) using
% Palamedes 

%% Load file
loadFile = uigetfile('*.mat', 'Select a .mat file to load.');
load(loadFile);

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
ResultsCell = struct2cell(Results);
ResultsTable = struct2table(Results);

% col_trialN = 1;
% col_EmoResp = 2;
% col_ConfResp = 3;
% col_EmoRT = 4;
% col_ConfRT = 5;
% col_trialSuccess = 6;
% col_MorphLevel = 7;
% col_subID = 8;
ResultsArray = table2array(ResultsTable(:,[1:6,8,10]));

%% Set options
ParOrNonPar = 1;
StimLevels = unique(ResultsArray(:,7))';
Ntotal = hist(ResultsArray(:,7), StimLevels);
NPosResponse = hist( ResultsArray(logical(ResultsArray(:,2)==0),7), StimLevels );       % recode as angry=1, happy=0              

NumPos = NPosResponse;
OutOfNum = Ntotal;        

%% Palamedes
PF = @PAL_Logistic;  %Alternatives: PAL_Gumbel, PAL_Weibull, PAL_Logistic
                     %PAL_Quick, PAL_logQuick,
                     %PAL_CumulativeNormal, PAL_HyperbolicSecant

%Threshold and Slope are free parameters, guess and lapse rate are fixed
paramsFree = [1 1 0 0];  %1: free parameter, 0: fixed parameter

%Parameter grid defining parameter space through which to perform a
%brute-force search for values to be used as initial guesses in iterative
%parameter search.
searchGrid.alpha = 0.01:.5:199;
searchGrid.beta = logspace(0,3,101);
searchGrid.gamma = 0.01;     %scalar here (since fixed) but may be vector
searchGrid.lambda = 0.02;   %ditto


%% Perform fit
disp('Fitting function.....');
[paramsValues LL exitflag] = PAL_PFML_Fit(StimLevels,NumPos, ...
    OutOfNum,searchGrid,paramsFree,PF);

disp('done:')
message = sprintf('Threshold estimate: %6.4f',paramsValues(1));
disp(message);
message = sprintf('Slope estimate: %6.4f\r',paramsValues(2));
disp(message);

%Number of simulations to perform to determine standard error
B=400;                  

disp('Determining standard errors.....');

if ParOrNonPar == 1
    [SD paramsSim LLSim converged] = PAL_PFML_BootstrapParametric(...
        StimLevels, OutOfNum, paramsValues, paramsFree, B, PF, ...
        'searchGrid', searchGrid);
else
    [SD paramsSim LLSim converged] = PAL_PFML_BootstrapNonParametric(...
        StimLevels, NumPos, OutOfNum, [], paramsFree, B, PF,...
        'searchGrid',searchGrid);
end

disp('done:');
message = sprintf('Standard error of Threshold: %6.4f',SD(1));
disp(message);
message = sprintf('Standard error of Slope: %6.4f\r',SD(2));
disp(message);

%Distribution of estimated slope parameters for simulations will be skewed
%(type: hist(paramsSim(:,2),40) to see this). However, distribution of
%log-transformed slope estimates will be approximately symmetric
%[type: hist(log10(paramsSim(:,2),40)]. This might motivate using 
%log-scale for slope values (uncomment next three lines to put on screen):
% SElog10slope = std(log10(paramsSim(:,2)));
% message = ['Estimate for log10(slope): ' num2str(log10(paramsValues(2))) ' +/- ' num2str(SElog10slope)];
% disp(message);

%Number of simulations to perform to determine Goodness-of-Fit
B=200;%1000;

disp('Determining Goodness-of-fit.....');

[Dev pDev] = PAL_PFML_GoodnessOfFit(StimLevels, NumPos, OutOfNum, ...
    paramsValues, paramsFree, B, PF, 'searchGrid', searchGrid);

disp('done:');

% Display summary of results
message = sprintf('Deviance: %6.4f',Dev);
disp(message);
message = sprintf('p-value: %6.4f',pDev);
disp(message);
 
%% Create simple plot
ProportionCorrectObserved=NumPos./OutOfNum; 
StimLevelsFineGrain=[min(StimLevels):max(StimLevels)./1000:max(StimLevels)];
ProportionCorrectModel = PF(paramsValues,StimLevelsFineGrain);
 
figure('name','Maximum Likelihood Psychometric Function Fitting');
axes
hold on
plot(StimLevelsFineGrain,ProportionCorrectModel,'-','color',[0 .7 0],'linewidth',4);
plot(StimLevels,ProportionCorrectObserved,'k.','markersize',40);
set(gca, 'fontsize',16);
set(gca, 'Xtick',StimLevels);
axis([min(StimLevels) max(StimLevels) 0 1]);
xlabel('Stimulus Intensity');
ylabel('Proportion ''Angry'' ');

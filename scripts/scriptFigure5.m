% scriptFigure5

% Set up directories and load data.
rootpath = '/Users/asbova/Documents/MATLAB';                                        % Add project filepath.
cd(rootpath)
projectName = 'switch_movement';
addpath(genpath(sprintf('./%s', projectName)))
cd(sprintf('./%s', projectName))

ephysFile = fullfile(pwd, '/data/matfiles/neuronStructureMatchedPavlovianMovement.mat');            % Load ephys and DLC .mat files.
load(ephysFile)

resultsFolder = fullfile(pwd, '/results/figures');                                  % Set data directory for figure output.
figureName = 'Figure5_Ensemble.pdf';



%%

PFCswitch = find(cellfun(@(x) all(x == 'PFCswitch'), {ephysDataStructure.group}));
PFCswitchNeurons = [ephysDataStructure(PFCswitch).neurons];

DMSswitch = find(cellfun(@(x) all(x == 'DMSswitch'), {ephysDataStructure.group}));
DMSswitchNeurons = [ephysDataStructure(DMSswitch).neurons];

PFCpavlov = find(cellfun(@(x) all(x == 'PFCpavlov'), {ephysDataStructure.group}));
PFCpavlovNeurons = [ephysDataStructure(PFCpavlov).neurons];

DMSpavlov = find(cellfun(@(x) all(x == 'DMSpavlov'), {ephysDataStructure.group}));
DMSpavlovNeurons = [ephysDataStructure(DMSpavlov).neurons];

badDMS = (cellfun(@(x) x <= 0.5, {DMSswitchNeurons.averageFiringRate}) | cellfun(@(x) x >= 20, {DMSswitchNeurons.averageFiringRate})) | ...
    (cellfun(@(x) x <= 0.5, {DMSpavlovNeurons.averageFiringRate}) | cellfun(@(x) x >= 20, {DMSpavlovNeurons.averageFiringRate}));
goodMSNs = ~badDMS & cellfun(@(x) strcmp(x, 'MSN'), {DMSswitchNeurons.type});
DMSswitchNeurons = DMSswitchNeurons(goodMSNs);
DMSpavlovNeurons = DMSpavlovNeurons(goodMSNs);


fig = figure('Units', 'Normalized', 'OuterPosition', [0, 0.04, 0.7, 0.6]);

statsPFC = runEnsembleAnalysis(PFCswitchNeurons, 1, 0.2);                % Bayeseian decoding analysis.
statsDMS = runEnsembleAnalysis(DMSswitchNeurons, 1, 0.2);
timeInterval = statsPFC.times(statsPFC.goodtimes == 1);
statsPFCpavlov = runEnsembleAnalysisPavlovian(PFCpavlovNeurons, 1, 0.2);
statsDMSpavlov = runEnsembleAnalysisPavlovian(DMSpavlovNeurons, 1, 0.2);
timeIntervalPavlov = statsPFCpavlov.times(statsPFCpavlov.goodtimes == 1);

subplot(2,3,1); cla; 
imagesc(timeInterval, timeInterval, statsPFC.y(statsPFC.goodtimes == 1, statsPFC.goodtimes == 1));
axis xy; 
xticks([0 6 18])
yticks([0 6 18]);
xlabel('Objective Time');
ylabel('Predicted Time');
colorbar;
colormap('jet');
title('PFC Switch')

subplot(2,3,2); cla;
imagesc(timeIntervalPavlov, timeIntervalPavlov, statsPFCpavlov.y(statsPFCpavlov.goodtimes == 1, statsPFCpavlov.goodtimes == 1));
axis xy;
xlabel('Objective Time');
ylabel('Predicted Time');
colorbar;
title('PFC Pavlovian')

subplot(2,3,3); cla;
data = {};
data{1} =  statsPFC.r2_0_6; 
data{2} =  statsPFCpavlov.r2_0_7; 
data{3} =  statsDMS.r2_0_6; 
data{4} =  statsDMSpavlov.r2_0_7; 
jitterPlot(data, 2, {'k', 'r', 'k', 'r'}); 
xticks([1.5 3.5]);
xticklabels({'PFC', 'DMS'});
ylabel('Decoding Accurary (r2)')

subplot(2,3,4); cla; 
imagesc(timeInterval, timeInterval, statsDMS.y(statsDMS.goodtimes == 1, statsDMS.goodtimes == 1)); axis xy; 
xticks([0 6 18]);
yticks([0 6 18]);
xlabel('Objective Time');
ylabel('Predicted Time');
colorbar;
title('DMS Switch')

subplot(2,3,5); cla;
imagesc(timeIntervalPavlov, timeIntervalPavlov, statsDMSpavlov.y(statsDMSpavlov.goodtimes == 1, statsDMSpavlov.goodtimes == 1));
axis xy;
xlabel('Objective Time');
ylabel('Predicted Time');
colorbar;
title('DMS pavlovian')


% Save figure.
origUnits = fig.Units;
fig.Units = fig.PaperUnits; 
fig.PaperSize = fig.Position(3:4);
fig.Units = origUnits;
saveas(fig, fullfile(resultsFolder, figureName));
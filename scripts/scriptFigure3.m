% scriptFigure3

% Set up directories and load data.
rootpath = '/Users/asbova/Documents/MATLAB';                                        % Add project filepath.
cd(rootpath)
projectName = 'switch_movement';
addpath(genpath(sprintf('./%s', projectName)))
cd(sprintf('./%s', projectName))

ephysFile = fullfile(pwd, '/data/matfiles/neuronStructureMovement.mat');            % Load ephys and DLC .mat files.
dlcFile = fullfile(pwd, '/data/matfiles/dlcData.mat');
load(ephysFile)
load(dlcFile)

resultsFolder = fullfile(pwd, '/results/figures');                                  % Set data directory for figure output.
figureName = 'Figure3_Movement.pdf';

% Add deeplabcut data to the ephys data structure.
for iSession = 1 : length(ephysDataStructure)
    sessionRow = find(contains({dlcStructure.mouseID}, {ephysDataStructure(iSession).mouseID}) &...
        contains({dlcStructure.date}, {ephysDataStructure(iSession).date}));
    if isempty(sessionRow)
        continue
    else
        ephysDataStructure(iSession).dlc = dlcStructure(sessionRow);
    end
end

%%

fig = figure('Units', 'Normalized', 'OuterPosition', [0, 0.04, 0.7, 0.6]);

% Plot example movement traces of long trials with color corresponding to time within trial.
exampleSession = 10;
trajectoryData = ephysDataStructure(exampleSession).dlc.smoothedTrajectories.LongTrials;
frameRate = ephysDataStructure(exampleSession).dlc.frameRate;
subplot(2,3,1); cla;                                    % Add image in Illustrator after.
plotTrajectoriesSwitchWithImage(trajectoryData, frameRate);
axis off


subplot(2,3,2); cla;
plotHeatMapsDLC(ephysDataStructure);

subplot(2,3,3); cla;
plotTimeInTrialHeatMapDLC(ephysDataStructure);

% Plot average velocity in long trials.
subplot(2,3,4); cla;
plotAverageVelocity(ephysDataStructure)
ylim([0 205]);

% Plot fraction of neurons that are movement- vs. time-related (or both).
[glmStructure, PETH, neurons] = runGLM(ephysDataStructure);
for iNeuron = 1 : length(neurons)
    if contains(neurons(iNeuron).type, 'MSN')
        glmStructure(iNeuron).group = 'DMS';
    else
        glmStructure(iNeuron).group = 'PFC';
    end
end

subplot(2,3,5); cla;
plotFractionNeuronsMovement(glmStructure);

subplot(2,3,6); cla;
plotTimeVsMovement(glmStructure);

% Save figure.
origUnits = fig.Units;
fig.Units = fig.PaperUnits; 
fig.PaperSize = fig.Position(3:4);
fig.Units = origUnits;
set(gcf, 'renderer', 'painters');
saveas(fig, fullfile(resultsFolder, figureName));




fig = figure; hold on;
plotVelocityHeatMapDLC(ephysDataStructure);
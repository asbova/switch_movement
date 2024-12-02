% scriptFigure2

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
% Run a generalized linear model on trial by trial firing rates and behavior.
% Also pulls out PETH for plotting and PCA.
[glmStructure, PETH, neurons] = runGLM(ephysDataStructure);
for iNeuron = 1 : length(neurons)
    if contains(neurons(iNeuron).type, 'MSN')
        glmStructure(iNeuron).group = 'DMS';
    else
        glmStructure(iNeuron).group = 'PFC';
    end
end

% Run PCA on all neurons together (DMS and PFC).
[coefficients, pcaScores, zPETH] = runPCA(PETH, 22, 18);

fig = figure('Units', 'Normalized', 'OuterPosition', [0, 0.04, 0.8, 0.7]);

subplot(4,4,1); cla;                                                        % Plot raster and average firing rate of example PFC neuron
intervalRaster = -4 : 0.25 : 22;
PFCneuron = 161;
periEventSpike = peSpike(neurons(PFCneuron).spikeTimestamps, neurons(PFCneuron).trialSpecificEvents.correctLongTrialCuesOn, -4:0.2:22); % correct trials
plotRaster(periEventSpike, intervalRaster, [94 176 71] ./ 255)

subplot(4,4,5); cla;
plotAverageFiringRate(periEventSpike, intervalRaster, [94 176 71] ./ 255)

subplot(4,4,9); cla;                                                        % Plot raster and average firing rate of example DMS neuron
intervalRaster = -4 : 0.25 : 22;
DMSneuron = 79;
periEventSpike = peSpike(neurons(DMSneuron).spikeTimestamps, neurons(DMSneuron).trialSpecificEvents.correctLongTrialCuesOn, -4:0.2:22); 
plotRaster(periEventSpike, intervalRaster, [39 43 175] ./ 255)

subplot(4,4,13); cla;
plotAverageFiringRate(periEventSpike, intervalRaster, [39 43 175] ./ 255)

subplot(4,4,[2 6]); cla;                                                    % Plot PETHs for PFC.
PFCneurons = find(cellfun(@(x) all(x == 'PFC'), {glmStructure.group}));
plotPETH(zPETH, pcaScores, PFCneurons, 18);
xlabel('');
ylabel('PFC Neuron #')

subplot(4,4,[10 14]); cla;                                                  % Plot PETHs for DMS.
DMSneurons = cellfun(@(x) all(x == 'DMS'), {glmStructure.group});
plotPETH(zPETH, pcaScores, DMSneurons, 18);
ylabel('DMS Neuron #')

subplot(4,4,[3 7]); cla;
plotFractionNeuronsRamp(glmStructure)

subplot(4,4,4); cla;                                                    % Plot PCA coefficients.    
plotPCA(coefficients, 18);
xlim([-0.5 18.5])

subplot(4,4,8); cla;                                                  % Plot PCA scores PFC vs DMS.
plotPCAscore(pcaScores, DMSneurons, PFCneurons)

subplot(4,4,[11 15]); cla;
plotSlope(glmStructure, 0.2);

subplot(4,4,[12 16]); cla;
plotFractionNonRampEvents(glmStructure)
legend off

% Save figure.
origUnits = fig.Units;
fig.Units = fig.PaperUnits; 
fig.PaperSize = fig.Position(3:4);
fig.Units = origUnits;
saveas(fig, fullfile(resultsFolder, 'Figure2_Ramping.pdf'));








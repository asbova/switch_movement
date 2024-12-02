% scriptFigure4

% Set up directories and load data.
rootpath = '/Users/asbova/Documents/MATLAB';                                        % Add project filepath.
cd(rootpath)
projectName = 'switch_movement';
addpath(genpath(sprintf('./%s', projectName)))
cd(sprintf('./%s', projectName))

ephysFile = fullfile(pwd, '/data/matfiles/neuronStructureMatchedPavlovianMovement.mat');            % Load ephys and DLC .mat files.
load(ephysFile)

resultsFolder = fullfile(pwd, '/results/figures');                                  % Set data directory for figure output.
figureName = 'Figure4_Pavlovian.pdf';

%% Run GLMs on switch and pavlovian recordings.
[glmStructure, PETHswitch, PETHpavlovian, neurons] = runGLMpavlovian(ephysDataStructure);
% Get rid of neurons whose firing rate is outside bounds.
nSessions = length(ephysDataStructure);
neuronInclusion = [];
for iSession = 1 : nSessions
    if contains(ephysDataStructure(iSession).group, 'DMSswitch')  % If the recording is from the DMS, extract only the MSNs.
        currentNeurons = ephysDataStructure(iSession).neurons;
        currentNeurons = currentNeurons(strcmp({currentNeurons.type}, 'MSN'));
        averageFiringRate = [currentNeurons.averageFiringRate];
        neuronInclusion = [neuronInclusion averageFiringRate > 0.5 & averageFiringRate < 20 & strcmp({currentNeurons.type},'MSN')];
    else
        continue;
    end
end
PETHpavlovian(~neuronInclusion, :) = [];
PETHswitch(~neuronInclusion, :) = [];
neuronInclusion = [neuronInclusion neuronInclusion];
glmStructure(~neuronInclusion) = [];


%% PLOT

[coefficients, pcaScores, zPETH] = runPCA(PETHpavlovian, 11, 7);

DMSneurons = 1 : sum(neuronInclusion/2);
PFCneurons = sum(neuronInclusion/2) + 1 : size(PETHpavlovian, 1);

fig = figure('Units', 'Normalized', 'OuterPosition', [0, 0.04, 0.5, 0.7]);

% Plot raster and average firing rate - PFC switch.
subplot(6,3,1); cla;
intervalRaster = -4 : 0.25 : 22;
PFCneuron = 237;
periEventSpike = peSpike(neurons(PFCneuron).spikeTimestamps, neurons(PFCneuron).trialSpecificEvents.correctLongTrialCuesOn, intervalRaster); % correct trials
plotRaster(periEventSpike, intervalRaster, 'k')

subplot(6,3,7); cla;
plotAverageFiringRate(periEventSpike, intervalRaster, 'k')

% Plot raster and average firing rate - PFC pavlovian.
subplot(6,3,4); cla;
intervalRaster = -4 : 0.25 : 22;
PFCneuron = 264;
periEventSpike = peSpike(neurons(PFCneuron).spikeTimestamps, neurons(PFCneuron).trialSpecificEvents.rewardedTrialCuesOn, intervalRaster); % correct trials
plotRaster(periEventSpike, intervalRaster, 'r')

subplot(6,3,7); hold on;
plotAverageFiringRate(periEventSpike, -4:0.25:11, 'r')
xlim([-3 21])
xticks([0 7 18])

% Plot raster and average firing rate - DMS switch.
subplot(6,3,10); cla;
intervalRaster = -4 : 0.25 : 22;
DMSneuron = 101;
periEventSpike = peSpike(neurons(DMSneuron).spikeTimestamps, neurons(DMSneuron).trialSpecificEvents.correctLongTrialCuesOn, intervalRaster); % correct trials
plotRaster(periEventSpike, intervalRaster, 'k')

subplot(6,3,16); cla;
plotAverageFiringRate(periEventSpike, intervalRaster, 'k')

% Plot raster and average firing rate - DMS pavlovian.
subplot(6,3,13); cla;
intervalRaster = -4 : 0.25 : 22;
DMSneuron = 207;
periEventSpike = peSpike(neurons(DMSneuron).spikeTimestamps, neurons(DMSneuron).trialSpecificEvents.rewardedTrialCuesOn, intervalRaster); % correct trials
plotRaster(periEventSpike, intervalRaster, 'r')

subplot(6,3,16); hold on;
plotAverageFiringRate(periEventSpike, -4:0.25:11, 'r')
xlim([-3 21])
xticks([0 7 18])

% Plot PETHs for PFC pavlovian.
subplot(6,3,[2 5 8]); cla;
plotPETH(zPETH, pcaScores, PFCneurons, 7);
xticks([0 7]);
xlabel('');

% Plot PETHs for PFC pavlovian.
subplot(6,3,[11 14 17]); cla;
plotPETH(zPETH, pcaScores, DMSneurons, 7);
xticks([0 7]);

% Plot PCA coefficients.    
subplot(6,3,[3 6]); cla;                                                    
plotPCA(coefficients, 7);
xlim([-0.5 7.5]);

% Plot PCA scores PFC vs DMS.
subplot(6,3,[9 12]); cla;                                                  
plotPCAscore(pcaScores, DMSneurons, PFCneurons)

% Plot percent of neurons that ramped during switch task vs. pavlovian task.
subplot(6,3,[15 18]); cla;
plotFractionNeuronsRampTasks(glmStructure)


% Save figure.
origUnits = fig.Units;
fig.Units = fig.PaperUnits; 
fig.PaperSize = fig.Position(3:4);
fig.Units = origUnits;
saveas(fig, fullfile(resultsFolder, figureName));
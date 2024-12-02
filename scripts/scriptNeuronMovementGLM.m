% scriptNeuronMovementGLM

addpath(genpath('./switch_movement'))
cd './switch_movement'

load './data/matfiles/neuronStructureForGrant.mat'; % ephys data
load './data/matfiles/dlcData.mat';          % dlc data

resultsFolder = './results/figures';

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

% Plot the percentage of neurons that were modulate by time and/or movement.
figure('Units', 'Normalized', 'OuterPosition', [0, 0.04, 0.4, 0.7]);
subplot(4,2,[1 3]); cla;
DMSneurons = find(cellfun(@(x) all(x == 'DMS'), {glmStructure.group}));
[coefficients, pcaScores] = plotPETH(PETH, DMSneurons);
title('DMS')

subplot(4,2,[2 4]); cla;
PFCneurons = find(cellfun(@(x) all(x == 'PFC'), {glmStructure.group}));
plotPETH(PETH, PFCneurons);
title('PFC')

subplot(4,2,2); cla;
plotPCA(coefficients);

subplot(4,2,6); cla;
plotPCAscore(pcaScores, DMSneurons, PFCneurons)

subplot(4,2,[7 8]); cla;
plotPercentNeuronsModulated(glmStructure)

saveas(gcf, fullfile(resultsFolder, 'dmsPFCpca.pdf'));

%%
% % Plot raster of a just time-modulated neuron.
% intervalRaster = -4 : 0.25 : 22;
% justTimeNeurons = find(cellfun(@(x) x < 0.05, {glmStructure.pTime}) & cellfun(@(x) x >= 0.05, {glmStructure.pVelocity}));
% timeNeuronToPlot = justTimeNeurons(1);
% periEventSpike = peSpike(neurons(timeNeuronToPlot).spikeTimestamps, neurons(timeNeuronToPlot).trialSpecificEvents.correctLongTrialCuesOn, intervalRaster);
% 
% subplot(4,2,2); cla;
% plotRaster(periEventSpike, intervalRaster, 'k');
% 
% % Plot the average firing rate and velocity of this neuron.
% % Extract velocity data
% sessionName = extractBefore(neurons(timeNeuronToPlot).filename, '_rough');
% sessionRow = find(contains({ephysDataStructure.pl2FilePathway}, sessionName));
% behaviorData = ephysDataStructure(sessionRow).mpcTrialData;  % Identify the long trials that are correct
% longTrials = find(cellfun(@(x) x == 18000, {behaviorData.programmedDuration}));
% correctTrials = find(cellfun(@(x) ~isempty(x), {behaviorData.reward_inTrial}));
% correctLongTrials = ismember(longTrials, correctTrials);
% velocityData = ephysDataStructure(sessionRow).dlc.velocity.LongTrials(correctLongTrials,:);
% 
% subplot(4,2,4); cla;
% plotColor = {[0 0 0]; [255 182 234] ./255};
% plotAverageFiringRateVelocity(periEventSpike, velocityData, intervalRaster, plotColor)
% 
% % Plot raster of a time- and velocity-modulated neuron.
% timeVelocityNeurons = find(cellfun(@(x) x < 0.05, {glmStructure.pTime}) & cellfun(@(x) x < 0.05, {glmStructure.pVelocity}));
% timeNeuronToPlot = timeVelocityNeurons(9);
% periEventSpike = peSpike(neurons(timeNeuronToPlot).spikeTimestamps, neurons(timeNeuronToPlot).trialSpecificEvents.correctLongTrialCuesOn, intervalRaster);
% 
% subplot(4,2,6); cla;
% plotRaster(periEventSpike, intervalRaster, 'k');
% 
% % Plot the average firing rate and velocity of this neuron.
% % Extract velocity data
% sessionName = extractBefore(neurons(timeNeuronToPlot).filename, '_rough');
% sessionRow = find(contains({ephysDataStructure.pl2FilePathway}, sessionName));
% behaviorData = ephysDataStructure(sessionRow).mpcTrialData;  % Identify the long trials that are correct
% longTrials = find(cellfun(@(x) x == 18000, {behaviorData.programmedDuration}));
% correctTrials = find(cellfun(@(x) ~isempty(x), {behaviorData.reward_inTrial}));
% correctLongTrials = ismember(longTrials, correctTrials);
% velocityData = ephysDataStructure(sessionRow).dlc.velocity.LongTrials(correctLongTrials,:);
% 
% subplot(4,2,8); cla;
% plotColor = {[0 0 0]; [255 182 234] ./255};
% plotAverageFiringRateVelocity(periEventSpike, velocityData, intervalRaster, plotColor)
% 





% % Plot raster of a just velocity-modulated neuron.
% velocityNeurons = find(cellfun(@(x) x >= 0.05, {glmStructure.pTime}) & cellfun(@(x) x < 0.05, {glmStructure.pVelocity}));
% timeNeuronToPlot = timeVelocityNeurons(16);
% periEventSpike = peSpike(neurons(timeNeuronToPlot).spikeTimestamps, neurons(timeNeuronToPlot).trialSpecificEvents.correctLongTrialCuesOn, intervalRaster);
% 
% subplot(4,2,6); cla;
% plotRaster(periEventSpike, intervalRaster, 'k');
% 
% % Plot the average firing rate and velocity of this neuron.
% % Extract velocity data
% sessionName = extractBefore(neurons(timeNeuronToPlot).filename, '_rough');
% sessionRow = find(contains({ephysDataStructure.pl2FilePathway}, sessionName));
% behaviorData = ephysDataStructure(sessionRow).mpcTrialData;  % Identify the long trials that are correct
% longTrials = find(cellfun(@(x) x == 18000, {behaviorData.programmedDuration}));
% correctTrials = find(cellfun(@(x) ~isempty(x), {behaviorData.reward_inTrial}));
% correctLongTrials = ismember(longTrials, correctTrials);
% velocityData = ephysDataStructure(sessionRow).dlc.velocity.LongTrials(correctLongTrials,:);
% 
% subplot(4,2,8); cla;
% plotColor = {[0 0 0]; [255 182 234] ./255};
% plotAverageFiringRateVelocity(periEventSpike, velocityData, intervalRaster, plotColor)
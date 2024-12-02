

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


    % Find neurons that ramp and/or are movement-related.
    rampingNeurons = find(cellfun(@(x) x < 0.05, {glmStructure.pTimeFDR}));
    nonrampingNeurons = find(cellfun(@(x) x >= 0.05, {glmStructure.pTimeFDR}));
    motorNeurons = find(cellfun(@(x) x < 0.05, {glmStructure.pVelocityFDR}));  
    nonmotorNeurons = find(cellfun(@(x) x >= 0.05, {glmStructure.pVelocityFDR}));
    rampAndMotorNeurons = intersect(rampingNeurons, motorNeurons); 
    rampAndNonmotorNeurons = intersect(rampingNeurons, nonmotorNeurons);
    nonrampAndMotorNeurons = intersect(nonrampingNeurons, motorNeurons);

    % nTotalNeurons(iGroup) = length(glmStructure);
    % nRampingNeurons(iGroup) = length(rampingNeurons);
    % nMotorNeurons(iGroup) = length(motorNeurons);
    % nRampAndMotorNeurons(iGroup) = length(rampAndMotorNeurons);


    % Set parameters.
    intervalStart = -4;
    intervalEnd = 22;   % Use for peSpike.
    binSize = 1.0;     % seconds
    intervalBins = intervalStart : binSize : intervalEnd;
    trialStart = 0;
    trialEnd = 18;      
    trialBins = trialStart : binSize : trialEnd;

    plotColors = gray(25);
    fig = figure('Units', 'Normalized', 'OuterPosition', [0, 0.04, 0.5, 0.7]);
    plotNumber = 1;
    for iNeuron = [rampAndNonmotorNeurons(28) nonrampAndMotorNeurons(16)]
        currentSession = glmStructure(iNeuron).session;
        
        % Extract the data for this neuron.
        mouseID = extractBefore(currentSession, '_20');
        structureRow = find(cellfun(@(x) strcmp(x, mouseID), {ephysDataStructure.mouseID}));
        dlcData = ephysDataStructure(structureRow).dlc;
        behaviorData = ephysDataStructure(structureRow).mpcTrialData;
        neuronName = glmStructure(iNeuron).neuron;
        neuronData = ephysDataStructure(structureRow).neurons;
        neuronRow = find(cellfun(@(x) strcmp(x, neuronName), {neuronData.name}));
    
        % Firing Rate
        clear *periEventSpike*
        periEventSpike = peSpike(neuronData(neuronRow).spikeTimestamps, neuronData(neuronRow).trialSpecificEvents.correctLongTrialCuesOn, intervalBins);
        spikeTrial = double(periEventSpike);
        histogramSpikeTrial = histc(spikeTrial', trialBins);
        histogramSpikeTrial(end,:) = [];
    
        % Velocity
        velocityData = dlcData.velocity.LongTrials;
        longTrials = find(cellfun(@(x) x == 18000, {behaviorData.programmedDuration}));
        correctTrials = find(cellfun(@(x) ~isempty(x), {behaviorData.reward_inTrial}));
        correctLongTrials = ismember(longTrials, correctTrials);
        correctVelocity = velocityData(correctLongTrials, :);
    
        % Bin average velocity 
        frameRate = dlcData.frameRate;
        framesPerBin = frameRate * binSize;       
        nBins = round(size(velocityData,2)/framesPerBin);
        binnedVelocity = NaN(nBins, size(correctVelocity, 1));
        for iTrial = 1 : size(correctVelocity, 1)
            binnedVelocity(1:nBins-1,iTrial) = arrayfun(@(x) mean(correctVelocity(iTrial, x:x+framesPerBin-1)), 1:framesPerBin:length(correctVelocity)-framesPerBin+1)';
        end
        binnedVelocity = binnedVelocity(5:22, :);
        
        % Plot
        subplot(2,2,plotNumber)
        hold on;
        binnedVelocityAll = reshape(binnedVelocity, [], 1);
        histogramSpikeTrialAll = reshape(histogramSpikeTrial, [], 1);
        scatter(binnedVelocityAll, histogramSpikeTrialAll, 'MarkerFaceColor', 'none', 'MarkerEdgeColor', 'none');
        lsline
        for iTrial = 1 : size(binnedVelocity, 2)
            scatter(binnedVelocity(:, iTrial), histogramSpikeTrial(:, iTrial), 'MarkerFaceColor', plotColors(iTrial, :), 'MarkerEdgeColor', plotColors(iTrial, :));
        end
        
        xlim([0 100])
        xlabel('Velocity (cm/s)')
        ylabel('Firing Rate (Hz)')
        if plotNumber == 1
            title('Ramping + Non-Movement');
        else
            title('Movement + Non-Ramping');
        end
        
        subplot(2,2,plotNumber+2)
        hold on;
        scatter(repmat(1 : size(histogramSpikeTrial, 1), [1, size(histogramSpikeTrial,2)]), histogramSpikeTrialAll, 'MarkerFaceColor', 'none', 'MarkerEdgeColor', 'none');
        lsline
        for iTrial = 1 : size(histogramSpikeTrial, 2)
            scatter(1 : size(histogramSpikeTrial, 1), histogramSpikeTrial(:, iTrial), 'MarkerFaceColor', plotColors(iTrial, :), 'MarkerEdgeColor', plotColors(iTrial, :));
        end
        plotNumber = plotNumber + 1;
        xlim([0 18]);
        % xticks(0:15:90)
        % set(gca, 'XTickLabel', 0:3:18);
        xlabel('Time (sec)');
        ylabel('Firing Rate (Hz)')
    end



    %exportgraphics(gcf, fullfile(resultsFolder, 'scatterFRvelocity.pdf'), 'ContentType', 'vector');

    origUnits = fig.Units;
    fig.Units = fig.PaperUnits; 
    % set the Page Size (figure's PaperSize) to match the figure size in the Paper units
    fig.PaperSize = fig.Position(3:4);
    % restore the original figure Units 
    fig.Units = origUnits;

    saveas(fig, fullfile(resultsFolder, 'scatterFRvelocity3.pdf'));
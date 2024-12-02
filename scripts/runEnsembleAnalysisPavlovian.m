function stats = runEnsembleAnalysisPavlovian(neurons, kernelBinWidth, binSize)
%
% Run a Bayesian Declassifier on neuronal ensemble activity.
%
% INPUTS:
%   neurons:                
%   kernelBinWidth:               
%   binSize:              
%
% OUTPUT
%   stats



    nTrials = NaN(length(neurons), 1);
    for iNeuron = 1 : length(neurons)
        nTrials(iNeuron) = length(neurons(iNeuron).trialSpecificEvents.rewardedTrialCuesOn); 
    end

    %[N, edges] = histcounts(nCorrectTrials, 1 : max(nCorrectTrials), 'Normalization', 'cdf');
    %maxTrialNumber = edges(find(N > 0.1, 1)); % >90% neuron number
    
    maxTrialNumber = 20;                                                % 20 is a reasonable number for classification.
    intervalEnd = 7; 
    intervalBuffer = 6;
    interval = -intervalBuffer : binSize : intervalEnd + intervalBuffer;
    time = interval(1 : end-1);
    
    data = NaN(numel(time), maxTrialNumber, length(neurons));           % fitcnb treats NaN as missing data, so we can include neurons with smaller trial numbers.
    for iNeuron = 1 : length(neurons)       
        trialStartTimestamps = neurons(iNeuron).trialSpecificEvents.rewardedTrialCuesOn;   
        periEventSpike = peSpike(neurons(iNeuron).spikeTimestamps, trialStartTimestamps, interval);
        periEventSpike = periEventSpike(~all(isnan(periEventSpike), 2), :);                                    % Remove trials with no spikes.
        periEventSpike = periEventSpike(1 : min([maxTrialNumber size(periEventSpike,1)]),:);                   
        probabilityEstimate = zeros(numel(time), size(periEventSpike,1));
        for jTrial = 1 : size(periEventSpike,1)
            probabilityEstimate(:,jTrial) = ksdensity(periEventSpike(jTrial,:), time, 'Bandwidth', kernelBinWidth, 'Support', [interval(1)-0.1 interval(end)+0.1], 'BoundaryCorrection', 'reflection');
        end
        data(:, 1:size(probabilityEstimate,2), iNeuron) = probabilityEstimate;                                                                                                     
    end
    zData = zscore(data);
    fprintf('time %d x trial %d x neuron %d, blank: %d\n', size(zData), length(find(isnan(zData)))) % time x trial x neuron
    
    nTrials = size(zData, 2); 
    bayesData = reshape(zData, [], size(zData,3));
    fullTime = repmat(time, 1, nTrials);
    fullTrialNumbers = reshape(repmat(1:nTrials, numel(time), 1), 1, []);
    shuffledTime = cell2mat(cellfun(@(x) x(randperm(numel(x))), repmat({time},1,nTrials), 'UniformOutput', false));
    goodTimes = time >= 0 & time <= intervalEnd;  
    
    earlyTimes = time >= 0 & time <= 7; 
   
    confusionMatrix = zeros(numel(time), numel(time));
    confusionMatrixShuffled = zeros(numel(time), numel(time));
    error = zeros(sum(goodTimes), 1);
    shuffleError = zeros(sum(goodTimes), 1);
    % while we can do cross validation with 'Leaveout' in the fitcnb, parfor with manual cross validation is much faster.
    parfor iTrial = 1 : nTrials
        testTrialIndex = fullTrialNumbers == iTrial;
        testData = bayesData(testTrialIndex, :);
        trainingPrediction = bayesData(~testTrialIndex, :);
        trainingTime = fullTime(~testTrialIndex);
        
        NBModel = fitcnb(trainingPrediction, trainingTime); %,'Distribution','kernel','KSWidth',3 make the model including trainingdata and class labels (i.e., what time in corresponding row was)
        shuffledModel = fitcnb(trainingPrediction, shuffledTime(~testTrialIndex));
        
        predictionLabels1 = predict(NBModel, testData);
        predictionLabels2 = predict(shuffledModel, testData);
    
        rSquared = corrcoef(predictionLabels1(goodTimes), time(goodTimes));
        r2(iTrial) = rSquared(1,2) ^ 2;  
        shuffledSquared = corrcoef(predictionLabels2(goodTimes), time(goodTimes)); 
        shuffledR2(iTrial) = shuffledSquared(1,2) ^ 2;  
        
        rsquared_0_7 = corrcoef(predictionLabels1(earlyTimes), time(earlyTimes));
        r2_0_7(iTrial) = rsquared_0_7(1,2) ^ 2;  
              
        confusionMatrix = confusionMatrix + confusionmat(time', predictionLabels1);
        confusionMatrixShuffled = confusionMatrixShuffled + confusionmat(time', predictionLabels2);
        
        error = error + abs(predictionLabels1(goodTimes) - time(goodTimes)');                             % compute error
        shuffleError = shuffleError + abs(predictionLabels2(goodTimes) - time(goodTimes)');
    end
    
    confusionMatrix = confusionMatrix / nTrials;
    confusionMatrixShuffled = confusionMatrixShuffled / nTrials;
    error = error / nTrials;
    shuffleError = shuffleError / nTrials;
    
    smoothf = 1.6; % in sec
    for iCount = 1 : numel(time)
        y_s = gausssmooth(confusionMatrix(iCount,:), smoothf/binSize);
        y(iCount, :) = y_s / max(y_s); 
        y_s = gausssmooth(confusionMatrixShuffled(iCount,:), smoothf/binSize);
        y2(iCount, :) = y_s / max(y_s);
    end
    
    nNeuronTrial = squeeze(sum(~isnan(data(1,:,:))));
    missingTrialRatio = sum(max(nNeuronTrial) - nNeuronTrial) / (max(nNeuronTrial)*size(data,3));
    
    stats.r2 = r2;   
    stats.r2_0_7 = r2_0_7;  
    stats.shuffledR2 = shuffledR2;
    stats.y = y;
    stats.y2 = y2;
    stats.confusion = confusionMatrix; 
    stats.confusionShuffled = confusionMatrixShuffled;
    stats.data = zData; 
    stats.times = time; 
    stats.goodtimes = goodTimes;
    
    stats.trialError = error; 
    stats.shuffledTrialError = shuffleError; 
    stats.missingTrialRatio = missingTrialRatio;


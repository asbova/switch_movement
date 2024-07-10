function plotPETH(PETH)
%
% Plot the percentage of neurons that are modulated by time and/or movement velocity. 
%
% Input: 
%       PETH:               Peri-event time histogram. Each row is a neuron's average PETH.
%
% Output: 
%       figure

    
    % Parameters
    intervalStart = -4;
    intervalEnd = 22;
    binSize = 0.15;
    intervalBins = intervalStart : binSize : intervalEnd;
    trialStart = 0;
    trialEnd = 18;
    PCtoSort = 1; 

    % Run a PCA.
    timeInterval = find(intervalBins > (trialStart - binSize) & intervalBins < (trialEnd + binSize));
    intervalPETH = PETH(:, timeInterval); 
    pethInterval = intervalBins(timeInterval);
    zPETH = zscore(intervalPETH')';
    warning off;
    [COEFF, SCORE, LATENT, TSQUARED, EXPLAINED] = pca(zPETH);
    warning on;
       
    % Plot
    [~,sortKey] = sort(SCORE(:, PCtoSort));  % For sorting by PCA
    imagesc(pethInterval, [], zPETH(sortKey,:), [-3 3]); 
    xlabel('Time from Trial Start (s)'); 
    ylabel('Neuron #')
    set(gca, 'xtick', [0 6 18], 'ytick', [1 size(zPETH,1)]);
    colorbar;
    colormap('jet');